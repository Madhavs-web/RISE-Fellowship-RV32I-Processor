`timescale 1ns / 1ps

module alu (
    input  wire [31:0] a,
    input  wire [31:0] b,
    input  wire [3:0]  alu_ctrl,   // FIXED: was [2:0], must be [3:0] to match alu_decoder
    output reg  [31:0] result,
    output wire        zero
);

    always @(*) begin
        case (alu_ctrl)
            4'b0000: result = a + b;                                            // ADD
            4'b0001: result = a - b;                                            // SUB
            4'b0010: result = a & b;                                            // AND
            4'b0011: result = a | b;                                            // OR
            4'b0100: result = a ^ b;                                            // XOR
            4'b0101: result = a << b[4:0];                                      // SLL (Shift Left Logical)
            4'b0110: result = a >> b[4:0];                                      // SRL (Shift Right Logical)
            4'b0111: result = $signed(a) >>> b[4:0];                            // SRA (Shift Right Arithmetic)
            4'b1000: result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0;       // SLT (Set Less Than Signed)
            4'b1001: result = (a < b) ? 32'd1 : 32'd0;                         // SLTU (Set Less Than Unsigned)
            4'b1010: result = b;                                                // PASS_B
            default: result = 32'd0;
        endcase
    end

    // Zero flag: high when result is zero
    assign zero = (result == 32'd0);

endmodule