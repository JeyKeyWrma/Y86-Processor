# Y68-Processor

This repository contains the implementation of a Y86 processor in both sequential and pipelined versions. The Y86 processor is a simplified, educational instruction set architecture (ISA) designed to teach the basic concepts of computer organization and architecture.

## Table of Contents
1. Introduction
2. Requirements
3. Usage
4. Sequential Version
5. Pipelined Version

## Introduction
The Y86 processor is a simplified ISA that emulates the basic operations of a real-world processor. It consists of a set of instructions, a register file, memory, and control logic to execute the instructions. This repository provides two implementations of the Y86 processor: a sequential version and a pipelined version.

The **sequential** version executes instructions one after the other, following the standard fetch-decode-execute cycle. This version is simpler to understand and serves as a good starting point to grasp the fundamental concepts of the Y86 processor.

The **pipelined** version breaks down the fetch-decode-execute cycle into stages and overlaps the execution of multiple instructions. This enables higher instruction throughput and improved performance by allowing the processor to work on multiple instructions simultaneously. However, it introduces challenges such as data hazards, control hazards, and resource conflicts that need to be managed.

## Requirements

To run the Y86 processor implementations, you need the following:

1. An iverilog compiler.
2. GTKWave installed.
3. A computer system running a Unix-like operating system (e.g., Linux or macOS). Windows users may use a Unix-like environment such as Cygwin or Windows Subsystem for Linux (WSL).

## Usage

To use the sequential and pipelined versions of the Y86 processor, follow these steps:

1. Clone this repository to your local machine.
2. Navigate to the cloned repository's directory.

## Sequential Version

The sequential implementation of the Y-86 processor is a basic implementation where instructions are executed one at a time in
sequence. Each instruction is fetched from memory, decoded, and executed before moving on to the next instruction.
The sequential implementation of the Y-86 processor is a simple and efficient approach that can be used to teach the basics of
computer architecture and assembly language programming. Its advantages include simplicity, predictability, and efficiency for
certain types of applications.

The commands for running the sequential are as follows

```
cd seq
iverilog -o seq processor.v
vvp seq
```

For the sequential version there are testbenches for *fetch*, *decode* and *execute* modules and can be run as follows respectively

```
cd seq
iverilog -o fetch fetch_tb.v
vvp fetch
```
```
cd seq
iverilog -o decode decode_tb.v
vvp decode
```
```
cd seq
iverilog -o execute execute_tb.v
vvp execute
```
## Pipelined Version

In pipeline implementation of the y86 processor, the instruction execution process is divided into five stages: fetch, decode,
execute, memory, and writeback. Each instruction is broken down into smaller tasks, and each task is executed by a different
stage of the pipeline. This allows multiple instructions to be in different stages of execution at the same time, leading to
improved performance and throughput.
One of the main advantages of pipeline implementation is increased speed. Because each instruction is broken down into
smaller tasks, multiple instructions can be executing simultaneously, resulting in a higher rate of instruction throughput. This
leads to faster execution of programs and increased overall performance.
Another advantage is improved efficiency. Pipeline implementation allows for better resource utilization by minimizing idle time
and reducing the amount of time that resources are unused. Additionally, pipeline implementation allows for more efficient use
of resources such as memory and registers.

The commands for running the pipelined are as follows

```
cd pipe
iverilog -o pipe processor.v
vvp pipe
```

Each of the module can be verified simply by GTKWave using the command
```
gtkwave [VCD_FILE]
```

Where VCD_FILE is the file generated after executing the verilog file for each tesbench.
