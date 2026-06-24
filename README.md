# 8-Bit Pipelined Microprocessor

A fully custom 8-bit microprocessor designed in Verilog HDL, featuring both a single-cycle and a pipelined implementation, built as part of IITISOC-2026.

---

## Overview

This project implements a custom-designed 8-bit microprocessor from scratch in Verilog HDL. It includes:

- A **single-cycle CPU** where each instruction completes in one clock cycle
- A **pipelined CPU** with multi-stage execution for improved throughput
- A **custom ISA** with 24-bit fixed-width instructions
- A **custom assembler** to translate assembly mnemonics into binary machine code

The design covers arithmetic, logic, memory, shift, branch, and jump operations, with a register file of 32 eight-bit registers and separate instruction and data memories.

---

## Repository Structure

```
8-bit-pipelined-microprocessor/
├── Modules/                  # Individual Verilog submodules
│   ├── alu.v                 # 8-bit ALU (11 operations)
│   ├── pc.v                  # 8-bit Program Counter
│   ├── Control_Unit.v        # Main control unit
│   ├── instruction_decoder.v # 24-bit instruction decoder
│   ├── Register_file.v       # 32 × 8-bit register file
│   ├── Data_Memory.v         # 32 × 8-bit data memory
│   ├── PC_Adder.v            # PC + 1 incrementer
│   ├── Branch_Adder.v        # Branch target calculator
│   ├── Mux.v                 # 2:1 MUX
│   └── MCPModule.v           # Top-level single-cycle CPU
├── Single_Cycle/
│   └── single_cycle.v        # Monolithic single-cycle implementation
├── Testbenches/              # Verilog testbenches
├── Simulation_Results/       # Waveform output and screenshots
├── Single_Cycle.jpeg         # Datapath block diagram
└── README.md
```

---

## Architecture

### Processor Specifications

| Parameter | Value |
|---|---|
| Data width | 8 bits |
| Address space | 8 bits (256 locations) |
| Instruction width | 24 bits (fixed) |
| Register file | 32 × 8-bit (R0–R31) |
| Data memory | 32 bytes |
| Instruction memory | Up to 32 instructions |

### Control Signals

The `Control_Unit` generates the following signals per instruction:

| Signal | Width | Description |
|---|---|---|
| RegWrite | 1 | Enable write to register file |
| ALUSrc | 1 | Select immediate (1) or register (0) as ALU operand B |
| MemWrite | 1 | Enable data memory write |
| MemRead | 1 | Enable data memory read |
| alu_control | 4 | ALU operation selector |
| ResultSrc | 1 | Write-back source: memory (1) or ALU (0) |
| PCSrc | 1 | Next PC: branch/jump target (1) or PC+1 (0) |

---

## Custom ISA

### Instruction Format (24-bit)

**R-Type**
```
 23      19 18     14 13      9  8      4  3      0
┌──────────┬──────────┬──────────┬──────────┬──────────┐
│  OPCODE  │    RS    │    RT    │    RD    │   FUNC   │
│  5 bits  │  5 bits  │  5 bits  │  5 bits  │  4 bits  │
└──────────┴──────────┴──────────┴──────────┴──────────┘
```

**I-Type / Branch**
```
 23      19 18     14 13      9  8              0
┌──────────┬──────────┬──────────┬──────────────┐
│  OPCODE  │    RS    │    RT    │   IMMEDIATE  │
│  5 bits  │  5 bits  │  5 bits  │    8 bits    │
└──────────┴──────────┴──────────┴──────────────┘
```

**J-Type**
```
 23      19 18                                  0
┌──────────┬─────────────────────────────────────┐
│  OPCODE  │            IMMEDIATE                │
│  5 bits  │              8 bits (LSB)           │
└──────────┴─────────────────────────────────────┘
```

| Field | Bits | Description |
|---|---|---|
| OPCODE | [23:19] | Instruction type |
| RS | [18:14] | Source register 1 |
| RT | [13:9] | Source register 2 |
| RD | [8:4] | Destination register |
| FUNC | [3:0] | ALU function code (R-type only) |
| IMMEDIATE | [7:0] | 8-bit immediate / offset |

### Instruction Set

#### R-Type Instructions (`OPCODE = 01100`)

| Mnemonic | FUNC | Operation | Description |
|---|---|---|---|
| ADD | 0000 | RD = RS + RT | Integer addition with overflow detection |
| SUB | 0001 | RD = RS − RT | Integer subtraction with overflow detection |
| MUL | 0010 | RD = RS × RT | Integer multiplication |
| DIV | 0011 | RD = RS / RT | Integer division (result 0 if RT = 0) |
| AND | 0100 | RD = RS & RT | Bitwise AND |
| OR  | 0101 | RD = RS \| RT | Bitwise OR |
| NOT | 0110 | RD = ~RS | Bitwise NOT (unary) |
| XOR | 0111 | RD = RS ^ RT | Bitwise XOR |

#### Shift Instructions

| Mnemonic | OPCODE | Operation | Description |
|---|---|---|---|
| LSHIFT | 00110 | RD = RS << RT | Logical left shift |
| RSHIFT | 00111 | RD = RS >>> RT | Arithmetic right shift (sign-extended) |

#### Memory Instructions

| Mnemonic | OPCODE | Operation | Description |
|---|---|---|---|
| LOADI | 00001 | RT = RS + IMM | Load immediate value into register |
| LOAD  | 00010 | RT = MEM[RS + IMM] | Load byte from data memory |
| STORE | 00011 | MEM[RS + IMM] = RT | Store byte to data memory |

