# PESP CPU — FPGA Implementation

A custom 32-bit processor designed in Verilog and implemented on the
Terasic DE10-Standard FPGA development board.

This project demonstrates the design and implementation of a processor
architecture, including instruction execution, register management,
memory operations, and FPGA-based hardware integration.

## Project Overview

The PESP CPU is a custom processor developed to explore computer
architecture and digital hardware design.

The processor uses a sequential, multi-cycle architecture in which
instructions progress through multiple execution stages.

The design was implemented using Intel Quartus Prime and deployed
on the Terasic DE10-Standard development board.

### Hardware and Development Tools

- **FPGA Board:** Terasic DE10-Standard
- **FPGA Device:** Intel Cyclone V SoC (5CSXFC6D6F31C6)
- **Hardware Description Language:** Verilog
- **Development Environment:** Intel Quartus Prime Standard 25.1
- **Simulation:** Verilog testbench

## Processor Architecture

The PESP CPU features:

- 32-bit instruction format
- 32 general-purpose 32-bit registers
- Custom instruction set architecture (ISA)
- Sequential multi-cycle instruction execution
- Instruction and data memory
- Arithmetic and logical operations
- Register-based data processing
- FPGA-based input/output interface

### Instruction Execution

The processor executes instructions using a finite-state machine (FSM).

The execution process consists of the following stages:

1. **Instruction Fetch:** Retrieve the instruction from memory.
2. **Instruction Decode:** Identify the operation and operands.
3. **Execute:** Perform arithmetic, logical, or address calculations.
4. **Memory Access:** Read or write data memory when required.
5. **Write Back:** Update the destination register with the result.

The processor also supports a HALT state to terminate execution.

## Hardware Components

### CPU Core

`pesp_cpu.v`

Implements the processor's control logic, instruction execution,
and coordination between internal components.

### Register File

`pesp_register.v`

Implements the processor's general-purpose register storage.

### Instruction Memory

`pesp_memory.v`

Stores machine-code instructions executed by the processor.

### Data Memory

`pesp_datamem.v`

Provides storage for data accessed during instruction execution.

### FPGA Top-Level Module

`pesp_top.v`

Integrates the processor with the FPGA development board.

### Seven-Segment Display Decoder

`hex_decoder.v`

Converts binary values into hexadecimal digits for display
on the FPGA board's seven-segment displays.

### Testbench

`pesp_cpu_tb.v`

Provides a simulation environment for testing processor behavior.

## Repository Structure

```text
PESP-CPU-FPGA/
│
├── PESP.qpf             # Quartus project
├── PESP.qsf             # FPGA configuration and pin assignments
├── PESP.v               # Verilog module
├── pesp_cpu.v           # CPU implementation
├── pesp_register.v      # Register file
├── pesp_memory.v        # Instruction memory
├── pesp_datamem.v       # Data memory
├── pesp_top.v           # FPGA top-level module
├── hex_decoder.v       # Seven-segment display decoder
├── pesp_cpu_tb.v        # CPU testbench
├── program.hex          # Machine-code program
└── README.md
```

## Running the Project

### Requirements

- Intel Quartus Prime Standard 25.1
- Terasic DE10-Standard FPGA development board

### Compilation

1. Clone this repository:

   ```bash
   git clone https://github.com/bryanduarte03/PESP-CPU-FPGA.git
   ```

2. Open Intel Quartus Prime.

3. Select **File > Open Project**.

4. Open `PESP.qpf`.

5. Verify that the correct FPGA device is selected.

6. Compile the design using **Processing > Start Compilation**.

### FPGA Programming

1. Connect the DE10-Standard board to the computer using USB-Blaster.
2. Power on the FPGA board.
3. Open **Tools > Programmer** in Quartus.
4. Select the appropriate hardware interface.
5. Load the generated `.sof` programming file.
6. Click **Start** to program the FPGA.

## Learning Outcomes

This project provided practical experience with:

- Processor architecture and instruction set design
- Finite-state machine implementation
- Digital logic design using Verilog
- Register files and memory organization
- FPGA synthesis and hardware implementation
- Hardware debugging and functional verification

## Related Projects

**[PESP CPU Simulator](https://github.com/bryanduarte03/PESP)**

A software-based implementation of the PESP processor architecture
developed in C.

## Author

Bryan Duarte

Computer Engineering — University of Maryland, College Park

[GitHub Profile](https://github.com/bryanduarte03)
