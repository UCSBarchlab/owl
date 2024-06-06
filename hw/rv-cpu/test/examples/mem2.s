# Testing lw and sw

main:

for1: # The first loop stores 20 values in d_mem
	add a0, zero, zero
	addi a1, zero, 20
loop1:
	beq a0, a1, end1
	srai a2, a0, 2
	addi a2, a2, 5
	sw a2, 0(a0)
	addi a0, a0, 4
	j loop1
end1:

for2: # The second loop copies the d_mem values and shifts them in memory
	add a0, zero, zero
loop2:
	beq a0, a1, end2
	lw a4, 0(a0)
	sw a4, 128(a0)
	addi a0, a0, 4
	j loop2
end2:

exit:

# Below is a test to ensure the program executed properly.

# assert(sim.inspect_mem(rf) == {10: 20, 11: 20, 12: 9, 14: 9})
# assert(sim.inspect_mem(d_mem) == {0: 5, 4: 6, 8: 7, 12: 8, 16: 9, 128: 5, 132: 6, 136: 7, 140: 8, 144: 9})
