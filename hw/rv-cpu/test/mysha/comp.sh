# !/bin/bash
riscv32-unknown-linux-gnu-gcc \
                -march=rv32i \
                -mabi=ilp32 \
                -nostdlib \
                -nostartfiles \
                -fno-pie    \
                -fno-zero-initialized-in-bss    \
                -static \
                -T link.ld  \
                -o a.out    \
                --entry main    \
                $1
