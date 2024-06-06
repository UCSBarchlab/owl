;;; TODO:
;;; For all of the `SetUpdate` functions, need to change:
;;; read rf @ cycle 1
;;; update pc @ cycle 0 (except JAL and JALR)
;;; update rf @ cycle 2

;; #lang rosette/safe
(require racket/match)
(define (and-match x y) (match x [(? boolean?) (and x y)] [_ (bvand x y)]))
(define (or-match x y) (match x [(? boolean?) (or x y)] [_ (bvor x y)]))
(define (xor-match x y) (match x [(? boolean?) (xor x y)] [_ (bvxor x y)]))

(define (Load mem addr)
  (let* ([mem-uninterpreted-func (vector-ref mem 0)]
         [mem-write-alist        (vector-ref mem 1)]
         [read-data              (assoc-bv addr mem-write-alist)])
    (cond [read-data (cdr read-data)]
          [else ;;; no write in alist at addr
           (apply mem-uninterpreted-func (list addr))])))

(define (LoadRs1 stage ports r)
  (let ([data-hazard? (bitvector->bool (stage 1 (ports "is_data_hazard_rs1")))]
	[data-hazard-output (stage 1 (ports "data_hazard_output"))])
    (if data-hazard?
        data-hazard-output
        (Load (stage 1 (ports "rf")) r))))

(define (LoadRs2 stage ports r)
  (let ([data-hazard? (bitvector->bool (stage 1 (ports "is_data_hazard_rs2")))]
	[data-hazard-output (stage 1 (ports "data_hazard_output"))])
    (if data-hazard?
        data-hazard-output
        (Load (stage 1 (ports "rf")) r))))

(define (Fetch pre ports)
  (Load (pre (ports "imem")) (extract 31 2 (pre (ports "fetch_pc")))))

(define (R-pre pre ports op funct3 funct7)
  (let ([ir (Fetch pre ports)])
    (assume
      (bveq (extract 6 0 ir)
            op))
    (assume
      (bveq (extract 14 12 ir)
            funct3))
    (assume
      (bveq (extract 31 25 ir)
            funct7))
    (assume ; rd =/= 0
      (not (bvzero? (extract 11 7 ir))))))

(define (CMOV-pre pre ports)
  (R-pre pre ports (bv #b0110011 7) (bv 2 3) (bv 16 7)))

(define (CMOV-post pre post ports)
  (let* ([ir (Fetch pre ports)]
         [rd (extract 11 7 ir)]
         [rs1 (extract 19 15 ir)]
         [rs2 (extract 24 20 ir)]
         [Rrs1 (if
                (bvzero? rs1)
                (bv 0 32)
                (Load (post 1 (ports "rf")) rs1))]
                ;; (LoadRs1 post ports rs1))]
         [Rrs2 (if
                (bvzero? rs2)
                (bv 0 32)
                (Load (post 1 (ports "rf")) rs2))]
                ;; (LoadRs2 post ports rs2))]
         [cond? (signed-lt? Rrs1 (bv 1 32))])
    (begin
       (assert
         (bveq (post 0 (ports "fetch_pc"))
               (bvadd
                (pre (ports "fetch_pc"))
                (bv 4 32))))

       ;; rs1 < 1 --> rf[rd] = rf[rd]
       ;; rs1 >= 1 --> rf[rd] = rf[rs2]
       (assert (bveq (Load (post 2 (ports "rf")) rd)
                     (if cond?
                         (Load (post 1 (ports "rf")) rd)
                         Rrs2))))))


;; DECODE FUNCS
(define (JAL-SetDecode pre ports)
    (let* (
            [c_15 (extract 31 2 (pre (ports "fetch_pc")))]
            [c_17 (Load (pre (ports "imem")) c_15)]
            [c_19 (extract 6 0 c_17)]
            [c_313 (bveq c_19 (bv 111 7))]
            [c_21 (extract 11 7 c_17)]
            [c_317 (bveq c_21 (bv 0 5))]
            [c_319 (not c_317)]
            [c_320 (and-match c_313 c_319)]
        )
    (assume c_320)
))

(define (JALR-SetDecode pre ports)
    (let* (
            [c_15 (extract 31 2 (pre (ports "fetch_pc")))]
            [c_17 (Load (pre (ports "imem")) c_15)]
            [c_19 (extract 6 0 c_17)]
            [c_326 (bveq c_19 (bv 103 7))]
            [c_21 (extract 11 7 c_17)]
            [c_330 (bveq c_21 (bv 0 5))]
            [c_332 (not c_330)]
            [c_333 (and-match c_326 c_332)]
        )
    (assume c_333)
))

(define (LW-SetDecode pre ports)
    (let* (
            [c_15 (extract 31 2 (pre (ports "fetch_pc")))]
            [c_17 (Load (pre (ports "imem")) c_15)]
            [c_19 (extract 6 0 c_17)]
            [c_356 (bveq c_19 (bv 3 7))]
            [c_27 (extract 14 12 c_17)]
            [c_360 (bveq c_27 (bv 2 3))]
            [c_362 (and-match c_356 c_360)]
            [c_21 (extract 11 7 c_17)]
            [c_365 (bveq c_21 (bv 0 5))]
            [c_367 (not c_365)]
            [c_368 (and-match c_362 c_367)]
        )
    (assume c_368)
))

(define (LH-SetDecode pre ports)
    (let* (
            [c_15 (extract 31 2 (pre (ports "fetch_pc")))]
            [c_17 (Load (pre (ports "imem")) c_15)]
            [c_19 (extract 6 0 c_17)]
            [c_382 (bveq c_19 (bv 3 7))]
            [c_27 (extract 14 12 c_17)]
            [c_386 (bveq c_27 (bv 1 3))]
            [c_388 (and-match c_382 c_386)]
            [c_21 (extract 11 7 c_17)]
            [c_391 (bveq c_21 (bv 0 5))]
            [c_393 (not c_391)]
            [c_394 (and-match c_388 c_393)]
        )
    (assume c_394)
))

(define (LB-SetDecode pre ports)
    (let* (
            [c_15 (extract 31 2 (pre (ports "fetch_pc")))]
            [c_17 (Load (pre (ports "imem")) c_15)]
            [c_19 (extract 6 0 c_17)]
            [c_421 (bveq c_19 (bv 3 7))]
            [c_27 (extract 14 12 c_17)]
            [c_425 (bveq c_27 (bv 0 3))]
            [c_427 (and-match c_421 c_425)]
            [c_21 (extract 11 7 c_17)]
            [c_430 (bveq c_21 (bv 0 5))]
            [c_432 (not c_430)]
            [c_433 (and-match c_427 c_432)]
        )
    (assume c_433)
))

(define (LHU-SetDecode pre ports)
    (let* (
            [c_15 (extract 31 2 (pre (ports "fetch_pc")))]
            [c_17 (Load (pre (ports "imem")) c_15)]
            [c_19 (extract 6 0 c_17)]
            [c_473 (bveq c_19 (bv 3 7))]
            [c_27 (extract 14 12 c_17)]
            [c_477 (bveq c_27 (bv 1 3))]
            [c_479 (and-match c_473 c_477)]
            [c_21 (extract 11 7 c_17)]
            [c_482 (bveq c_21 (bv 0 5))]
            [c_484 (not c_482)]
            [c_485 (and-match c_479 c_484)]
        )
    (assume c_485)
))

(define (LBU-SetDecode pre ports)
    (let* (
            [c_15 (extract 31 2 (pre (ports "fetch_pc")))]
            [c_17 (Load (pre (ports "imem")) c_15)]
            [c_19 (extract 6 0 c_17)]
            [c_512 (bveq c_19 (bv 3 7))]
            [c_27 (extract 14 12 c_17)]
            [c_516 (bveq c_27 (bv 0 3))]
            [c_518 (and-match c_512 c_516)]
            [c_21 (extract 11 7 c_17)]
            [c_521 (bveq c_21 (bv 0 5))]
            [c_523 (not c_521)]
            [c_524 (and-match c_518 c_523)]
        )
    (assume c_524)
))

(define (SW-SetDecode pre ports)
    (let* (
            [c_15 (extract 31 2 (pre (ports "fetch_pc")))]
            [c_17 (Load (pre (ports "imem")) c_15)]
            [c_19 (extract 6 0 c_17)]
            [c_590 (bveq c_19 (bv 35 7))]
            [c_27 (extract 14 12 c_17)]
            [c_594 (bveq c_27 (bv 2 3))]
            [c_596 (and-match c_590 c_594)]
        )
    (assume c_596)
))

(define (SH-SetDecode pre ports)
    (let* (
            [c_15 (extract 31 2 (pre (ports "fetch_pc")))]
            [c_17 (Load (pre (ports "imem")) c_15)]
            [c_19 (extract 6 0 c_17)]
            [c_608 (bveq c_19 (bv 35 7))]
            [c_27 (extract 14 12 c_17)]
            [c_612 (bveq c_27 (bv 1 3))]
            [c_614 (and-match c_608 c_612)]
        )
    (assume c_614)
))

(define (SB-SetDecode pre ports)
    (let* (
            [c_15 (extract 31 2 (pre (ports "fetch_pc")))]
            [c_17 (Load (pre (ports "imem")) c_15)]
            [c_19 (extract 6 0 c_17)]
            [c_655 (bveq c_19 (bv 35 7))]
            [c_27 (extract 14 12 c_17)]
            [c_659 (bveq c_27 (bv 0 3))]
            [c_661 (and-match c_655 c_659)]
        )
    (assume c_661)
))

(define (ADD-SetDecode pre ports)
    (let* (
            [c_15 (extract 31 2 (pre (ports "fetch_pc")))]
            ;[c_15 (extract 31 2 (pre (ports "fetch_pc")))]
            [c_17 (Load (pre (ports "imem")) c_15)]
            [c_19 (extract 6 0 c_17)]
            [c_766 (bveq c_19 (bv 51 7))]
            [c_27 (extract 14 12 c_17)]
            [c_770 (bveq c_27 (bv 0 3))]
            [c_772 (and-match c_766 c_770)]
            [c_29 (extract 31 25 c_17)]
            [c_775 (bveq c_29 (bv 0 7))]
            [c_777 (and-match c_772 c_775)]
            [c_21 (extract 11 7 c_17)]
            [c_780 (bveq c_21 (bv 0 5))]
            [c_782 (not c_780)]
            [c_783 (and-match c_777 c_782)]
        )
    (assume c_783)
))

(define (AND-SetDecode pre ports)
    (let* (
            [c_15 (extract 31 2 (pre (ports "fetch_pc")))]
            [c_17 (Load (pre (ports "imem")) c_15)]
            [c_19 (extract 6 0 c_17)]
            [c_789 (bveq c_19 (bv 51 7))]
            [c_27 (extract 14 12 c_17)]
            [c_793 (bveq c_27 (bv 7 3))]
            [c_795 (and-match c_789 c_793)]
            [c_29 (extract 31 25 c_17)]
            [c_798 (bveq c_29 (bv 0 7))]
            [c_800 (and-match c_795 c_798)]
            [c_21 (extract 11 7 c_17)]
            [c_803 (bveq c_21 (bv 0 5))]
            [c_805 (not c_803)]
            [c_806 (and-match c_800 c_805)]
        )
    (assume c_806)
))

(define (OR-SetDecode pre ports)
    (let* (
            [c_15 (extract 31 2 (pre (ports "fetch_pc")))]
            [c_17 (Load (pre (ports "imem")) c_15)]
            [c_19 (extract 6 0 c_17)]
            [c_812 (bveq c_19 (bv 51 7))]
            [c_27 (extract 14 12 c_17)]
            [c_816 (bveq c_27 (bv 6 3))]
            [c_818 (and-match c_812 c_816)]
            [c_29 (extract 31 25 c_17)]
            [c_821 (bveq c_29 (bv 0 7))]
            [c_823 (and-match c_818 c_821)]
            [c_21 (extract 11 7 c_17)]
            [c_826 (bveq c_21 (bv 0 5))]
            [c_828 (not c_826)]
            [c_829 (and-match c_823 c_828)]
        )
    (assume c_829)
))

(define (XOR-SetDecode pre ports)
    (let* (
            [c_15 (extract 31 2 (pre (ports "fetch_pc")))]
            [c_17 (Load (pre (ports "imem")) c_15)]
            [c_19 (extract 6 0 c_17)]
            [c_835 (bveq c_19 (bv 51 7))]
            [c_27 (extract 14 12 c_17)]
            [c_839 (bveq c_27 (bv 4 3))]
            [c_841 (and-match c_835 c_839)]
            [c_29 (extract 31 25 c_17)]
            [c_844 (bveq c_29 (bv 0 7))]
            [c_846 (and-match c_841 c_844)]
            [c_21 (extract 11 7 c_17)]
            [c_849 (bveq c_21 (bv 0 5))]
            [c_851 (not c_849)]
            [c_852 (and-match c_846 c_851)]
        )
    (assume c_852)
))

(define (SLL-SetDecode pre ports)
    (let* (
            [c_15 (extract 31 2 (pre (ports "fetch_pc")))]
            [c_17 (Load (pre (ports "imem")) c_15)]
            [c_19 (extract 6 0 c_17)]
            [c_858 (bveq c_19 (bv 51 7))]
            [c_27 (extract 14 12 c_17)]
            [c_862 (bveq c_27 (bv 1 3))]
            [c_864 (and-match c_858 c_862)]
            [c_29 (extract 31 25 c_17)]
            [c_867 (bveq c_29 (bv 0 7))]
            [c_869 (and-match c_864 c_867)]
            [c_21 (extract 11 7 c_17)]
            [c_872 (bveq c_21 (bv 0 5))]
            [c_874 (not c_872)]
            [c_875 (and-match c_869 c_874)]
        )
    (assume c_875)
))

(define (SRL-SetDecode pre ports)
    (let* (
            [c_15 (extract 31 2 (pre (ports "fetch_pc")))]
            [c_17 (Load (pre (ports "imem")) c_15)]
            [c_19 (extract 6 0 c_17)]
            [c_881 (bveq c_19 (bv 51 7))]
            [c_27 (extract 14 12 c_17)]
            [c_885 (bveq c_27 (bv 5 3))]
            [c_887 (and-match c_881 c_885)]
            [c_29 (extract 31 25 c_17)]
            [c_890 (bveq c_29 (bv 0 7))]
            [c_892 (and-match c_887 c_890)]
            [c_21 (extract 11 7 c_17)]
            [c_895 (bveq c_21 (bv 0 5))]
            [c_897 (not c_895)]
            [c_898 (and-match c_892 c_897)]
        )
    (assume c_898)
))

(define (SUB-SetDecode pre ports)
    (let* (
            [c_15 (extract 31 2 (pre (ports "fetch_pc")))]
            [c_17 (Load (pre (ports "imem")) c_15)]
            [c_19 (extract 6 0 c_17)]
            [c_904 (bveq c_19 (bv 51 7))]
            [c_27 (extract 14 12 c_17)]
            [c_908 (bveq c_27 (bv 0 3))]
            [c_910 (and-match c_904 c_908)]
            [c_29 (extract 31 25 c_17)]
            [c_913 (bveq c_29 (bv 32 7))]
            [c_915 (and-match c_910 c_913)]
            [c_21 (extract 11 7 c_17)]
            [c_918 (bveq c_21 (bv 0 5))]
            [c_920 (not c_918)]
            [c_921 (and-match c_915 c_920)]
        )
    (assume c_921)
))

(define (SRA-SetDecode pre ports)
    (let* (
            [c_15 (extract 31 2 (pre (ports "fetch_pc")))]
            [c_17 (Load (pre (ports "imem")) c_15)]
            [c_19 (extract 6 0 c_17)]
            [c_927 (bveq c_19 (bv 51 7))]
            [c_27 (extract 14 12 c_17)]
            [c_931 (bveq c_27 (bv 5 3))]
            [c_933 (and-match c_927 c_931)]
            [c_29 (extract 31 25 c_17)]
            [c_936 (bveq c_29 (bv 32 7))]
            [c_938 (and-match c_933 c_936)]
            [c_21 (extract 11 7 c_17)]
            [c_941 (bveq c_21 (bv 0 5))]
            [c_943 (not c_941)]
            [c_944 (and-match c_938 c_943)]
        )
    (assume c_944)
))

