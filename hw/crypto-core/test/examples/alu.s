# Testing various ALU functionality

main: 
	addi a0, zero, 18 
	add a1, a0, a0
	addi a1, a1, -28
	xor a2, a0, a1
	sub a0, a0, a1
	slt a3, a1, a0
	slli a3, a3, 31
	slti s0, a3, 0 #6A413
	sltiu s1, a3, 0 #6B493
	ori a3, a3, 0xff
	addi a4, zero, 31 #1F00713
	srl s2, a3, a4 #E6D933
	sra s3, a3, a4 #40E6D9B3
	andi a4, a3, 0xff #FF6F713
	sub a4, a4, a0 #40A70733
exit:
