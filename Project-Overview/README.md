# RV32I Single-Cycle Processor

## 1. Project Introduction

This project focuses on the design and implementation of a 32-bit RISC-V RV32I single-cycle processor using Verilog HDL.

The processor is designed to execute instructions through a single-cycle datapath, integrating instruction decoding, control signal generation, arithmetic and logical operations, memory access, and register write-back.

The project was developed as part of the **Semiconductor School RISE Fellowship – Cohort 2**.

## 2. Project Objectives

- Understand the RV32I instruction set architecture.
- Design and implement the major components of a processor using Verilog HDL.
- Develop the processor datapath and control unit.
- Integrate instruction memory and data memory.
- Simulate and verify individual modules and processor functionality.

## 3. Processor Architecture

The processor follows a single-cycle architecture, in which an instruction is processed within one clock cycle.

The implementation includes the following major components:

- **Program Counter (PC):** Maintains the address of the current instruction.
- **Control Unit:** Generates control signals based on the instruction opcode and function fields.
- **ALU:** Performs arithmetic and logical operations.
- **Register File:** Contains 32 general-purpose 32-bit registers.
- **Immediate Generator:** Extracts and generates immediate values from instruction formats.
- **Instruction Memory:** Stores the instructions to be executed.
- **Data Memory:** Handles load and store operations.
- **Load-Store Unit (LSU):** Supports memory access operations with byte-enable control.
- **Next PC Logic:** Determines the address of the next instruction, including branch and jump targets.

## 4. Tools and Technologies

- Verilog HDL
- AMD Xilinx Vivado
- XSim Simulator
- RISC-V RV32I Instruction Set Architecture

## 5. Source Code Organization

The project source code is organized into three main sections:

- **RTL:** Verilog modules implementing the processor architecture.
- **Testbench:** Testbench modules for testing individual components and processor functionality.
- **Program Memory Files:** HEX files used to initialize instruction memory with sample programs.

## 6. Verification

The project includes separate testbenches for important processor components, including the ALU, register file, instruction memory, data memory, immediate generator, multiplexers, and program counter.

A processor-level testbench is also included to simulate program execution using memory initialization files.

## 7. Learning Outcomes

Through this project, I gained practical experience in:

- Digital design and Verilog HDL.
- Understanding the internal organization of a RISC-V processor.
- Processor datapath and control unit design.
- RTL debugging and simulation.
- Testbench development and functional verification.
- Understanding how instructions are fetched, decoded, and executed.

## 8. Fellowship

**Semiconductor School RISE Fellowship – Cohort 2**

This project was developed as part of the fellowship's learning and practical implementation activities.
