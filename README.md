# RV32I Single-Cycle RISC-V Processor (Verilog)

## Overview

This project implements a **32-bit RV32I single-cycle RISC-V processor** using Verilog.
The processor fetches, decodes, executes, and writes back instructions in **one clock cycle**.

The design follows the standard **RISC-V datapath architecture** and includes all essential components such as instruction memory, register file, ALU, control unit, and branch logic.

The processor is verified using **Icarus Verilog simulation && VIVADO ** and waveform analysis using **GTKWave**.

---

## Architecture

The processor uses a **single-cycle datapath** where each instruction completes within one clock cycle.

### Datapath Flow

```
PC
 ↓
Instruction Memory
 ↓
Register File
 ↓
Immediate Generator
 ↓
ALU
 ↓
Data Memory
 ↓
Write Back
```

### Execution Stages

1. **Instruction Fetch (IF)**
   Program Counter (PC) fetches instruction from instruction memory.

2. **Instruction Decode (ID)**
   Instruction fields are decoded and register operands are read.

3. **Execute (EX)**
   ALU performs arithmetic or logical operations.

4. **Memory Access (MEM)**
   Load or store instructions access data memory.

5. **Write Back (WB)**
   Result is written back to the register file.

---

## Supported RV32I Instructions

### R-Type

* ADD
* SUB
* AND
* OR
* XOR
* SLT
* SLL
* SRL
* SRA

### I-Type

* ADDI
* ANDI
* ORI
* XORI
* SLTI
* SLLI
* SRLI
* SRAI

### Memory Instructions

* LW
* SW

### Branch Instructions

* BEQ
* BNE
* BLT
* BGE

### Jump Instructions

* JAL
* JALR

### Upper Immediate

* LUI
* AUIPC

---

## Project Structure

```
risc-v/
│
├── rv32i_top.v        # Top-level CPU module
├── pc.v               # Program Counter
├── imem.v             # Instruction memory
├── dmem.v             # Data memory
├── regfile.v          # Register file (32 registers)
├── immgen.v           # Immediate generator
├── alu.v              # Arithmetic Logic Unit
├── alu_control.v      # ALU control logic
├── control_main.v     # Main control unit
├── branch_unit.v      # Branch comparison logic
├── mux2.v             # 2:1 multiplexer
├── mux4.v             # 4:1 multiplexer
├── program.hex        # RISC-V instruction program
├── tb_32.v            # Testbench
└── tb_32.vcd          # Waveform output (generated)
```

---

## Testbench

The testbench performs the following tasks:

* Generates clock and reset signals
* Instantiates the CPU (Device Under Test)
* Loads instructions from `program.hex`
* Runs the simulation for several clock cycles
* Prints instruction execution trace
* Displays final register values
* Generates waveform (`.vcd`) for GTKWave

<img width="1552" height="709" alt="image" src="https://github.com/user-attachments/assets/42f0b741-892b-4715-9cfc-571d1551c3fb" />


Example output:

```
Cycle=0  PC=00000004  Instr=01400113  ALU=00000014
Cycle=1  PC=00000008  Instr=002081b3  ALU=0000001e
Cycle=2  PC=0000000c  Instr=00302023  ALU=00000000
...
```

Final register results:

```
x1 = 10
x2 = 20
x3 = 30
x4 = 30
x5 = 2
```

---

## Simulation Instructions

### 1. Compile

```
iverilog -g2012 -o cpu_sim *.v
```

### 2. Run Simulation

```
vvp cpu_sim
```

### 3. View Waveform

```
gtkwave tb_32.vcd
```

---

## Example Program

The sample program in `program.hex` performs:

1. `addi x1, x0, 10`
2. `addi x2, x0, 20`
3. `add  x3, x1, x2`
4. `sw   x3, 0(x0)`
5. `lw   x4, 0(x0)`
6. `beq  x3, x4`
7. `addi x5, x0, 2`
8. `jal  x0, 0` (infinite loop)

Expected result:

```
x1 = 10
x2 = 20
x3 = 30
x4 = 30
x5 = 2
```

---

## Waveform Analysis

Waveforms can be viewed in **GTKWave** showing:

* Program Counter (PC)
* Instruction
* ALU inputs and output
* Register file data
* Control signals
* Memory access

This allows step-by-step verification of processor execution.

---

## Future Improvements

Possible extensions to this processor:

* 5-Stage Pipeline (IF, ID, EX, MEM, WB)
* Hazard detection unit
* Forwarding unit
* Cache memory
* Interrupt handling
* Branch prediction

---

## Tools Used

* **Verilog HDL**
* **Icarus Verilog**
* **GTKWave**
* **Visual Studio Code**

---

## Author

**BADAM SRINIVASA REDDY**
Electronics and Communication Engineering
Rajiv Gandhi University of Knowledge Technologies
