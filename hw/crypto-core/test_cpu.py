import pyrtl, sys
from argparse import ArgumentParser
from os import listdir
from os.path import isfile, join, splitext

from src import Program, rv_cpu

# A set of hand-written smoke tests
benchmarks = [
    # Test various alu functionality
    Program(
        name="alu",
        instructions=[
            # main:
            0x01200513,  # addi a0, zero, 18
            0x00A505B3,  # add a1, a0, a0
            0xFE458593,  # addi a1, a1, -28
            0x00B54633,  # xor a2, a0, a1
            0x40B50533,  # sub a0, a0, a1
            0x00A5A6B3,  # slt a3, a1, a0
            0x01F69693,  # slli a3, a3, 31
            0x0006A413,  # slti s0, a3, 0
            # 0x0006B493,  # sltiu s1, a3, 0
            # 0x0FF6E693,  # ori a3, a3, 0xff
            # 0x01F00713,  # addi a4, zero, 31
            # 0x0FF6F713,  # andi a4, a3, 0xff
            # 0x40A70733,  # sub a4, a4, a0
            
            # exit:
        ],
        rf={
            10: 10, 11: 8, 12: 26, 13: 2147483648, 8: 1
        },
        dmem={},
    ),
    # Test that the zero register is not changed throughout program execution
    Program(
        name="zero",
        instructions=[
            # main:
            0x00000533,  # add a0, zero, zero  # zero is initially set to 0 so a0 = 0.
            0x0F6735B7,  # lui a1, 0xf673      # Loads large negative number into a1
            0x00B02223,  # sw a1, 0x1(zero)    # Stores the value from a1 in d_mem[1]
            0x00402003,  # lw zero, 0x1(zero)  # this line shoudn't change zero
            0x00500413,  # addi s0, zero, 0x5  # s0 = 5
            0x00240013,  # addi zero, s0, 0x2  # This line also shoudn't change zero
            # exit:
        ],
        rf={8: 5, 10: 0, 11: 258420736},
        dmem={1: 258420736},
    ),
    # Test lui instruction
    Program(
        name="lui",
        instructions=[
            # main:
            0x086DB537,  # lui a0, 34523
            0x000EA5B7,  # lui a1, 234
            0x00000637,  # lui a2, 0
            # exit:
        ],
        rf={10: 141406208, 11: 958464, 12: 0},
        dmem={},
    ),
    Program(
        name="dumb",
        instructions=[
            # main:
            0x000EA5B7,  # lui a1, 234
            # exit:
        ],
        rf={11: 958464},
        dmem={},
    ),
    # Test various jumps and branches
    Program(
        name="branch",
        instructions=[
            # main:
            0x00000863,  # beq zero, zero, start
            0x00188893,  # addi s1, s1, 1
            # middle:
            0x001A8A93,  # addi s5, s5, 1
            0x0240006F,  # j branch1
            # start:
            0x00190913,  # addi s2, s2, 1
            0x0340046F,  # jal s0, hawaii
            0x00500513,  # addi a0, zero, 5
            0x00150593,  # addi a1, a0, 1
            # branch0:
            0x00B50E63,  # beq a0, a1, branch2
            # branch3:
            0x001A0A13,  # addi s4, s4, 1
            0xFEA5D0E3,  # bge a1, a0, middle
            0x02A5C463,  # blt a1, a0, end
            # branch1:
            0x001B0B13,  # addi s6, s6, 1
            0x00150513,  # addi a0, a0, 1
            0xFE0514E3,  # bne a0, zero, branch0
            # branch2:
            0x001B8B93,  # addi s7, s7, 1
            0xFEA042E3,  # blt zero, a0, branch3
            0x00188893,  # addi s1, s1, 1
            # hawaii:
            0x00198993,  # addi s3, s3, 1
            0x00040367,  # jalr t1, s0, 0
            0x00188893,  # addi s1, s1, 1
            # end:
        ],
        rf={6: 80, 8: 24, 10: 7, 11: 6, 18: 1, 19: 1, 20: 3, 21: 2, 22: 2, 23: 1},
        dmem={},
    ),
    # Test various loads and stores
    Program(
        name="mem1",
        instructions=[
            # main:
            0x00033537,  # lui a0, 0x33
            0xBFB50513,  # addi a0, a0, 0xbfb
            0x00E51513,  # slli a0, a0, 0xe
            0xABE50513,  # addi a0, a0, 0xabe
            0x10004593,  # xori a1, zero, 0x100
            0x00A5A023,  # sw a0, 0(a1)
            0x0005A603,  # lw a2, 0(a1)
            0x00C54433,  # xor s0, a0, a2
            0x00059603,  # lh a2, 0(a1)
            0x0005D683,  # lhu a3, 0(a1)
            0xFFF60613,  # addi a2, a2, -1
            0x00D636B3,  # sltu a3, a2, a3
            0x00D40433,  # add s0, s0, a3
            0x0025D603,  # lhu a2, 2(a1)
            0x01061693,  # slli a3, a2, 16
            0x0005D603,  # lhu a2, 0(a1)
            0x00C686B3,  # add a3, a3, a2
            0x00D546B3,  # xor a3, a0, a3
            0x00D40433,  # add s0, s0, a3
            0x00358603,  # lb a2, 3(a1)
            0x01861693,  # slli a3, a2, 24
            0x0025C603,  # lbu a2, 2(a1)
            0x01061613,  # slli a2, a2, 16
            0x00C686B3,  # add a3, a3, a2
            0x0005D603,  # lhu a2, 0(a1)
            0x00C686B3,  # add a3, a3, a2
            0x00D546B3,  # xor a3, a0, a3
            0x00D40433,  # add s0, s0, a3
            0x00358603,  # lb a2, 3(a1)
            0x00C5A223,  # sw a2, 4(a1)
            0x0025C603,  # lbu a2, 2(a1)
            0x00C59323,  # sh a2, 6(a1)
            0x0015C603,  # lbu a2, 1(a1)
            0x00C582A3,  # sb a2, 5(a1)
            0x0005C603,  # lbu a2, 0(a1)
            0x00C583A3,  # sb a2, 7(a1)
            # exit:
        ],
        rf={8: 0, 10: 0xCAFEBABE, 11: 0x100, 12: 190, 13: 0},
        dmem={0x40: 0xCAFEBABE, 0x41: 0xBEFEBACA},
    ),
    # Test loading/storing to dmem while branching
    Program(
        name="mem2",
        instructions=[
            # main:
            # for1: # The first loop stores 20 values in d_mem
            0x00000533,  # add a0, zero, zero
            0x01400593,  # addi a1, zero, 20
            # loop1:
            0x00B50C63,  # beq a0, a1, end1
            0x00255613,  # srai a2, a0, 2
            0x00560613,  # addi a2, a2, 5
            0x00C52023,  # sw a2, 0(a0)
            0x00450513,  # addi a0, a0, 4
            0xFEDFF06F,  # j loop1
            # end1:
            # for2: # The second loop copies the d_mem values and shifts them in memory
            0x00000533,  # add a0, zero, zero
            # loop2:
            0x00B50A63,  # beq a0, a1, end2
            0x00052703,  # lw a4, 0(a0)
            0x08E52023,  # sw a4, 128(a0)
            0x00450513,  # addi a0, a0, 4
            0xFF1FF06F,  # j loop2
            # end2:
            # exit:
        ],
        rf={10: 20, 11: 20, 12: 9, 14: 9},
        dmem={0: 5, 1: 6, 2: 7, 3: 8, 4: 9, 32: 5, 33: 6, 34: 7, 35: 8, 36: 9},
    ),
    # Test various data hazards
    Program(
        name="forward",
        instructions=[
            # main:
            0x01200513,  # addi a0, zero, 18
            0x00A02423,  # sw a0, 8(zero)
            0x008505B3,  # add a1, a0, s0
            0x00100693,  # addi a3, zero, 1
            0x01700713,  # addi a4, zero, 23
            0x40D58633,  # sub a2, a1, a3
            0x00E67433,  # and s0, a2, a4
            0x00C5E4B3,  # or s1, a1, a2
            0x00C60933,  # add s2, a2, a2
            0x012621A3,  # sw s2, 3(a2)
            0x01402783,  # lw a5, 20(zero)
            0x0007E833,  # or a6, a5, zero
            # exit:
        ],
        rf={
            8: 17,
            9: 19,
            10: 18,
            11: 18,
            12: 17,
            13: 1,
            14: 23,
            15: 34,
            16: 34,
            18: 34,
        },
        dmem={2: 18, 5: 34},
    ),
    # Test addition and branching by incrementing triangle numbers
    Program(
        name="triangle",
        instructions=[
            # main:
            0x29A00513,  # addi a0, zero, 666
            # loop:
            0x00C50863,  # beq a0, a2, end
            0x00158593,  # addi a1, a1, 1
            0x00B60633,  # add a2, a2, a1
            0xFF5FF06F,  # j loop
            # exit:
        ],
        rf={10: 666, 11: 36, 12: 666},
        dmem={},
    ),
    # Test jump
    Program(
        name="jump",
        instructions=[
            # loop:
            0x29A00513,  # addi a0, zero, 666
            0x00158593,  # addi a1, a1, 1
            0x29A00613,  # addi a2, zero, 666
            0xFF5FF06F,  # j loop
            # exit:
        ],
        rf={10: 666, 11: 51, 12: 666},
    ),
    # More sensible testcase for jump
    Program(
        name="jump-v2",
        instructions=[
            # loop:
            0x00100513,  # addi a0, zero, 0x1
            0x00550593,  # addi a1, a0, 0x5
            0x00a58633,  # add a2, a1, a0
            0x0080006f,  # j dest
            0x04500693,  # addi a3, zero, 0x45
            #dest:
            0x00c686b3,  #addi a3, a3, a2
            # exit:
        ],
        rf={10: 0x1, 11: 0x6, 12: 0x7, 13: 0x7},
    ),
    Program(
        name="cmov-true",
        instructions=[
            # main:
            0x01200593,  # addi    a1, zero, 0x12
            0x04500613,  # addi    a2, zero, 0x45
            0x00100693,  # addi    a3, zero, 0x01 #a3 is condition, here is true
            0x20C6A5B3,  # sh1add  a1, a3, a2
            # exit:
        ],
        rf={11: 0x45, 12: 0x45, 13: 0x01},
    ),
    # Test conditional mov when condition is false
    Program(
        name="cmov-false",
        instructions=[
            # main:
            0x01200593,  # addi    a1, zero, 0x12
            0x04500613,  # addi    a2, zero, 0x45
            0x00000693,  # addi    a3, zero, 0x00 #a3 is condition, here is false
            0x20C6A5B3,  # sh1add  a1, a3, a2
            # exit:
        ],
        rf={11: 0x12, 12: 0x45, 13: 0x00},
    ),
]

