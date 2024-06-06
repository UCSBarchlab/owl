import pyrtl

from .control import MaskMode
from .util import add_wire


def inst_memory(pc):
    """Instruction memory IOs:

    :param pc: the program counter
    :return inst_mem: a reference to the memory block
    :return inst: the fetched instruction (inst_mem[pc])
    """
    inst_mem = pyrtl.MemBlock(
        bitwidth=32, addrwidth=30, name="imem", asynchronous=True
    )

    # The addresses in instruction memory are word-addressable, while the addresses produced by
    # alu operations with the immediates, pcs, etc. are byte-addressable, so we need to shift
    # the address given by two to the right to get the word address
    inst = pyrtl.WireVector(bitwidth=32, name="inst")
    inst <<= inst_mem[pc[2:]]
    # inst <<= inst_mem[pyrtl.shift_right_logical(pc, 2)]
    return inst_mem, inst


def data_memory(addr, write_data, read, write, mask_mode, sign_ext):
    """The data memory

    :param addr: memory address to access
    :param write_data: data to write to addr
    :param mem_read: control signal for reading
    :param mem_write: control signal for writing
    :param mask_mode: inst[12:14] (i.e. lower two bits of fn3)
        0x10 means word (see lw/sw), 0x00 and 0x01 are byte, halfword respectively
    :param sign_ext: inst[14] (i.e. upper bit of funct3)
        1 means its lb/lh, 0 means its lbu/lhu

    :return: data read from addr
    """
    addr = add_wire(addr, bitwidth=32, name="mem_addr")
    write_data = add_wire(write_data, bitwidth=32, name="mem_write_data")
    read = add_wire(read, bitwidth=1, name="mem_read")
    write = add_wire(write, bitwidth=1, name="mem_write")
    mask_mode = add_wire(mask_mode, bitwidth=2, name="mem_mask_mode")
    sign_ext = add_wire(sign_ext, bitwidth=1, name="mem_sign_ext")

    data_mem = pyrtl.MemBlock(
        bitwidth=32, addrwidth=30, name="dmem", asynchronous=True
    )

    offset = addr[0:2]  # lower 2 bits determine if its byte 0, 1, 2, or 3 of word
    real_addr = addr[2:]
    read_data = data_mem[real_addr]

    # Store: write the particular byte/halfword/word to memory and maintain
    # the other bytes (in the class of byte/halfword) already present
    to_write = pyrtl.WireVector(len(write_data))
    with pyrtl.conditional_assignment:
        with mask_mode == MaskMode.BYTE:
            with offset == 0:
                to_write |= write_data[0:8].zero_extended(len(read_data)) \
                    | (~(pyrtl.Const("32'hff")) & read_data)
            with offset == 1:
                to_write |= pyrtl.concat(
                    write_data[0:8],
                    pyrtl.Const(0, bitwidth=8)).zero_extended(len(read_data)) \
                    | (~(pyrtl.Const("32'hff00")) & read_data)
            with offset == 2:
                to_write |= pyrtl.concat(
                    write_data[0:8],
                    pyrtl.Const(0, bitwidth=16)).zero_extended(len(read_data)) \
                    | (~(pyrtl.Const("32'hff0000")) & read_data)
            with pyrtl.otherwise:
                to_write |= pyrtl.concat(
                    write_data[0:8],
                    pyrtl.Const(0, bitwidth=24)).zero_extended(len(read_data)) \
                    | (~(pyrtl.Const("32'hff000000")) & read_data)
        with mask_mode == MaskMode.SHORT:
            with offset == 0:
                to_write |= write_data[0:16].zero_extended(len(read_data)) | (~(pyrtl.Const("32'hffff")) & read_data)
            with offset == 2:
                to_write |= pyrtl.concat(write_data[0:16], pyrtl.Const(0, bitwidth=16)) \
                    | (~(pyrtl.Const("32'hffff0000")) & read_data)
            with pyrtl.otherwise:  # illegal non-aligned write
                to_write |= read_data
        with pyrtl.otherwise:
            with offset == 0:
                to_write |= write_data
            with pyrtl.otherwise:
                to_write |= read_data

    data_mem[real_addr] <<= pyrtl.MemBlock.EnabledWrite(to_write, write)

    def data_ext(data, ext, width):
        return pyrtl.select(
            ext,
            data.sign_extended(width),
            data.zero_extended(width))

    # Load
    read_data_ext = pyrtl.WireVector(len(read_data), name="read_data_ext")
    with pyrtl.conditional_assignment:
        with mask_mode == MaskMode.BYTE:
            with offset == 0:
                read_data_ext |= data_ext(read_data[0:8], sign_ext, len(read_data))
            with offset == 1:
                read_data_ext |= data_ext(read_data[8:16], sign_ext, len(read_data))
            with offset == 2:
                read_data_ext |= data_ext(read_data[16:24], sign_ext, len(read_data))
            with pyrtl.otherwise:
                read_data_ext |= data_ext(read_data[24:32], sign_ext, len(read_data))
        with mask_mode == MaskMode.SHORT:
            with offset == 0:
                read_data_ext |= data_ext(read_data[0:16], sign_ext, len(read_data))
            with offset == 2:
                read_data_ext |= data_ext(read_data[16:32], sign_ext, len(read_data))
            with pyrtl.otherwise:
                read_data_ext |= pyrtl.Const(0, len(read_data))
        with pyrtl.otherwise:  # whole word, and sign-extending is meaningless
            read_data_ext |= pyrtl.select(
                offset == 0,
                read_data,
                pyrtl.Const(0, len(read_data)))

    return add_wire(read_data_ext, name="mem_data_read")