(define (SLT-SetDecode pre ports)
    (let* (
            [c_15 (extract 31 2 (pre (ports "fetch_pc")))]
            [c_17 (Load (pre (ports "imem")) c_15)]
            [c_19 (extract 6 0 c_17)]
            [c_950 (bveq c_19 (bv 51 7))]
            [c_27 (extract 14 12 c_17)]
            [c_954 (bveq c_27 (bv 2 3))]
            [c_956 (and-match c_950 c_954)]
            [c_29 (extract 31 25 c_17)]
            [c_959 (bveq c_29 (bv 0 7))]
            [c_961 (and-match c_956 c_959)]
            [c_21 (extract 11 7 c_17)]
            [c_964 (bveq c_21 (bv 0 5))]
            [c_966 (not c_964)]
            [c_967 (and-match c_961 c_966)]
        )
    (assume c_967)
))

(define (SLTU-SetDecode pre ports)
    (let* (
            [c_15 (extract 31 2 (pre (ports "fetch_pc")))]
            [c_17 (Load (pre (ports "imem")) c_15)]
            [c_19 (extract 6 0 c_17)]
            [c_979 (bveq c_19 (bv 51 7))]
            [c_27 (extract 14 12 c_17)]
            [c_983 (bveq c_27 (bv 3 3))]
            [c_985 (and-match c_979 c_983)]
            [c_29 (extract 31 25 c_17)]
            [c_988 (bveq c_29 (bv 0 7))]
            [c_990 (and-match c_985 c_988)]
            [c_21 (extract 11 7 c_17)]
            [c_993 (bveq c_21 (bv 0 5))]
            [c_995 (not c_993)]
            [c_996 (and-match c_990 c_995)]
        )
    (assume c_996)
))

(define (ADDI-SetDecode pre ports)
    (let* (
            [c_15 (extract 31 2 (pre (ports "fetch_pc")))]
            [c_17 (Load (pre (ports "imem")) c_15)]
            [c_19 (extract 6 0 c_17)]
            [c_1024 (bveq c_19 (bv 19 7))]
            [c_27 (extract 14 12 c_17)]
            [c_1028 (bveq c_27 (bv 0 3))]
            [c_1030 (and-match c_1024 c_1028)]
            [c_21 (extract 11 7 c_17)]
            [c_1033 (bveq c_21 (bv 0 5))]
            [c_1035 (not c_1033)]
            [c_1036 (and-match c_1030 c_1035)]
        )
    (assume c_1036)
))

(define (SLTI-SetDecode pre ports)
    (let* (
            [c_15 (extract 31 2 (pre (ports "fetch_pc")))]
            [c_17 (Load (pre (ports "imem")) c_15)]
            [c_19 (extract 6 0 c_17)]
            [c_1042 (bveq c_19 (bv 19 7))]
            [c_27 (extract 14 12 c_17)]
            [c_1046 (bveq c_27 (bv 2 3))]
            [c_1048 (and-match c_1042 c_1046)]
            [c_21 (extract 11 7 c_17)]
            [c_1051 (bveq c_21 (bv 0 5))]
            [c_1053 (not c_1051)]
            [c_1054 (and-match c_1048 c_1053)]
        )
    (assume c_1054)
))

(define (SLTIU-SetDecode pre ports)
    (let* (
            [c_15 (extract 31 2 (pre (ports "fetch_pc")))]
            [c_17 (Load (pre (ports "imem")) c_15)]
            [c_19 (extract 6 0 c_17)]
            [c_1066 (bveq c_19 (bv 19 7))]
            [c_27 (extract 14 12 c_17)]
            [c_1070 (bveq c_27 (bv 3 3))]
            [c_1072 (and-match c_1066 c_1070)]
            [c_21 (extract 11 7 c_17)]
            [c_1075 (bveq c_21 (bv 0 5))]
            [c_1077 (not c_1075)]
            [c_1078 (and-match c_1072 c_1077)]
        )
    (assume c_1078)
))

(define (ANDI-SetDecode pre ports)
    (let* (
            [c_15 (extract 31 2 (pre (ports "fetch_pc")))]
            [c_17 (Load (pre (ports "imem")) c_15)]
            [c_19 (extract 6 0 c_17)]
            [c_1090 (bveq c_19 (bv 19 7))]
            [c_27 (extract 14 12 c_17)]
            [c_1094 (bveq c_27 (bv 7 3))]
            [c_1096 (and-match c_1090 c_1094)]
            [c_21 (extract 11 7 c_17)]
            [c_1099 (bveq c_21 (bv 0 5))]
            [c_1101 (not c_1099)]
            [c_1102 (and-match c_1096 c_1101)]
        )
    (assume c_1102)
))

(define (ORI-SetDecode pre ports)
    (let* (
            [c_15 (extract 31 2 (pre (ports "fetch_pc")))]
            [c_17 (Load (pre (ports "imem")) c_15)]
            [c_19 (extract 6 0 c_17)]
            [c_1108 (bveq c_19 (bv 19 7))]
            [c_27 (extract 14 12 c_17)]
            [c_1112 (bveq c_27 (bv 6 3))]
            [c_1114 (and-match c_1108 c_1112)]
            [c_21 (extract 11 7 c_17)]
            [c_1117 (bveq c_21 (bv 0 5))]
            [c_1119 (not c_1117)]
            [c_1120 (and-match c_1114 c_1119)]
        )
    (assume c_1120)
))

(define (XORI-SetDecode pre ports)
    (let* (
            [c_15 (extract 31 2 (pre (ports "fetch_pc")))]
            [c_17 (Load (pre (ports "imem")) c_15)]
            [c_19 (extract 6 0 c_17)]
            [c_1126 (bveq c_19 (bv 19 7))]
            [c_27 (extract 14 12 c_17)]
            [c_1130 (bveq c_27 (bv 4 3))]
            [c_1132 (and-match c_1126 c_1130)]
            [c_21 (extract 11 7 c_17)]
            [c_1135 (bveq c_21 (bv 0 5))]
            [c_1137 (not c_1135)]
            [c_1138 (and-match c_1132 c_1137)]
        )
    (assume c_1138)
))

(define (SLLI-SetDecode pre ports)
    (let* (
            [c_15 (extract 31 2 (pre (ports "fetch_pc")))]
            [c_17 (Load (pre (ports "imem")) c_15)]
            [c_19 (extract 6 0 c_17)]
            [c_1144 (bveq c_19 (bv 19 7))]
            [c_27 (extract 14 12 c_17)]
            [c_1148 (bveq c_27 (bv 1 3))]
            [c_1150 (and-match c_1144 c_1148)]
            [c_29 (extract 31 25 c_17)]
            [c_1153 (bveq c_29 (bv 0 7))]
            [c_1155 (and-match c_1150 c_1153)]
            [c_21 (extract 11 7 c_17)]
            [c_1158 (bveq c_21 (bv 0 5))]
            [c_1160 (not c_1158)]
            [c_1161 (and-match c_1155 c_1160)]
        )
    (assume c_1161)
))

(define (SRLI-SetDecode pre ports)
    (let* (
            [c_15 (extract 31 2 (pre (ports "fetch_pc")))]
            [c_17 (Load (pre (ports "imem")) c_15)]
            [c_19 (extract 6 0 c_17)]
            [c_1167 (bveq c_19 (bv 19 7))]
            [c_27 (extract 14 12 c_17)]
            [c_1171 (bveq c_27 (bv 5 3))]
            [c_1173 (and-match c_1167 c_1171)]
            [c_29 (extract 31 25 c_17)]
            [c_1176 (bveq c_29 (bv 0 7))]
            [c_1178 (and-match c_1173 c_1176)]
            [c_21 (extract 11 7 c_17)]
            [c_1181 (bveq c_21 (bv 0 5))]
            [c_1183 (not c_1181)]
            [c_1184 (and-match c_1178 c_1183)]
        )
    (assume c_1184)
))

(define (SRAI-SetDecode pre ports)
    (let* (
            [c_15 (extract 31 2 (pre (ports "fetch_pc")))]
            [c_17 (Load (pre (ports "imem")) c_15)]
            [c_19 (extract 6 0 c_17)]
            [c_1190 (bveq c_19 (bv 19 7))]
            [c_27 (extract 14 12 c_17)]
            [c_1194 (bveq c_27 (bv 5 3))]
            [c_1196 (and-match c_1190 c_1194)]
            [c_29 (extract 31 25 c_17)]
            [c_1199 (bveq c_29 (bv 32 7))]
            [c_1201 (and-match c_1196 c_1199)]
            [c_21 (extract 11 7 c_17)]
            [c_1204 (bveq c_21 (bv 0 5))]
            [c_1206 (not c_1204)]
            [c_1207 (and-match c_1201 c_1206)]
        )
    (assume c_1207)
))

