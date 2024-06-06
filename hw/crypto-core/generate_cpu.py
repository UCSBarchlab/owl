import pyrtl, sys, io
sys.path.append('..')
from generate_ir import generate_ir
from src import crypto_cpu

if __name__ == "__main__":
    from argparse import ArgumentParser

    # Take in number of pipeline stages as an argument
    parser = ArgumentParser()
    parser.add_argument(
        "-c", "--control-holes", action="store_true", dest="holes", help="insert holes for control logic into design"
    )
    args = parser.parse_args()

    holes = args.holes

    crypto_cpu(holes=holes)

    pyrtl.optimize()

    ir = generate_ir(pyrtl.working_block())
    print(ir)

    if not holes:
        pyrtl.synthesize()
        print("wires: {}, gates: {}".format(len(pyrtl.working_block().wirevector_set), len(pyrtl.working_block().logic)))