TEST_DIR = "test/bin/"
TEST_EXT = ".o"

# A set of riscv programs from openpiton
tests = []
for test in map(
    lambda f: splitext(f)[0],
    filter(
        lambda f: isfile(join(TEST_DIR, f)) and splitext(f)[-1] == TEST_EXT,
        listdir(TEST_DIR),
    ),
):
    with open(join(TEST_DIR, test + TEST_EXT), "rb") as test_file:
        tests.append(
            Program(
                name="inst_" + test,
                instructions=list(
                    map(
                        lambda x: (x[3] << 24) + (x[2] << 16) + (x[1] << 8) + x[0],
                        zip(*[iter(test_file.read())] * 4),
                    )
                ),
                check_pass=True,
            )
        )

if __name__ == "__main__":
    parser = ArgumentParser("Test the RISC-V CPU implementation.")
    parser.add_argument(
        "-s", "--stages", type=int, dest="stages", help="number of pipeline stages"
    )
    parser.add_argument(
        "-e",
        "--ext",
        type=str,
        dest="extension",
        help="ISA extension rv(i), zbk(b), zbk(c)",
    )
    parser.add_argument(
        "--test", type=str, dest="test", help="name of a specific test (all by default)"
    )
    parser.add_argument(
        "--debug", action="store_true", help="display memory on each cycle"
    )
    args = parser.parse_args()

    num_stages = args.stages if args.stages is not None else 1
    extension = args.extension if args.extension is not None else "i"

    # Instantiate the CPU design
    rv_cpu(num_stages=num_stages, isa=extension, holes=False, synth=True)

    print(f"Testing {num_stages}-stage RISC-V CPU design")
    
    sha256_test = Program(name="sha256", check_pass = True)

    sha256_test.execute(max_cycles=150000, debug=args.debug)
    """
    for program in benchmarks:
        if args.test is None or args.test == program.name:
            program.execute(max_cycles=256, debug=args.debug)

    for program in tests:
        if args.test is None or args.test == program.name:
            program.execute(max_cycles=4096, debug=args.debug)
    """
