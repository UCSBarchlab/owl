(define-block sketch
(decl (13 (OUTPUT 1 "is_data_hazard_rs2"))
  (14 (OUTPUT 1 "is_data_hazard_rs1"))
  (15 (OUTPUT 32 "data_hazard_output"))
  (16 (OUTPUT 32 "arch_pc"))
  (17 (REGISTER 32 0 "decode_pc"))
  (18 (REGISTER 1 0 "wb_cont_mem_read"))
  (19 (REGISTER 32 0 "wb_pc"))
  (20 (REGISTER 1 0 "wb_cont_mem_sign_ext"))
  (21 (REGISTER 5 0 "wb_rd"))
  (22 (REGISTER 2 0 "wb_cont_mask_mode"))
  (23 (REGISTER 32 0 "wb_reg_write_data"))
  (24 (REGISTER 32 0 "wb_mem_address"))
  (25 (REGISTER 32 0 "wb_mem_write_data"))
  (26 (REGISTER 1 0 "instruction_commit"))
  (27 (REGISTER 1 0 "wb_cont_mem_write"))
  (28 (REGISTER 32 0 "pc"))
  (29 (REGISTER 32 0 "inst_pipelined"))
  (30 (REGISTER 1 0 "wb_reg_write_enable"))
  (31 (REGISTER 32 0 "fetch_pc"))
  (32 (REGISTER 1 0 "if_idex_valid"))
  (33 (MEMORY 32 30 "dmem"))
  (34 (MEMORY 32 5 "rf"))
  (35 (MEMORY 32 30 "imem"))
  (0 (HOLE 2 (list 70 69 68) "cont_mask_mode_hole"))
  (1 (HOLE 3 (list 70 69 68) "cont_imm_type_hole"))
  (2 (HOLE 1 (list 70 69 68) "cont_target_hole"))
  (3 (HOLE 1 (list 70 69 68) "cont_is_cmov_hole"))
  (4 (HOLE 1 (list 70 69 68) "cont_reg_write_src_hole"))
  (5 (HOLE 1 (list 70 69 68) "cont_mem_read_hole"))
  (6 (HOLE 1 (list 70 69 68) "cont_alu_pc_hole"))
  (7 (HOLE 1 (list 70 69 68) "cont_jump_hole"))
  (8 (HOLE 1 (list 70 69 68) "cont_mem_write_hole"))
  (9 (HOLE 1 (list 70 69 68) "cont_mem_sign_ext_hole"))
  (10 (HOLE 1 (list 70 69 68) "cont_reg_write_hole"))
  (11 (HOLE 1 (list 70 69 68) "cont_alu_imm_hole"))
  (12 (HOLE 4 (list 70 69 68) "cont_alu_op_hole")))
(stmt (36 (CONST 0 29))
  (37 (CONST 0 4))
  (38 (CONST 0 24))
  (16 (:= 28))
  (39 (CONST 0 16))
  (40 (SEL 31 (SLICE 2 31)))
  (41 (SEL 24 (SLICE 0 1)))
  (42 (SEL 24 (SLICE 2 31)))
  (43 (CONST 0 32))
  (44 (MUX 32 19 17))
  (45 (NOT 32))
  (46 (CONCAT (list 37 (CONST 0 1))))
  (47 (SEL 25 (SLICE 0 7)))
  (48 (SEL 25 (SLICE 0 15)))
  (49 (CONCAT (list 39 48)))
  (50 (CONCAT (list (CONST 0 1) (CONST 0 1))))
  (51 (CONST 0 8))
  (52 (READ 33 42))
  (53 (CONCAT (list 48 (CONST 0 16))))
  (54 (CONCAT (list 43 (CONST 0 1))))
  (55 (CONST 0 31))
  (56 (SEL 29 (SLICE 8 11)))
  (57 (SEL 29 (SLICE 12 19)))
  (58 (SEL 29 (SLICE 20 24)))
  (59 (SEL 29 (SLICE 20 31)))
  (60 (SEL 29 (SLICE 7 11)))
  (61 (SEL 29 (list 7)))
  (62 (SEL 29 (SLICE 25 30)))
  (63 (SEL 29 (SLICE 21 30)))
  (64 (SEL 29 (list 20)))
  (65 (SEL 29 (list 31)))
  (66 (SEL 29 (SLICE 15 19)))
  (67 (SEL 29 (SLICE 12 31)))
  (68 (SEL 29 (SLICE 25 31)))
  (69 (SEL 29 (SLICE 12 14)))
  (70 (SEL 29 (SLICE 0 6)))
  (71 (AND (CONST 4294967040 32) 52))
  (72 (AND (CONST 4278255615 32) 52))
  (73 (SEL 52 (SLICE 0 7)))
  (74 (AND (CONST 4294901760 32) 52))
  (75 (AND (CONST 65535 32) 52))
  (76 (SEL 52 (SLICE 8 15)))
  (77 (SEL 52 (SLICE 24 31)))
  (78 (AND (CONST 4294902015 32) 52))
  (79 (SEL 52 (SLICE 16 31)))
  (80 (AND (CONST 16777215 32) 52))
  (81 (SEL 52 (SLICE 0 15)))
  (82 (SEL 52 (SLICE 16 23)))
  (83 (EQ 41 50))
  (84 (CONCAT (list 50 50)))
  (85 (EQ 66 46))
  (86 (READ 34 66))
  (87 (NOT 83))
  (88 (MUX 83 (CONST 0 32) 52))
  (89 (CONCAT (list (CONST 0 1) (CONST 1 1))))
  (90 (CONCAT (list 39 81)))
  (91 (SEL 81 (list 15)))
  (92 (EQ 21 66))
  (93 (EQ 21 46))
  (94 (EQ 22 50))
  (95 (MUX 32 26 32))
  (96 (NOT 26))
  (97 (MUX 26 28 19))
  (98 (CONCAT (list 36 (CONST 4 3))))
  (99 (EQ 41 (CONST 2 2)))
  (100 (SEL 73 (list 7)))
  (101 (CONCAT (list 38 73)))
  (102 (CONCAT (list 47 (CONST 0 16))))
  (103 (CONCAT (list 47 (CONST 0 8))))
  (104 (CONCAT (list 38 47)))
  (105 (CONCAT (list 47 (CONST 0 24))))
  (106 (CONCAT (list 55 (CONST 0 1))))
  (107 (CONCAT (list 55 (CONST 1 1))))
  (108 (READ 35 40))
  (109 (AND 30 92))
  (110 (SEL 59 (list 11)))
  (111 (EQ 41 89))
  (112 (EQ 22 89))
  (113 (MUX 45 44 19))
  (114 (CONCAT (list 67 (CONST 0 12))))
  (115 (CONCAT (list 84 84)))
  (116 (NOT 99))
  (117 (CONCAT (list 38 77)))
  (118 (SEL 77 (list 7)))
  (119 (OR 53 75))
  (120 (CONCAT (list 38 76)))
  (121 (SEL 76 (list 7)))
  (122 (CONCAT (list 51 102)))
  (123 (NOT 94))
  (124 (AND 94 83))
  (125 (CONCAT (list 39 79)))
  (126 (SEL 79 (list 15)))
  (127 (AND 94 87))
  (128 (SEL 121 (list 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)))
  (129 (:= 12))
  (130 (:= 3))
  (131 (:= 0))
  (132 (:= 2))
  (133 (:= 6))
  (134 (:= 5))
  (135 (:= 1))
  (136 (:= 11))
  (137 (:= 9))
  (138 (:= 7))
  (139 (:= 4))
  (140 (:= 10))
  (141 (:= 8))
  (142 (SEL 118 (list 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)))
  (143 (NOT 130))
  (144 (MUX 130 106 (CONST 1 32)))
  (145 (CONCAT (list 65 61 62 56 (CONST 0 1))))
  (146 (EQ 58 46))
  (147 (EQ 21 58))
  (148 (READ 34 58))
  (149 (CONCAT (list 128 76)))
  (150 (OR 140 134))
  (151 (OR 49 74))
  (152 (CONCAT (list 38 82)))
  (153 (SEL 82 (list 7)))
  (154 (MUX 45 95 (CONST 0 1)))
  (155 (CONCAT (list 68 60)))
  (156 (CONCAT (list 65 57 64 63 (CONST 0 1))))
  (157 (SEL 110 (list 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)))
  (158 (SEL 91 (list 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)))
  (159 (SEL 155 (list 11)))
  (160 (NOT 93))
  (161 (MUX 96 97 28))
  (162 (SEL 135 (list 2)))
  (163 (SEL 135 (SLICE 0 1)))
  (164 (OR 105 80))
  (165 (SEL 100 (list 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)))
  (166 (MUX 85 86 (CONST 0 32)))
  (167 (ADD-CARRY 31 98))
  (168 (ADD-CARRY 17 98))
  (169 (OR 122 72))
  (170 (SEL 129 (SLICE 0 2)))
  (171 (SEL 129 (list 3)))
  (172 (MUX 138 29 (CONST 19 32)))
  (173 (NOT 138))
  (174 (MUX 138 32 (CONST 0 1)))
  (175 (CONCAT (list 157 59)))
  (176 (AND 30 147))
  (177 (SEL 126 (list 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)))
  (178 (SEL 145 (list 12)))
  (179 (CONCAT (list 39 103)))
  (180 (SEL 178 (list 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)))
  (181 (OR 104 71))
  (182 (MUX 20 120 149))
  (183 (CONCAT (list 115 115)))
  (184 (AND 123 112))
  (185 (NOT 112))
  (186 (NOT 111))
  (187 (AND 127 111))
  (188 (CONCAT (list 180 145)))
  (189 (SEL 153 (list 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)))
  (190 (AND 127 186))
  (191 (SEL 159 (list 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)))
  (192 (SEL 156 (list 20)))
  (193 (CONCAT (list 158 81)))
  (194 (SEL 170 (list 2)))
  (195 (SEL 170 (SLICE 0 1)))
  (196 (CONCAT (list 142 77)))
  (197 (CONCAT (list 165 73)))
  (198 (SEL 195 (list 0)))
  (199 (SEL 195 (list 1)))
  (200 (CONCAT (list 177 79)))
  (201 (MUX 173 174 (CONST 1 1)))
  (202 (MUX 173 172 108))
  (203 (CONCAT (list 189 82)))
  (204 (SEL 192 (list 0 0 0 0 0 0 0 0 0 0 0)))
  (205 (AND 184 83))
  (206 (AND 184 87))
  (207 (AND 206 99))
  (208 (AND 206 116))
  (209 (MUX 124 106 181))
  (210 (AND 30 160))
  (211 (AND 176 160))
  (212 (AND 109 160))
  (213 (MUX 20 90 193))
  (214 (SEL 163 (list 0)))
  (215 (SEL 163 (list 1)))
  (216 (AND 123 185))
  (217 (CONCAT (list 191 155)))
  (218 (OR 179 78))
  (219 (MUX 146 148 (CONST 0 32)))
  (220 (MUX 20 117 196))
  (221 (AND 190 99))
  (222 (AND 190 116))
  (223 (MUX 20 101 197))
  (224 (CONCAT (list 204 156)))
  (225 (MUX 187 209 218))
  (14 (:= 212))
  (226 (MUX 214 106 175))
  (227 (SEL 167 (SLICE 0 31)))
  (228 (AND 216 87))
  (229 (AND 216 83))
  (13 (:= 211))
  (230 (MUX 214 217 188))
  (231 (MUX 20 125 200))
  (232 (MUX 214 114 224))
  (233 (MUX 20 152 203))
  (234 (MUX 124 106 223))
  (235 (MUX 221 225 169))
  (236 (MUX 215 226 230))
  (237 (MUX 215 232 106))
  (238 (MUX 187 234 182))
  (239 (MUX 222 235 164))
  (240 (MUX 221 238 233))
  (241 (MUX 205 239 151))
  (242 (MUX 207 241 119))
  (243 (MUX 162 236 237))
  (244 (MUX 222 240 220))
  (245 (MUX 208 242 52))
  (246 (ADD-CARRY 17 243))
  (247 (MUX 205 244 213))
  (248 (MUX 229 245 25))
  (249 (MUX 207 247 231))
  (250 (MUX 228 248 52))
  (251 (MUX 208 249 (CONST 0 32)))
  (252 (MUX 216 251 88))
  (253 (MUX 18 23 252))
  (254 (MUX 212 166 253))
  (15 (:= 253))
  (255 (MUX 211 219 253))
  (256 (MUX 133 254 17))
  (257 (SEL 256 (SLICE 0 30)))
  (258 (SEL 256 (SLICE 1 31)))
  (259 (SEL 256 (list 31)))
  (260 (CONCAT (list (CONST 0 1) 258)))
  (261 (CONCAT (list 259 258)))
  (262 (CONCAT (list 259 259)))
  (263 (NOT 259))
  (264 (CONCAT (list 262 262)))
  (265 (CONCAT (list 264 264)))
  (266 (CONCAT (list 265 265)))
  (267 (CONCAT (list 257 (CONST 0 1))))
  (268 (CONCAT (list 257 259)))
  (269 (MUX 143 144 255))
  (270 (MUX 136 269 243))
  (271 (MUX (CONST 0 1) 260 267))
  (272 (MUX (CONST 1 1) 260 267))
  (273 (MUX (CONST 0 1) 261 268))
  (274 (SEL 270 (SLICE 0 4)))
  (275 (OR 256 270))
  (276 (MUX 198 270 106))
  (277 (SEL 270 (list 31)))
  (278 (SUB-CARRY 256 270))
  (279 (LT 256 270))
  (280 (AND 256 270))
  (281 (XOR 256 270))
  (282 (ADD-CARRY 256 270))
  (283 (SEL 278 (list 32)))
  (284 (MUX 198 278 54))
  (285 (XOR 283 263))
  (286 (CONCAT (list (CONST 0 1) 275)))
  (287 (SEL 274 (list 3)))
  (288 (SEL 274 (list 0)))
  (289 (SEL 274 (list 4)))
  (290 (SEL 274 (list 1)))
  (291 (SEL 274 (list 2)))
  (292 (NOT 277))
  (293 (MUX 198 286 282))
  (294 (MUX 288 256 271))
  (295 (MUX 288 256 273))
  (296 (MUX 288 256 272))
  (297 (MUX 199 284 54))
  (298 (XOR 285 292))
  (299 (SEL 294 (SLICE 0 29)))
  (300 (SEL 294 (SLICE 2 31)))
  (301 (SEL 296 (SLICE 0 29)))
  (302 (SEL 296 (SLICE 2 31)))
  (303 (CONCAT (list 299 50)))
  (304 (CONCAT (list 301 50)))
  (305 (SEL 295 (SLICE 0 29)))
  (306 (SEL 295 (SLICE 2 31)))
  (307 (MUX 198 298 279))
  (308 (CONCAT (list 50 300)))
  (309 (CONCAT (list 50 302)))
  (310 (CONCAT (list 305 262)))
  (311 (CONCAT (list 262 306)))
  (312 (CONCAT (list 55 307)))
  (313 (MUX (CONST 0 1) 308 303))
  (314 (MUX (CONST 1 1) 309 304))
  (315 (MUX (CONST 0 1) 311 310))
  (316 (MUX 290 294 313))
  (317 (MUX 290 295 315))
  (318 (SEL 317 (SLICE 0 27)))
  (319 (SEL 317 (SLICE 4 31)))
  (320 (SEL 316 (SLICE 0 27)))
  (321 (SEL 316 (SLICE 4 31)))
  (322 (MUX 290 296 314))
  (323 (CONCAT (list 318 264)))
  (324 (CONCAT (list 84 321)))
  (325 (CONCAT (list 264 319)))
  (326 (CONCAT (list 320 84)))
  (327 (SEL 322 (SLICE 0 27)))
  (328 (SEL 322 (SLICE 4 31)))
  (329 (CONCAT (list 327 84)))
  (330 (MUX (CONST 0 1) 325 323))
  (331 (MUX (CONST 0 1) 324 326))
  (332 (CONCAT (list 84 328)))
  (333 (MUX 291 316 331))
  (334 (MUX 291 317 330))
  (335 (MUX (CONST 1 1) 332 329))
  (336 (SEL 333 (SLICE 0 23)))
  (337 (SEL 333 (SLICE 8 31)))
  (338 (SEL 334 (SLICE 0 23)))
  (339 (SEL 334 (SLICE 8 31)))
  (340 (MUX 291 322 335))
  (341 (CONCAT (list 336 115)))
  (342 (CONCAT (list 115 337)))
  (343 (CONCAT (list 338 265)))
  (344 (CONCAT (list 265 339)))
  (345 (SEL 340 (SLICE 8 31)))
  (346 (SEL 340 (SLICE 0 23)))
  (347 (MUX (CONST 0 1) 342 341))
  (348 (CONCAT (list 346 115)))
  (349 (MUX (CONST 0 1) 344 343))
  (350 (CONCAT (list 115 345)))
  (351 (MUX 287 333 347))
  (352 (MUX 287 334 349))
  (353 (MUX (CONST 1 1) 350 348))
  (354 (SEL 351 (SLICE 16 31)))
  (355 (SEL 351 (SLICE 0 15)))
  (356 (SEL 352 (SLICE 16 31)))
  (357 (SEL 352 (SLICE 0 15)))
  (358 (MUX 287 340 353))
  (359 (CONCAT (list 183 354)))
  (360 (CONCAT (list 357 266)))
  (361 (CONCAT (list 355 183)))
  (362 (CONCAT (list 266 356)))
  (363 (SEL 358 (SLICE 0 15)))
  (364 (SEL 358 (SLICE 16 31)))
  (365 (CONCAT (list 363 183)))
  (366 (MUX (CONST 0 1) 359 361))
  (367 (MUX (CONST 0 1) 362 360))
  (368 (CONCAT (list 183 364)))
  (369 (MUX 289 351 366))
  (370 (MUX 289 352 367))
  (371 (MUX (CONST 1 1) 368 365))
  (372 (MUX 198 281 369))
  (373 (CONCAT (list (CONST 0 1) 372)))
  (374 (MUX 198 106 370))
  (375 (MUX 289 358 371))
  (376 (MUX 199 373 293))
  (377 (MUX 199 374 276))
  (378 (MUX 198 280 375))
  (379 (CONCAT (list (CONST 0 1) 377)))
  (380 (MUX 199 378 312))
  (381 (MUX 194 297 379))
  (382 (CONCAT (list (CONST 0 1) 380)))
  (383 (MUX 194 382 376))
  (384 (MUX 171 383 381))
  (385 (SEL 384 (SLICE 0 31)))
  (386 (CONCAT (list (CONST 0 1) 385)))
  (387 (EQ 385 107))
  (388 (MUX 387 (CONST 0 1) (CONST 0 1)))
  (389 (NOT 387))
  (390 (MUX 132 246 386))
  (391 (MUX 389 388 (CONST 1 1)))
  (392 (SEL 390 (SLICE 0 31)))
  (393 (MUX 391 253 255))
  (394 (AND 130 391))
  (395 (MUX 138 31 392))
  (396 (MUX 130 106 393))
  (397 (OR 150 394))
  (398 (MUX 173 395 227))
  (399 (MUX 143 396 385))
  (400 (CONCAT (list (CONST 0 1) 399)))
  (401 (MUX 139 400 168))
  (402 (SEL 401 (SLICE 0 31)))
  (34 (WRITE 21 253 210))
  (33 (WRITE 42 250 27))
  (32 (:= 201))
  (29 (:= 202))
  (24 (:= 385))
  (21 (:= 60))
  (28 (:= 161))
  (27 (:= 141))
  (17 (:= 31))
  (26 (:= 154))
  (25 (:= 255))
  (31 (:= 398))
  (30 (:= 397))
  (18 (:= 134))
  (19 (:= 113))
  (20 (:= 137))
  (23 (:= 402))
  (22 (:= 131))))