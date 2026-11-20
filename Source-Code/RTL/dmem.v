`timescale 1ns / 1ps

module dmem #(
    parameter DEPTH = 1024
)(
    input  wire        clk,
    input  wire        mem_write,
    input  wire [3:0]  wstrb,
    input  wire [31:0] addr,
    input  wire [31:0] wdata,
    output wire [31:0] rdata
);

    // Memory array of 32-bit words
    reg [31:0] mem [0:DEPTH-1];
    integer i;

    // FIXED: Initialize all data memory to zero to prevent X propagation
    initial begin
        for (i = 0; i < DEPTH; i = i + 1) begin
            mem[i] = 32'd0;
        end
    end

    // Asynchronous read (word-aligned address)
    assign rdata = mem[addr[31:2]];

    // Synchronous write with byte enables (wstrb)
    always @(posedge clk) begin
        if (mem_write) begin
            if (wstrb[0]) mem[addr[31:2]][ 7: 0] <= wdata[ 7: 0];
            if (wstrb[1]) mem[addr[31:2]][15: 8] <= wdata[15: 8];
            if (wstrb[2]) mem[addr[31:2]][23:16] <= wdata[23:16];
            if (wstrb[3]) mem[addr[31:2]][31:24] <= wdata[31:24];
        end
    end

endmodule