import pyrtl
from enum import IntEnum

from .alu import alu_rvi, alu_zbkc, alu_zbkb
from .control import control, control_zbkb, control_holes, control_zbkb_holes, control_zbkc_holes, Opcode, RegWriteSrc, JumpTarget, ImmType
from .decode import insert_nop, decode_inst, get_immediate
from .mem import inst_memory, data_memory
from .rf import reg_file
from .util import add_register, add_wire

class ISA():
    RVI  = 'i'
    ZBKB = 'b'
    ZBKC = 'c'

def cpu(control=control, isa=ISA.RVI):
    pc = pyrtl.wire.Register(bitwidth=32, name="pc")  # program counter
    pc_plus_4 = add_wire(pc + 4, len(pc))  # program counter plus four

    # fetch inst and decode
    inst_mem, inst = inst_memory(pc=pc)
    inst_fn7, inst_rs2, inst_rs1, inst_fn3, inst_rd, inst_op = decode_inst(
        inst, nop=None
    )

    # define control block
    (
        cont_imm_type,  # (3) type of instruction (R, I, S, etc.)
        cont_jump,  # (1) unconditional jump is taken
        cont_target,  # (1) jump to immediate or alu_out
        cont_branch,  # (1) conditional branch is taken
        cont_branch_inv,  # (1) branch is taken if alu_out != 0
        cont_reg_write,  # (1) register rd is updated
        cont_reg_write_src,  # (1) write alu_out or pc+4 to rd
        cont_mem_write,  # (1) write to memory
        cont_mem_read,  # (1) read from memory
        cont_alu_imm,  # (1) alu_in2 from register or immediate
        cont_alu_pc,  # (1) alu_in1 from register or pc
        cont_alu_op,  # (4--5) alu operation to use
        cont_mask_mode,  # (2) whether to r/w byte, short, or word
        cont_mem_sign_ext,  # (1) zero extend read_data
    ) = control(op=inst_op, fn3=inst_fn3, fn7=inst_fn7, imm=inst[20:32]) if isa == ISA.ZBKB else \
        control(op=inst_op, fn3=inst_fn3, fn7=inst_fn7)

    # parse immediate
    inst_imm = get_immediate(inst, cont_imm_type)

    # register file
    reg_write_data = pyrtl.WireVector(bitwidth=32)
    rs1_val, rs2_val = reg_file(
        rs1=inst_rs1,
        rs2=inst_rs2,
        rd=inst_rd,
        write_data=reg_write_data,
        write=cont_reg_write | cont_mem_read,  # if read memory, always write
    )

    # alu block
    if isa == ISA.RVI:
        alu_out = alu_rvi(
            op=cont_alu_op,
            in1=pyrtl.mux(cont_alu_pc, rs1_val, pc),
            in2=pyrtl.mux(cont_alu_imm, rs2_val, inst_imm),
        )
    elif isa == ISA.ZBKC:
        alu_out = alu_zbkc(
            op=cont_alu_op,
            in1=pyrtl.mux(cont_alu_pc, rs1_val, pc),
            in2=pyrtl.mux(cont_alu_imm, rs2_val, inst_imm),
        )
    elif isa == ISA.ZBKB:
        alu_out = alu_zbkb(
            op=cont_alu_op,
            in1=pyrtl.mux(cont_alu_pc, rs1_val, pc),
            in2=pyrtl.mux(cont_alu_imm, rs2_val, inst_imm),
        )

    # data memory
    read_data = data_memory(
        addr=alu_out,
        write_data=rs2_val,
        read=cont_mem_read,
        write=cont_mem_write,
        mask_mode=cont_mask_mode,
        sign_ext=cont_mem_sign_ext,
    )

    # write to register file
    reg_write_data <<= pyrtl.mux(
        cont_mem_read,
        pyrtl.enum_mux(
            cont_reg_write_src, {RegWriteSrc.ALU: alu_out, RegWriteSrc.PC: pc_plus_4}
        ),
        read_data,
    )

    # update pc
    taken = add_wire(
        cont_jump | (cont_branch & ((alu_out == 0) ^ cont_branch_inv)), name="taken"
    )
    target = pyrtl.enum_mux(
        cont_target,
        {JumpTarget.IMM: (pc + inst_imm), JumpTarget.ALU: alu_out}
    )
    with pyrtl.conditional_assignment:
        with taken:
            pc.next |= target
        with pyrtl.otherwise:
            pc.next |= pc_plus_4

    return inst_mem  # return ref to instruction memory unit

