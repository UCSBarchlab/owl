(define-block sketch
(decl (14 (REGISTER 32 0 "pc"))
  (15 (MEMORY 32 5 "rf"))
  (16 (MEMORY 32 30 "imem"))
  (17 (MEMORY 32 30 "dmem"))
  (0 (HOLE 1 (list 60 62 57) "cont_mem_write_hole"))
  (1 (HOLE 1 (list 60 62 57) "cont_jump_hole"))
  (2 (HOLE 1 (list 60 62 57) "cont_target_hole"))
  (3 (HOLE 1 (list 60 62 57) "cont_alu_imm_hole"))
  (4 (HOLE 5 (list 60 62 57) "cont_alu_op_hole"))
  (5 (HOLE 1 (list 60 62 57) "cont_branch_hole"))
  (6 (HOLE 1 (list 60 62 57) "cont_mem_sign_ext_hole"))
  (7 (HOLE 1 (list 60 62 57) "cont_reg_write_hole"))
  (8 (HOLE 1 (list 60 62 57) "cont_mem_read_hole"))
  (9 (HOLE 2 (list 60 62 57) "cont_mask_mode_hole"))
  (10 (HOLE 3 (list 60 62 57) "cont_imm_type_hole"))
  (11 (HOLE 1 (list 60 62 57) "cont_alu_pc_hole"))
  (12 (HOLE 1 (list 60 62 57) "cont_branch_inv_hole"))
  (13 (HOLE 1 (list 60 62 57) "cont_reg_write_src_hole")))
(stmt (18 (CONST 0 18))
  (19 (CONST 0 28))
  (20 (CONST 0 7))
  (21 (CONST 0 23))
  (22 (CONST 0 17))
  (23 (CONST 0 12))
  (24 (CONST 0 22))
  (25 (CONST 0 6))
  (26 (CONST 0 11))
  (27 (CONST 0 27))
  (28 (CONST 0 24))
  (29 (CONST 0 21))
  (30 (CONST 0 10))
  (31 (CONST 0 26))
  (32 (CONST 0 5))
  (33 (CONST 0 15))
  (34 (CONST 0 31))
  (35 (CONST 0 25))
  (36 (CONST 0 20))
  (37 (CONST 0 16))
  (38 (CONST 0 30))
  (39 (CONST 0 14))
  (40 (CONST 0 13))
  (41 (CONST 0 9))
  (42 (CONST 0 29))
  (43 (CONST 0 19))
  (44 (CONST 0 3))
  (45 (SEL 14 (SLICE 2 31)))
  (46 (CONST 0 4))
  (47 (CONST 0 2))
  (48 (CONCAT (list (CONST 0 1) (CONST 0 1))))
  (49 (CONST 0 32))
  (50 (CONCAT (list (CONST 0 1) (CONST 1 1))))
  (51 (CONST 0 8))
  (52 (CONCAT (list 34 (CONST 0 1))))
  (53 (READ 16 45))
  (54 (CONCAT (list 46 (CONST 0 1))))
  (55 (CONCAT (list 49 (CONST 0 1))))
  (56 (CONCAT (list 42 (CONST 4 3))))
  (57 (SEL 53 (SLICE 25 31)))
  (58 (SEL 53 (list 7)))
  (59 (SEL 53 (SLICE 25 30)))
  (60 (SEL 53 (SLICE 0 6)))
  (61 (SEL 53 (SLICE 15 19)))
  (62 (SEL 53 (SLICE 12 14)))
  (63 (SEL 53 (SLICE 20 31)))
  (64 (SEL 53 (list 31)))
  (65 (SEL 53 (SLICE 20 24)))
  (66 (SEL 53 (SLICE 7 11)))
  (67 (SEL 53 (SLICE 12 31)))
  (68 (SEL 53 (SLICE 21 30)))
  (69 (SEL 53 (SLICE 12 19)))
  (70 (SEL 53 (list 20)))
  (71 (SEL 53 (SLICE 8 11)))
  (72 (ADD-CARRY 14 56))
  (73 (CONCAT (list 48 48)))
  (74 (READ 15 65))
  (75 (EQ 65 54))
  (76 (SEL 72 (SLICE 0 31)))
  (77 (SEL 63 (list 11)))
  (78 (CONCAT (list 67 (CONST 0 12))))
  (79 (MUX 75 74 (CONST 0 32)))
  (80 (:= 0))
  (81 (:= 3))
  (82 (:= 10))
  (83 (:= 9))
  (84 (:= 8))
  (85 (:= 13))
  (86 (:= 12))
  (87 (:= 4))
  (88 (:= 7))
  (89 (:= 11))
  (90 (:= 2))
  (91 (:= 1))
  (92 (:= 5))
  (93 (:= 6))
  (94 (SEL 79 (SLICE 0 7)))
  (95 (SEL 79 (SLICE 0 15)))
  (96 (SEL 82 (list 2)))
  (97 (SEL 82 (SLICE 0 1)))
  (98 (CONCAT (list 73 73)))
  (99 (CONCAT (list 94 (CONST 0 8))))
  (100 (CONCAT (list 94 (CONST 0 16))))
  (101 (CONCAT (list 28 94)))
  (102 (CONCAT (list 94 (CONST 0 24))))
  (103 (CONCAT (list 37 95)))
  (104 (CONCAT (list 95 (CONST 0 16))))
  (105 (CONCAT (list 98 98)))
  (106 (CONCAT (list 51 100)))
  (107 (EQ 61 54))
  (108 (READ 15 61))
  (109 (EQ 83 48))
  (110 (EQ 83 50))
  (111 (CONCAT (list 37 99)))
  (112 (NOT 109))
  (113 (SEL 77 (list 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)))
  (114 (SEL 87 (list 4)))
  (115 (SEL 87 (SLICE 0 3)))
  (116 (NOT 110))
  (117 (AND 112 110))
  (118 (SEL 115 (SLICE 0 2)))
  (119 (SEL 115 (list 3)))
  (120 (OR 88 84))
  (121 (CONCAT (list 57 66)))
  (122 (EQ 66 54))
  (123 (SEL 97 (list 0)))
  (124 (SEL 97 (list 1)))
  (125 (NOT 122))
  (126 (MUX 107 108 (CONST 0 32)))
  (127 (CONCAT (list 113 63)))
  (128 (SEL 121 (list 11)))
  (129 (AND 112 116))
  (130 (SEL 118 (SLICE 0 1)))
  (131 (SEL 118 (list 2)))
  (132 (MUX 89 126 14))
  (133 (CONCAT (list 64 69 70 68 (CONST 0 1))))
  (134 (CONCAT (list 64 58 59 71 (CONST 0 1))))
  (135 (AND 120 125))
  (136 (SEL 133 (list 20)))
  (137 (SEL 132 (SLICE 7 31)))
  (138 (SEL 132 (SLICE 26 31)))
  (139 (SEL 132 (SLICE 0 3)))
  (140 (SEL 132 (SLICE 10 31)))
  (141 (SEL 132 (SLICE 16 31)))
  (142 (SEL 132 (SLICE 3 31)))
  (143 (SEL 132 (SLICE 9 31)))
  (144 (SEL 132 (SLICE 0 19)))
  (145 (SEL 132 (SLICE 11 31)))
  (146 (SEL 132 (SLICE 2 31)))
  (147 (SEL 132 (SLICE 0 7)))
  (148 (SEL 132 (SLICE 0 14)))
  (149 (SEL 132 (SLICE 0 28)))
  (150 (SEL 132 (SLICE 18 31)))
  (151 (SEL 132 (SLICE 1 31)))
  (152 (SEL 132 (SLICE 29 31)))
  (153 (SEL 132 (SLICE 0 6)))
  (154 (SEL 132 (SLICE 0 8)))
  (155 (SEL 132 (list 0)))
  (156 (SEL 132 (SLICE 0 12)))
  (157 (SEL 132 (SLICE 12 31)))
  (158 (SEL 132 (SLICE 0 29)))
  (159 (SEL 132 (SLICE 0 5)))
  (160 (SEL 132 (list 31)))
  (161 (SEL 132 (SLICE 19 31)))
  (162 (SEL 132 (SLICE 5 31)))
  (163 (SEL 132 (SLICE 0 25)))
  (164 (SEL 132 (SLICE 23 31)))
  (165 (SEL 132 (SLICE 0 22)))
  (166 (SEL 132 (SLICE 6 31)))
  (167 (SEL 132 (SLICE 30 31)))
  (168 (SEL 132 (SLICE 17 31)))
  (169 (SEL 132 (SLICE 14 31)))
  (170 (SEL 132 (SLICE 0 30)))
  (171 (SEL 132 (SLICE 25 31)))
  (172 (SEL 132 (SLICE 0 21)))
  (173 (SEL 132 (SLICE 0 9)))
  (174 (SEL 132 (SLICE 0 2)))
  (175 (SEL 132 (SLICE 0 16)))
  (176 (SEL 132 (SLICE 4 31)))
  (177 (SEL 132 (SLICE 0 27)))
  (178 (SEL 132 (SLICE 0 23)))
  (179 (SEL 132 (SLICE 15 31)))
  (180 (SEL 132 (SLICE 0 15)))
  (181 (SEL 132 (SLICE 0 1)))
  (182 (SEL 132 (SLICE 27 31)))
  (183 (SEL 132 (SLICE 0 18)))
  (184 (SEL 132 (SLICE 0 13)))
  (185 (SEL 132 (SLICE 0 4)))
  (186 (SEL 132 (SLICE 24 31)))
  (187 (SEL 132 (SLICE 21 31)))
  (188 (SEL 132 (SLICE 20 31)))
  (189 (SEL 132 (SLICE 22 31)))
  (190 (SEL 132 (SLICE 0 20)))
  (191 (SEL 132 (SLICE 0 26)))
  (192 (SEL 132 (SLICE 0 24)))
  (193 (SEL 132 (SLICE 28 31)))
  (194 (SEL 132 (SLICE 0 11)))
  (195 (SEL 132 (SLICE 0 10)))
  (196 (SEL 132 (SLICE 13 31)))
  (197 (SEL 132 (SLICE 8 31)))
  (198 (SEL 132 (SLICE 0 17)))
  (199 (SEL 128 (list 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)))
  (200 (CONCAT (list 25 166)))
  (201 (CONCAT (list 38 167)))
  (202 (CONCAT (list 39 169)))
  (203 (CONCAT (list 24 189)))
  (204 (SEL 130 (list 1)))
  (205 (SEL 130 (list 0)))
  (206 (SEL 136 (list 0 0 0 0 0 0 0 0 0 0 0)))
  (207 (CONCAT (list 41 143)))
  (208 (CONCAT (list 158 (CONST 0 2))))
  (209 (CONCAT (list 170 (CONST 0 1))))
  (210 (CONCAT (list 175 (CONST 0 15))))
  (211 (CONCAT (list 192 (CONST 0 7))))
  (212 (CONCAT (list 44 142)))
  (213 (CONCAT (list 144 (CONST 0 12))))
  (214 (CONCAT (list 26 145)))
  (215 (CONCAT (list 43 161)))
  (216 (CONCAT (list 177 (CONST 0 4))))
  (217 (CONCAT (list 27 182)))
  (218 (CONCAT (list 194 (CONST 0 20))))
  (219 (CONCAT (list 199 121)))
  (220 (CONCAT (list 153 (CONST 0 25))))
  (221 (CONCAT (list 148 (CONST 0 17))))
  (222 (CONCAT (list 165 (CONST 0 9))))
  (223 (CONCAT (list 206 133)))
  (224 (CONCAT (list 42 152)))
  (225 (CONCAT (list 173 (CONST 0 22))))
  (226 (CONCAT (list 181 (CONST 0 30))))
  (227 (CONCAT (list 29 187)))
  (228 (CONCAT (list 198 (CONST 0 14))))
  (229 (CONCAT (list 156 (CONST 0 19))))
  (230 (CONCAT (list 139 (CONST 0 28))))
  (231 (CONCAT (list 37 141)))
  (232 (CONCAT (list 185 (CONST 0 27))))
  (233 (CONCAT (list 28 186)))
  (234 (CONCAT (list 51 197)))
  (235 (SEL 134 (list 12)))
  (236 (CONCAT (list 31 138)))
  (237 (CONCAT (list 30 140)))
  (238 (CONCAT (list 18 150)))
  (239 (NOT 160))
  (240 (CONCAT (list 34 160)))
  (241 (CONCAT (list 170 160)))
  (242 (CONCAT (list 160 160)))
  (243 (MUX 123 52 127))
  (244 (CONCAT (list 163 (CONST 0 6))))
  (245 (CONCAT (list 32 162)))
  (246 (CONCAT (list 40 196)))
  (247 (SEL 235 (list 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)))
  (248 (CONCAT (list 149 (CONST 0 3))))
  (249 (CONCAT (list (CONST 0 1) 151)))
  (250 (CONCAT (list 160 151)))
  (251 (CONCAT (list 190 (CONST 0 11))))
  (252 (CONCAT (list 19 193)))
  (253 (CONCAT (list 20 137)))
  (254 (CONCAT (list 147 (CONST 0 24))))
  (255 (CONCAT (list 21 164)))
  (256 (CONCAT (list 178 (CONST 0 8))))
  (257 (CONCAT (list 33 179)))
  (258 (CONCAT (list 180 (CONST 0 16))))
  (259 (CONCAT (list 47 146)))
  (260 (CONCAT (list 174 (CONST 0 29))))
  (261 (CONCAT (list 183 (CONST 0 13))))
  (262 (CONCAT (list 191 (CONST 0 5))))
  (263 (CONCAT (list 195 (CONST 0 21))))
  (264 (CONCAT (list 159 (CONST 0 26))))
  (265 (CONCAT (list 22 168)))
  (266 (CONCAT (list 35 171)))
  (267 (CONCAT (list 172 (CONST 0 10))))
  (268 (CONCAT (list 184 (CONST 0 18))))
  (269 (CONCAT (list 242 242)))
  (270 (CONCAT (list 247 134)))
  (271 (CONCAT (list 23 157)))
  (272 (CONCAT (list 154 (CONST 0 23))))
  (273 (CONCAT (list 155 (CONST 0 31))))
  (274 (CONCAT (list 46 176)))
  (275 (CONCAT (list 36 188)))
  (276 (MUX 123 78 223))
  (277 (MUX (CONST 0 1) 249 209))
  (278 (MUX (CONST 1 1) 249 209))
  (279 (MUX (CONST 0 1) 250 241))
  (280 (MUX 123 219 270))
  (281 (CONCAT (list 269 269)))
  (282 (CONCAT (list 281 281)))
  (283 (MUX 124 276 52))
  (284 (MUX 124 243 280))
  (285 (MUX 96 284 283))
  (286 (MUX 81 79 285))
  (287 (ADD-CARRY 14 285))
  (288 (SEL 286 (list 31)))
  (289 (SEL 286 (list 18)))
  (290 (AND 132 286))
  (291 (SEL 286 (SLICE 0 4)))
  (292 (OR 132 286))
  (293 (SEL 286 (list 5)))
  (294 (SEL 286 (list 26)))
  (295 (SEL 286 (list 19)))
  (296 (SEL 286 (list 6)))
  (297 (MUX 205 286 52))
  (298 (SEL 286 (list 13)))
  (299 (LT 132 286))
  (300 (SEL 286 (list 1)))
  (301 (SEL 286 (list 22)))
  (302 (SEL 286 (list 0)))
  (303 (SEL 286 (list 16)))
  (304 (SEL 286 (list 29)))
  (305 (SUB-CARRY 132 286))
  (306 (SEL 286 (list 17)))
  (307 (SEL 286 (list 4)))
  (308 (SEL 286 (list 28)))
  (309 (SEL 286 (list 8)))
  (310 (SEL 286 (list 14)))
  (311 (SEL 286 (list 21)))
  (312 (SEL 286 (list 20)))
  (313 (SEL 286 (list 25)))
  (314 (SEL 286 (list 12)))
  (315 (SEL 286 (list 7)))
  (316 (SEL 286 (list 27)))
  (317 (SEL 286 (list 15)))
  (318 (SEL 286 (list 3)))
  (319 (SEL 286 (list 9)))
  (320 (SEL 286 (list 10)))
  (321 (SEL 286 (list 2)))
  (322 (SEL 286 (list 24)))
  (323 (SEL 286 (list 30)))
  (324 (ADD-CARRY 132 286))
  (325 (SEL 286 (list 11)))
  (326 (SEL 286 (list 23)))
  (327 (XOR 132 286))
  (328 (SEL 305 (list 32)))
  (329 (MUX 205 305 55))
  (330 (MUX 308 (CONST 0 32) 274))
  (331 (MUX 308 (CONST 0 32) 230))
  (332 (MUX 301 (CONST 0 32) 237))
  (333 (MUX 301 (CONST 0 32) 225))
  (334 (MUX 289 (CONST 0 32) 202))
  (335 (MUX 289 (CONST 0 32) 268))
  (336 (CONCAT (list (CONST 0 1) 292)))
  (337 (MUX 294 (CONST 0 32) 200))
  (338 (MUX 294 (CONST 0 32) 264))
  (339 (MUX 316 (CONST 0 32) 245))
  (340 (MUX 316 (CONST 0 32) 232))
  (341 (MUX 321 (CONST 0 32) 208))
  (342 (MUX 321 (CONST 0 32) 201))
  (343 (MUX 326 (CONST 0 32) 207))
  (344 (MUX 326 (CONST 0 32) 272))
  (345 (MUX 307 (CONST 0 32) 252))
  (346 (MUX 307 (CONST 0 32) 216))
  (347 (MUX 309 (CONST 0 32) 256))
  (348 (MUX 309 (CONST 0 32) 233))
  (349 (MUX 317 (CONST 0 32) 265))
  (350 (MUX 317 (CONST 0 32) 210))
  (351 (MUX 293 (CONST 0 32) 217))
  (352 (MUX 293 (CONST 0 32) 262))
  (353 (MUX 302 (CONST 0 32) 132))
  (354 (MUX 303 (CONST 0 32) 258))
  (355 (MUX 303 (CONST 0 32) 231))
  (356 (MUX 304 (CONST 0 32) 212))
  (357 (MUX 304 (CONST 0 32) 260))
  (358 (MUX 306 (CONST 0 32) 221))
  (359 (MUX 306 (CONST 0 32) 257))
  (360 (MUX 319 (CONST 0 32) 255))
  (361 (MUX 319 (CONST 0 32) 222))
  (362 (XOR 328 239))
  (363 (MUX 298 (CONST 0 32) 215))
  (364 (MUX 298 (CONST 0 32) 261))
  (365 (MUX 315 (CONST 0 32) 211))
  (366 (MUX 315 (CONST 0 32) 266))
  (367 (MUX 320 (CONST 0 32) 267))
  (368 (MUX 320 (CONST 0 32) 203))
  (369 (MUX 312 (CONST 0 32) 218))
  (370 (MUX 312 (CONST 0 32) 271))
  (371 (MUX 314 (CONST 0 32) 275))
  (372 (MUX 314 (CONST 0 32) 213))
  (373 (MUX 205 336 324))
  (374 (MUX 313 (CONST 0 32) 220))
  (375 (MUX 313 (CONST 0 32) 253))
  (376 (MUX 296 (CONST 0 32) 236))
  (377 (MUX 296 (CONST 0 32) 244))
  (378 (MUX 300 (CONST 0 32) 209))
  (379 (MUX 300 (CONST 0 32) 240))
  (380 (MUX 310 (CONST 0 32) 238))
  (381 (MUX 310 (CONST 0 32) 228))
  (382 (MUX 318 (CONST 0 32) 248))
  (383 (MUX 318 (CONST 0 32) 224))
  (384 (MUX 323 (CONST 0 32) 226))
  (385 (MUX 323 (CONST 0 32) 259))
  (386 (MUX 325 (CONST 0 32) 227))
  (387 (MUX 325 (CONST 0 32) 251))
  (388 (MUX 288 (CONST 0 32) 249))
  (389 (NOT 288))
  (390 (MUX 288 (CONST 0 32) 273))
  (391 (SEL 291 (list 2)))
  (392 (SEL 291 (list 0)))
  (393 (SEL 291 (list 1)))
  (394 (SEL 291 (list 4)))
  (395 (SEL 291 (list 3)))
  (396 (MUX 295 (CONST 0 32) 246))
  (397 (MUX 295 (CONST 0 32) 229))
  (398 (MUX 322 (CONST 0 32) 234))
  (399 (MUX 322 (CONST 0 32) 254))
  (400 (XOR (CONST 0 32) 379))
  (401 (XOR 362 389))
  (402 (MUX 392 132 278))
  (403 (MUX 392 132 277))
  (404 (MUX 392 132 279))
  (405 (XOR (CONST 0 32) 353))
  (406 (MUX 311 (CONST 0 32) 214))
  (407 (MUX 311 (CONST 0 32) 263))
  (408 (MUX 204 329 55))
  (409 (XOR 400 342))
  (410 (SEL 402 (SLICE 0 29)))
  (411 (SEL 402 (SLICE 2 31)))
  (412 (SEL 403 (SLICE 2 31)))
  (413 (SEL 403 (SLICE 0 29)))
  (414 (XOR 405 378))
  (415 (CONCAT (list 48 412)))
  (416 (CONCAT (list 413 48)))
  (417 (MUX 205 401 299))
  (418 (CONCAT (list 48 411)))
  (419 (SEL 404 (SLICE 0 29)))
  (420 (SEL 404 (SLICE 2 31)))
  (421 (XOR 409 383))
  (422 (MUX (CONST 0 1) 415 416))
  (423 (MUX 393 403 422))
  (424 (CONCAT (list 410 48)))
  (425 (CONCAT (list 242 420)))
  (426 (CONCAT (list 419 242)))
  (427 (CONCAT (list 34 417)))
  (428 (MUX (CONST 0 1) 425 426))
  (429 (XOR 421 345))
  (430 (MUX (CONST 1 1) 418 424))
  (431 (XOR 414 341))
  (432 (SEL 423 (SLICE 4 31)))
  (433 (SEL 423 (SLICE 0 27)))
  (434 (MUX 393 404 428))
  (435 (CONCAT (list 433 73)))
  (436 (XOR 431 382))
  (437 (MUX 393 402 430))
  (438 (XOR 429 351))
  (439 (XOR 436 346))
  (440 (XOR 439 352))
  (441 (SEL 434 (SLICE 0 27)))
  (442 (SEL 434 (SLICE 4 31)))
  (443 (SEL 437 (SLICE 0 27)))
  (444 (SEL 437 (SLICE 4 31)))
  (445 (CONCAT (list 443 73)))
  (446 (CONCAT (list 73 432)))
  (447 (XOR 438 376))
  (448 (XOR 440 377))
  (449 (CONCAT (list 441 269)))
  (450 (MUX (CONST 0 1) 446 435))
  (451 (XOR 448 365))
  (452 (CONCAT (list 73 444)))
  (453 (MUX 391 423 450))
  (454 (CONCAT (list 269 442)))
  (455 (XOR 447 366))
  (456 (MUX (CONST 0 1) 454 449))
  (457 (MUX (CONST 1 1) 452 445))
  (458 (SEL 453 (SLICE 0 23)))
  (459 (SEL 453 (SLICE 8 31)))
  (460 (MUX 391 434 456))
  (461 (XOR 455 348))
  (462 (XOR 451 347))
  (463 (SEL 460 (SLICE 8 31)))
  (464 (SEL 460 (SLICE 0 23)))
  (465 (CONCAT (list 464 281)))
  (466 (CONCAT (list 458 98)))
  (467 (MUX 391 437 457))
  (468 (CONCAT (list 281 463)))
  (469 (XOR 461 360))
  (470 (MUX (CONST 0 1) 468 465))
  (471 (CONCAT (list 98 459)))
  (472 (XOR 462 361))
  (473 (SEL 467 (SLICE 0 23)))
  (474 (SEL 467 (SLICE 8 31)))
  (475 (MUX (CONST 0 1) 471 466))
  (476 (CONCAT (list 473 98)))
  (477 (MUX 395 453 475))
  (478 (CONCAT (list 98 474)))
  (479 (XOR 469 368))
  (480 (XOR 472 367))
  (481 (MUX 395 460 470))
  (482 (SEL 477 (SLICE 16 31)))
  (483 (SEL 477 (SLICE 0 15)))
  (484 (MUX (CONST 1 1) 478 476))
  (485 (XOR 479 386))
  (486 (CONCAT (list 483 105)))
  (487 (XOR 480 387))
  (488 (SEL 481 (SLICE 16 31)))
  (489 (SEL 481 (SLICE 0 15)))
  (490 (XOR 487 372))
  (491 (CONCAT (list 282 488)))
  (492 (CONCAT (list 105 482)))
  (493 (MUX 395 467 484))
  (494 (XOR 485 371))
  (495 (CONCAT (list 489 282)))
  (496 (XOR 490 364))
  (497 (MUX (CONST 0 1) 492 486))
  (498 (SEL 493 (SLICE 16 31)))
  (499 (SEL 493 (SLICE 0 15)))
  (500 (XOR 494 363))
  (501 (MUX (CONST 0 1) 491 495))
  (502 (MUX 394 477 497))
  (503 (CONCAT (list 105 498)))
  (504 (XOR 500 380))
  (505 (XOR 496 381))
  (506 (CONCAT (list 499 105)))
  (507 (MUX 394 481 501))
  (508 (MUX 205 327 502))
  (509 (XOR 504 349))
  (510 (CONCAT (list (CONST 0 1) 508)))
  (511 (MUX 204 510 373))
  (512 (XOR 505 350))
  (513 (MUX (CONST 1 1) 503 506))
  (514 (MUX 205 52 507))
  (515 (XOR 512 354))
  (516 (XOR 509 355))
  (517 (MUX 394 493 513))
  (518 (MUX 204 514 297))
  (519 (XOR 515 358))
  (520 (CONCAT (list (CONST 0 1) 518)))
  (521 (MUX 131 408 520))
  (522 (XOR 516 359))
  (523 (MUX 205 290 517))
  (524 (XOR 519 335))
  (525 (XOR 522 334))
  (526 (MUX 204 523 427))
  (527 (XOR 524 397))
  (528 (CONCAT (list (CONST 0 1) 526)))
  (529 (XOR 525 396))
  (530 (XOR 527 369))
  (531 (MUX 131 528 511))
  (532 (XOR 529 370))
  (533 (XOR 530 407))
  (534 (MUX 119 531 521))
  (535 (XOR 532 406))
  (536 (XOR 533 333))
  (537 (XOR 535 332))
  (538 (XOR 536 344))
  (539 (XOR 537 343))
  (540 (XOR 538 399))
  (541 (XOR 539 398))
  (542 (XOR 540 374))
  (543 (XOR 541 375))
  (544 (XOR 542 338))
  (545 (XOR 543 337))
  (546 (XOR 544 340))
  (547 (XOR 545 339))
  (548 (XOR 546 331))
  (549 (XOR 547 330))
  (550 (XOR 548 357))
  (551 (XOR 549 356))
  (552 (XOR 550 384))
  (553 (XOR 551 385))
  (554 (XOR 552 390))
  (555 (XOR 553 388))
  (556 (MUX 205 52 554))
  (557 (MUX 205 555 52))
  (558 (MUX 204 52 556))
  (559 (MUX 204 557 52))
  (560 (MUX 131 558 559))
  (561 (MUX 119 52 560))
  (562 (CONCAT (list (CONST 0 1) 561)))
  (563 (MUX 114 534 562))
  (564 (SEL 563 (SLICE 0 31)))
  (565 (SEL 564 (SLICE 0 1)))
  (566 (SEL 564 (SLICE 2 31)))
  (567 (EQ 564 52))
  (568 (CONCAT (list (CONST 0 1) 564)))
  (569 (MUX 85 564 76))
  (570 (READ 17 566))
  (571 (EQ 565 50))
  (572 (EQ 565 (CONST 2 2)))
  (573 (EQ 565 48))
  (574 (SEL 570 (SLICE 0 15)))
  (575 (AND (CONST 4294967040 32) 570))
  (576 (AND (CONST 4294901760 32) 570))
  (577 (SEL 570 (SLICE 16 23)))
  (578 (SEL 570 (SLICE 16 31)))
  (579 (SEL 570 (SLICE 0 7)))
  (580 (SEL 570 (SLICE 24 31)))
  (581 (AND (CONST 16777215 32) 570))
  (582 (AND (CONST 65535 32) 570))
  (583 (AND (CONST 4278255615 32) 570))
  (584 (AND (CONST 4294902015 32) 570))
  (585 (SEL 570 (SLICE 8 15)))
  (586 (OR 111 584))
  (587 (NOT 571))
  (588 (SEL 577 (list 7)))
  (589 (CONCAT (list 28 577)))
  (590 (NOT 572))
  (591 (CONCAT (list 28 579)))
  (592 (SEL 579 (list 7)))
  (593 (SEL 588 (list 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)))
  (594 (MUX 90 287 568))
  (595 (OR 101 575))
  (596 (SEL 578 (list 15)))
  (597 (CONCAT (list 37 578)))
  (598 (OR 106 583))
  (599 (AND 129 573))
  (600 (MUX 573 (CONST 0 32) 570))
  (601 (AND 109 573))
  (602 (AND 117 573))
  (603 (NOT 573))
  (604 (CONCAT (list 37 574)))
  (605 (SEL 574 (list 15)))
  (606 (CONCAT (list 593 577)))
  (607 (SEL 596 (list 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)))
  (608 (SEL 605 (list 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)))
  (609 (XOR 567 86))
  (610 (CONCAT (list 28 580)))
  (611 (SEL 580 (list 7)))
  (612 (OR 102 581))
  (613 (CONCAT (list 28 585)))
  (614 (SEL 585 (list 7)))
  (615 (CONCAT (list 608 574)))
  (616 (SEL 614 (list 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)))
  (617 (CONCAT (list 607 578)))
  (618 (CONCAT (list 616 585)))
  (619 (OR 103 576))
  (620 (OR 104 582))
  (621 (SEL 594 (SLICE 0 31)))
  (622 (MUX 601 52 595))
  (623 (AND 109 603))
  (624 (AND 117 603))
  (625 (AND 129 603))
  (626 (SEL 592 (list 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)))
  (627 (SEL 611 (list 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)))
  (628 (MUX 93 597 617))
  (629 (MUX 93 589 606))
  (630 (AND 92 609))
  (631 (CONCAT (list 626 579)))
  (632 (OR 91 630))
  (633 (MUX 93 604 615))
  (634 (MUX 93 613 618))
  (635 (AND 624 590))
  (636 (AND 624 572))
  (637 (MUX 93 591 631))
  (638 (AND 623 587))
  (639 (AND 623 571))
  (640 (CONCAT (list 627 580)))
  (641 (MUX 639 622 586))
  (642 (NOT 632))
  (643 (MUX 632 14 621))
  (644 (MUX 93 610 640))
  (645 (MUX 601 52 637))
  (646 (MUX 639 645 634))
  (647 (MUX 642 643 76))
  (648 (AND 638 590))
  (649 (AND 638 572))
  (650 (MUX 649 641 598))
  (651 (MUX 649 646 629))
  (652 (MUX 648 651 644))
  (653 (MUX 648 650 612))
  (654 (MUX 602 652 633))
  (655 (MUX 602 653 619))
  (656 (MUX 636 654 628))
  (657 (MUX 636 655 620))
  (658 (MUX 635 656 (CONST 0 32)))
  (659 (MUX 635 657 570))
  (660 (MUX 129 658 600))
  (661 (MUX 599 659 79))
  (662 (MUX 84 569 660))
  (663 (MUX 625 661 570))
  (15 (WRITE 66 662 135))
  (17 (WRITE 566 663 80))
  (14 (:= 647))))