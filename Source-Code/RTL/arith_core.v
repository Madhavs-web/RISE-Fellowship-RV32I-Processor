`timescale 1ns / 1ps

module arith_core #(
    parameter INIT_FILE = "arith.hex"
)(
    input wire clk,
    input wire rst
);

    // Datapath wires
    wire [31:0] pc_current, pc_next;
    wire [31:0] instr;
    wire [31:0] rs1_data, rs2_data, imm_ext;
    wire [31:0] alu_in_b, alu_result;
    wire        alu_zero;
    
    // Control unit wires
    wire        reg_write;
    wire [2:0]  imm_src;
    wire        alu_src_a, alu_src_b;
    wire [1:0]  result_src, alu_op;
    wire [3:0]  alu_ctrl;

    // Unused control wires in pure arithmetic core
    wire mem_write, mem_read, branch, jump, jalr;

    // --- Instruction Fetch ---
    adder u_pc_adder (
        .a(pc_current),
        .b(32'd4),
        .y(pc_next)
    );

    pc_reg #(
        .RESET_VECTOR(32'h0000_0000)
    ) u_pc_reg (
        .clk(clk),
        .rst(rst),
        .pc_next(pc_next),
        .pc(pc_current)
    );

    imem #(
        .DEPTH(1024),
        .INIT_FILE(INIT_FILE)   // FIXED: pass hex file via parameter
    ) u_imem (
        .addr(pc_current),
        .rdata(instr)
    );

    // --- Decode ---
    control_unit u_control_unit (
        .opcode     (instr[6:0]),
        .reg_write  (reg_write),
        .imm_src    (imm_src),
        .alu_src_a  (alu_src_a),
        .alu_src_b  (alu_src_b),
        .mem_write  (mem_write),
        .mem_read   (mem_read),
        .result_src (result_src),
        .branch     (branch),
        .jump       (jump),
        .jalr       (jalr),
        .alu_op     (alu_op)
    );

    regfile u_regfile (
        .clk       (clk),
        .rst       (rst),
        .reg_write (reg_write),
        .rd_addr   (instr[11:7]),
        .rd_data   (alu_result),
        .rs1_addr  (instr[19:15]),
        .rs2_addr  (instr[24:20]),
        .rs1_data  (rs1_data),
        .rs2_data  (rs2_data)
    );

    imm_gen u_imm_gen (
        .instr   (instr),
        .imm_src (imm_src),
        .imm     (imm_ext)
    );

    // --- Execute ---
    alu_decoder u_alu_decoder (
        .alu_op   (alu_op),
        .funct3   (instr[14:12]),
        .funct7_5 (instr[30]),
        .opcode_5 (instr[5]),
        .alu_ctrl (alu_ctrl)
    );

    mux2 #(.WIDTH(32)) u_src_b_mux (
        .d0  (rs2_data),
        .d1  (imm_ext),
        .sel (alu_src_b),
        .y   (alu_in_b)
    );

    alu u_alu (
        .a        (rs1_data),
        .b        (alu_in_b),
        .alu_ctrl (alu_ctrl),
        .result   (alu_result),
        .zero     (alu_zero)     // FIXED: connected zero output
    );

endmodule