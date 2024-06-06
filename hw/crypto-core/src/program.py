import pyrtl, inspect
import struct
from enum import IntEnum

def read2_32bits(fd, dest):
    while True:
        binary = fd.read(4)

        if not binary:
            break

        value = struct.unpack('<I', binary)[0]

        dest.append(value)

    return dest

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
    def __init__(self, name, debug=False, check_pass=False, **kwargs):
        self.name = name
        # self.instructions = instructions
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

        mysha_path = "./test/mysha/"
        f_instr = open(mysha_path+"CODE.dat", "rb")
        f_data = open(mysha_path+"DATA.dat", "rb")

        sha256_instr = []
        sha256_data = []

        # sha256_instr = f_instr.read()
        # sha256_data = f_data.read()

        # read2_32bits(f_data, sha256_data)
        read2_32bits(f_instr, sha256_instr)
        read2_32bits(f_data, sha256_data)

        print("msg[2] early print:", sha256_data[(0x3100 + 2*4)>>2])

        # Initialize the inst_mem with your instuctions.
        
        #sim = pyrtl.Simulation(
        #    tracer=sim_trace,
        #    memory_value_map={inst_mem: dict(enumerate(self.instructions))},
        #)
        
        # pyrtl.optimize()

        sim = pyrtl.Simulation(
            tracer=sim_trace,
            memory_value_map={inst_mem: dict(enumerate(sha256_instr)), 
                            data_mem: dict(enumerate(sha256_data))},
        )
        
        fin_addr = 0x3678
        sha256_start = 0x3600
        inspec_start = 0x367c
        str_len = 0x3624

        #loopvar_0 = 0x37ac
        loopvar = 0x3674

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
            mem = sim.inspect_mem(data_mem)
            if mem[fin_addr >> 2] == 1:
                ok("number of cycles:", cycle)
                break
            
            step(sim)
            cycle += 1
            if not sim.inspect(inst):
                countdown = countdown - 1 if countdown else 8  # probably enough time
            elif countdown is not None:
                countdown = None

        if cycle >= max_cycles:
            warning(f"Warning: exceeded maximum clock cycles ({max_cycles})")

        failed = False
        
        #for wire in self.assertions:
        #    value = (
        #        sim.inspect(get_wire(wire))
        #        if get_wire(wire)
        #        else sim.inspect_mem(get_mem(wire))
        #    )
        #    if value != self.assertions[wire]:
        #        failed = True
        #        error(
        #            f"Invalid assertion: {wire} \n\texpected {self.assertions[wire]} \n\tactual {value})"
        #        )

        if True:
            mem = sim.inspect_mem(data_mem)
            with open("mem_dump.txt", "w") as mem_dump:
                for key, value in mem.items():
                    mem_dump.write(f"{key}: {value}\n")
            
            #if 0x4000000 not in mem or mem[0x4000000] != int(
            #    "".join(map(lambda i: hex(ord(i))[2:], reversed("PASS"))), 16
            #):
            #    failed = True
            
            
            ok("finish: ", mem[fin_addr>>2])
            
            # for i in range(64):
            #     ok("inspect[", i, "]: ",  mem[(inspec_start + 4 * i)>>2])

            # ok("loopvar_0: ", mem[loopvar_0>>2])
            ok("loopvar: ", mem[loopvar>>2])
            ok("str_len: ", mem[str_len>>2])

            ok("msg[2]:", mem[(0x3100 + 2 * 4)>>2])

            if(mem[fin_addr>>2] == int(1)):
                for pi in range(0, 32, 4):
                    ok(mem[(sha256_start + pi)>>2])
            
        # Use render_trace() to debug if your code doesn't work.
        # sim_trace.render_trace()
        fd = open("output_wave.vcd", "w")
        sim_trace.print_vcd(file=fd, include_clock=True)

        if failed:
            error(f"Failed!")
        else:
            ok("Passed!")

        return not failed