################################################################################
# Two stager, "easier" (branch resolution in stage 1)
################################################################################
def cpu_two_stage(control=control, isa=ISA.RVI):

    ############################################################################
    # Stage 1: Instruction fetch, decode, execute
    ############################################################################

    pc = pyrtl.Register(bitwidth=32, name="pc")  # program counter
    next_pc = pyrtl.Register(bitwidth=32, name='next_pc')
    pc_plus_4 = add_wire(next_pc + 4, len(next_pc))  # program counter plus four

    # I added this output to prevent `pc` from being optimized out.
    arch_pc = pyrtl.Output(bitwidth=32, name="arch_pc")
    arch_pc <<= pc

    # fetch inst and decode
    inst_mem, inst = inst_memory(pc=next_pc)
    inst_fn7, inst_rs2, inst_rs1, inst_fn3, inst_rd, inst_op = decode_inst(
        inst, nop=None
    )

    # define control block
    (
        cont_imm_type,  # (3) type of instruction (R, I, S, etc.)
        cont_jump,  # (1) unconditional jump is taken
        cont_target,  # (1) jump to immediate or alu_out
        cont_branch,  # (1) conditional branch is taken
        cont_branch_inv,  # (1) branch is taken if alu_out != 0
        cont_reg_write,  # (1) register rd is updated
        cont_reg_write_src,  # (1) write alu_out or pc+4 to rd
        cont_mem_write,  # (1) write to memory
        cont_mem_read,  # (1) read from memory
        cont_alu_imm,  # (1) alu_in2 from register or immediate
        cont_alu_pc,  # (1) alu_in1 from register or pc
        cont_alu_op,  # (4--5) alu operation to use
        cont_mask_mode,  # (2) whether to r/w byte, short, or word
        cont_mem_sign_ext,  # (1) zero extend read_data
    ) = control(op=inst_op, fn3=inst_fn3, fn7=inst_fn7, imm=inst[20:32]) if isa == ISA.ZBKB else \
        control(op=inst_op, fn3=inst_fn3, fn7=inst_fn7)

    # parse immediate
    inst_imm = get_immediate(inst, cont_imm_type)

    # register file
    reg_write_data = pyrtl.WireVector(bitwidth=32, name='reg_write_data')
    wb_rd = pyrtl.Register(name='wb_rd', bitwidth=5)
    wb_reg_write_enable = pyrtl.Register(name='wb_reg_write_enable', bitwidth=1)
    rs1_val, rs2_val = reg_file(
        rs1=inst_rs1,
        rs2=inst_rs2,
        # Stage 2 (Write Back):
        rd=wb_rd,
        write_data=reg_write_data,
        write=wb_reg_write_enable,
    )

    # forwarding
    rs1_val = pyrtl.select(
        wb_reg_write_enable & (wb_rd == inst_rs1) & (wb_rd != 0),
        reg_write_data,
        rs1_val)

    rs2_val = pyrtl.select(
        wb_reg_write_enable & (wb_rd == inst_rs2) & (wb_rd != 0),
        reg_write_data,
        rs2_val)

    # alu
    if isa == ISA.RVI:
        alu_out = alu_rvi(
            op=cont_alu_op,
            in1=pyrtl.mux(cont_alu_pc, rs1_val, next_pc),
            in2=pyrtl.mux(cont_alu_imm, rs2_val, inst_imm),
        )
    elif isa == ISA.ZBKC:
        alu_out = alu_zbkc(
            op=cont_alu_op,
            in1=pyrtl.mux(cont_alu_pc, rs1_val, next_pc),
            in2=pyrtl.mux(cont_alu_imm, rs2_val, inst_imm),
        )
    elif isa == ISA.ZBKB:
        alu_out = alu_zbkb(
            op=cont_alu_op,
            in1=pyrtl.mux(cont_alu_pc, rs1_val, next_pc),
            in2=pyrtl.mux(cont_alu_imm, rs2_val, inst_imm),
        )

    # compute next pc
    taken = add_wire(
        cont_jump | (cont_branch & ((alu_out == 0) ^ cont_branch_inv)), name="taken"
    )
    target = pyrtl.enum_mux(
        cont_target, {JumpTarget.IMM: next_pc + inst_imm, JumpTarget.ALU: alu_out}
    )
    instruction_commit = pyrtl.Register(name='instruction_commit', bitwidth=1)
    with pyrtl.conditional_assignment:
        with taken:
            next_pc.next |= target
            instruction_commit.next |= 1
        with pyrtl.otherwise:
            next_pc.next |= pc_plus_4
            instruction_commit.next |= 1

    wb_cont_mem_read = pyrtl.Register(name='wb_cont_mem_read', bitwidth=1)
    wb_cont_mem_write = pyrtl.Register(name='wb_cont_mem_write', bitwidth=1)
    wb_cont_mem_sign_ext = pyrtl.Register(name='wb_cont_mem_sign_ext', bitwidth=1)
    wb_cont_mask_mode = pyrtl.Register(name='wb_cont_mask_mode', bitwidth=2)
    wb_reg_write_data = pyrtl.Register(name='wb_reg_write_data', bitwidth=32)
    wb_mem_address = pyrtl.Register(name='wb_mem_address', bitwidth=32)
    wb_mem_write_data = pyrtl.Register(name='wb_mem_write_data', bitwidth=32)

    wb_cont_mem_read.next <<= cont_mem_read
    wb_cont_mem_write.next <<= cont_mem_write
    wb_cont_mem_sign_ext.next <<= cont_mem_sign_ext
    wb_cont_mask_mode.next <<= cont_mask_mode

    wb_rd.next <<= inst_rd
    wb_reg_write_data.next <<= pyrtl.enum_mux(
        cont_reg_write_src, {RegWriteSrc.ALU: alu_out, RegWriteSrc.PC: pc_plus_4}
    )
    wb_reg_write_enable.next <<= cont_reg_write | cont_mem_read

    wb_mem_address.next <<= alu_out
    wb_mem_write_data.next <<= rs2_val

    ############################################################################
    # Stage 2: Memory and Write Back (wb)
    ############################################################################

    # data memory
    read_data = data_memory(
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
            pc.next |= next_pc

    return inst_mem  # return ref to instruction memory unit

################################################################################
# Two stager, "harder" (branch resolution in stage 2).
# More similar to Ibex 2-stage.
################################################################################
def cpu_two_stage_ibex(control=control, isa=ISA.RVI):

    ############################################################################
    # Stage 1: Instruction fetch (f)
    ############################################################################

    # program counter
    pc = pyrtl.Register(bitwidth=32, name="pc")
    # Instruction fetch stage PC
    f_pc = pyrtl.Register(bitwidth=32, name="f_pc")

    # I added this output to prevent `pc` from being optimized out.
    arch_pc = pyrtl.Output(bitwidth=32, name="arch_pc")
    arch_pc <<= pc

    # fetch inst
    inst_mem, inst = inst_memory(pc=f_pc)
    pc_plus_4 = add_wire(f_pc + 4, len(f_pc))

    # pipeline registers
    x_inst = pyrtl.Register(bitwidth=32, name="x_inst")
    x_pc = pyrtl.Register(bitwidth=32, name="x_pc")
    x_pc_plus_4 = pyrtl.Register(bitwidth=32, name="x_pc_plus_4")

    ctrl_hazard = pyrtl.WireVector(bitwidth=1, name='ctrl_hazard')
    x_inst.next <<= pyrtl.select(
        ctrl_hazard,
        pyrtl.Const(19, bitwidth=len(inst)), # nop
        inst)
    x_pc.next <<= f_pc
    x_pc_plus_4.next <<= pc_plus_4

    branch_target = pyrtl.WireVector(bitwidth=32, name='branch_target')
    with pyrtl.conditional_assignment:
        with ctrl_hazard:
            f_pc.next |= branch_target
        with pyrtl.otherwise:
            f_pc.next |= pc_plus_4

    ############################################################################
    # Stage 2: Decode, Execute, Memory and Write Back (x)
    ############################################################################

    # decode
    inst_fn7, inst_rs2, inst_rs1, inst_fn3, inst_rd, inst_op = decode_inst(
        x_inst, nop=None
    )

    # define control block
    (
        cont_imm_type,  # (3) type of instruction (R, I, S, etc.)
        cont_jump,  # (1) unconditional jump is taken
        cont_target,  # (1) jump to immediate or alu_out
        cont_branch,  # (1) conditional branch is taken
        cont_branch_inv,  # (1) branch is taken if alu_out != 0
        cont_reg_write,  # (1) register rd is updated
        cont_reg_write_src,  # (1) write alu_out or pc+4 to rd
        cont_mem_write,  # (1) write to memory
        cont_mem_read,  # (1) read from memory
        cont_alu_imm,  # (1) alu_in2 from register or immediate
        cont_alu_pc,  # (1) alu_in1 from register or pc
        cont_alu_op,  # (4--5) alu operation to use
        cont_mask_mode,  # (2) whether to r/w byte, short, or word
        cont_mem_sign_ext,  # (1) zero extend read_data
    ) = control(op=inst_op, fn3=inst_fn3, fn7=inst_fn7, imm=inst[20:32]) if isa == ISA.ZBKB else \
        control(op=inst_op, fn3=inst_fn3, fn7=inst_fn7)

    # parse immediate
    inst_imm = get_immediate(x_inst, cont_imm_type)

    # register file
    reg_write_data = pyrtl.WireVector(bitwidth=32, name='reg_write_data')
    reg_write_enable = pyrtl.WireVector(name='reg_write_enable', bitwidth=1)
    rs1_val, rs2_val = reg_file(
        rs1=inst_rs1,
        rs2=inst_rs2,
        rd=inst_rd,
        write_data=reg_write_data,
        write=reg_write_enable,
    )

    # alu
    if isa == ISA.RVI:
        alu_out = alu_rvi(
            op=cont_alu_op,
            in1=pyrtl.mux(cont_alu_pc, rs1_val, x_pc),
            in2=pyrtl.mux(cont_alu_imm, rs2_val, inst_imm),
        )
    elif isa == ISA.ZBKC:
        alu_out = alu_zbkc(
            op=cont_alu_op,
            in1=pyrtl.mux(cont_alu_pc, rs1_val, x_pc),
            in2=pyrtl.mux(cont_alu_imm, rs2_val, inst_imm),
        )
    elif isa == ISA.ZBKB:
        alu_out = alu_zbkb(
            op=cont_alu_op,
            in1=pyrtl.mux(cont_alu_pc, rs1_val, x_pc),
            in2=pyrtl.mux(cont_alu_imm, rs2_val, inst_imm),
        )

    # compute next pc
    taken = add_wire(
        cont_jump | (cont_branch & ((alu_out == 0) ^ cont_branch_inv)), name="taken"
    )
    target = pyrtl.enum_mux(
        cont_target, {JumpTarget.IMM: x_pc + inst_imm, JumpTarget.ALU: alu_out}
    )
    ctrl_hazard <<= taken
    branch_target <<= target
    with pyrtl.conditional_assignment:
        with taken:
            pc.next |= target
        with pyrtl.otherwise:
            pc.next |= x_pc_plus_4

    reg_write_enable <<= cont_reg_write | cont_mem_read

    # data memory
    read_data = data_memory(
        addr=alu_out,
        write_data=rs2_val,
        read=cont_mem_read,
        write=cont_mem_write,
        mask_mode=cont_mask_mode,
        sign_ext=cont_mem_sign_ext,
    )

    # compute reg write data
    reg_write_data <<= pyrtl.mux(
        cont_mem_read,
        pyrtl.enum_mux(
            cont_reg_write_src, {RegWriteSrc.ALU: alu_out, RegWriteSrc.PC: x_pc_plus_4}
        ),
        read_data,
    )

    return inst_mem  # return ref to instruction memory unit

def rv_cpu(num_stages=1, isa=ISA.RVI, holes=False):
    selected_control = control
    if isa == ISA.RVI and holes:
        selected_control = control_holes
    elif isa == ISA.ZBKB and holes:
        selected_control = control_zbkb_holes
    elif isa == ISA.ZBKB and not holes:
        selected_control = control_zbkb
    elif isa == ISA.ZBKC and holes:
        selected_control = control_zbkc_holes
    else:
        selected_control = control

    if num_stages == 1:
        return cpu(control=selected_control, isa=isa)
    elif num_stages == 2:
        return cpu_two_stage(control=selected_control, isa=isa)
    elif num_stages == 11:
        return cpu(control=control_op_holes, isa=isa)
    elif num_stages == 12:
        return cpu_two_stage_ibex(control=selected_control, isa=isa)
    else:
        raise ValueError("invalid number of pipeline stages")