#### Branch & Jump Instructions

| Mnemonic | OPCODE | Condition | Description |
|---|---|---|---|
| JUMP       | 00100 | Always | PC ← PC + IMM (unconditional jump) |
| BEQ        | 01101 | Zero flag set | Branch if RS == RT |
| BNE        | 01110 | Zero flag clear | Branch if RS ≠ RT |
| BRANCH_OVF | 01000 | Overflow flag set | Branch if last ADD overflowed |

#### Comparison Instructions

| Mnemonic | OPCODE | Operation | Description |
|---|---|---|---|
| SLT | 01001 | RD = (RS < RT) ? 1 : 0 | Set less than (signed comparison) |

### ALU Operation Encoding

| alu_control | Operation |
|---|---|
| 1000 | ADD |
| 1001 | SUBTRACT |
| 1010 | MULTIPLY |
| 1011 | DIVIDE |
| 1100 | AND |
| 1101 | OR |
| 1110 | NOT |
| 1111 | XOR |
| 0001 | Arithmetic Right Shift |
| 0010 | Left Shift |
| 0101 | Set Less Than (SLT) |

The ALU outputs two status flags:
- **Zero** — asserted when result = 0 (used by BEQ / BNE)
- **Overflow** — asserted on signed ADD/SUB overflow (used by BRANCH_OVF)

---

## Module Descriptions

| Module | Description |
|---|---|
| `alu.v` | 8-bit combinational ALU. Accepts two 8-bit operands and a 4-bit control signal. Outputs an 8-bit result along with Zero and Overflow flags. Supports 11 operations. |
| `instruction_decoder.v` | Decodes a 24-bit instruction word into opcode, func, rs, rt, rd, and immediate fields. Handles all instruction formats (R-type, I-type, branch, jump). |
| `Control_Unit.v` | Combinational control unit. Takes the 5-bit opcode, 4-bit func, and Zero/Overflow flags to generate all datapath control signals. |
| `Register_file.v` | Synchronous write, asynchronous read register file with 32 × 8-bit registers. Writes occur on the rising clock edge when RegWrite is asserted. |
| `Data_Memory.v` | 32 × 8-bit synchronous data memory. Supports separate read/write enables and resets to zero on reset. |
| `PC_Adder.v` | Simple incrementer: `PC_Plus1 = PC + 1`. |
| `Branch_Adder.v` | Computes branch/jump target: `BranchTarget = PC + Immediate`. |
| `Mux.v` | Parameterized 2:1 multiplexer (8-bit). Used for ALU source select, write-back source select, and next-PC select. |
| `MCPModule.v` | Top-level single-cycle CPU. Instantiates and connects all submodules. Exposes current ALU result on `result[7:0]`. |

---

## Simulation

### Prerequisites

- [Icarus Verilog](http://iverilog.icarus.com/) (`iverilog` + `vvp`) or any compatible simulator (ModelSim, Vivado, etc.)
- [GTKWave](http://gtkwave.sourceforge.net/) for waveform viewing (optional)

### Running the Single-Cycle Design

```bash
# Compile
iverilog -o sim_out Single_Cycle/single_cycle.v Testbenches/<testbench>.v

# Simulate
vvp sim_out

# View waveforms (if testbench generates a .vcd)
gtkwave dump.vcd
```

### Running with Separate Modules

```bash
iverilog -o sim_out \
  Modules/alu.v \
  Modules/pc.v \
  Modules/Control_Unit.v \
  Modules/instruction_decoder.v \
  Modules/Register_file.v \
  Modules/Data_Memory.v \
  Modules/PC_Adder.v \
  Modules/Branch_Adder.v \
  Modules/Mux.v \
  Modules/MCPModule.v \
  Testbenches/<testbench>.v

vvp sim_out
gtkwave dump.vcd
```

Simulation results are stored in the `Simulation_Results/` directory.

---

## Custom Assembler

A custom assembler translates programs written in the project's assembly language into 24-bit binary machine code compatible with the processor's instruction memory. It handles opcode assignment, function code selection, register field packing, and immediate encoding automatically.

### Example Program

```asm
ADD     R0, R1, R2          # Integer addition
SUB     R0, R1, R3          # Integer subtraction
MUL     R0, R1, R4          # Integer multiplication
DIV     R0, R1, R5          # Integer division
AND     R0, R1, R6          # Bitwise AND
OR      R0, R1, R7          # Bitwise OR
NOT     R0, R1, R8          # Bitwise NOT
XOR     R0, R1, R9          # Bitwise XOR
LOADI   R10, 3              # Load immediate 3
LOAD    R12, R13, 5         # Load from MEM[R12 + 5]
STORE   R14, R15, #4        # Store to MEM[R14 + 4]
JUMP    3                   # PC = PC + 3
LSH     R16, R17, R18       # Left shift
RSH     R19, R20, R21       # Arithmetic right shift
SLT     R22, R23, R24       # Set less than
BEQ     R25, R26, 2         # Branch if equal (offset 2)
BNE     R27, R28, 2         # Branch if not equal
BOV     R29, R30, 4         # Branch on overflow
```

---

## Contributors

Built as part of **IITISOC-2026** (IIT Indore Summer of Code):

| Roll No. | Name |
|---|---|
| 250002015 | Anshuman Nema |
| 250002044 | Nilesh Kalra |
| 250002075 | Tanuj Malay Jog |
| 250002006 | Abhinav Shailesh Chavan |

---

## License

This project is open-source and available for educational and research use. See individual files for any specific licensing notes.

## License

This project is open-source and available for educational and research use. See individual files for any specific licensing notes.
