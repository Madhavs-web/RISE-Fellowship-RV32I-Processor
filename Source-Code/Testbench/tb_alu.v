`timescale 1ns / 1ps

`define ALU_ADD    4'b0000
`define ALU_SUB    4'b0001
`define ALU_OR     4'b0010
`define ALU_AND    4'b0011
`define ALU_XOR    4'b0100
`define ALU_SLL    4'b0101
`define ALU_SRL    4'b0110
`define ALU_SRA    4'b0111
`define ALU_SLT    4'b1000
`define ALU_SLTU   4'b1001
`define ALU_PASS_B 4'b1010

module tb_alu();

    reg  [31:0] a;
    reg  [31:0] b;
    reg  [3:0]  alu_ctrl;
    wire [31:0] result;

    alu uut (
        .a(a),
        .b(b),
        .alu_ctrl(alu_ctrl),
        .result(result)
    );

    // Task to apply vectors and advance simulation time
    task apply_vector;
        input [31:0] in_a;
        input [31:0] in_b;
        input [3:0]  in_ctrl;
        begin
            a = in_a;
            b = in_b;
            alu_ctrl = in_ctrl;
            #10;
        end
    endtask

    initial begin
        $monitor("Time=\%0t \vert{} a=\%h \vert{} b=\%h \vert{} ctrl=\%b \vert{} result=\%h", $time, a, b, alu_ctrl, result);

        // 1. ALU_ADD
        apply_vector(32'h0000_0000, 32'h0000_0000, `ALU_ADD); // Zero boundary
        apply_vector(32'h7FFF_FFFF, 32'h0000_0001, `ALU_ADD); // Max Signed + 1
        apply_vector(32'hFFFF_FFFF, 32'h0000_0001, `ALU_ADD); // All Ones (-1) + 1
        apply_vector(32'h8000_0000, 32'h7FFF_FFFF, `ALU_ADD); // Min Signed + Max Signed

        // 2. ALU_SUB
        apply_vector(32'h0000_0000, 32'h0000_0000, `ALU_SUB);
        apply_vector(32'h8000_0000, 32'h0000_0001, `ALU_SUB); // Min Signed - 1
        apply_vector(32'h7FFF_FFFF, 32'hFFFF_FFFF, `ALU_SUB); // Max Signed - (-1)
        apply_vector(32'h0000_0000, 32'hFFFF_FFFF, `ALU_SUB); // 0 - (-1)

        // 3. ALU_AND
        apply_vector(32'hFFFF_FFFF, 32'h0000_0000, `ALU_AND);
        apply_vector(32'h7FFF_FFFF, 32'h8000_0000, `ALU_AND); // Disjoint bits
        apply_vector(32'hAAAAAAAA, 32'h55555555, `ALU_AND); // Alternating bits
        apply_vector(32'hFFFF_FFFF, 32'hFFFF_FFFF, `ALU_AND);

        // 4. ALU_OR
        apply_vector(32'h0000_0000, 32'hFFFF_FFFF, `ALU_OR);
        apply_vector(32'h7FFF_FFFF, 32'h8000_0000, `ALU_OR);
        apply_vector(32'hAAAAAAAA, 32'h55555555, `ALU_OR);
        apply_vector(32'h0000_0000, 32'h0000_0000, `ALU_OR);

        // 5. ALU_XOR
        apply_vector(32'hFFFF_FFFF, 32'h0000_0000, `ALU_XOR);
        apply_vector(32'h7FFF_FFFF, 32'h8000_0000, `ALU_XOR);
        apply_vector(32'hAAAAAAAA, 32'h55555555, `ALU_XOR);
        apply_vector(32'hFFFF_FFFF, 32'hFFFF_FFFF, `ALU_XOR);

        // 6. ALU_SLL
        apply_vector(32'hFFFF_FFFF, 32'h0000_0001, `ALU_SLL);
        apply_vector(32'h8000_0000, 32'h0000_0001, `ALU_SLL);
        apply_vector(32'h7FFF_FFFF, 32'h0000_001F, `ALU_SLL); // Shift by 31 (max shift)
        apply_vector(32'h0000_0000, 32'h0000_0010, `ALU_SLL);

        // 7. ALU_SRL
        apply_vector(32'hFFFF_FFFF, 32'h0000_0001, `ALU_SRL);
        apply_vector(32'h8000_0000, 32'h0000_001F, `ALU_SRL); // Shift by 31
        apply_vector(32'h7FFF_FFFF, 32'h0000_0004, `ALU_SRL);
        apply_vector(32'h0000_0000, 32'h0000_0010, `ALU_SRL);

        // 8. ALU_SRA
        apply_vector(32'hFFFF_FFFF, 32'h0000_0001, `ALU_SRA); // Sign bit 1
        apply_vector(32'h8000_0000, 32'h0000_001F, `ALU_SRA); // Sign bit 1, shift max
        apply_vector(32'h7FFF_FFFF, 32'h0000_0004, `ALU_SRA); // Sign bit 0
        apply_vector(32'h0000_0000, 32'h0000_0010, `ALU_SRA); // Zero

        // 9. ALU_SLT (Signed comparison)
        apply_vector(32'h8000_0000, 32'h7FFF_FFFF, `ALU_SLT); // Min < Max (True)
        apply_vector(32'h7FFF_FFFF, 32'h8000_0000, `ALU_SLT); // Max < Min (False)
        apply_vector(32'hFFFF_FFFF, 32'h0000_0000, `ALU_SLT); // -1 < 0 (True)
        apply_vector(32'h0000_0000, 32'h0000_0000, `ALU_SLT); // 0 < 0 (False)

        // 10. ALU_SLTU (Unsigned comparison)
        apply_vector(32'h8000_0000, 32'h7FFF_FFFF, `ALU_SLTU); // 2G < 2G-1 (False)
        apply_vector(32'h7FFF_FFFF, 32'h8000_0000, `ALU_SLTU); // 2G-1 < 2G (True)
        apply_vector(32'hFFFF_FFFF, 32'h0000_0000, `ALU_SLTU); // MaxUnsigned < 0 (False)
        apply_vector(32'h0000_0000, 32'hFFFF_FFFF, `ALU_SLTU); // 0 < MaxUnsigned (True)

        // 11. ALU_PASS_B
        apply_vector(32'h0000_0000, 32'hFFFF_FFFF, `ALU_PASS_B);
        apply_vector(32'hFFFF_FFFF, 32'h8000_0000, `ALU_PASS_B);
        apply_vector(32'h7FFF_FFFF, 32'h7FFF_FFFF, `ALU_PASS_B);
        apply_vector(32'h8000_0000, 32'h0000_0000, `ALU_PASS_B);

        $finish;
    end

endmodule