import pyrtl
from enum import IntEnum

from .control import ImmType, Opcode


def insert_nop(fn7, rs2, rs1, fn3, rd, op, nop):
    return (
        pyrtl.mux(nop, fn7, pyrtl.Const(0, bitwidth=len(fn7))),
        pyrtl.mux(nop, rs2, pyrtl.Const(0, bitwidth=len(rs2))),
        pyrtl.mux(nop, rs1, pyrtl.Const(0, bitwidth=len(rs1))),
        pyrtl.mux(nop, fn3, pyrtl.Const(0, bitwidth=len(fn3))),
        pyrtl.mux(nop, rd, pyrtl.Const(0, bitwidth=len(rd))),
        pyrtl.mux(nop, op, pyrtl.Const(Opcode.REG, bitwidth=len(op))),
    )


def decode_inst(inst, nop=None):
    """Decodes fetched instruction, inserting a nop if a bubble is needed.

    :param inst: the input full encoded RISC-V instruction
    :param nop: a control signal indicating if a nop should be inserted
    :return: a tuple containing the components (funct7, rs2, rs1, funct3, rd, opcode)
    """

    # fetch inst and decode
    fn7, rs2, rs1, fn3, rd, op = pyrtl.chop(inst, 7, 5, 5, 3, 5, 7)

    if nop is None:
        return fn7, rs2, rs1, fn3, rd, op
    else:
        fn7, rs2, rs1, fn3, rd, op = insert_nop(fn7=fn7, rs2=rs2, rs1=rs1, fn3=fn3, rd=rd, op=op, nop=nop)
        return fn7, rs2, rs1, fn3, rd, op


def get_immediate(inst, imm_type):
    """Takes a RISC-V instruction and returns the sign-exteneded immediate value.

    Note that different RISC-V instruction types have different bits used as the immediate.
    Also, for the B type and J type instructions, the values are *already* shifted
    left on the output.

    See Volume 1 of the RISC-V Manual, Figures 2.3 and 2.4

    :param inst: the input full encoded RISC-V instruction
    :param imm_type: the immediate format of the instruction (R, I, S, etc.)
    :return: the output sign-extended immediate value encoded in the instruction
    """

    imm = pyrtl.WireVector(bitwidth=32, name="inst_imm")
    imm <<= pyrtl.enum_mux(
        imm_type,
        {
            ImmType.I: inst[20:].sign_extended(32),
            ImmType.S: pyrtl.concat(inst[25:], inst[7:12]).sign_extended(32),
            ImmType.B: pyrtl.concat(
                inst[31], inst[7], inst[25:31], inst[8:12], 0
            ).sign_extended(32),
            ImmType.U: pyrtl.concat(inst[12:], pyrtl.Const(0, bitwidth=12)),
            ImmType.J: pyrtl.concat(
                inst[31], inst[12:20], inst[20], inst[21:31], 0
            ).sign_extended(32),
        },
        default=0,
    )

    return imm