(define (LUI-SetDecode pre ports)
    (let* (
            [c_15 (extract 31 2 (pre (ports "fetch_pc")))]
            [c_17 (Load (pre (ports "imem")) c_15)]
            [c_19 (extract 6 0 c_17)]
            [c_1216 (bveq c_19 (bv 55 7))]
            [c_21 (extract 11 7 c_17)]
            [c_1220 (bveq c_21 (bv 0 5))]
            [c_1222 (not c_1220)]
            [c_1223 (and-match c_1216 c_1222)]
        )
    (assume c_1223)
))

(define (AUIPC-SetDecode pre ports)
    (let* (
            [c_15 (extract 31 2 (pre (ports "fetch_pc")))]
            [c_17 (Load (pre (ports "imem")) c_15)]
            [c_19 (extract 6 0 c_17)]
            [c_1228 (bveq c_19 (bv 23 7))]
            [c_21 (extract 11 7 c_17)]
            [c_1232 (bveq c_21 (bv 0 5))]
            [c_1234 (not c_1232)]
            [c_1235 (and-match c_1228 c_1234)]
        )
    (assume c_1235)
))

;; UPDATE FUNCS
(define (JAL-SetUpdate pre post ports)
    (let* (
        [c_15 (extract 31 2 (pre (ports "fetch_pc")))]
        [c_17 (Load (pre (ports "imem")) c_15)]
        [c_95 (extract 31 31 c_17)]
        [c_97 (extract 19 12 c_17)]
        [c_99 (extract 20 20 c_17)]
        [c_101 (extract 30 21 c_17)]
        [c_109 (concat c_101 (bv 0 1))]
        [c_115 (concat c_99 c_109)]
        [c_121 (concat c_97 c_115)]
        [c_127 (concat c_95 c_121)]
        [c_129 (sign-extend c_127 (bitvector 32))]
        [c_321 (bvadd (pre (ports "fetch_pc")) c_129)]
        [c_21 (extract 11 7 c_17)]
        [c_224 (bvadd (pre (ports "fetch_pc")) (bv 4 32))]
        )
    (assert (bveq (post 1 (ports "fetch_pc")) c_321))
    (assert (bveq (Load (post 2 (ports "rf")) c_21) c_224))
))

(define (JALR-SetUpdate pre post ports)
    (let* (
        [c_15 (extract 31 2 (pre (ports "fetch_pc")))]
        [c_17 (Load (pre (ports "imem")) c_15)]
        [c_23 (extract 19 15 c_17)]
        [c_205 (bveq c_23 (bv 0 5))]
        ;; [c_209 (LoadRs1 post ports c_23)]
        [c_209 (Load (post 1 (ports "rf")) c_23)]
        [c_211 (if c_205 (bv 0 32) c_209)]
        [c_33 (extract 31 20 c_17)]
        [c_35 (sign-extend c_33 (bitvector 32))]
        [c_334 (bvadd c_211 c_35)]
        [c_21 (extract 11 7 c_17)]
        [c_224 (bvadd (pre (ports "fetch_pc")) (bv 4 32))]
        )
    (assert (bveq (post 1 (ports "fetch_pc")) c_334))
    (assert (bveq (Load (post 2 (ports "rf")) c_21) c_224))
))

(define (LW-SetUpdate pre post ports)
    (let* (
        [c_352 (bvadd (pre (ports "fetch_pc")) (bv 4 32))]
        [c_15 (extract 31 2 (pre (ports "fetch_pc")))]
        [c_17 (Load (pre (ports "imem")) c_15)]
        [c_21 (extract 11 7 c_17)]
        [c_23 (extract 19 15 c_17)]
        [c_338 (bveq c_23 (bv 0 5))]
        ;; [c_342 (LoadRs1 post ports c_23)]
        [c_342 (Load (post 1 (ports "rf")) c_23)]
        [c_344 (if c_338 (bv 0 32) c_342)]
        [c_33 (extract 31 20 c_17)]
        [c_35 (sign-extend c_33 (bitvector 32))]
        [c_345 (bvadd c_344 c_35)]
        [c_369 (extract 1 0 c_345)]
        [c_375 (bveq c_369 (bv 0 2))]
        [c_346 (extract 31 2 c_345)]
        [c_348 (Load (post 2 (ports "dmem")) c_346)]
        [c_377 (if c_375 c_348 (bv 0 32))]
        )
    (assert (bveq (post 0 (ports "fetch_pc")) c_352))
    (assert (bveq (Load (post 2 (ports "rf")) c_21) c_377))
))

(define (LH-SetUpdate pre post ports)
    (let* (
        [c_352 (bvadd (pre (ports "fetch_pc")) (bv 4 32))]
        [c_15 (extract 31 2 (pre (ports "fetch_pc")))]
        [c_17 (Load (pre (ports "imem")) c_15)]
        [c_21 (extract 11 7 c_17)]
        [c_23 (extract 19 15 c_17)]
        [c_338 (bveq c_23 (bv 0 5))]
        [c_342 (Load (pre (ports "rf")) c_23)]
        [c_344 (if c_338 (bv 0 32) c_342)]
        [c_33 (extract 31 20 c_17)]
        [c_35 (sign-extend c_33 (bitvector 32))]
        [c_345 (bvadd c_344 c_35)]
        [c_395 (extract 1 0 c_345)]
        [c_401 (bveq c_395 (bv 0 2))]
        [c_346 (extract 31 2 c_345)]
        [c_348 (Load (pre (ports "dmem")) c_346)]
        [c_403 (extract 15 0 c_348)]
        [c_405 (sign-extend c_403 (bitvector 32))]
        [c_409 (bveq c_395 (bv 2 2))]
        [c_411 (extract 31 16 c_348)]
        [c_413 (sign-extend c_411 (bitvector 32))]
        [c_415 (if c_409 c_413 (bv 0 32))]
        [c_416 (if c_401 c_405 c_415)]
        )
    (assert (bveq (post (ports "fetch_pc")) c_352))
    (assert (bveq (Load (post (ports "rf")) c_21) c_416))
))

(define (LB-SetUpdate pre post ports)
    (let* (
        [c_352 (bvadd (pre (ports "fetch_pc")) (bv 4 32))]
        [c_15 (extract 31 2 (pre (ports "fetch_pc")))]
        [c_17 (Load (pre (ports "imem")) c_15)]
        [c_21 (extract 11 7 c_17)]
        [c_23 (extract 19 15 c_17)]
        [c_338 (bveq c_23 (bv 0 5))]
        [c_342 (Load (pre (ports "rf")) c_23)]
        [c_344 (if c_338 (bv 0 32) c_342)]
        [c_33 (extract 31 20 c_17)]
        [c_35 (sign-extend c_33 (bitvector 32))]
        [c_345 (bvadd c_344 c_35)]
        [c_434 (extract 1 0 c_345)]
        [c_440 (bveq c_434 (bv 0 2))]
        [c_346 (extract 31 2 c_345)]
        [c_348 (Load (pre (ports "dmem")) c_346)]
        [c_442 (extract 7 0 c_348)]
        [c_444 (sign-extend c_442 (bitvector 32))]
        [c_448 (bveq c_434 (bv 1 2))]
        [c_450 (extract 15 8 c_348)]
        [c_452 (sign-extend c_450 (bitvector 32))]
        [c_456 (bveq c_434 (bv 2 2))]
        [c_458 (extract 23 16 c_348)]
        [c_460 (sign-extend c_458 (bitvector 32))]
        [c_462 (extract 31 24 c_348)]
        [c_464 (sign-extend c_462 (bitvector 32))]
        [c_466 (if c_456 c_460 c_464)]
        [c_467 (if c_448 c_452 c_466)]
        [c_468 (if c_440 c_444 c_467)]
        )
    (assert (bveq (post (ports "fetch_pc")) c_352))
    (assert (bveq (Load (post (ports "rf")) c_21) c_468))
))

