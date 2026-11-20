`timescale 1ns / 1ps

module rv32i_top #(
    parameter INIT_FILE = "p3_fib.hex"
)(
    input wire clk,
    input wire rst
);

    // ==========================================
    // Interconnect Wires
    // ==========================================
    // Instruction Memory Interface
    wire [31:0] instr_addr;
    wire [31:0] instr_rdata;
    
    // Data Memory Interface
    wire [31:0] data_addr;
    wire [31:0] data_wdata;
    wire [3:0]  data_be;
    wire        data_we;
    wire [31:0] data_rdata;

    // ==========================================
    // Core Instantiation
    // ==========================================
    rv32i_core u_core (
        .clk         (clk),
        .rst         (rst),
        .instr_addr  (instr_addr),
        .instr_rdata (instr_rdata),
        .data_addr   (data_addr),
        .data_wdata  (data_wdata),
        .data_be     (data_be),
        .data_we     (data_we),
        .data_rdata  (data_rdata)
    );

    // ==========================================
    // Memory Instantiations
    // ==========================================
    
    // Instruction Memory (1024 words)
    imem #(
        .DEPTH(1024),
        .INIT_FILE(INIT_FILE)
    ) u_imem (
        .addr  (instr_addr),
        .rdata (instr_rdata)
    );

    // Data Memory (1024 words)
    // Base address is 0x00000000 in its own space, so we pass data_addr directly.
    dmem #(
        .DEPTH(1024)
    ) u_dmem (
        .clk       (clk),
        .mem_write (data_we),
        .wstrb     (data_be),
        .addr      (data_addr),
        .wdata     (data_wdata),
        .rdata     (data_rdata)
    );

endmodule