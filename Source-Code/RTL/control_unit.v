`timescale 1ns / 1ps

module control_unit (
    input  wire [6:0] opcode,
    output reg        reg_write,
    output reg [2:0]  imm_src,
    output reg        alu_src_a,
    output reg        alu_src_b,
    output reg        mem_write,
    output reg        mem_read,
    output reg [1:0]  result_src,
    output reg        branch,
    output reg        jump,
    output reg        jalr,
    output reg [1:0]  alu_op
);

    always @(*) begin
        // Safe default control signal values
        reg_write   = 1'b0;
        imm_src     = 3'b000;
        alu_src_a   = 1'b0;
        alu_src_b   = 1'b0;
        mem_write   = 1'b0;
        mem_read    = 1'b0;
        result_src  = 2'b00;
        branch      = 1'b0;
        jump        = 1'b0;
        jalr        = 1'b0;
        alu_op      = 2'b00;

        case (opcode)
            7'b0110011: begin // R-type (add, sub, and, or, xor, sll, srl, sra, slt, sltu)
                reg_write   = 1'b1;
                alu_op      = 2'b10;
            end

            7'b0010011: begin // I-type ALU (addi, andi, ori, xori, slli, srli, srai, slti, sltiu)
                reg_write   = 1'b1;
                alu_src_b   = 1'b1;
                imm_src     = 3'b000;
                alu_op      = 2'b10;
            end

            7'b0000011: begin // Load (lw, lh, lb, lhu, lbu)
                reg_write   = 1'b1;
                alu_src_b   = 1'b1;
                imm_src     = 3'b000;
                mem_read    = 1'b1;
                result_src  = 2'b01;
                alu_op      = 2'b00;
            end

            7'b0100011: begin // Store (sw, sh, sb)
                reg_write   = 1'b0;
                alu_src_b   = 1'b1;
                imm_src     = 3'b001;
                mem_write   = 1'b1;
                alu_op      = 2'b00;
            end

            7'b1100011: begin // Branch (beq, bne, blt, bge, bltu, bgeu)
                branch      = 1'b1;
                imm_src     = 3'b010;
                alu_op      = 2'b01;
            end

            7'b1101111: begin // JAL (Jump and Link)
                reg_write   = 1'b1;
                jump        = 1'b1;
                imm_src     = 3'b100; // FIXED: J-type is now 3'b100 (was 3'b011)
                result_src  = 2'b10;
            end

            7'b1100111: begin // JALR (Jump and Link Register)
                reg_write   = 1'b1;
                jalr        = 1'b1;
                alu_src_b   = 1'b1;
                imm_src     = 3'b000; // I-type
                result_src  = 2'b10;
            end

            7'b0110111: begin // LUI (Load Upper Immediate)
                reg_write   = 1'b1;
                imm_src     = 3'b011; // FIXED: U-type is now 3'b011 (was 3'b100)
                alu_src_a   = 1'b0;   // rs1 forced to x0 in rv32i_core
                alu_src_b   = 1'b1;   // Use immediate
                alu_op      = 2'b00;  // Addition: 0 + imm
            end

            7'b0010111: begin // AUIPC (Add Upper Immediate to PC)
                reg_write   = 1'b1;
                imm_src     = 3'b011; // FIXED: U-type is now 3'b011 (was 3'b100)
                alu_src_a   = 1'b1;   // Use PC
                alu_src_b   = 1'b1;   // Use immediate
                alu_op      = 2'b00;  // Addition: PC + imm
            end

            default: ;
        endcase
    end

endmodule