(define (LHU-SetUpdate pre post ports)
    (let* (
        [c_352 (bvadd (pre (ports "fetch_pc")) (bv 4 32))]
        [c_15 (extract 31 2 (pre (ports "fetch_pc")))]
        [c_17 (Load (pre (ports "imem")) c_15)]
        [c_21 (extract 11 7 c_17)]
        [c_23 (extract 19 15 c_17)]
        [c_338 (bveq c_23 (bv 0 5))]
        [c_342 (Load (pre (ports "rf")) c_23)]
        [c_344 (if c_338 (bv 0 32) c_342)]
        [c_33 (extract 31 20 c_17)]
        [c_35 (sign-extend c_33 (bitvector 32))]
        [c_345 (bvadd c_344 c_35)]
        [c_486 (extract 1 0 c_345)]
        [c_492 (bveq c_486 (bv 0 2))]
        [c_346 (extract 31 2 c_345)]
        [c_348 (Load (pre (ports "dmem")) c_346)]
        [c_494 (extract 15 0 c_348)]
        [c_496 (zero-extend c_494 (bitvector 32))]
        [c_500 (bveq c_486 (bv 2 2))]
        [c_502 (extract 31 16 c_348)]
        [c_504 (zero-extend c_502 (bitvector 32))]
        [c_506 (if c_500 c_504 (bv 0 32))]
        [c_507 (if c_492 c_496 c_506)]
        )
    (assert (bveq (post (ports "fetch_pc")) c_352))
    (assert (bveq (Load (post (ports "rf")) c_21) c_507))
))

(define (LBU-SetUpdate pre post ports)
    (let* (
        [c_352 (bvadd (pre (ports "fetch_pc")) (bv 4 32))]
        [c_15 (extract 31 2 (pre (ports "fetch_pc")))]
        [c_17 (Load (pre (ports "imem")) c_15)]
        [c_21 (extract 11 7 c_17)]
        [c_23 (extract 19 15 c_17)]
        [c_338 (bveq c_23 (bv 0 5))]
        [c_342 (Load (post 1 (ports "rf")) c_23)]
        [c_344 (if c_338 (bv 0 32) c_342)]
        [c_33 (extract 31 20 c_17)]
        [c_35 (sign-extend c_33 (bitvector 32))]
        [c_345 (bvadd c_344 c_35)]
        [c_525 (extract 1 0 c_345)]
        [c_531 (bveq c_525 (bv 0 2))]
        [c_346 (extract 31 2 c_345)]
        [c_348 (Load (post 1 (ports "dmem")) c_346)]
        [c_533 (extract 7 0 c_348)]
        [c_535 (zero-extend c_533 (bitvector 32))]
        [c_539 (bveq c_525 (bv 1 2))]
        [c_541 (extract 15 8 c_348)]
        [c_543 (zero-extend c_541 (bitvector 32))]
        [c_547 (bveq c_525 (bv 2 2))]
        [c_549 (extract 23 16 c_348)]
        [c_551 (zero-extend c_549 (bitvector 32))]
        [c_553 (extract 31 24 c_348)]
        [c_555 (zero-extend c_553 (bitvector 32))]
        [c_557 (if c_547 c_551 c_555)]
        [c_558 (if c_539 c_543 c_557)]
        [c_559 (if c_531 c_535 c_558)]
        )
    (assert (bveq (post 0 (ports "fetch_pc")) c_352))
    (assert (bveq (Load (post 2 (ports "rf")) c_21) c_559))
))

(define (SW-SetUpdate pre post ports)
    (let* (
        [c_15 (extract 31 2 (pre (ports "fetch_pc")))]
        [c_17 (Load (pre (ports "imem")) c_15)]
        [c_23 (extract 19 15 c_17)]
        [c_563 (bveq c_23 (bv 0 5))]
        [c_567 (Load (post 1 (ports "rf")) c_23)]
        [c_569 (if c_563 (bv 0 32) c_567)]
        [c_37 (extract 31 25 c_17)]
        [c_39 (extract 11 7 c_17)]
        [c_45 (concat c_37 c_39)]
        [c_47 (sign-extend c_45 (bitvector 32))]
        [c_579 (bvadd c_569 c_47)]
        [c_580 (extract 31 2 c_579)]
        [c_597 (extract 1 0 c_579)]
        [c_601 (bveq c_597 (bv 0 2))]
        [c_25 (extract 24 20 c_17)]
        [c_572 (bveq c_25 (bv 0 5))]
        [c_576 (Load (post 1 (ports "rf")) c_25)]
        [c_578 (if c_572 (bv 0 32) c_576)]
        [c_582 (Load (post 2 (ports "dmem")) c_580)]
        [c_603 (if c_601 c_578 c_582)]
        [c_586 (bvadd (pre (ports "fetch_pc")) (bv 4 32))]
        )
    (assert (bveq (post 0 (ports "fetch_pc")) c_586))
    (assert (bveq (Load (post 2 (ports "dmem")) c_580) c_603))
))

(define (SH-SetUpdate pre post ports)
    (let* (
        [c_15 (extract 31 2 (pre (ports "fetch_pc")))]
        [c_17 (Load (pre (ports "imem")) c_15)]
        [c_23 (extract 19 15 c_17)]
        [c_563 (bveq c_23 (bv 0 5))]
        [c_567 (Load (pre (ports "rf")) c_23)]
        [c_569 (if c_563 (bv 0 32) c_567)]
        [c_37 (extract 31 25 c_17)]
        [c_39 (extract 11 7 c_17)]
        [c_45 (concat c_37 c_39)]
        [c_47 (sign-extend c_45 (bitvector 32))]
        [c_579 (bvadd c_569 c_47)]
        [c_580 (extract 31 2 c_579)]
        [c_615 (extract 1 0 c_579)]
        [c_619 (bveq c_615 (bv 0 2))]
        [c_25 (extract 24 20 c_17)]
        [c_572 (bveq c_25 (bv 0 5))]
        [c_576 (Load (pre (ports "rf")) c_25)]
        [c_578 (if c_572 (bv 0 32) c_576)]
        [c_621 (extract 15 0 c_578)]
        [c_623 (zero-extend c_621 (bitvector 32))]
        [c_627 (bvnot (bv 65535 32))]
        [c_582 (Load (pre (ports "dmem")) c_580)]
        [c_628 (and-match c_627 c_582)]
        [c_629 (or-match c_623 c_628)]
        [c_632 (bveq c_615 (bv 2 2))]
        [c_634 (extract 15 0 c_578)]
        [c_642 (concat c_634 (bv 0 16))]
        [c_646 (bvnot (bv 4294901760 32))]
        [c_647 (and-match c_646 c_582)]
        [c_648 (or-match c_642 c_647)]
        [c_649 (if c_632 c_648 c_582)]
        [c_650 (if c_619 c_629 c_649)]
        [c_586 (bvadd (pre (ports "fetch_pc")) (bv 4 32))]
        )
    (assert (bveq (post (ports "fetch_pc")) c_586))
    (assert (bveq (Load (post (ports "dmem")) c_580) c_650))
))

(define (SB-SetUpdate pre post ports)
    (let* (
        [c_15 (extract 31 2 (pre (ports "fetch_pc")))]
        [c_17 (Load (pre (ports "imem")) c_15)]
        [c_23 (extract 19 15 c_17)]
        [c_563 (bveq c_23 (bv 0 5))]
        [c_567 (Load (post 1 (ports "rf")) c_23)]
        [c_569 (if c_563 (bv 0 32) c_567)]
        [c_37 (extract 31 25 c_17)]
        [c_39 (extract 11 7 c_17)]
        [c_45 (concat c_37 c_39)]
        [c_47 (sign-extend c_45 (bitvector 32))]
        [c_579 (bvadd c_569 c_47)]
        [c_580 (extract 31 2 c_579)]
        [c_662 (extract 1 0 c_579)]
        [c_666 (bveq c_662 (bv 0 2))]
        [c_25 (extract 24 20 c_17)]
        [c_572 (bveq c_25 (bv 0 5))]
        [c_576 (Load (post 1 (ports "rf")) c_25)]
        [c_578 (if c_572 (bv 0 32) c_576)]
        [c_668 (extract 7 0 c_578)]
        [c_670 (zero-extend c_668 (bitvector 32))]
        [c_674 (bvnot (bv 255 32))]
        [c_582 (Load (post 0 (ports "dmem")) c_580)]
        ;; [c_582 (Load (post 2 (ports "dmem")) c_580)]
        [c_675 (and-match c_674 c_582)]
        [c_676 (or-match c_670 c_675)]
        [c_679 (bveq c_662 (bv 1 2))]
        [c_681 (extract 7 0 c_578)]
        [c_689 (concat c_681 (bv 0 8))]
        [c_691 (zero-extend c_689 (bitvector 32))]
        [c_695 (bvnot (bv 65280 32))]
        [c_696 (and-match c_695 c_582)]
        [c_697 (or-match c_691 c_696)]
        [c_700 (bveq c_662 (bv 2 2))]
        [c_702 (extract 7 0 c_578)]
        [c_710 (concat c_702 (bv 0 16))]
        [c_712 (zero-extend c_710 (bitvector 32))]
        [c_716 (bvnot (bv 16711680 32))]
        [c_717 (and-match c_716 c_582)]
        [c_718 (or-match c_712 c_717)]
        [c_719 (extract 7 0 c_578)]
        [c_727 (concat c_719 (bv 0 24))]
        [c_731 (bvnot (bv 4278190080 32))]
        [c_732 (and-match c_731 c_582)]
        [c_733 (or-match c_727 c_732)]
        [c_734 (if c_700 c_718 c_733)]
        [c_735 (if c_679 c_697 c_734)]
        [c_736 (if c_666 c_676 c_735)]
        [c_586 (bvadd (pre (ports "fetch_pc")) (bv 4 32))]
        )
    (assert (bveq (post 0 (ports "fetch_pc")) c_586))
    (assert (bveq (Load (post 2 (ports "dmem")) c_580) c_736))
))

