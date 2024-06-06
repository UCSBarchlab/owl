import pyrtl, sys
sys.path.append('..')
from generate_ir import generate_ir
from aes import AES


aes = AES()
plaintext = pyrtl.Input(bitwidth=128, name='plaintext')
key_in = pyrtl.Input(bitwidth=128, name='key_in')
aes_ciphertext = pyrtl.Output(bitwidth=128, name='aes_ciphertext')
reset = pyrtl.Input(1, name='reset')
ready = pyrtl.Output(1, name='ready')
ready_out, aes_cipher = aes.encrypt_state_m(plaintext, key_in, reset)
ready <<= ready_out
aes_ciphertext <<= aes_cipher

pyrtl.constant_propagation(pyrtl.working_block(), True)
pyrtl.common_subexp_elimination(pyrtl.working_block())

ir = generate_ir(pyrtl.working_block())

print(ir)


# sim_trace = pyrtl.SimulationTrace()
# sim = pyrtl.Simulation(tracer=sim_trace)
# sim.step ({
#     'plaintext': 0xdead,
#     'key_in': 0xdead,
#     'reset': 1
# })
# for cycle in range(1,12):
#     sim.step ({
#         'plaintext': 0xdead,
#         'key_in': 0xdead,
#         'reset': 0
#     })
# sim_trace.render_trace(symbol_len=40, segment_size=1)
