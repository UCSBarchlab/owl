import pyrtl
from functools import reduce

from .control import ALUOp
from .util import add_wire

def count_ones(w):
    return reduce(pyrtl.corecircuits._basic_add, w, pyrtl.Const(0, len(w)))

def count_zeroes_from_end(x, end):
    def f(accum, x):
        found, count = accum
        is_zero = x == 0
        to_add = ~found & is_zero
        count = count + to_add
        return (found | ~is_zero, count)
    xs = pyrtl.mux(end, x[::-1], x)
    return reduce(f, xs, (pyrtl.as_wires(False), 0))[1]

def clmul(rs1, rs2):
    rs1, rs2 = pyrtl.match_bitwidth(rs1, rs2)
    w = len(rs1)
    prod = [pyrtl.select(rs2[i],\
            pyrtl.shift_left_logical(rs1, i) if i else rs1,\
            pyrtl.Const(0,bitwidth=w)) for i in range(0, w)]
    return reduce(lambda x,y: x ^ y, prod, pyrtl.Const(0,bitwidth=w))

def clmulh(rs1, rs2):
    rs1, rs2 = pyrtl.match_bitwidth(rs1, rs2)
    w = len(rs1)
    prod = [pyrtl.select(rs2[i],\
            pyrtl.shift_right_logical(rs1, (w - i)),\
            pyrtl.Const(0,bitwidth=w)) for i in range(1, w)]
    return reduce(lambda x,y: x ^ y, prod, pyrtl.Const(0,bitwidth=w))

def rotatel(a, b):
    #return pyrtl.shift_right_logical(pyrtl.concat(a, a), len(a) - b)[:len(a)]
    #return pyrtl.shift_left_logical(a, b) | pyrtl.shift_right_logical(a, len(a) - b)
    w = len(a)
    shamt = b & (w -1)
    return pyrtl.shift_left_logical(a, shamt) | pyrtl.shift_right_logical(a, ((w - shamt) & (w -1)))

def rotater(a, b):
    return pyrtl.shift_right_logical(pyrtl.concat(a, a), b)[:32]

def zip32(a):
    result = {}
    for i in range(16):
        result[i * 2] = a[i]
        result[i*2 + 1] = a[i + 16]
    return pyrtl.concat_list([result[i] for i in range(32)])

def unzip32(a):
    result = {}
    for i in range(16):
        result[i] = a[i * 2]
        result[i + 16] = a[(i * 2) + 1]
    return pyrtl.concat_list([result[i] for i in range(32)])

def revb(a):
    result = {}
    for i in range(0, 32, 8):
        result[i] = pyrtl.concat_list([a[i] for i in range(i+7,i-1,-1)])
    return pyrtl.concat_list([result[0], result[8], result[16], result[24]])

def rev8(a):
    return pyrtl.concat(a[0:8], a[8:16], a[16:24], a[24:32])

def alu_rvi(op, in1, in2):
    """The ALU logic for the RV processor

    :param alu_op: the operation the ALU should perform
    :param alu_in1: the first input
    :param alu_in2: the second input

    :return: the result of the computation
    """
    op = add_wire(op, bitwidth=4, name="alu_op")
    in1 = add_wire(in1, bitwidth=32, name="alu_in1")
    in2 = add_wire(in2, bitwidth=32, name="alu_in2")

    out = pyrtl.WireVector(bitwidth=32, name="alu_out")
    out <<= pyrtl.enum_mux(
        op,
        {
            ALUOp.ADD: in1 + in2,
            ALUOp.SUB: in1 - in2,
            ALUOp.SLL: pyrtl.shift_left_logical(in1, in2[0:5]),
            ALUOp.SLT: pyrtl.signed_lt(in1, in2),
            ALUOp.SLTU: in1 < in2,
            ALUOp.XOR: in1 ^ in2,
            ALUOp.SRL: pyrtl.shift_right_logical(in1, in2[0:5]),
            ALUOp.SRA: pyrtl.shift_right_arithmetic(in1, in2[0:5]),
            ALUOp.OR: in1 | in2,
            ALUOp.AND: in1 & in2,
            ALUOp.IMM: in2,
        },
        default=0,
    )

    return out

