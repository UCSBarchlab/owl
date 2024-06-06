import pyrtl
from functools import reduce

from .control import ALUOp
from .util import add_wire


def alu(op, in1, in2):
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

