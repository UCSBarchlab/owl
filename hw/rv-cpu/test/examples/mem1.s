# Testing loads and stores

main:
    lui a0, 0x33
    addi a0, a0, 0xbfb
    slli a0, a0, 0xe
    addi a0, a0, 0xabe
    xori a1, zero, 0x100
    sw a0, 0(a1)
    lw a2, 0(a1)
    xor s0, a0, a2
    lh a2, 0(a1)
    lhu a3, 0(a1)
    addi a2, a2, -1
    sltu a3, a2, a3
    add s0, s0, a3
    lhu a2, 2(a1)
    slli a3, a2, 16
    lhu a2, 0(a1)
    add a3, a3, a2
    xor a3, a0, a3
    add s0, s0, a3
    lb a2, 3(a1)
    slli a3, a2, 24
    lbu a2, 2(a1)
    slli a2, a2, 16
    add a3, a3, a2
    lhu a2, 0(a1)
    add a3, a3, a2
    xor a3, a0, a3
    add s0, s0, a3
    lb a2, 3(a1)
    sw a2, 4(a1)
    lbu a2, 2(a1)
    sh a2, 6(a1)
    lbu a2, 1(a1)
    sb a2, 5(a1)
    lbu a2, 0(a1)
    sb a2, 7(a1)
exit:

