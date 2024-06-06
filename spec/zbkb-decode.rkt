;; #lang rosette/safe
(require racket/match)
(define (and-match x y) (match x [(? boolean?) (and x y)] [_ (bvand x y)]))

(define decode-syntax
(hash
"beq"
#'(define (BEQ-SetDecode instr)
    (let* (
            
            [c_17 instr]
            [c_19 (extract 6 0 c_17)]
            [c_228 (bveq c_19 (bv 99 7))]
            [c_27 (extract 14 12 c_17)]
            [c_232 (bveq c_27 (bv 0 3))]
            [c_234 (and-match c_228 c_232)]
        )
    c_234
))
"bne"
#'(define (BNE-SetDecode instr)
    (let* (
            
            [c_17 instr]
            [c_19 (extract 6 0 c_17)]
            [c_241 (bveq c_19 (bv 99 7))]
            [c_27 (extract 14 12 c_17)]
            [c_245 (bveq c_27 (bv 1 3))]
            [c_247 (and-match c_241 c_245)]
        )
    c_247
))
"blt"
#'(define (BLT-SetDecode instr)
    (let* (
            
            [c_17 instr]
            [c_19 (extract 6 0 c_17)]
            [c_255 (bveq c_19 (bv 99 7))]
            [c_27 (extract 14 12 c_17)]
            [c_259 (bveq c_27 (bv 4 3))]
            [c_261 (and-match c_255 c_259)]
        )
    c_261
))
"bltu"
#'(define (BLTU-SetDecode instr)
    (let* (
            
            [c_17 instr]
            [c_19 (extract 6 0 c_17)]
            [c_268 (bveq c_19 (bv 99 7))]
            [c_27 (extract 14 12 c_17)]
            [c_272 (bveq c_27 (bv 6 3))]
            [c_274 (and-match c_268 c_272)]
        )
    c_274
))
"bge"
#'(define (BGE-SetDecode instr)
    (let* (
            
            [c_17 instr]
            [c_19 (extract 6 0 c_17)]
            [c_281 (bveq c_19 (bv 99 7))]
            [c_27 (extract 14 12 c_17)]
            [c_285 (bveq c_27 (bv 5 3))]
            [c_287 (and-match c_281 c_285)]
        )
    c_287
))
"bgeu"
#'(define (BGEU-SetDecode instr)
    (let* (
            
            [c_17 instr]
            [c_19 (extract 6 0 c_17)]
            [c_297 (bveq c_19 (bv 99 7))]
            [c_27 (extract 14 12 c_17)]
            [c_301 (bveq c_27 (bv 7 3))]
            [c_303 (and-match c_297 c_301)]
        )
    c_303
))
"jal"
#'(define (JAL-SetDecode instr)
    (let* (
            
            [c_17 instr]
            [c_19 (extract 6 0 c_17)]
            [c_313 (bveq c_19 (bv 111 7))]
            [c_21 (extract 11 7 c_17)]
            [c_317 (bveq c_21 (bv 0 5))]
            [c_319 (not c_317)]
            [c_320 (and-match c_313 c_319)]
        )
    c_320
))
"jalr"
#'(define (JALR-SetDecode instr)
    (let* (
            
            [c_17 instr]
            [c_19 (extract 6 0 c_17)]
            [c_326 (bveq c_19 (bv 103 7))]
            [c_21 (extract 11 7 c_17)]
            [c_330 (bveq c_21 (bv 0 5))]
            [c_332 (not c_330)]
            [c_333 (and-match c_326 c_332)]
        )
    c_333
))
"lw"
#'(define (LW-SetDecode instr)
    (let* (
            
            [c_17 instr]
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
    c_368
))
"lh"
#'(define (LH-SetDecode instr)
    (let* (
            
            [c_17 instr]
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
    c_394
))
"lb"
#'(define (LB-SetDecode instr)
    (let* (
            
            [c_17 instr]
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
    c_433
))
"lhu"
#'(define (LHU-SetDecode instr)
    (let* (
            
            [c_17 instr]
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
    c_485
))
"lbu"
#'(define (LBU-SetDecode instr)
    (let* (
            
            [c_17 instr]
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
    c_524
))
"sw"
#'(define (SW-SetDecode instr)
    (let* (
            
            [c_17 instr]
            [c_19 (extract 6 0 c_17)]
            [c_590 (bveq c_19 (bv 35 7))]
            [c_27 (extract 14 12 c_17)]
            [c_594 (bveq c_27 (bv 2 3))]
            [c_596 (and-match c_590 c_594)]
        )
    c_596
))
"sh"
#'(define (SH-SetDecode instr)
    (let* (
            
            [c_17 instr]
            [c_19 (extract 6 0 c_17)]
            [c_608 (bveq c_19 (bv 35 7))]
            [c_27 (extract 14 12 c_17)]
            [c_612 (bveq c_27 (bv 1 3))]
            [c_614 (and-match c_608 c_612)]
        )
    c_614
))
"sb"
#'(define (SB-SetDecode instr)
    (let* (
            
            [c_17 instr]
            [c_19 (extract 6 0 c_17)]
            [c_655 (bveq c_19 (bv 35 7))]
            [c_27 (extract 14 12 c_17)]
            [c_659 (bveq c_27 (bv 0 3))]
            [c_661 (and-match c_655 c_659)]
        )
    c_661
))
"add"
#'(define (ADD-SetDecode instr)
    (let* (
            
            [c_17 instr]
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
    c_783
))
"and"
#'(define (AND-SetDecode instr)
    (let* (
            
            [c_17 instr]
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
    c_806
))
"or"
#'(define (OR-SetDecode instr)
    (let* (
            
            [c_17 instr]
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
    c_829
))
"xor"
#'(define (XOR-SetDecode instr)
    (let* (
            
            [c_17 instr]
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
    c_852
))
"sll"
#'(define (SLL-SetDecode instr)
    (let* (
            
            [c_17 instr]
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
    c_875
))
"srl"
#'(define (SRL-SetDecode instr)
    (let* (
            
            [c_17 instr]
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
    c_898
))
"sub"
#'(define (SUB-SetDecode instr)
    (let* (
            
            [c_17 instr]
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
    c_921
))
"sra"
#'(define (SRA-SetDecode instr)
    (let* (
            
            [c_17 instr]
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
    c_944
))
"slt"
#'(define (SLT-SetDecode instr)
    (let* (
            
            [c_17 instr]
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
    c_967
))
"sltu"
#'(define (SLTU-SetDecode instr)
    (let* (
            
            [c_17 instr]
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
    c_996
))
"addi"
#'(define (ADDI-SetDecode instr)
    (let* (
            
            [c_17 instr]
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
    c_1036
))
"slti"
#'(define (SLTI-SetDecode instr)
    (let* (
            
            [c_17 instr]
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
    c_1054
))
"sltiu"
#'(define (SLTIU-SetDecode instr)
    (let* (
            
            [c_17 instr]
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
    c_1078
))
"andi"
#'(define (ANDI-SetDecode instr)
    (let* (
            
            [c_17 instr]
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
    c_1102
))
"ori"
#'(define (ORI-SetDecode instr)
    (let* (
            
            [c_17 instr]
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
    c_1120
))
"xori"
#'(define (XORI-SetDecode instr)
    (let* (
            
            [c_17 instr]
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
    c_1138
))
"slli"
#'(define (SLLI-SetDecode instr)
    (let* (
            
            [c_17 instr]
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
    c_1161
))
"srli"
#'(define (SRLI-SetDecode instr)
    (let* (
            
            [c_17 instr]
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
    c_1184
))
"srai"
#'(define (SRAI-SetDecode instr)
    (let* (
            
            [c_17 instr]
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
    c_1207
))
"lui"
#'(define (LUI-SetDecode instr)
    (let* (
            
            [c_17 instr]
            [c_19 (extract 6 0 c_17)]
            [c_1216 (bveq c_19 (bv 55 7))]
            [c_21 (extract 11 7 c_17)]
            [c_1220 (bveq c_21 (bv 0 5))]
            [c_1222 (not c_1220)]
            [c_1223 (and-match c_1216 c_1222)]
        )
    c_1223
))
"auipc"
#'(define (AUIPC-SetDecode instr)
    (let* (
            
            [c_17 instr]
            [c_19 (extract 6 0 c_17)]
            [c_1228 (bveq c_19 (bv 23 7))]
            [c_21 (extract 11 7 c_17)]
            [c_1232 (bveq c_21 (bv 0 5))]
            [c_1234 (not c_1232)]
            [c_1235 (and-match c_1228 c_1234)]
        )
    c_1235
))
"andn"
#'(define (ANDN-SetDecode instr)
    (let* (
            
            [c_17 instr]
            [c_19 (extract 6 0 c_17)]
            [c_789 (bveq c_19 (bv #b0110011 7))]
            [c_27 (extract 14 12 c_17)]
            [c_793 (bveq c_27 (bv #b111 3))]
            [c_795 (and-match c_789 c_793)]
            [c_29 (extract 31 25 c_17)]
            [c_798 (bveq c_29 (bv #b0100000 7))]
            [c_800 (and-match c_795 c_798)]
            [c_21 (extract 11 7 c_17)]
            [c_803 (bveq c_21 (bv 0 5))]
            [c_805 (not c_803)]
            [c_806 (and-match c_800 c_805)]
        )
    c_806
))
"orn"
#'(define (ORN-SetDecode instr)
    (let* (
            
            [c_17 instr]
            [c_19 (extract 6 0 c_17)]
            [c_789 (bveq c_19 (bv #b0110011 7))]
            [c_27 (extract 14 12 c_17)]
            [c_793 (bveq c_27 (bv #b110 3))]
            [c_795 (and-match c_789 c_793)]
            [c_29 (extract 31 25 c_17)]
            [c_798 (bveq c_29 (bv #b0100000 7))]
            [c_800 (and-match c_795 c_798)]
            [c_21 (extract 11 7 c_17)]
            [c_803 (bveq c_21 (bv 0 5))]
            [c_805 (not c_803)]
            [c_806 (and-match c_800 c_805)]
        )
    c_806
))
"xnor"
#'(define (XNOR-SetDecode instr)
    (let* (
            
            [c_17 instr]
            [c_19 (extract 6 0 c_17)]
            [c_789 (bveq c_19 (bv #b0110011 7))]
            [c_27 (extract 14 12 c_17)]
            [c_793 (bveq c_27 (bv #b100 3))]
            [c_795 (and-match c_789 c_793)]
            [c_29 (extract 31 25 c_17)]
            [c_798 (bveq c_29 (bv #b0100000 7))]
            [c_800 (and-match c_795 c_798)]
            [c_21 (extract 11 7 c_17)]
            [c_803 (bveq c_21 (bv 0 5))]
            [c_805 (not c_803)]
            [c_806 (and-match c_800 c_805)]
        )
    c_806
))
"rol" 
#'(define (ROL-SetDecode instr)
    (let* (
            
            [c_17 instr]
            [c_19 (extract 6 0 c_17)]
            [c_789 (bveq c_19 (bv #b0110011 7))]
            [c_27 (extract 14 12 c_17)]
            [c_793 (bveq c_27 (bv #b001 3))]
            [c_795 (and-match c_789 c_793)]
            [c_29 (extract 31 25 c_17)]
            [c_798 (bveq c_29 (bv #b0110000 7))]
            [c_800 (and-match c_795 c_798)]
            [c_21 (extract 11 7 c_17)]
            [c_803 (bveq c_21 (bv 0 5))]
            [c_805 (not c_803)]
            [c_806 (and-match c_800 c_805)]
        )
    c_806
))
"ror" 
#'(define (ROR-SetDecode instr)
    (let* (
            
            [c_17 instr]
            [c_19 (extract 6 0 c_17)]
            [c_789 (bveq c_19 (bv #b0110011 7))]
            [c_27 (extract 14 12 c_17)]
            [c_793 (bveq c_27 (bv #b101 3))]
            [c_795 (and-match c_789 c_793)]
            [c_29 (extract 31 25 c_17)]
            [c_798 (bveq c_29 (bv #b0110000 7))]
            [c_800 (and-match c_795 c_798)]
            [c_21 (extract 11 7 c_17)]
            [c_803 (bveq c_21 (bv 0 5))]
            [c_805 (not c_803)]
            [c_806 (and-match c_800 c_805)]
        )
    c_806
))
"rori"
#'(define (RORI-SetDecode instr)
    (let* (
            
            [c_17 instr]
            [c_19 (extract 6 0 c_17)]
            [c_789 (bveq c_19 (bv #b0010011 7))]
            [c_27 (extract 14 12 c_17)]
            [c_793 (bveq c_27 (bv #b101 3))]
            [c_795 (and-match c_789 c_793)]
            [c_29 (extract 31 26 c_17)]
            [c_798 (bveq c_29 (bv #b011000 7))]
            [c_800 (and-match c_795 c_798)]
            [c_21 (extract 11 7 c_17)]
            [c_803 (bveq c_21 (bv 0 5))]
            [c_805 (not c_803)]
            [c_806 (and-match c_800 c_805)]
        )
    c_806
))
"pack"
#'(define (PACK-SetDecode instr)
    (let* (
            
            [c_17 instr]
            [c_19 (extract 6 0 c_17)]
            [c_789 (bveq c_19 (bv #b0110011 7))]
            [c_27 (extract 14 12 c_17)]
            [c_793 (bveq c_27 (bv #b100 3))]
            [c_795 (and-match c_789 c_793)]
            [c_29 (extract 31 25 c_17)]
            [c_798 (bveq c_29 (bv #b0000100 7))]
            [c_800 (and-match c_795 c_798)]
            [c_21 (extract 11 7 c_17)]
            [c_803 (bveq c_21 (bv 0 5))]
            [c_805 (not c_803)]
            [c_806 (and-match c_800 c_805)]
        )
    c_806
))
"packh"
#'(define (PACKH-SetDecode instr)
    (let* (
            
            [c_17 instr]
            [c_19 (extract 6 0 c_17)]
            [c_789 (bveq c_19 (bv #b0110011 7))]
            [c_27 (extract 14 12 c_17)]
            [c_793 (bveq c_27 (bv #b111 3))]
            [c_795 (and-match c_789 c_793)]
            [c_29 (extract 31 25 c_17)]
            [c_798 (bveq c_29 (bv #b0000100 7))]
            [c_800 (and-match c_795 c_798)]
            [c_21 (extract 11 7 c_17)]
            [c_803 (bveq c_21 (bv 0 5))]
            [c_805 (not c_803)]
            [c_806 (and-match c_800 c_805)]
        )
    c_806
))
"zip" 
#'(define (ZIP-SetDecode instr)
    (let* (
            
            [c_17 instr]
            [c_19 (extract 6 0 c_17)]
            [c_789 (bveq c_19 (bv #b0010011 7))]
            [c_27 (extract 14 12 c_17)]
            [c_793 (bveq c_27 (bv #b001 3))]
            [c_795 (and-match c_789 c_793)]
            [c_29 (extract 31 20 c_17)]
            [c_798 (bveq c_29 (bv #b000010001111 12))]
            [c_800 (and-match c_795 c_798)]
            [c_21 (extract 11 7 c_17)]
            [c_803 (bveq c_21 (bv 0 5))]
            [c_805 (not c_803)]
            [c_806 (and-match c_800 c_805)]
        )
    c_806
))
"unzip"
#'(define (UNZIP-SetDecode instr)
    (let* (
            
            [c_17 instr]
            [c_19 (extract 6 0 c_17)]
            [c_789 (bveq c_19 (bv #b0010011 7))]
            [c_27 (extract 14 12 c_17)]
            [c_793 (bveq c_27 (bv #b101 3))]
            [c_795 (and-match c_789 c_793)]
            [c_29 (extract 31 20 c_17)]
            [c_798 (bveq c_29 (bv #b000010001111 12))]
            [c_800 (and-match c_795 c_798)]
            [c_21 (extract 11 7 c_17)]
            [c_803 (bveq c_21 (bv 0 5))]
            [c_805 (not c_803)]
            [c_806 (and-match c_800 c_805)]
        )
    c_806
))
"rev8"
#'(define (REV8-SetDecode instr)
    (let* (
            
            [c_17 instr]
            [c_19 (extract 6 0 c_17)]
            [c_789 (bveq c_19 (bv #b0010011 7))]
            [c_27 (extract 14 12 c_17)]
            [c_793 (bveq c_27 (bv #b101 3))]
            [c_795 (and-match c_789 c_793)]
            [c_29 (extract 31 20 c_17)]
            [c_798 (bveq c_29 (bv #b011010011000 12))]
            [c_800 (and-match c_795 c_798)]
            [c_21 (extract 11 7 c_17)]
            [c_803 (bveq c_21 (bv 0 5))]
            [c_805 (not c_803)]
            [c_806 (and-match c_800 c_805)]
        )
    c_806
))
"revb"
#'(define (REVB-SetDecode instr)
    (let* (
            
            [c_17 instr]
            [c_19 (extract 6 0 c_17)]
            [c_789 (bveq c_19 (bv #b0010011 7))]
            [c_27 (extract 14 12 c_17)]
            [c_793 (bveq c_27 (bv #b101 3))]
            [c_795 (and-match c_789 c_793)]
            [c_29 (extract 31 20 c_17)]
            [c_798 (bveq c_29 (bv #b011010000111 12))]
            [c_800 (and-match c_795 c_798)]
            [c_21 (extract 11 7 c_17)]
            [c_803 (bveq c_21 (bv 0 5))]
            [c_805 (not c_803)]
            [c_806 (and-match c_800 c_805)]
        )
    c_806
))))
