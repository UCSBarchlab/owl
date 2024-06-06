RV32CC = riscv32-unknown-linux-gnu-gcc
CC = gcc
FLAGS = -march=rv32izba -nostartfiles -nostdlib -static 

SRC = test.s
ELF = test.out
BINARY = instr.dat
ASM_READER_SRC = converter.c


reader.out: $(ASM_READER_SRC)
	$(CC) $^ -o $@

all: $(BINARY) reader.out
	./reader.out

$(ELF): $(SRC)
	$(RV32CC) $(FLAGS) $^ -o $@

$(BINARY): $(ELF)
	llvm-objcopy -O binary --only-section .text $(ELF) $(BINARY)

clean:
	rm $(ELF) $(BINARY) reader.out