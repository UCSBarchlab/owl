import pyrtl


def add_wire(wire, bitwidth=None, name="", block=None):
    """Creates a new wire driven by the wire."""
    bitwidth = bitwidth if bitwidth is not None else len(wire)
    named_wire = pyrtl.WireVector(bitwidth=bitwidth, name=name, block=block)
    named_wire <<= wire
    return named_wire


def add_register(wire, bitwidth=None, name="", block=None):
    """Creates a new register driven by the wire."""
    bitwidth = bitwidth if bitwidth is not None else len(wire)
    register = pyrtl.Register(bitwidth=bitwidth, name=name, block=block)
    register.next <<= wire
    return register
