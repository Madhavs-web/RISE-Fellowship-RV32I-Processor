module branch_unit (
    input  wire [2:0]  funct3,
    input  wire [31:0] rs1_data,
    input  wire [31:0] rs2_data,
    input  wire        branch,
    output wire        branch_taken
);
    reg cond_met;

    always @(*) begin
        case (funct3)
            3'b000: cond_met = (rs1_data == rs2_data); // BEQ
            3'b001: cond_met = (rs1_data != rs2_data); // BNE (Loop continuation check)
            3'b100: cond_met = ($signed(rs1_data) < $signed(rs2_data));  // BLT
            3'b101: cond_met = ($signed(rs1_data) >= $signed(rs2_data)); // BGE
            3'b110: cond_met = (rs1_data < rs2_data);  // BLTU
            3'b111: cond_met = (rs1_data >= rs2_data); // BGEU
            default: cond_met = 1'b0;
        endcase
    end

    assign branch_taken = branch & cond_met;

endmodule