(define (ADD-SetUpdate pre post ports)
    (let* (
        [c_762 (bvadd (pre (ports "fetch_pc")) (bv 4 32))]
        [c_15 (extract 31 2 (pre (ports "fetch_pc")))]
        [c_17 (Load (pre (ports "imem")) c_15)]
        [c_21 (extract 11 7 c_17)]
        [c_23 (extract 19 15 c_17)]
        [c_740 (bveq c_23 (bv 0 5))]
        ;; [c_744 (LoadRs1 post ports c_23)]
        [c_744 (Load (post 1 (ports "rf")) c_23)]
        [c_746 (if c_740 (bv 0 32) c_744)]
        [c_25 (extract 24 20 c_17)]
        [c_749 (bveq c_25 (bv 0 5))]
        ;; [c_753 (LoadRs2 post ports c_25)]
        [c_753 (Load (post 1 (ports "rf")) c_25)]
        [c_755 (if c_749 (bv 0 32) c_753)]
        [c_784 (bvadd c_746 c_755)]
        )
    (assert (bveq (post 0 (ports "fetch_pc")) c_762))
    ;(assert (bveq (post 2 (ports "fetch_pc")) c_762))
    (assert (bveq (Load (post 2 (ports "rf")) c_21) c_784))
))

(define (AND-SetUpdate pre post ports)
    (let* (
        [c_762 (bvadd (pre (ports "fetch_pc")) (bv 4 32))]
        [c_15 (extract 31 2 (pre (ports "fetch_pc")))]
        [c_17 (Load (pre (ports "imem")) c_15)]
        [c_21 (extract 11 7 c_17)]
        [c_23 (extract 19 15 c_17)]
        [c_740 (bveq c_23 (bv 0 5))]
        [c_744 (Load (post 1 (ports "rf")) c_23)]
        [c_746 (if c_740 (bv 0 32) c_744)]
        [c_25 (extract 24 20 c_17)]
        [c_749 (bveq c_25 (bv 0 5))]
        [c_753 (Load (post 1 (ports "rf")) c_25)]
        [c_755 (if c_749 (bv 0 32) c_753)]
        [c_807 (and-match c_746 c_755)]
        )
    (assert (bveq (post 0 (ports "fetch_pc")) c_762))
    (assert (bveq (Load (post 2 (ports "rf")) c_21) c_807))
))

(define (OR-SetUpdate pre post ports)
    (let* (
        [c_762 (bvadd (pre (ports "fetch_pc")) (bv 4 32))]
        [c_15 (extract 31 2 (pre (ports "fetch_pc")))]
        [c_17 (Load (pre (ports "imem")) c_15)]
        [c_21 (extract 11 7 c_17)]
        [c_23 (extract 19 15 c_17)]
        [c_740 (bveq c_23 (bv 0 5))]
        [c_744 (Load (post 1 (ports "rf")) c_23)]
        [c_746 (if c_740 (bv 0 32) c_744)]
        [c_25 (extract 24 20 c_17)]
        [c_749 (bveq c_25 (bv 0 5))]
        [c_753 (Load (post 1 (ports "rf")) c_25)]
        [c_755 (if c_749 (bv 0 32) c_753)]
        [c_830 (or-match c_746 c_755)]
        )
    (assert (bveq (post 0 (ports "fetch_pc")) c_762))
    (assert (bveq (Load (post 2 (ports "rf")) c_21) c_830))
))

(define (XOR-SetUpdate pre post ports)
    (let* (
        [c_762 (bvadd (pre (ports "fetch_pc")) (bv 4 32))]
        [c_15 (extract 31 2 (pre (ports "fetch_pc")))]
        [c_17 (Load (pre (ports "imem")) c_15)]
        [c_21 (extract 11 7 c_17)]
        [c_23 (extract 19 15 c_17)]
        [c_740 (bveq c_23 (bv 0 5))]
        [c_744 (Load (post 1 (ports "rf")) c_23)]
        [c_746 (if c_740 (bv 0 32) c_744)]
        [c_25 (extract 24 20 c_17)]
        [c_749 (bveq c_25 (bv 0 5))]
        [c_753 (Load (post 1 (ports "rf")) c_25)]
        [c_755 (if c_749 (bv 0 32) c_753)]
        [c_853 (xor-match c_746 c_755)]
        )
    (assert (bveq (post 0 (ports "fetch_pc")) c_762))
    (assert (bveq (Load (post 2 (ports "rf")) c_21) c_853))
))

(define (SLL-SetUpdate pre post ports)
    (let* (
        [c_762 (bvadd (pre (ports "fetch_pc")) (bv 4 32))]
        [c_15 (extract 31 2 (pre (ports "fetch_pc")))]
        [c_17 (Load (pre (ports "imem")) c_15)]
        [c_21 (extract 11 7 c_17)]
        [c_23 (extract 19 15 c_17)]
        [c_740 (bveq c_23 (bv 0 5))]
        [c_744 (Load (pre (ports "rf")) c_23)]
        [c_746 (if c_740 (bv 0 32) c_744)]
        [c_25 (extract 24 20 c_17)]
        [c_749 (bveq c_25 (bv 0 5))]
        [c_753 (Load (pre (ports "rf")) c_25)]
        [c_755 (if c_749 (bv 0 32) c_753)]
        [c_756 (extract 4 0 c_755)]
        [c_758 (zero-extend c_756 (bitvector 32))]
        [c_876 (bvshl c_746 c_758)]
        )
    (assert (bveq (post (ports "fetch_pc")) c_762))
    (assert (bveq (Load (post (ports "rf")) c_21) c_876))
))

(define (SRL-SetUpdate pre post ports)
    (let* (
        [c_762 (bvadd (pre (ports "fetch_pc")) (bv 4 32))]
        [c_15 (extract 31 2 (pre (ports "fetch_pc")))]
        [c_17 (Load (pre (ports "imem")) c_15)]
        [c_21 (extract 11 7 c_17)]
        [c_23 (extract 19 15 c_17)]
        [c_740 (bveq c_23 (bv 0 5))]
        [c_744 (Load (pre (ports "rf")) c_23)]
        [c_746 (if c_740 (bv 0 32) c_744)]
        [c_25 (extract 24 20 c_17)]
        [c_749 (bveq c_25 (bv 0 5))]
        [c_753 (Load (pre (ports "rf")) c_25)]
        [c_755 (if c_749 (bv 0 32) c_753)]
        [c_756 (extract 4 0 c_755)]
        [c_758 (zero-extend c_756 (bitvector 32))]
        [c_899 (bvlshr c_746 c_758)]
        )
    (assert (bveq (post (ports "fetch_pc")) c_762))
    (assert (bveq (Load (post (ports "rf")) c_21) c_899))
))

