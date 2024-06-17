# Artifact for _Control Logic Synthesis: Drawing the Rest of the OWL_

## Artifact Directory Overview

* `benchmarks`: Scripts to run benchmarks in the paper.
* `hw`: PyRTL code for benchmark designs. Includes Python script that compiles
  PyRTL designs to Oyster IR.
* `ila-to-rosette`: C++ library that compiles ILA specifications into Rosette
  pre/postconditions.
* `oyster`: Racket code that symbolically evaluates Oyster IR and automatically
  generates control logic based on ILA specifications.
* `pyrtl-code-gen`: Scripts that demonstrate generating PyRTL code from the
  control logic synthesis results.
* `results`: Stores results from running control logic synthesis benchmarks
  (initially empty).
* `spec`: Directory storing compiled ILA specifications used for benchmarks.

## Requirements

The following are dependencies for running the artifact. The provided
`Dockerfile` sets up an environment with the required dependencies.

* Python (v3.11)
* [PyRTL](https://github.com/pllab/PyRTL) built with branch `function-holes`
* [Racket (v8.7 or later)](https://racket-lang.org/)
* [Rosette (v4.1)](https://docs.racket-lang.org/rosette-guide/index.html)
* [Boolector (v2.4.1 or later)](https://boolector.github.io/)
* [CVC4 (v1.8 or later)](https://cvc4.github.io/)

## Kick the Tires

The whole environment for the artifact can be set up using Docker. (This is
recommended for artifact evaluation.)

### Step 1: Set Up Docker Environment

#### Step 1a

Run the `docker-build.sh` script to build the Docker image. (Depending how
Docker is installed on your machine, you may need to run the script with
`sudo`/`doas`.)

```shell
$ ./docker-build.sh
```

#### Step 1b

After successfully building the Docker image, run `docker-run.sh` to launch the
Docker image, landing you at a bash shell prompt.

```shell
$ ./docker-run.sh
```

#### Step 1c

At the bash prompt, run:

```shell
$ ./setup.sh
```

to install the Oyster language framework. Now the environment is all set up and
ready to run the benchmarks.

Note: You may need to run `setup.sh` again after exiting and re-entering the
Docker environment. You will need to rerun if you see an error such as:

```
runner.rkt:5:9: collection not found
  for module path: oyster
  collection: "oyster"
  ...
```

### Step 2: PyRTL to Oyster IR

Next, `cd` into the `hw` directory, and read the `README.md` file, following the
steps written there.

### Step 3: ILA to Rosette

Next, `cd` into the `/opt/ila-to-rosette/build` directory on the container. Running
the binary `ILAngToRosette` will produce a file called `riscv_rspec.rkt`, which
contains the translation for a RISC-V ILA to Rosette pre/postconditions. If you instead
wish to produce the Rosette specification for the AES accelerator:

1. Uncomment the lines of code specified in `/opt/ila-to-rosette/src/main.cc` and
   comment out the `riscv` lines (also specified). In total: 3 lines commented,
   1 line uncommented.
2. Go to `/opt/ila-to-rosette/build` and run the `cmake` command listed in the
   Docker file associated with `ila-to-rosette`.
3. Run `make`.
4. Run the `ILAngToRosette` binary which will produce `AES_128_Rnd_rspec.rkt`.

## Benchmark Evaluation

This part of the artifact evaluates the main control logic synthesis technique
over the three case studies.

### Control Logic Synthesis

`cd` into the `benchmarks` directory, and read the `README.md` file, following
the steps written there.

### PyRTL Code Generation

`cd` into the `pyrtl-code-gen` directory, and read the `README.md` file,
following the steps written there.

