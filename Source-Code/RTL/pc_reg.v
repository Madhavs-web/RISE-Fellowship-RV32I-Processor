`timescale 1ns / 1ps

module pc_reg #(
    parameter RESET_VECTOR = 32'h0000_0000  
)(
    input  wire        clk,
    input  wire        rst,
    input  wire [31:0] pc_next,
    output reg  [31:0] pc
);

    initial begin
        pc = RESET_VECTOR;
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc <= RESET_VECTOR;
        end else begin
            pc <= pc_next;
        end
    end

endmodule