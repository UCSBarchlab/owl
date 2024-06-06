.global _start
_start:
    addi a0, zero, 0x1
    addi a1, a0, 0x5
    add a2, a1, a0
    j dest
    addi a3, zero, 0x45
dest:
    add a3, a3, a2

# a0 = 0x1, a1 = 0x6, a2 = 0x7, a3 = 0x7

/*
00010074 <_start>:
   10074: 13 05 10 00  	li	a0, 1
   10078: 93 05 55 00  	addi	a1, a0, 5
   1007c: 33 86 a5 00  	add	a2, a1, a0
   10080: 6f 00 80 00  	j	0x10088 <dest>
   10084: 93 06 50 04  	li	a3, 69

00010088 <dest>:
   10088: b3 86 c6 00  	add	a3, a3, a2
*/