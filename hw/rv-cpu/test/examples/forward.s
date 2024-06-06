# Testing forwarding

main:
    addi a0, zero, 18
    sw a0, 8(zero)
    add a1, a0, s0
    addi a3, zero, 1
    addi a4, zero, 23
    sub a2, a1, a3
    and s0, a2, a4
    or s1, a1, a2
    add s2, a2, a2
    sw s2, 3(a2)
    lw a5, 20(zero)
    or a6, a5, zero
exit:
