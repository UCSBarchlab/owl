#! /usr/bin/env racket
#lang racket/load
(require racket/cmdline)
(require rosette)
(require oyster)

(require rosette/solver/smt/boolector)
(current-solver (boolector
#:logic 'QF_AUFBV))

(define steps (make-parameter 1))
(define fsm (make-parameter #f))
(define reg-state (make-parameter null))
(define mem-state (make-parameter null))
(define isa-instrs (make-parameter null))

;;; command line parser
(define parser
  (command-line
   #:usage-help
   "Runner script for automated control logic generation tool."

   #:once-each
   [("-s" "--steps")  STEPS
                      "Number of steps of symbolic evaluation (default: 1)."
                      (steps (string->number STEPS))]
   [("-f" "--fsm")    FSM
                      "FSM-style control logic (default: false)."
                      (fsm #t)]
   #:multi
   [("-r" "--reg-state") REG
                         "Add name of architectural register."
                         (reg-state (cons REG (reg-state)))]
   [("-m" "--mem-state") MEM
                         "Add name of architectural memory."
                         (mem-state (cons MEM (mem-state)))]
   [("-i" "--isa-instruction") INSTR
                               "Add ISA instruction from spec. Optional, if blank, selects all ISA instructions from spec."
                               (isa-instrs (cons INSTR (isa-instrs)))]
   ;;; TODO: flags for control signal assertions
   ;;; [ ] What stage is control unit.
   ;;;     I.e., where the are holes (and quantify over holes in other stages).

   #:args (sketch-filename spec-filename decode-filename)
          (list sketch-filename spec-filename decode-filename)))

(define sketch-filename (first parser))
(define spec-filename (second parser))
(define decode-filename (third parser))

;;; provides `sketch` variable
(load sketch-filename)
;;; provides `spec` variable
(load spec-filename)
;;; Decode logic syntax
(load decode-filename)

(define (build-conditions instruction pre)
  (define defs (make-hash))

  (define (decode->ir term)
    (syntax-case
        term
        (define let* extract bveq bv and-match not assume)
      [(define (name args ...) other ...)
       ;;; process args
       (for ([t (syntax->list #'(args ...))])
         (hash-set! defs (syntax->datum t) (decode->ir t)))
       ;;; process body
       (for ([t (syntax->list #'(other ...))]) (decode->ir t))]
      [(let* ([var expr] ...) body ...)
       (for ([x (map list (syntax->list #'(var ...)) (syntax->list #'(expr ...)))])
         (let ([v (syntax->datum (first x))]
               [e (second x)])
           (hash-set! defs v (decode->ir e))))
       (for ([t (syntax->list #'(body ...))])
         (hash-set! defs instruction (decode->ir t)))]
      [(extract h l w)
       (with-syntax ([w (decode->ir #'w)]
					 [h (decode->ir #'h)]
					 [l (decode->ir #'l)])
         (SEL (syntax->datum #'w)
			  (SLICE (syntax->datum #'l) (syntax->datum #'h))))]
         ;; #'(SEL w (SLICE l h)))]
      [(bveq w1 w2)
       (with-syntax ([w1 (decode->ir #'w1)]
                     [w2 (decode->ir #'w2)])
         (EQ (syntax->datum #'w1) (syntax->datum #'w2)))]
      [(and-match w1 w2)
       (with-syntax ([w1 (decode->ir #'w1)]
                     [w2 (decode->ir #'w2)])
         (AND (syntax->datum #'w1) (syntax->datum #'w2)))]
      [(not w)
       (with-syntax ([w (decode->ir #'w)])
         (NOT (syntax->datum #'w)))]
      [(bv v w)
       (with-syntax ([v (decode->ir #'v)]
                     [w (decode->ir #'w)])
         (CONST (syntax->datum #'v) (syntax->datum #'w)))]
      [_
       (let ([datum (syntax->datum term)])
         (if (hash-has-key? defs datum)
             (hash-ref defs datum)
             datum))]))
  (decode->ir pre)
  (hash-ref defs instruction))

(define (make-signal->ops ctrl signals ops)
  (define signal->ops (make-hash))
  (for ([signal signals])
	(define val->op (make-hash))
	(for ([op ops])
	  (let* ([op-hash (hash-ref ctrl op)]
			 [signal-val! (car (hash-ref op-hash signal))]
			 [signal-val (if (symbolic? signal-val!)
						   (bv 0 (length (bitvector->bits signal-val!)))
						   signal-val!)]
			 [op-val (if (hash-has-key? val->op signal-val)
					   (cons op (hash-ref val->op signal-val))
					   (list op))])
		(hash-set! val->op signal-val op-val)))
	(hash-set! signal->ops signal val->op))
  signal->ops)

(define (mux-gen val->op)
  (if (empty? val->op)
    0
	(let* ([val/op (car val->op)]
		   [val (car val/op)]
		   [con (if (= (length (cdr val/op)) 1)
			    (cadr val/op)
				(foldl (lambda (x y) (if (equal? x y) x (OR x y)))
					   (cadr val/op)
					   (cdr val/op)))])
	  (MUX con (mux-gen (cdr val->op)) val))))

(require racket/string)

(define (ir->pyrtl stmts ops)
  (define pyrtl-out "")

  (define (expr->pyrtl expr)
	(match expr
	  [(AND w1 w2) (format "(~a & ~a)"
						   (expr->pyrtl w1)
						   (expr->pyrtl w2))]
	  [(OR w1 w2) (format "(~a | ~a)"
						   (expr->pyrtl w1)
						   (expr->pyrtl w2))]
	  [(EQ w1 w2) (format "(~a == ~a)"
						  (expr->pyrtl w1)
						  (expr->pyrtl w2))]
	  [(MUX c w1 w2) (format "mux(~a, ~a, ~a)"
							 (expr->pyrtl c)
							 (expr->pyrtl w1)
						     (expr->pyrtl w2))]
	  [(NOT w) (format "~~~~~a"
					   (expr->pyrtl w))]
	  [(REDUCE-OR (CONCAT ws)) (let ([ws_ (map expr->pyrtl ws)])
								 (format "or_all_bits(concat_list([~a]))"
										 (foldl (lambda (x y)
												  (format "~a, ~a" x y))
												(car ws_)
												(cdr ws_))))]
	  [(REDUCE-OR w) (format "or_all_bits(~a)"
							 (expr->pyrtl w))]
	  [(CONCAT wires) (format "concat(~a)"
							  (let concatter ([wl wires])
								(if (= (length wl) 1)
								    (format "~a" (expr->pyrtl (car wl)))
								    (format "~a, ~a"
											(expr->pyrtl (car wl))
											(concatter (cdr wl))))))]
      [(SEL w slice) (format "~a[~a]"
							 w
							 (match slice
							   [(SLICE l h) (format "~a:~a + 1" l h)]))]
	  [(CONST v _) (format "~a" v)]
	  [(? symbolic?) "0"]
	  [(? bv?) (format "~a" (bitvector->natural expr))]
	  [(? string?) (if (member expr ops)
					 (format "~a_" expr)
					 expr)]
	  [_ expr]))

  (define (stmt->pyrtl stmt)
	(match stmt
	  [(list out expr) (format "~a = ~a"
							   (expr->pyrtl out)
							   (expr->pyrtl expr))]))
  (for ([stmt stmts])
    (set! pyrtl-out (string-append pyrtl-out (stmt->pyrtl stmt) "~n")))
  pyrtl-out)

 (begin
   (define signals-all
	 (for/list ([d (block-decls sketch)])
	   (let ([args (second d)])
        (match args
          [(HOLE _ _ n) n]
          [_ (void)]))))
   (define signals (filter string? signals-all))

   (define ops (hash-keys decode-syntax))

   (define synthd-ctrl (synthesize-control
    #:semantics spec
    #:steps (steps)
    #:sketch sketch
    #:reg-state (reg-state)
    #:mem-state (mem-state)
    #:fsm (fsm)
    #:debug #f
    (isa-instrs)))

   (define pres
	 (for/list ([op ops])
	   (list op (build-conditions op (hash-ref decode-syntax op)))))
   (define signal->ops (make-signal->ops synthd-ctrl signals ops))
   (define muxs
	 (for/list ([signal signals])
	   (list signal (mux-gen (hash->list (hash-ref signal->ops signal))))))
	(printf "from pyrtl.corecircuits import mux~n")
	(printf (ir->pyrtl (append pres muxs) ops)))
