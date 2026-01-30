# CORDIC
The CORDIC (Coordinate Rotation Digital Computer) algorithm is a hardware-efficient method to compute trigonometric functions like sine and cosine using only adders, subtractors, and bit-shifters—no multipliers required.

This repository implements a synthesizable, 16-bit, 16-stage pipelined CORDIC in Verilog. The design has been tested with a static SystemVerilog testbench, verified using UVM-based testbenches, and validated against MATLAB simulations for accuracy.

Features:

* High-throughput pipelined design
* Fixed-point sine and cosine calculation
* Full functional verification with UVM
* MATLAB validation for correctness
