import pyrtl, sys, io
sys.path.append('..')
from generate_ir import generate_ir
from src import rv_cpu

if __name__ == "__main__":
    from argparse import ArgumentParser

    # Take in number of pipeline stages as an argument
    parser = ArgumentParser()
    parser.add_argument(
        "-s", "--stages", type=int, dest="stages", help="number of pipeline stages"
    )
    parser.add_argument(
        "-e", "--ext", type=str, dest="extension", help="ISA extension rv(i), zbk(b), zbk(c)"
    )
    parser.add_argument(
        "-c", "--control-holes", action="store_true", dest="holes", help="insert holes for control logic into design"
    )
    args = parser.parse_args()

    num_stages = args.stages if args.stages is not None else 1
    extension = args.extension if args.extension is not None else 'i'
    holes = args.holes

    rv_cpu(num_stages=num_stages, isa=extension, holes=holes)

    pyrtl.optimize()

    ir = generate_ir(pyrtl.working_block())
    print(ir)

    if not holes:
        pyrtl.synthesize()
        print("wires: {}, gates: {}".format(len(pyrtl.working_block().wirevector_set), len(pyrtl.working_block().logic)))
