.global _start
.section .text

_start:
    addi    a1, zero, 0x12
    addi    a2, zero, 0x45
    addi    a3, zero, 1 #x3 preserve condition
    sh1add  a1, a3, a2
    