(define (SUB-SetUpdate pre post ports)
    (let* (
        [c_762 (bvadd (pre (ports "fetch_pc")) (bv 4 32))]
        [c_15 (extract 31 2 (pre (ports "fetch_pc")))]
        [c_17 (Load (pre (ports "imem")) c_15)]
        [c_21 (extract 11 7 c_17)]
        [c_23 (extract 19 15 c_17)]
        [c_740 (bveq c_23 (bv 0 5))]
        [c_744 (Load (post 1 (ports "rf")) c_23)]
        [c_746 (if c_740 (bv 0 32) c_744)]
        [c_25 (extract 24 20 c_17)]
        [c_749 (bveq c_25 (bv 0 5))]
        [c_753 (Load (post 1 (ports "rf")) c_25)]
        [c_755 (if c_749 (bv 0 32) c_753)]
        [c_922 (bvsub c_746 c_755)]
        )
    (assert (bveq (post 0 (ports "fetch_pc")) c_762))
    (assert (bveq (Load (post 2 (ports "rf")) c_21) c_922))
))

(define (SRA-SetUpdate pre post ports)
    (let* (
        [c_762 (bvadd (pre (ports "fetch_pc")) (bv 4 32))]
        [c_15 (extract 31 2 (pre (ports "fetch_pc")))]
        [c_17 (Load (pre (ports "imem")) c_15)]
        [c_21 (extract 11 7 c_17)]
        [c_23 (extract 19 15 c_17)]
        [c_740 (bveq c_23 (bv 0 5))]
        [c_744 (Load (pre (ports "rf")) c_23)]
        [c_746 (if c_740 (bv 0 32) c_744)]
        [c_25 (extract 24 20 c_17)]
        [c_749 (bveq c_25 (bv 0 5))]
        [c_753 (Load (pre (ports "rf")) c_25)]
        [c_755 (if c_749 (bv 0 32) c_753)]
        [c_756 (extract 4 0 c_755)]
        [c_758 (zero-extend c_756 (bitvector 32))]
        [c_945 (bvashr c_746 c_758)]
        )
    (assert (bveq (post (ports "fetch_pc")) c_762))
    (assert (bveq (Load (post (ports "rf")) c_21) c_945))
))

(define (SLT-SetUpdate pre post ports)
    (let* (
        [c_762 (bvadd (pre (ports "fetch_pc")) (bv 4 32))]
        [c_15 (extract 31 2 (pre (ports "fetch_pc")))]
        [c_17 (Load (pre (ports "imem")) c_15)]
        [c_21 (extract 11 7 c_17)]
        [c_23 (extract 19 15 c_17)]
        [c_740 (bveq c_23 (bv 0 5))]
        [c_744 (Load (post 1 (ports "rf")) c_23)]
        [c_746 (if c_740 (bv 0 32) c_744)]
        [c_25 (extract 24 20 c_17)]
        [c_749 (bveq c_25 (bv 0 5))]
        [c_753 (Load (post 1 (ports "rf")) c_25)]
        [c_755 (if c_749 (bv 0 32) c_753)]
        [c_968 (signed-lt? c_746 c_755)]
        [c_974 (if c_968 (bv 1 32) (bv 0 32))]
        )
    (assert (bveq (post 0 (ports "fetch_pc")) c_762))
    (assert (bveq (Load (post 2 (ports "rf")) c_21) c_974))
))

(define (SLTU-SetUpdate pre post ports)
    (let* (
        [c_762 (bvadd (pre (ports "fetch_pc")) (bv 4 32))]
        [c_15 (extract 31 2 (pre (ports "fetch_pc")))]
        [c_17 (Load (pre (ports "imem")) c_15)]
        [c_21 (extract 11 7 c_17)]
        [c_23 (extract 19 15 c_17)]
        [c_740 (bveq c_23 (bv 0 5))]
        [c_744 (Load (post 1 (ports "rf")) c_23)]
        [c_746 (if c_740 (bv 0 32) c_744)]
        [c_25 (extract 24 20 c_17)]
        [c_749 (bveq c_25 (bv 0 5))]
        [c_753 (Load (post 1 (ports "rf")) c_25)]
        [c_755 (if c_749 (bv 0 32) c_753)]
        [c_997 (bvult c_746 c_755)]
        [c_1003 (if c_997 (bv 1 32) (bv 0 32))]
        )
    (assert (bveq (post 0 (ports "fetch_pc")) c_762))
    (assert (bveq (Load (post 2 (ports "rf")) c_21) c_1003))
))

(define (ADDI-SetUpdate pre post ports)
    (let* (
        [c_1020 (bvadd (pre (ports "fetch_pc")) (bv 4 32))]
        [c_15 (extract 31 2 (pre (ports "fetch_pc")))]
        [c_17 (Load (pre (ports "imem")) c_15)]
        [c_21 (extract 11 7 c_17)]
        [c_23 (extract 19 15 c_17)]
        [c_1007 (bveq c_23 (bv 0 5))]
        [c_1011 (Load (post 1 (ports "rf")) c_23)]
        [c_1013 (if c_1007 (bv 0 32) c_1011)]
        [c_33 (extract 31 20 c_17)]
        [c_35 (sign-extend c_33 (bitvector 32))]
        [c_1037 (bvadd c_1013 c_35)]
        )
    (assert (bveq (post 0 (ports "fetch_pc")) c_1020))
    (assert (bveq (Load (post 2 (ports "rf")) c_21) c_1037))
))

(define (SLTI-SetUpdate pre post ports)
    (let* (
        [c_1020 (bvadd (pre (ports "fetch_pc")) (bv 4 32))]
        [c_15 (extract 31 2 (pre (ports "fetch_pc")))]
        [c_17 (Load (pre (ports "imem")) c_15)]
        [c_21 (extract 11 7 c_17)]
        [c_23 (extract 19 15 c_17)]
        [c_1007 (bveq c_23 (bv 0 5))]
        [c_1011 (Load (pre (ports "rf")) c_23)]
        [c_1013 (if c_1007 (bv 0 32) c_1011)]
        [c_33 (extract 31 20 c_17)]
        [c_35 (sign-extend c_33 (bitvector 32))]
        [c_1055 (signed-lt? c_1013 c_35)]
        [c_1061 (if c_1055 (bv 1 32) (bv 0 32))]
        )
    (assert (bveq (post (ports "fetch_pc")) c_1020))
    (assert (bveq (Load (post (ports "rf")) c_21) c_1061))
))

(define (SLTIU-SetUpdate pre post ports)
    (let* (
        [c_1020 (bvadd (pre (ports "fetch_pc")) (bv 4 32))]
        [c_15 (extract 31 2 (pre (ports "fetch_pc")))]
        [c_17 (Load (pre (ports "imem")) c_15)]
        [c_21 (extract 11 7 c_17)]
        [c_23 (extract 19 15 c_17)]
        [c_1007 (bveq c_23 (bv 0 5))]
        [c_1011 (Load (post 1 (ports "rf")) c_23)]
        [c_1013 (if c_1007 (bv 0 32) c_1011)]
        [c_33 (extract 31 20 c_17)]
        [c_35 (sign-extend c_33 (bitvector 32))]
        [c_1079 (bvult c_1013 c_35)]
        [c_1085 (if c_1079 (bv 1 32) (bv 0 32))]
        )
    (assert (bveq (post 0 (ports "fetch_pc")) c_1020))
    (assert (bveq (Load (post 2 (ports "rf")) c_21) c_1085))
))

(define (ANDI-SetUpdate pre post ports)
    (let* (
        [c_1020 (bvadd (pre (ports "fetch_pc")) (bv 4 32))]
        [c_15 (extract 31 2 (pre (ports "fetch_pc")))]
        [c_17 (Load (pre (ports "imem")) c_15)]
        [c_21 (extract 11 7 c_17)]
        [c_23 (extract 19 15 c_17)]
        [c_1007 (bveq c_23 (bv 0 5))]
        [c_1011 (Load (post 1 (ports "rf")) c_23)]
        [c_1013 (if c_1007 (bv 0 32) c_1011)]
        [c_33 (extract 31 20 c_17)]
        [c_35 (sign-extend c_33 (bitvector 32))]
        [c_1103 (and-match c_1013 c_35)]
        )
    (assert (bveq (post 0 (ports "fetch_pc")) c_1020))
    (assert (bveq (Load (post 2 (ports "rf")) c_21) c_1103))
))

