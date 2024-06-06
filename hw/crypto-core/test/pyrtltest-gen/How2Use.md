## Instruction for test bench generator

### Step 1: Write assembly code in test.s
You only need to write assembly code in test.s, there's already few lines of code inside.

### Step 2: Generate test bench
Type `make all` under the terminal of current directory, and you will get some hex code. These are the generated test progra,

### Step 3: Copy and run
start a new test case in rv-cpu/src/test_cpu.py, it should looks like this:

```
Program(
    name="cmov-true",
    instructions=[
        # main:
        0x01200593,  # addi    a1, zero, 0x12
        0x04500613,  # addi    a2, zero, 0x45
        0x00100693,  # addi    a3, zero, 0x01 #a3 is condition, here is true
        0x20C6A5B3,  # sh1add  a1, a3, a2, we treat sh1add as cmov
        # exit:
    ],
    rf={11: 0x45, 12: 0x45, 13: 0x01},
),
```
`instructions` is the place where actual program goes to, you may copy the `make all` result here
`rf` is the final state of our machine, and you should do a dry run and type the result here
I suggest you use register like a1-a7 on your program, since they are easier to deal with
`rf={11: 0x45, 12: 0x45, 13: 0x01}` means after the program above are executed in our processor, what does those register looks like. Here we have 
```
a1(11) holds value 0x45
a2(12) holds value 0x45
a3(13) holds value 0x01
```

you can came up with more interesting program with the instruction that are supported by our processor in rv-cpu/test/mysha/inst2impl 

Goodluck :P