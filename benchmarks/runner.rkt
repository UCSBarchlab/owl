#! /usr/bin/env racket
#lang racket/load
(require racket/cmdline)
(require rosette)
(require oyster)

(require rosette/solver/smt/z3)
;(current-solver (z3
; #:options (hash
;  ':parallel.enable 'true
;  ':parallel.threads.max 32)))
(require rosette/solver/smt/cvc4)
(require rosette/solver/smt/boolector)

(define steps (make-parameter 1))
(define fsm (make-parameter #f))
(define smt (make-parameter 0))
(define reg-state (make-parameter null))
(define mem-state (make-parameter null))
(define isa-instrs (make-parameter null))

;;; command line parser
(define parser
  (command-line
   #:usage-help
   "Runner script for automated control logic generation tool."

   #:once-each
   [("-s" "--steps") STEPS
                      "Number of steps of symbolic evaluation (default: 1)."
                      (steps (string->number STEPS))]
   [("-t" "--smt")  SMT
                      "SMT Solver 0 for boolector, 1 for cvc4, 2 for z3."
                      (smt (string->number SMT))]
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

   #:args (sketch-filename spec-filename) (list sketch-filename spec-filename)))

(define sketch-filename (first parser))
(define spec-filename (second parser))

(cond [(= (smt) 0)
       (current-solver (boolector #:logic 'QF_AUFBV))]
      [(= (smt) 1)
       (current-solver (cvc4 #:logic 'QF_AUFBV))]
      [else 
	(current-solver (z3 #:logic 'QF_AUFBV))])

;;; provides `sketch` variable
(load sketch-filename)
;;; provides `spec` variable
(load spec-filename)

(time
 (begin
   (synthesize-control
    #:semantics spec
    #:steps (steps)
    #:sketch sketch
    #:reg-state (reg-state)
    #:mem-state (mem-state)
    #:fsm (fsm)
    #:debug #t
    (isa-instrs))))
