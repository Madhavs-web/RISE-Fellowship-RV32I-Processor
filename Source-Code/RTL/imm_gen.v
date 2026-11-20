`timescale 1ns / 1ps

module imm_gen (
    input  wire [31:0] instr,
    input  wire [2:0]  imm_src,
    output reg  [31:0] imm
);

    always @(*) begin
        case (imm_src)
            3'b000: imm = {{20{instr[31]}}, instr[31:20]};                                   // I-type (addi, lw, jalr)
            3'b001: imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};                      // S-type (sw, sh, sb)
            3'b010: imm = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};      // B-type (branch)
            3'b011: imm = {instr[31:12], 12'b0};                                             // U-type (lui, auipc) - FIXED: was J-type
            3'b100: imm = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};    // J-type (jal) - FIXED: was U-type
            default: imm = 32'd0;
        endcase
    end

endmodule