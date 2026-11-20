`timescale 1ns / 1ps

module alu_decoder (
    input  wire [1:0]  alu_op,
    input  wire [2:0]  funct3,
    input  wire        funct7_5,
    input  wire        opcode_5,
    output reg  [3:0]  alu_ctrl
);

    always @(*) begin
        case (alu_op)
            2'b00: alu_ctrl = 4'b0000; // ADD (Loads, Stores, LUI, AUIPC)
            2'b01: alu_ctrl = 4'b0001; // SUB (Branch comparison)
            2'b10: begin // R-type / I-type arithmetic and logic
                case (funct3)
                    3'b000:  alu_ctrl = (opcode_5 && funct7_5) ? 4'b0001 : 4'b0000; // SUB (R-type only) vs ADD
                    3'b001:  alu_ctrl = 4'b0101;                                     // SLL / SLLI
                    3'b010:  alu_ctrl = 4'b1000;                                     // SLT / SLTI
                    3'b011:  alu_ctrl = 4'b1001;                                     // SLTU / SLTIU
                    3'b100:  alu_ctrl = 4'b0100;                                     // XOR / XORI
                    3'b101:  alu_ctrl = funct7_5 ? 4'b0111 : 4'b0110;                // SRA(I) vs SRL(I)
                    3'b110:  alu_ctrl = 4'b0011;                                     // OR / ORI
                    3'b111:  alu_ctrl = 4'b0010;                                     // AND / ANDI
                    default: alu_ctrl = 4'b0000;
                endcase
            end
            default: alu_ctrl = 4'b0000;
        endcase
    end

endmodule