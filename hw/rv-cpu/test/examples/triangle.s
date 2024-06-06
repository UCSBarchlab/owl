main:
	addi a0, zero, 666
loop:
	beq a0, a2, end
	addi a1, a1, 1
	add a2, a2, a1
	j loop
exit:
