# Testing that $zero is not changed throughout program execution

main:
	add a0, zero, zero  # $zero is initially set to 0 so a0 = 0.
	lui a1, 0xf673      # Loads large negative number into a1
	sw a1, 0x4(zero)    # Stores the value from a1 in d_mem[1]
	lw zero, 0x4(zero)  # this line shoudn't change zero
	addi s0, zero, 0x5  # s0 = 5
	addi zero, s0, 0x2  # This line also shoudn't change zero
exit:

# Below is a list of assertions to ensure the program executed properly.

# sim.inspect_mem(rf) == {8: 5, 10: 0, 11: 258420736},
# sim.inspect_mem(data_mem) == {1: 258420736},
