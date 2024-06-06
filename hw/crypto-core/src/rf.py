import pyrtl

from .util import add_wire


def reg_file(rs1, rs2, rd, write_data, write):
    """Register file IOs:

    :param rs1: the number of the register to read
    :param rs2: the number of the register to read
    :param rd: the number of the register to write
    :param write_data: the data to write into R[rd]
    :param reg_write: write enable; if true, write the rd register
    :return rs1_val: the data in register number rs1 (R[rs1])
    :return rs2_val: the data in register number rs2 (R[rs2])

    Basic operation:
    - rs1_val = R[rs1]
    - rs2_val = R[rs2]
    - if (reg_write) R[rd] = write_data
    """
    rs1 = add_wire(rs1, bitwidth=5, name="rf_rs1")
    rs2 = add_wire(rs2, bitwidth=5, name="rf_rs2")
    rd = add_wire(rd, bitwidth=5, name="rf_rd")
    write_data = add_wire(write_data, bitwidth=32, name="rf_write_data")
    write = add_wire(write, bitwidth=1, name="rf_write")

    # PyRTL defaults to all memories having value 0. By disallowing
    # writing to the zero register with the condition in the EnabledWrite below,
    # the zero register is essentially hardwired to zero.

    # Read async, write sync
    # NOTE: When async=False, PyRTL complains about the read-addresses not being ready,
    # since it doesn't know at this point that they're Inputs or Registers
    rf = pyrtl.MemBlock(bitwidth=32, addrwidth=5, name="rf", asynchronous=True)
    rf[rd] <<= pyrtl.MemBlock.EnabledWrite(write_data, write & (rd != 0))

    rs1_val = pyrtl.WireVector(bitwidth=32, name="rf_rs1_val")
    rs2_val = pyrtl.WireVector(bitwidth=32, name="rf_rs2_val")
    rs1_val <<= pyrtl.select(rs1 == 0, pyrtl.Const(0, bitwidth=32), rf[rs1])
    rs2_val <<= pyrtl.select(rs2 == 0, pyrtl.Const(0, bitwidth=32), rf[rs2])

    return rs1_val, rs2_val
