import pyrtl

# Given a PyRTL Block, gathers all components and generates Oyster IR
def generate_ir(block, block_name="sketch"):

    var = dict() # var name -> uint
    vid = 0
    decls = []
    #hole_inputs = []
    hole_inputs = dict()
    stmts = []

    for i in block.wirevector_subset(pyrtl.Input):
        # decls.append("({} (INPUT {} \"{}\"))".format(vid, i.bitwidth, i.name))
        var[i.name] = vid
        vid += 1

    for o in block.wirevector_subset(pyrtl.Output):
        decls.append("({} (OUTPUT {} \"{}\"))".format(vid, o.bitwidth, o.name))
        var[o.name] = vid
        vid += 1

    for r in block.wirevector_subset(pyrtl.Register):
        defaultval = r.reset_value if r.reset_value else 0
        decls.append("({} (REGISTER {} {} \"{}\"))".format(vid, r.bitwidth, defaultval, r.name))
        var[r.name] = vid
        vid += 1

    #for h in block.wirevector_subset(pyrtl.Hole):
    #    decls.append("({} (HOLE {} \"{}\"))".format(vid, h.bitwidth, h.name))
    #    var[h.name] = vid
    #    vid += 1

    for m in block.logic_subset('m@'):
        name = m.op_param[1].name
        if name in var:
            continue
        bitw = m.args[1].bitwidth if m.op == '@' else m.dests[0].bitwidth
        addrw = m.args[0].bitwidth
        if isinstance(m.op_param[1], pyrtl.RomBlock):
            data = " ".join(['(??)'] * 2**int(m.args[0].bitwidth)) if callable(m.op_param[1].data) \
                          else " ".join([str(x) for x in m.op_param[1].data])
            decls.append("({} (ROM {} {} (list {}) \"{}\"))".format(vid, bitw, addrw, data, name))
        elif isinstance(m.op_param[1], pyrtl.MemBlock):
            decls.append("({} (MEMORY {} {} \"{}\"))".format(vid, bitw, addrw, name))
        var[name] = vid
        vid += 1

    for c in block.wirevector_subset(pyrtl.Const):
        #const = str(c)
        #val = const[const.rfind('_') + 1:const.find('/')]
        #if "'b" in val:
        #    val = val[:val.find("'b")]
        #stmts.append("({} (CONST {} {}))".format(vid, val, c.bitwidth))
        #var[c.name] = vid
        #vid += 1
        var[c.name] = "(CONST {} {})".format(c.val, c.bitwidth)

    simple_func = {
        'w': ':=',
        '~': 'NOT',
        '&': 'AND',
        '|': 'OR',
        '^': 'XOR',
        'n': 'NAND',
        '+': 'ADD-CARRY',
        '-': 'SUB-CARRY',
        '*': 'MULT',
        '<': 'LT',
        '>': 'GT',
        '=': 'EQ',
        'x': 'MUX',
    }

    def _make_expr(net):
        if net.op in 'r@':
            return
        elif net.op in simple_func:
            argvars = " ".join((str(var[arg.name]) for arg in net.args))
            return "{} {}".format(simple_func[net.op], argvars)
        elif net.op == 'c':
            argvars = " ".join((str(var[arg.name]) for arg in net.args))
            return "CONCAT (list {})".format(argvars)
        elif net.op == 'h':
            argvars = " ".join((str(var[arg.name]) for arg in filter(lambda arg: arg.name != net.op_param + '_input', net.args)))
            #hole_inputs.append(net.op_param + '_input')
            hole_inputs[net.op_param + '_input'] = 'HOLE {} (list {}) \"{}\"'.format(net.dests[0].bitwidth, argvars, net.op_param)
            return ":= {}".format(var[net.op_param + '_input'])
        elif net.op == 's':
            zeroExtBits = 0
            for a in net.op_param:
                if a == 0:
                    zeroExtBits += 1
                else:
                    zeroExtBits = 0
                    break
            if zeroExtBits > 0 and net.args[0]._code == 'C':
                const = str(net.args[0])
                val = const[const.rfind('_') + 1:const.find('/')]
                if "'b" in val:
                    val = val[:val.find("'b")]
                return "CONST {} {}".format(val, zeroExtBits)
            slice_args = []
            slices = [a for a in net.op_param]
            monotone = False
            s = slices[0]
            for i in range(1, len(slices)):
                if s >= slices[i]:
                    monotone = False
                    break
                monotone = True
                s = slices[i]
            if monotone:
                low = str(slices[0])
                high = str(slices[-1])
                slice_args = "SLICE {} {}".format(low, high)
            else:
                slice_args = "list " + " ".join([str(a) for a in net.op_param])
            dest = str(var[net.args[0].name])
            return "SEL {} ({})".format(dest, slice_args)
        elif net.op == 'm':
            id_name = net.op_param[1].name
            id = str(var[id_name])
            addr = str(var[net.args[0].name])
            #read_op = 'READ-ASSOC' if 'mem' in id_name else 'READ'
            return "{} {} {}".format('READ', id, addr)
        #elif net.op == 'h':
        #    argvars = " ".join((str(var[arg.name]) for arg in net.args))
        #    return "HOLE {} {}".format(net.op_param, argvars)
        else:
            return None

    for net in block:
        if net.op in 'r@': # don't want to add again; wait until end
            continue
        for d in net.dests:
            if d.name in var:
                continue
            var[d.name] = vid
            vid += 1
        expr = _make_expr(net)
        if expr is None:
            #print("OP {} not recognized! Skipping!".format(net.op))
            continue
        stmt = "({} ({}))".format(" ".join([str(var[d.name]) for d in net.dests]), expr)
        stmts.append(stmt)

    for write in block.logic_subset('@'):
        argvars = " ".join((str(var[arg.name]) for arg in write.args))
        dest_name = write.op_param[1].name
        dest = str(var[dest_name])
        #write_op = 'WRITE-ASSOC' if 'mem' in dest_name else 'WRITE'
        stmt = "({} ({} {}))".format(dest, 'WRITE', argvars)
        stmts.append(stmt)

    for r in block.logic_subset('r'):
        argvar = str(var[r.args[0].name])
        dest = str(var[r.dests[0].name])
        stmt = "({} (:= {}))".format(dest, argvar)
        stmts.append(stmt)

    for i in block.wirevector_subset(pyrtl.Input):
        if i.name in hole_inputs.keys():
            decls.append("({} ({}))".format(var[i.name], hole_inputs[i.name]))
        else:
            decls.append("({} (INPUT {} \"{}\"))".format(var[i.name], i.bitwidth, i.name))

    return "(define-block {}\n(decl {})\n(stmt {}))".format(block_name, "\n  ".join(decls), "\n  ".join(stmts))