(define (ORI-SetUpdate pre post ports)
    (let* (
        [c_1020 (bvadd (pre (ports "fetch_pc")) (bv 4 32))]
        [c_15 (extract 31 2 (pre (ports "fetch_pc")))]
        [c_17 (Load (pre (ports "imem")) c_15)]
        [c_21 (extract 11 7 c_17)]
        [c_23 (extract 19 15 c_17)]
        [c_1007 (bveq c_23 (bv 0 5))]
        [c_1011 (Load (pre (ports "rf")) c_23)]
        [c_1013 (if c_1007 (bv 0 32) c_1011)]
        [c_33 (extract 31 20 c_17)]
        [c_35 (sign-extend c_33 (bitvector 32))]
        [c_1121 (or-match c_1013 c_35)]
        )
    (assert (bveq (post (ports "fetch_pc")) c_1020))
    (assert (bveq (Load (post (ports "rf")) c_21) c_1121))
))

(define (XORI-SetUpdate pre post ports)
    (let* (
        [c_1020 (bvadd (pre (ports "fetch_pc")) (bv 4 32))]
        [c_15 (extract 31 2 (pre (ports "fetch_pc")))]
        [c_17 (Load (pre (ports "imem")) c_15)]
        [c_21 (extract 11 7 c_17)]
        [c_23 (extract 19 15 c_17)]
        [c_1007 (bveq c_23 (bv 0 5))]
        [c_1011 (Load (post 1 (ports "rf")) c_23)]
        [c_1013 (if c_1007 (bv 0 32) c_1011)]
        [c_33 (extract 31 20 c_17)]
        [c_35 (sign-extend c_33 (bitvector 32))]
        [c_1139 (xor-match c_1013 c_35)]
        )
    (assert (bveq (post 0 (ports "fetch_pc")) c_1020))
    (assert (bveq (Load (post 2 (ports "rf")) c_21) c_1139))
))

(define (SLLI-SetUpdate pre post ports)
    (let* (
        [c_1020 (bvadd (pre (ports "fetch_pc")) (bv 4 32))]
        [c_15 (extract 31 2 (pre (ports "fetch_pc")))]
        [c_17 (Load (pre (ports "imem")) c_15)]
        [c_21 (extract 11 7 c_17)]
        [c_23 (extract 19 15 c_17)]
        [c_1007 (bveq c_23 (bv 0 5))]
        [c_1011 (Load (post 1 (ports "rf")) c_23)]
        [c_1013 (if c_1007 (bv 0 32) c_1011)]
        [c_1014 (extract 24 20 c_17)]
        [c_1016 (zero-extend c_1014 (bitvector 32))]
        [c_1162 (bvshl c_1013 c_1016)]
        )
    (assert (bveq (post 0 (ports "fetch_pc")) c_1020))
    (assert (bveq (Load (post 2 (ports "rf")) c_21) c_1162))
))

(define (SRLI-SetUpdate pre post ports)
    (let* (
        [c_1020 (bvadd (pre (ports "fetch_pc")) (bv 4 32))]
        [c_15 (extract 31 2 (pre (ports "fetch_pc")))]
        [c_17 (Load (pre (ports "imem")) c_15)]
        [c_21 (extract 11 7 c_17)]
        [c_23 (extract 19 15 c_17)]
        [c_1007 (bveq c_23 (bv 0 5))]
        [c_1011 (Load (pre (ports "rf")) c_23)]
        [c_1013 (if c_1007 (bv 0 32) c_1011)]
        [c_1014 (extract 24 20 c_17)]
        [c_1016 (zero-extend c_1014 (bitvector 32))]
        [c_1185 (bvlshr c_1013 c_1016)]
        )
    (assert (bveq (post (ports "fetch_pc")) c_1020))
    (assert (bveq (Load (post (ports "rf")) c_21) c_1185))
))

(define (SRAI-SetUpdate pre post ports)
    (let* (
        [c_1020 (bvadd (pre (ports "fetch_pc")) (bv 4 32))]
        [c_15 (extract 31 2 (pre (ports "fetch_pc")))]
        [c_17 (Load (pre (ports "imem")) c_15)]
        [c_21 (extract 11 7 c_17)]
        [c_23 (extract 19 15 c_17)]
        [c_1007 (bveq c_23 (bv 0 5))]
        [c_1011 (Load (pre (ports "rf")) c_23)]
        [c_1013 (if c_1007 (bv 0 32) c_1011)]
        [c_1014 (extract 24 20 c_17)]
        [c_1016 (zero-extend c_1014 (bitvector 32))]
        [c_1208 (bvashr c_1013 c_1016)]
        )
    (assert (bveq (post (ports "fetch_pc")) c_1020))
    (assert (bveq (Load (post (ports "rf")) c_21) c_1208))
))

(define (LUI-SetUpdate pre post ports)
    (let* (
        [c_1212 (bvadd (pre (ports "fetch_pc")) (bv 4 32))]
        [c_15 (extract 31 2 (pre (ports "fetch_pc")))]
        [c_17 (Load (pre (ports "imem")) c_15)]
        [c_21 (extract 11 7 c_17)]
        [c_85 (extract 31 12 c_17)]
        [c_93 (concat c_85 (bv 0 12))]
        )
    (assert (bveq (post 0 (ports "fetch_pc")) c_1212))
    (assert (bveq (Load (post 2 (ports "rf")) c_21) c_93))
))


(define (AUIPC-SetUpdate pre post ports)
    (let* (
        [c_1212 (bvadd (pre (ports "fetch_pc")) (bv 4 32))]
        [c_15 (extract 31 2 (pre (ports "fetch_pc")))]
        [c_17 (Load (pre (ports "imem")) c_15)]
        [c_21 (extract 11 7 c_17)]
        [c_85 (extract 31 12 c_17)]
        [c_93 (concat c_85 (bv 0 12))]
        [c_1236 (bvadd (pre (ports "fetch_pc")) c_93)]
        )
    (assert (bveq (post 0 (ports "fetch_pc")) c_1212))
    (assert (bveq (Load (post 2 (ports "rf")) c_21) c_1236))
))

(define spec
(hash
"cmov" (list CMOV-pre CMOV-post) ;; good
"add" (list ADD-SetDecode ADD-SetUpdate) ;; good
"sub" (list SUB-SetDecode SUB-SetUpdate) ;; good
"xor" (list XOR-SetDecode XOR-SetUpdate)
"or" (list OR-SetDecode OR-SetUpdate) ;; good
"and" (list AND-SetDecode AND-SetUpdate) ;; good
"slt" (list SLT-SetDecode SLT-SetUpdate) ;; good
"sltu" (list SLTU-SetDecode SLTU-SetUpdate) ;; good
"sll" (list SLL-SetDecode SLL-SetUpdate)
"srl" (list SRL-SetDecode SRL-SetUpdate)
"sra" (list SRA-SetDecode SRA-SetUpdate)
"addi" (list ADDI-SetDecode ADDI-SetUpdate) ;; good
"xori" (list XORI-SetDecode XORI-SetUpdate) ;; good
"ori" (list ORI-SetDecode ORI-SetUpdate)
"andi" (list ANDI-SetDecode ANDI-SetUpdate) ;; good
"slli" (list SLLI-SetDecode SLLI-SetUpdate) ;; good
"srli" (list SRLI-SetDecode SRLI-SetUpdate)
"srai" (list SRAI-SetDecode SRAI-SetUpdate)
"sltiu" (list SLTIU-SetDecode SLTIU-SetUpdate) ;; good
"slti" (list SLTI-SetDecode SLTI-SetUpdate)
"lb" (list LB-SetDecode LB-SetUpdate)
"lh" (list LH-SetDecode LH-SetUpdate)
"lw" (list LW-SetDecode LW-SetUpdate) ;; good
"lbu" (list LBU-SetDecode LBU-SetUpdate) ;; good
"lhu" (list LHU-SetDecode LHU-SetUpdate)
"sb" (list SB-SetDecode SB-SetUpdate) ;; question mark
"sh" (list SH-SetDecode SH-SetUpdate) ;; good
"sw" (list SW-SetDecode SW-SetUpdate) ;; fixed by adding assumption (good)
"jal" (list JAL-SetDecode JAL-SetUpdate) ;; good
"jalr" (list JALR-SetDecode JALR-SetUpdate) ;; good
"lui" (list LUI-SetDecode LUI-SetUpdate) ;; good
"auipc" (list AUIPC-SetDecode AUIPC-SetUpdate))) ;; good
