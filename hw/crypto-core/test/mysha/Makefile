RV32CC = riscv32-unknown-linux-gnu-gcc
CFLAGS = -march=rv32izba \
                -mabi=ilp32 \
                -nostdlib \
                -nostartfiles \
                -fPIE    \
                -fPIC   \
                -fno-zero-initialized-in-bss    \
                -fno-stack-protector   \
                -static \
                -T link.ld  \
                -o a.out    \
                --entry main    \
                startup.s   \

SECTION_FLG =   -O binary \
                --only-section .text \
                --only-section .sha256_rodata \
                --only-section .eh_frame \
                --only-section .data \
                --only-section .got \
                --only-section .got.plt \
                --only-section .data.rel \

RV32DISASM = llvm-objdump
RV32OPJCOPY = llvm-objcopy

SRC = mysha-brless.c
TARGET = mysha-brless.out
DISASM = asm
CODE = CODE.dat
DATA = DATA.dat

all: $(TARGET) $(DISASM) $(CODE) $(DATA)

$(TARGET): $(SRC)
	$(RV32CC) $(CFLAGS) $^ -o $@

$(DISASM): $(TARGET)
	$(RV32DISASM) -D $^ > $@

$(CODE): $(TARGET)
	$(RV32OPJCOPY) $(SECTION_FLG) $^ $@

$(DATA): $(TARGET)
	$(RV32OPJCOPY) $(SECTION_FLG) $^ $@

clean:
	rm $(TARGET) $(DISASM) $(CODE) $(DATA)
	 