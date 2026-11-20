`timescale 1ns / 1ps

module regfile (
    input  wire        clk,
    input  wire        rst,
    input  wire        reg_write,
    input  wire [4:0]  rs1_addr,
    input  wire [4:0]  rs2_addr,
    input  wire [4:0]  rd_addr,
    input  wire [31:0] rd_data,
    output wire [31:0] rs1_data,
    output wire [31:0] rs2_data
);

    // 32 general-purpose 32-bit registers
    reg [31:0] regs [0:31];
    integer i;

    // FIXED: Initialize all registers to zero at startup to prevent X
    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            regs[i] = 32'd0;
        end
    end

    // Combinational reads: register x0 is always hardwired to 0
    assign rs1_data = (rs1_addr != 5'd0) ? regs[rs1_addr] : 32'd0;
    assign rs2_data = (rs2_addr != 5'd0) ? regs[rs2_addr] : 32'd0;

    // Synchronous write on positive clock edge or active-high reset
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1) begin
                regs[i] <= 32'd0;
            end
        end else if (reg_write && (rd_addr != 5'd0)) begin
            regs[rd_addr] <= rd_data;
            $display("REGWRITE: x%0d <= %0d (0x%h) at time %0t", rd_addr, rd_data, rd_data, $time);
        end
    end

endmodule