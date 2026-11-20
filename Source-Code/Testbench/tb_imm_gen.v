`timescale 1ns / 1ps

`define IMM_I 3'b000
`define IMM_S 3'b001
`define IMM_B 3'b010
`define IMM_J 3'b011
`define IMM_U 3'b100

module tb_imm_gen();

    reg  [31:0] instr;
    reg  [2:0]  imm_src;
    wire [31:0] imm;

    imm_gen uut (
        .instr(instr),
        .imm_src(imm_src),
        .imm(imm)
    );

    initial begin
        $monitor("Time=%0t | imm_src=%b | instr=%h | imm(hex)=%h | imm(dec)=%0d", 
                 $time, imm_src, instr, imm, $signed(imm));

        // 1. I-type: addi x1, x2, -4 (imm = -4 = 32'hFFFF_FFFC)
        instr = 32'hFFC10093; imm_src = `IMM_I; #10;

        // 2. S-type: sw x2, 8(x1) (imm = +8 = 32'h0000_0008)
        instr = 32'h0020A423; imm_src = `IMM_S; #10;

        // 3. B-type: Question 3 Test Vector (32'hFE008CE3) -> should produce -8
        instr = 32'hFE008CE3; imm_src = `IMM_B; #10;

        // 4. U-type: lui x1, 0x12345 (imm = 32'h1234_5000)
        instr = 32'h123450B7; imm_src = `IMM_U; #10;

        // 5. J-type: jal x1, -4 (imm = -4 = 32'hFFFF_FFFC)
        instr = 32'hFFDFF0EF; imm_src = `IMM_J; #10;

        $finish;
    end

endmodule