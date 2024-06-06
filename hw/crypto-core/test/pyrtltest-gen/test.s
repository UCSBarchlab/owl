.global _start
_start:
    /*Amazing program start here */
    addi    a1, zero, 0x12
    addi    a2, zero, 0x45
    addi    a3, zero, 0x01 /* a3 is condition, here is true */
    sh1add  a1, a3, a2