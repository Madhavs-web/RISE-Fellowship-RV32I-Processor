`timescale 1ns / 1ps

module tb_mux();

    // Signals for 32-bit mux4
    reg  [31:0] d0_32, d1_32, d2_32, d3_32;
    reg  [1:0]  sel4;
    wire [31:0] y4_32;

    // Signals for 5-bit mux2 (e.g., register address mux)
    reg  [4:0]  d0_5, d1_5;
    reg         sel2;
    wire [4:0]  y2_5;

    // 1. 32-bit instantiation (default parameter)
    mux4 #(.WIDTH(32)) uut_mux4 (
        .d0(d0_32),
        .d1(d1_32),
        .d2(d2_32),
        .d3(d3_32),
        .sel(sel4),
        .y(y4_32)
    );

    // 2. 5-bit instantiation (overridden parameter)
    mux2 #(.WIDTH(5)) uut_mux2 (
        .d0(d0_5),
        .d1(d1_5),
        .sel(sel2),
        .y(y2_5)
    );

    initial begin
        // Initialize 32-bit inputs
        d0_32 = 32'hAAAA_0000;
        d1_32 = 32'hBBBB_1111;
        d2_32 = 32'hCCCC_2222;
        d3_32 = 32'hDDDD_3333;

        // Initialize 5-bit inputs
        d0_5 = 5'd10;
        d1_5 = 5'd25;

        // Test all 4 inputs of mux4
        sel4 = 2'b00; #10;
        sel4 = 2'b01; #10;
        sel4 = 2'b10; #10;
        sel4 = 2'b11; #10;

        // Test mux2
        sel2 = 1'b0; #10;
        sel2 = 1'b1; #10;

        $finish;
    end

endmodule