def alu_zbkc(op, in1, in2):
    """The ALU logic for the RV processor

    :param alu_op: the operation the ALU should perform
    :param alu_in1: the first input
    :param alu_in2: the second input

    :return: the result of the computation
    """
    op = add_wire(op, bitwidth=5, name="alu_op")
    in1 = add_wire(in1, bitwidth=32, name="alu_in1")
    in2 = add_wire(in2, bitwidth=32, name="alu_in2")

    out = pyrtl.WireVector(bitwidth=32, name="alu_out")
    out <<= pyrtl.enum_mux(
        op,
        {
            ALUOp.ADD: in1 + in2,
            ALUOp.SUB: in1 - in2,
            ALUOp.SLL: pyrtl.shift_left_logical(in1, in2[0:5]),
            ALUOp.SLT: pyrtl.signed_lt(in1, in2),
            ALUOp.SLTU: in1 < in2,
            ALUOp.XOR: in1 ^ in2,
            ALUOp.SRL: pyrtl.shift_right_logical(in1, in2[0:5]),
            ALUOp.SRA: pyrtl.shift_right_arithmetic(in1, in2[0:5]),
            ALUOp.OR: in1 | in2,
            ALUOp.AND: in1 & in2,
            ALUOp.IMM: in2,
            ALUOp.CLMUL: clmul(in1, in2),
            ALUOp.CLMULH: clmulh(in1, in2),
        },
        default=0,
    )

    return out

def alu_zbkb(op, in1, in2):
    """The ALU logic for the RV processor

    :param alu_op: the operation the ALU should perform
    :param alu_in1: the first input
    :param alu_in2: the second input

    :return: the result of the computation
    """
    op = add_wire(op, bitwidth=5, name="alu_op")
    in1 = add_wire(in1, bitwidth=32, name="alu_in1")
    in2 = add_wire(in2, bitwidth=32, name="alu_in2")

    out = pyrtl.WireVector(bitwidth=32, name="alu_out")
    out <<= pyrtl.enum_mux(
        op,
        {
            ALUOp.ADD: in1 + in2,
            ALUOp.SUB: in1 - in2,
            ALUOp.SLL: pyrtl.shift_left_logical(in1, in2[0:5]),
            ALUOp.SLT: pyrtl.signed_lt(in1, in2),
            ALUOp.SLTU: in1 < in2,
            ALUOp.XOR: in1 ^ in2,
            ALUOp.SRL: pyrtl.shift_right_logical(in1, in2[0:5]),
            ALUOp.SRA: pyrtl.shift_right_arithmetic(in1, in2[0:5]),
            ALUOp.OR: in1 | in2,
            ALUOp.AND: in1 & in2,
            ALUOp.IMM: in2,
            ALUOp.ROR: rotater(in1, in2[0:5]),
            ALUOp.ROL: rotatel(in1, in2[0:5]),
            ALUOp.ANDN: in1 & ~(in2), # add control sig to invert ALU input
            ALUOp.ORN: in1 | ~(in2),  # and reuse existing AND or OR
            ALUOp.XNOR: ~(in1 ^ in2),
            ALUOp.PACK: pyrtl.concat(in2[0:16], in1[0:16]),
            ALUOp.PACKH: pyrtl.concat(in2[0:8], in1[0:8]).zero_extended(32),
            ALUOp.ZIP: zip32(in1),
            ALUOp.UNZIP: unzip32(in1),
            ALUOp.REV8: rev8(in1),
            ALUOp.REVB: revb(in1),
            #ALUOp.CZ: count_zeroes_from_end(in1, in2[0]),
            #ALUOp.CPOP: count_ones(in1),
        },
        default=0,
    )

    return out
