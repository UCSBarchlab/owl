import pyrtl
from enum import IntEnum

from .alu import alu
from .control import (
    control,
    Opcode,
    RegWriteSrc,
    JumpTarget,
    ImmType,
)
from .decode import insert_nop, decode_inst, get_immediate
from .mem import inst_memory, data_memory
from .rf import reg_file
from .util import add_register, add_wire


################################################################################
# Three stage (IF|ID EX|MEM WB)
################################################################################
def cpu_three_stage_cmov(control=control):
    ############################################################################
    # Stage 1: Instruction fetch
    ############################################################################
    taken_wire = pyrtl.wire.WireVector(bitwidth=1, name="taken_wire")
    inst_pipelined = pyrtl.Register(bitwidth=32, name="inst_pipelined")

    # program counter
    pc = pyrtl.Register(bitwidth=32, name="pc")

    fetch_pc = pyrtl.Register(bitwidth=32, name="fetch_pc")
    decode_pc = pyrtl.Register(bitwidth=32, name="decode_pc")
    wb_pc = pyrtl.Register(bitwidth=32, name="wb_pc")

    if_idex_valid = pyrtl.Register(bitwidth=1, name="if_idex_valid")

    decode_pc.next <<= fetch_pc

    # I added this output to prevent `pc` from being optimized out.
    arch_pc = pyrtl.Output(bitwidth=32, name="arch_pc")
    arch_pc <<= pc

    # fetch inst and decode
    inst_mem, inst = inst_memory(pc=fetch_pc)

    # for jump and other instructions
    target = pyrtl.WireVector(bitwidth=32, name="target")
    with pyrtl.conditional_assignment:
        with taken_wire:
            inst_pipelined.next |= 0x00000013
            if_idex_valid.next |= 0x00
            fetch_pc.next |= target
        with pyrtl.otherwise:
            inst_pipelined.next |= inst
            fetch_pc.next |= fetch_pc + 4
            if_idex_valid.next |= 0x01

    # inst_pipelined.next <<= inst

    ############################################################################
    # Stage 2: Instruction decode
    ############################################################################
    inst_fn7, inst_rs2, inst_rs1, inst_fn3, inst_rd, inst_op = decode_inst(
        inst_pipelined, nop=None
    )

    # define control block
    (
        cont_imm_type,  # (3) type of instruction (R, I, S, etc.)
        cont_jump,  # (1) unconditional jump is taken
        cont_target,  # (1) jump to immediate or alu_out
        cont_reg_write,  # (1) register rd is updated
        cont_reg_write_src,  # (1) write alu_out or pc+4 to rd
        cont_mem_write,  # (1) write to memory
        cont_mem_read,  # (1) read from memory
        cont_alu_imm,  # (1) alu_in2 from register or immediate
        cont_alu_pc,  # (1) alu_in1 from register or pc
        cont_alu_op,  # (4--5) alu operation to use
        cont_mask_mode,  # (2) whether to r/w byte, short, or word
        cont_mem_sign_ext,  # (1) zero extend read_data
        cont_is_cmov,  # (1) control signal for conditional move(cmov)
    ) = control(op=inst_op, fn3=inst_fn3, fn7=inst_fn7)

    # parse immediate
    inst_imm = get_immediate(inst_pipelined, cont_imm_type)

    # register file
    reg_write_data = pyrtl.WireVector(bitwidth=32, name="reg_write_data")
    wb_rd = pyrtl.Register(name="wb_rd", bitwidth=5)
    wb_reg_write_enable = pyrtl.Register(name="wb_reg_write_enable", bitwidth=1)
    rs1_val, rs2_val = reg_file(
        rs1=inst_rs1,
        rs2=inst_rs2,
        # Stage 2 (Write Back):
        rd=wb_rd,
        write_data=reg_write_data,
        write=wb_reg_write_enable,
    )

    is_data_hazard_rs1 = pyrtl.Output(bitwidth=1, name="is_data_hazard_rs1")
    is_data_hazard_rs2 = pyrtl.Output(bitwidth=1, name="is_data_hazard_rs2")
    data_hazard_output = pyrtl.Output(bitwidth=32, name="data_hazard_output")
    is_data_hazard_rs1 <<= wb_reg_write_enable & (wb_rd == inst_rs1) & (wb_rd != 0)
    is_data_hazard_rs2 <<= wb_reg_write_enable & (wb_rd == inst_rs2) & (wb_rd != 0)
    data_hazard_output <<= reg_write_data

    # forwarding
    rs1_val = pyrtl.select(
        wb_reg_write_enable & (wb_rd == inst_rs1) & (wb_rd != 0),
        reg_write_data,
        rs1_val,
    )

    rs2_val = pyrtl.select(
        wb_reg_write_enable & (wb_rd == inst_rs2) & (wb_rd != 0),
        reg_write_data,
        rs2_val,
    )

    # cmov
    alu_in2 = pyrtl.WireVector(bitwidth=32, name="alu_in2_cmov")
    with pyrtl.conditional_assignment:
        with cont_is_cmov:
            alu_in2 |= 1
        with pyrtl.otherwise:
            alu_in2 |= rs2_val

    # alu
    alu_out = alu(
            op=cont_alu_op,
            in1=pyrtl.mux(cont_alu_pc, rs1_val, decode_pc),
            in2=pyrtl.mux(cont_alu_imm, alu_in2, inst_imm),
    )

    # compute next pc
    taken = add_wire(
        cont_jump, name="taken"  # | (cont_branch & ((alu_out == 0) ^ cont_branch_inv)),
    )
    taken_wire <<= taken
    target <<= pyrtl.enum_mux(
        cont_target, {JumpTarget.IMM: decode_pc + inst_imm, JumpTarget.ALU: alu_out}
    )
    instruction_commit = pyrtl.Register(name="instruction_commit", bitwidth=1)
    """
    with pyrtl.conditional_assignment:
        with taken:
            wb_pc.next |= target
            instruction_commit.next |= 1
        with pyrtl.otherwise:
            wb_pc.next |= decode_pc + 4
            instruction_commit.next |= 1
    """
    with pyrtl.conditional_assignment:
        with if_idex_valid:
            wb_pc.next |= decode_pc
            instruction_commit.next |= if_idex_valid
        with pyrtl.otherwise:
            wb_pc.next |= wb_pc
            instruction_commit.next |= 0x00

    wb_cont_mem_read = pyrtl.Register(name="wb_cont_mem_read", bitwidth=1)
    wb_cont_mem_write = pyrtl.Register(name="wb_cont_mem_write", bitwidth=1)
    wb_cont_mem_sign_ext = pyrtl.Register(name="wb_cont_mem_sign_ext", bitwidth=1)
    wb_cont_mask_mode = pyrtl.Register(name="wb_cont_mask_mode", bitwidth=2)
    wb_reg_write_data = pyrtl.Register(name="wb_reg_write_data", bitwidth=32)
    wb_mem_address = pyrtl.Register(name="wb_mem_address", bitwidth=32)
    wb_mem_write_data = pyrtl.Register(name="wb_mem_write_data", bitwidth=32)

    wb_cont_mem_read.next <<= cont_mem_read
    wb_cont_mem_write.next <<= cont_mem_write
    wb_cont_mem_sign_ext.next <<= cont_mem_sign_ext
    wb_cont_mask_mode.next <<= cont_mask_mode

    wb_rd.next <<= inst_rd

    # for CMOV
    cont_alu_out = pyrtl.WireVector(bitwidth=1, name="cont_alu_out")
    alu_out_cmov = pyrtl.WireVector(bitwidth=32, name="alu_out_cmov")
    # for write back enable
    # (rs1 < 1) ? rd : rs2
    with pyrtl.conditional_assignment:
        with alu_out == 1:
            # rd := rd
            # skip write back
            cont_alu_out |= 0
        with pyrtl.otherwise:
            # rd := rs2
            # enable write back
            cont_alu_out |= 1

    # for wb_reg_write_data
    # alu_out_cmov will have the value of rs2_val or the original alu_out
    # depending on which instruction we are executing
    with pyrtl.conditional_assignment:
        with cont_is_cmov:
            alu_out_cmov |= pyrtl.select(
                cont_alu_out,
                rs2_val,
                reg_write_data,  # might not be the correct data but we don't care because wb won't be enabled
            )
        # for other instructions
        with pyrtl.otherwise:
            alu_out_cmov |= alu_out

    wb_reg_write_data.next <<= pyrtl.enum_mux(
        cont_reg_write_src,
        {RegWriteSrc.ALU: alu_out_cmov, RegWriteSrc.PC: decode_pc + 4},
    )
    wb_reg_write_enable.next <<= (
        cont_reg_write | cont_mem_read | (cont_is_cmov & cont_alu_out)
    )

    wb_mem_address.next <<= alu_out
    wb_mem_write_data.next <<= rs2_val

    ############################################################################
    # Stage 3: Memory and Write Back (wb)
    ############################################################################

    # data memory
    read_data = pyrtl.WireVector(bitwidth=32, name="read_data")
    read_data <<= data_memory(
        addr=wb_mem_address,
        write_data=wb_mem_write_data,
        read=wb_cont_mem_read,
        write=wb_cont_mem_write,
        mask_mode=wb_cont_mask_mode,
        sign_ext=wb_cont_mem_sign_ext,
    )

    # compute reg write data
    reg_write_data <<= pyrtl.mux(
        wb_cont_mem_read,
        wb_reg_write_data,
        read_data,
    )

    # update architectural pc
    with pyrtl.conditional_assignment:
        with instruction_commit:
            pc.next |= wb_pc
        with pyrtl.otherwise:
            pc.next |= pc

    return inst_mem  # return ref to instruction memory unit


