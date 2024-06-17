# PyRTL with holes

If you are not running from the Docker environment, you need to pull and build a
particular branch of PyRTL (if you are running from Docker, skip this step):

* Pull PyRTL from the `function-holes` branch in this repo:
  <https://github.com/pllab/PyRTL/tree/function-holes>
* Run `pip3 install .`
* This branch includes the `net_hole` functionality in PyRTL, which lives here:
  <https://github.com/pllab/PyRTL/blob/function-holes/pyrtl/corecircuits.py#L608>

# PyRTL to Oyster IR

* File `generate_ir.py` provides `generate_ir()` function.
* The following sections show how to compile datapaths with holes implemented in
  PyRTL to the Oyster IR for the three case studies presented in the paper:
    1. Embedded-Class RISC-V Core
    2. Constant-Time Cryptography Core
    3. AES Hardware Accelerator

## Embedded-Class RISC-V Core

`cd` into the `rv-cpu` directory, run:

```shell
$ python3 generate_cpu.py -h
```

This commands shows how to use the PyRTL RISC-V CPU generator. 

To generate a single-cycle design (`-s 1`) with the base integer instruction set
(`-e i`) and "holes" for the control logic (`-c`), run:

```shell
$ python3 generate_cpu.py -s 1 -e i -c
```

The script writes the Oyster IR to standard out. You can compare it with the
pre-compiled Oyster IR in `out/rvi-single-cycle.rkt`. The holes in the datapath
come from `rv-cpu/src/control.py`, the function `control_holes()` (the functions
in this file without `_holes` in the name are reference implementations). The
holes in the IR are declared at the top of the output in the `(decl)` block.

To generate the Oyster for the largest design in the paper:

* two-stage pipeline (`-s 2`)
* the base integer instruction set plus Zbkc extension for carryless multiply
  (`-e c`)
* and "holes" for the control logic (`-c`)

```shell
$ python3 generate_cpu.py -s 2 -e c -c
```

## Constant-Time Cryptography Core

* `cd` in to the `crypto-core` directory.
* This core is similar to the RISC-V CPU, except it has a three-stage pipeline
  and implements a custom instruction set (a subset of RISC-V with a custom
  conditional move instruction `cmov`).
* Run `python3 generate_cpu.py -c` to generate Oyster IR with holes for the
  crypto core.
* There are 13 holes in this design.

## AES Hardware Accelerator

* First, `cd` in to the `aes` directory.
* Open `aes.py` and search for instances of `pyrtl.net_hole`. This construct
  inserts holes into the PyRTL design.
* Run `python3 aes_instance.py`.
* This command writes the Oyster IR to standard out. There are four holes in
  this design.

