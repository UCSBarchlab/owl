# Testing lui

main:
	lui a0, 34523
	lui a1, 234
	lui a2, 0
exit:

# Below is a test to ensure the program executed properly.

# assert(sim.inspect_mem(rf) == {10: 141406208, 11: 958464, 12: 0})
# assert(sim.inspect_mem(d_mem) == {})
