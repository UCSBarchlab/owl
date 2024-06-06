import pyrtl
from enum import IntEnum

from .control import (
    control,
    control_holes,
)
from .cpu_cmov import cpu_three_stage_cmov


def crypto_cpu(holes=False):
    if holes:
        selected_control = control_holes
    else:
        selected_control = control

    return cpu_three_stage_cmov(control=selected_control)

