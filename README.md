# 8-Bit ALU in Verilog

An 8-bit combinational arithmetic logic unit (ALU) implemented in Verilog.

This project is being developed to practice RTL design, digital logic, simulation, and hardware verification.

## Current Features

The ALU accepts two 8-bit inputs and a 3-bit opcode and supports:

| Opcode | Operation |
|--------|-----------|
| `000` | Addition |
| `001` | Subtraction |
| `010` | Bitwise AND |
| `011` | Bitwise OR |
| `100` | Bitwise XOR |
| `101` | Bitwise NOT |
| `110` | Logical Left Shift |
| `111` | Logical Right Shift |

The design also produces:

Status Flags

- `carry` — arithmetic carry or subtraction underflow indicator
- `zero` — asserted when the result equals zero
- `Overflow` — Detects signed two's-complement overflow during addittion and subtraction.

Verification

- Self_cehcking Verilog testbench with an independent refrence model.
- Exhaustive testing of all 524,288 binary input combinations across eight ALU operations.

## Project Structure

```text
src/    Verilog RTL source files
tb/     Testbench and verification files
docs/   Project documentation and simulation results