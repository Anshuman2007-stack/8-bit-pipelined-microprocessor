# 8-Bit Pipelined Microprocessor

A fully custom 8-bit microprocessor designed in Verilog HDL, featuring both a single-cycle and a pipelined implementation, built as part of IITISOC-2026.

## Overview

This project implements a custom-designed 8-bit microprocessor from scratch in Verilog HDL. It includes:

- A **single-cycle CPU** where each instruction completes in one clock cycle
- A **pipelined CPU** with multi-stage execution for improved throughput (in progress)
- A **custom ISA** with 24-bit fixed-width instructions
- A **custom assembler** to translate assembly mnemonics into binary machine code

The design covers arithmetic, logic, memory, shift, rotate, branch, and jump operations, with a register file of 32 eight-bit registers and **separate instruction and data memories** (Harvard-style organization).

## Repository Structure

```
8-bit-pipelined-microprocessor/
├── Modules/                  # Individual Verilog submodules
│   ├── alu.v                 # 8-bit ALU (14 operations)
│   ├── pc.v                  # 8-bit Program Counter
│   ├── Control_Unit.v        # Main control unit
│   ├── instruction_decoder.v # 24-bit instruction decoder
│   ├── Register_file.v       # 32 × 8-bit register file
│   ├── Data_Memory.v         # 32 × 8-bit data memory
│   ├── Instruction_Memory.v  # 32 × 24-bit instruction memory
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

## Architecture

### Processor Specifications

| Parameter | Value |
|---|---|
| Data width | 8 bits |
| Address path width | 8 bits (256 locations max) |
| Instruction width | 24 bits (fixed) |
| Register file | 32 × 8-bit (R0–R31) |
| Data memory | 32 bytes |
| Instruction memory | 32 instructions |
| Memory organization | Harvard (separate instruction and data memory) |
| Execution model | Single-cycle |
| Control unit | Combinational |

### Control Signals

The `Control_Unit` generates the following signals per instruction:

| Signal | Width | Description |
|---|---|---|
| `RegWrite` | 1 | Enable write to register file |
| `ALUSrc` | 1 | Select immediate (1) or register (0) as ALU operand B |
| `MemWrite` | 1 | Enable data memory write |
| `MemRead` | 1 | Enable data memory read |
| `alu_control` | 4 | ALU operation selector |
| `ResultSrc` | 1 | Write-back source: memory (1) or ALU (0) |
| `PCSrc` | 1 | Next PC: branch/jump target (1) or PC+1 (0) |

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
│  OPCODE  │    RS    │  RT/RD   │   IMMEDIATE  │
│  5 bits  │  5 bits  │  5 bits  │    8 bits    │
└──────────┴──────────┴──────────┴──────────────┘
```
> Note: for `LOADI`, `LOAD`, `STORE`, and `ADDI`, the destination/second-operand field occupies the same bit position (`[13:9]`) — its role (source vs. destination) depends on the opcode, not the bit position.

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
| `OPCODE` | [23:19] | Instruction type |
| `RS` | [18:14] | Source register 1 |
| `RT` / `RD` | [13:9] | Source register 2, or destination, depending on opcode |
| `RD` (R-type only) | [8:4] | Destination register |
| `FUNC` | [3:0] | ALU function code (R-type only) |
| `IMMEDIATE` | [7:0] | 8-bit immediate / offset (two's complement, −128 to 127) |

### Instruction Set

#### R-Type Instructions (OPCODE = `01100`)

| Mnemonic | FUNC | Operation | Description |
|---|---|---|---|
| `ADD` | `0000` | `RD = RS + RT` | Integer addition, with overflow detection |
| `SUB` | `0001` | `RD = RS − RT` | Integer subtraction, with overflow detection |
| `MUL` | `0010` | `RD = RS × RT` | Integer multiplication (result truncated to 8 bits) |
| `DIV` | `0011` | `RD = RS / RT` | Integer division (result 0 if RT = 0) |
| `AND` | `0100` | `RD = RS & RT` | Bitwise AND |
| `OR` | `0101` | `RD = RS \| RT` | Bitwise OR |
| `NOT` | `0110` | `RD = ~RS` | Bitwise NOT (unary — RT is decoded but unused) |
| `XOR` | `0111` | `RD = RS ^ RT` | Bitwise XOR |

#### Shift & Rotate Instructions

| Mnemonic | OPCODE | Operation | Description |
|---|---|---|---|
| `LSH` | `00110` | `RD = RS << RT` | Logical left shift |
| `RSH` | `00111` | `RD = RS >>> RT` | Arithmetic right shift (sign-extended) |
| `LSR` | `01111` | `RD = RS >> RT` | Logical right shift (zero-filled) |
| `ROR` | `01010` | `RD = RS rotated right by RT` | Rotate right, modulo-8, zero-shift guarded |
| `ROL` | `01011` | `RD = RS rotated left by RT` | Rotate left, modulo-8, zero-shift guarded |

#### Memory Instructions

| Mnemonic | OPCODE | Operation | Description |
|---|---|---|---|
| `LOADI` | `00001` | `RT = RS + IMM` | Load immediate value into register |
| `LOAD` | `00010` | `RT = MEM[RS + IMM]` | Load byte from data memory (base-plus-offset) |
| `STORE` | `00011` | `MEM[RS + IMM] = RT` | Store byte to data memory (base-plus-offset) |
| `ADDI` | `00101` | `RD = RS + IMM` | Add immediate to register |

#### Branch & Jump Instructions

| Mnemonic | OPCODE | Condition | Description |
|---|---|---|---|
| `JUMP` | `00100` | Always | `PC ← PC + IMM` (unconditional, PC-relative) |
| `BEQ` | `01101` | Zero flag set | Branch if RS == RT |
| `BNE` | `01110` | Zero flag clear | Branch if RS ≠ RT |
| `BOV` | `01000` | Overflow flag set | Branch if last ADD/SUB overflowed |

#### Comparison Instructions

| Mnemonic | OPCODE | Operation | Description |
|---|---|---|---|
| `SLT` | `01001` | `RD = (RS < RT) ? 1 : 0` | Set-less-than, signed comparison, overflow-corrected |

### ALU Operation Encoding

| `alu_control` | Operation |
|---|---|
| `1000` | ADD |
| `1001` | SUBTRACT |
| `1010` | MULTIPLY |
| `1011` | DIVIDE |
| `1100` | AND |
| `1101` | OR |
| `1110` | NOT |
| `1111` | XOR |
| `0001` | Arithmetic Right Shift |
| `0010` | Left Shift |
| `0011` | Logical Right Shift (LSR) |
| `0100` | Rotate Right (ROR) |
| `0101` | Set Less Than (SLT) |
| `0110` | Rotate Left (ROL) |

The ALU outputs two status flags:

- **Zero** — asserted when result = 0 (used by `BEQ` / `BNE`)
- **Overflow** — asserted on signed ADD/SUB overflow (used by `BOV`, and to correct `SLT`)

## Module Descriptions

| Module | Description |
|---|---|
| `alu.v` | 8-bit combinational ALU. Accepts two 8-bit operands and a 4-bit control signal. Outputs an 8-bit result along with `Zero` and `Overflow` flags. Supports 14 operations including signed-safe comparison and guarded rotates. |
| `instruction_decoder.v` | Decodes a 24-bit instruction word into `opcode`, `func`, `rs`, `rt`, `rd`, and `immediate` fields. Handles all instruction formats (R-type, I-type, branch, jump). |
| `Control_Unit.v` | Combinational control unit. Takes the 5-bit opcode, 4-bit func, and `Zero`/`Overflow` flags to generate all datapath control signals. |
| `Register_file.v` | Combinational-read, synchronous-write register file with 32 × 8-bit registers. Writes occur on the rising clock edge when `RegWrite` is asserted. |
| `Data_Memory.v` | 32 × 8-bit memory. Read output is gated by `MemRead` (outputs 0 when not reading); writes occur synchronously when `MemWrite` is asserted. Resets to zero on `reset`. |
| `Instruction_Memory.v` | 32 × 24-bit instruction store, addressed combinationally by the program counter. |
| `PC_Adder.v` | Simple incrementer: `PC_Plus1 = PC + 1`. |
| `Branch_Adder.v` | Computes branch/jump target: `BranchTarget = PC + Immediate`. |
| `Mux.v` | Parameterized 2:1 multiplexer (8-bit). Used for ALU source select, write-back source select, and next-PC select. |
| `MCPModule.v` | Top-level single-cycle CPU. Instantiates and connects all submodules. Exposes the current ALU result on `result[7:0]`. |
| `PC` | Program counter. **Resets asynchronously** (`posedge reset` in the sensitivity list) — independent of the clock. `Register_file` and `Data_Memory` reset **synchronously**, on the next clock edge. |

## Simulation

### Prerequisites

- [Icarus Verilog](http://iverilog.icarus.com/) (`iverilog` + `vvp`) or any compatible simulator (ModelSim, Vivado Simulator, etc.)
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
  Modules/Instruction_Memory.v \
  Modules/PC_Adder.v \
  Modules/Branch_Adder.v \
  Modules/Mux.v \
  Modules/MCPModule.v \
  Testbenches/<testbench>.v

vvp sim_out
gtkwave dump.vcd
```

Simulation results are stored in the `Simulation_Results/` directory.

## Custom Assembler

A custom assembler translates programs written in the project's assembly language into 24-bit binary machine code compatible with the processor's instruction memory. It handles opcode assignment, function code selection, register field packing, and immediate encoding automatically, including range validation (immediates must fit `−128` to `127`).

## Example Program — Bubble Sort

This program sorts a 3-element array (`arr[0], arr[1], arr[2]`, held in data memory) in place using a nested-loop bubble sort, mirroring:

```c
for (int i = 0; i < n; i++)
    for (int j = i; j < n; j++)
        if (arr[i] > arr[j]) { swap(arr[i], arr[j]); }
```

Register usage: `R1` = outer index `i`, `R2` = inner index `j`, `R3` = `n` (array size), `R4`/`R5` = loaded values for comparison, `R6` = comparison result.

```asm
LOADI       R3, 3                # n = 3
LOADI       R1, 0                # i = 0

OUTER_LOOP:
BEQ         R1, R3, 13            # if i == n, exit outer loop
ADDI        R2, R1, 0             # j = i

INNER_LOOP:
BEQ         R2, R3, 9             # if j == n, exit inner loop
LOAD        R1, R4, 0             # R4 = arr[i]
LOAD        R2, R5, 0             # R5 = arr[j]
SLT         R5, R4, R6            # R6 = (arr[j] < arr[i]) ? 1 : 0
BEQ         R6, R0, 3             # if not less-than, skip swap
STORE       R1, R5, 0             # arr[i] = R5
STORE       R2, R4, 0             # arr[j] = R4

SKIP_SWAP:
ADDI        R2, R2, 1             # j++
JUMP        -8                    # back to INNER_LOOP

END_INNER:
ADDI        R1, R1, 1             # i++
JUMP        -12                   # back to OUTER_LOOP

EXIT:
JUMP        0                     # halt (self-jump)
```

This program exercises every major subsystem of the processor: immediate loading (`LOADI`), register-to-register arithmetic (`ADDI`), base-plus-offset memory access (`LOAD`/`STORE`), signed comparison (`SLT`), conditional branching (`BEQ`), and unconditional jumps (`JUMP`) — including backward (negative-offset) jumps for both loop bodies.

**Verified result:** `{5, 8, 2}` → `{2, 5, 8}`, confirmed via Vivado behavioral simulation (`tb_MCPModule_behav`), with simulation completing cleanly.

## Contributors

Built as part of IITISOC-2026 (IIT Indore Summer of Code):

| Roll No. | Name |
|---|---|
| 250002015 | Anshuman Nema |
| 250002044 | Nilesh Kalra |
| 250002075 | Tanuj Malay Jog |
| 250002006 | Abhinav Shailesh Chavan |

## License

This project is open-source and available for educational and research use. See individual files for any specific licensing notes.
