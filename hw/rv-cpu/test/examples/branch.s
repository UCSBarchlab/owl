# Test various branches and jumps

main: 
	beq zero, zero, start
	addi s1, s1, 1
middle:
	addi s5, s5, 1
	j branch1
start:
	addi s2, s2, 1
	jal s0, hawaii
	addi a0, zero, 5
	addi a1, a0, 1
branch0:
	beq a0, a1, branch2
branch3:
	addi s4, s4, 1
	bge a1, a0, middle
	blt a1, a0, end
branch1:
	addi s6, s6, 1
	addi a0, a0, 1
	bne a0, zero, branch0
branch2:
	addi s7, s7, 1
	blt zero, a0, branch3
	addi s1, s1, 1
hawaii:
	addi s3, s3, 1
	jalr t1, s0, 0
	addi s1, s1, 1
end:
