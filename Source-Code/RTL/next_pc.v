module next_pc (
    input  wire [31:0] pc,
    input  wire [31:0] imm,
    input  wire [31:0] rs1_data,
    input  wire        branch_taken,
    input  wire        jump,
    input  wire        jalr,
    output wire [31:0] pc_plus4,
    output reg  [31:0] pc_next
);

    // CRITICAL: RISC-V instructions are 4 bytes, so next sequential instruction is PC + 4
    assign pc_plus4 = pc + 32'd4;

    // Target address calculation for branches and JAL
    wire [31:0] target_pc = pc + imm;

    // Target address calculation for JALR (rs1 + imm, with LSB cleared)
    wire [31:0] jalr_target = (rs1_data + imm) & ~32'd1;

    always @(*) begin
        if (jalr) begin
            pc_next = jalr_target;
        end else if (jump || branch_taken) begin
            pc_next = target_pc;
        end else begin
            pc_next = pc_plus4;
        end
    end

endmodule