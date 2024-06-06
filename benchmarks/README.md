# Benchmarks

This directory contains scripts that run the control logic synthesis technique
over the three case studies in the paper:

1. Embedded-Class RISC-V Core
2. Constant-Time Cryptography Core
3. AES Hardware Accelerator

These scripts aim to recreate the control logic synthesis times found in Table 1
of the paper.

## Embedded-Class RISC-V Core

### Single-Cycle Core

Run:

```shell
$ ./rv-single-cycle.sh
```

This script runs control logic synthesis for the three variants of the
single-cycle core (RVI, RVI + Zbkb, and RVI + Zbkc).

The script prints the run time for each variant. These should roughly match the
control logic synthesis times given in Table 1.

The script runs control logic synthesis for each instruction concurrently. The
results are stored in the top-level `results` directory with file name
`ISA.1.INST.out` where `ISA` is either `rvi`, `zbkb`, or `zbkc`, and `INST` is
the given ISA instruction.

The `.out` file stores the results of control logic synthesis for a particular
ISA instruction. It lists the synthesized control signals for each hole in the
datapath. The results should be concrete bitvectors, however it is possible that
some control signals synthesize to `x` which indicates a symbolic value (that
is, it does not matter which value it takes and can take any value).

There should be no instances of `unsat` in any of the results files, which would
indicate that control logic synthesis failed to find a satisfiable solution. For
convenience, the runner scripts `grep` for "unsat" in the results files.

### Two-Stage Core

Run:

```shell
$ ./rv-two-stage.sh
```

This script runs control logic synthesis for the three variants of the
two-stage core (RVI, RVI + Zbkb, and RVI + Zbkc).

The script prints the run time for each variant. These should roughly match the
control logic synthesis times given in Table 1. Solver times are
machine-dependent, so the times may not exactly match the times in Table 1.
However, the two-stage core should take longer than the single-cycle core.

As before, the results are stored in the top-level `results` directory, this
time with file name `ISA.2.INST.out` where `ISA` is either `rvi`, `zbkb`, or
`zbkc`, and `INST` is the given ISA instruction.

## Constant-Time Cryptography Core

Run:

```shell
$ ./crypto-core.sh
```

This script runs control logic synthesis for the constant-time cryptography core
with the custom CMOV ISA.

The synthesis time for this benchmark should be faster than both the
single-cycle and two-stage cores.

As before, the results are stored in the top-level `results` directory, this
time with file name `cmov.3.INST.out` where `INST` is the given ISA instruction.

## AES Hardware Accelerator

Run:

```shell
$ ./aes.sh
```

This script runs control logic synthesis for the AES hardware accelerator.

This benchmark demonstrates synthesizing the control logic all-at-once instead
of independently solving for each instruction. Therefore, the output is not
written to the `results` folder but instead the Oyster IR is printed to standard
out. The last three lines of IR output are the synthesized holes for the state
encodings; you can see output similar to the following (where the three concrete
bitvector values are unique):

```
state1: ((bv #b11 2))
state3: ((bv #b01 2))
state2: ((bv #b00 2))
```

And farther up the IR output you can find the synthesized expression for the state
transition logic. For the pre-compiled datapath sketch, this is variable `54`.
The output will be similar to the following:

```
(list 54 (MUX (LT 11 (bv #x9 4)) (MUX (GE 11 (bv #x8 4)) (bv #b00 2) (bv #b01 2)) (MUX (LT 11 (bv #x
1 4)) (bv #b00 2) (bv #b11 2))))
```

