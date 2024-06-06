import pyrtl, inspect
from enum import IntEnum


# print fancy colors to terminal
def error(*args, **kwargs):
    print("\033[91m" + " ".join(map(str, args)) + "\033[0m", **kwargs)


def ok(*args, **kwargs):
    print("\033[96m" + " ".join(map(str, args)) + "\033[0m", **kwargs)


def warning(*args, **kwargs):
    print("\033[93m" + " ".join(map(str, args)) + "\033[0m", **kwargs)


def get_wire(name):
    return pyrtl.working_block().get_wirevector_by_name(name)


def get_mem(name):
    return pyrtl.working_block().get_memblock_by_name(name)


class Program:
    def __init__(self, name, instructions, debug=False, check_pass=False, **kwargs):
        self.name = name
        self.instructions = instructions
        self.debug = debug
        self.assertions = kwargs
        self.check_pass = check_pass

    def execute(self, max_cycles=256, debug=False):
        debug = debug or self.debug

        pc = get_wire("pc")
        inst = get_wire("inst")
        rf = get_mem("rf")
        inst_mem = get_mem("imem")
        data_mem = get_mem("dmem")

        print(f"Running program {self.name}...")

        # Start a simulation trace
        sim_trace = pyrtl.SimulationTrace()

        # Initialize the inst_mem with your instuctions.
        sim = pyrtl.Simulation(
            tracer=sim_trace,
            memory_value_map={inst_mem: dict(enumerate(self.instructions))},
        )

        # Simulate program execution
        def step(sim):
            sim.step({})
            if debug:
                print(cycle)
                print(f"INST: {sim.inspect(pc):#0x} ({sim.inspect(inst):#0{10}x})")
                print(f"REGS: {sim.inspect_mem(rf)}")
                print(f"DMEM: {sim.inspect_mem(data_mem)}")

        cycle = 0
        countdown = None
        while (countdown is None or countdown > 0) and cycle < max_cycles:
            step(sim)
            cycle += 1
            if not sim.inspect(inst):
                countdown = countdown - 1 if countdown else 8  # probably enough time
            elif countdown is not None:
                countdown = None

        if cycle >= max_cycles:
            warning(f"Warning: exceeded maximum clock cycles ({max_cycles})")

        failed = False
        for wire in self.assertions:
            value = (
                sim.inspect(get_wire(wire))
                if get_wire(wire)
                else sim.inspect_mem(get_mem(wire))
            )
            if value != self.assertions[wire]:
                failed = True
                error(
                    f"Invalid assertion: {wire} \n\texpected {self.assertions[wire]} \n\tactual {value})"
                )

        if self.check_pass:
            mem = sim.inspect_mem(data_mem)
            if 0x4000000 not in mem or mem[0x4000000] != int(
                "".join(map(lambda i: hex(ord(i))[2:], reversed("PASS"))), 16
            ):
                failed = True

        # Use render_trace() to debug if your code doesn't work.
        # sim_trace.render_trace()

        if failed:
            error(f"Failed!")
        else:
            ok("Passed!")

        return not failed
