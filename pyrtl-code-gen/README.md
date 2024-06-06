# PyRTL Code Generation

This part demonstrates how to generate PyRTL code from the control logic
synthesis results (following the algorithm presented in Figure 6 of the paper as
implemented in `ctrl-gen-runner.rkt`). The provided scripts run PyRTL code
generation over the single-cycle RISC-V core for each of the three variants
(RVI, RVI + Zbkb, and RVI + Zbkc).

## RVI

Run:

```shell
$ ./rvi-single-cycle.sh
```
This script produces the file `rvi-single-cycle.py`, which contains the control
logic synthesis results for the single-cycle RVI variant compiled to PyRTL.

## RVI + Zbkb

Run:

```shell
$ ./zbkb-single-cycle.sh
```
This script produces the file `zbkb-single-cycle.py`, which contains the control
logic synthesis results for the single-cycle Zbkb variant compiled to PyRTL.

## RVI + Zbkc

Run:

```shell
$ ./zbkc-single-cycle.sh
```
This script produces the file `zbkc-single-cycle.py`, which contains the control
logic synthesis results for the single-cycle Zbkc variant compiled to PyRTL.

