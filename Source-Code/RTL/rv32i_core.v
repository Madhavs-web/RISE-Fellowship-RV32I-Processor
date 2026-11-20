`timescale 1ns / 1ps

module rv32i_core (
    input  wire        clk,
    input  wire        rst,
    
    // Instruction Memory Interface
    output wire [31:0] instr_addr,
    input  wire [31:0] instr_rdata,
    
    // Data Memory Interface
    output wire [31:0] data_addr,
    output wire [31:0] data_wdata,
    output wire [3:0]  data_be,
    output wire        data_we,
    input  wire [31:0] data_rdata
);

    // ==========================================
    // 1. Instruction Field Extraction
    // ==========================================
    wire [31:0] instr    = instr_rdata;
    wire [6:0]  opcode   = instr[6:0];
    wire [4:0]  rd       = instr[11:7];
    wire [2:0]  funct3   = instr[14:12];

    // FIXED: For LUI, bits [19:15] are part of the 20-bit immediate, NOT an rs1 field.
    // If we read regs[instr[19:15]] for LUI, we'd get a garbage register value.
    // Force rs1 to x0 for LUI so ALU computes 0 + imm = imm.
    wire [4:0]  rs1      = (opcode == 7'b0110111) ? 5'd0 : instr[19:15];
    wire [4:0]  rs2      = instr[24:20];
    wire [6:0]  funct7   = instr[31:25];
    wire        funct7_5 = instr[30];
    wire        opcode_5 = instr[5];

    // ==========================================
    // 2. Control Wires
    // ==========================================
    wire        reg_write, alu_src_a, alu_src_b, mem_write, mem_read;
    wire        branch, jump, jalr, branch_taken;
    wire [2:0]  imm_src;
    wire [1:0]  result_src, alu_op;
    wire [3:0]  alu_ctrl;

    // ==========================================
    // 3. Datapath Wires
    // ==========================================
    wire [31:0] pc_current, pc_next, pc_plus4;
    wire [31:0] rs1_data, rs2_data, imm_ext;
    wire [31:0] alu_in_a, alu_in_b, alu_result;
    wire        alu_zero;
    wire [31:0] lsu_mem_wdata, lsu_load_data, writeback_data;
    wire [3:0]  lsu_wstrb;

    // ==========================================
    // 4. External Memory Assignments
    // ==========================================
    assign instr_addr = pc_current;
    assign data_addr  = alu_result;
    assign data_wdata = lsu_mem_wdata;
    assign data_be    = lsu_wstrb;
    assign data_we    = mem_write;

    // ==========================================
    // 5. Module Instantiations
    // ==========================================
    
    pc_reg #(
        .RESET_VECTOR(32'h0000_0000)
    ) u_pc (
        .clk(clk),
        .rst(rst),
        .pc_next(pc_next),
        .pc(pc_current)
    );

    next_pc u_next_pc (
        .pc(pc_current),
        .imm(imm_ext),
        .rs1_data(rs1_data),
        .branch_taken(branch_taken),
        .jump(jump),
        .jalr(jalr),
        .pc_plus4(pc_plus4),
        .pc_next(pc_next)
    );

    control_unit u_control_unit (
        .opcode(opcode),
        .reg_write(reg_write),
        .imm_src(imm_src),
        .alu_src_a(alu_src_a),
        .alu_src_b(alu_src_b),
        .mem_write(mem_write),
        .mem_read(mem_read),
        .result_src(result_src),
        .branch(branch),
        .jump(jump),
        .jalr(jalr),
        .alu_op(alu_op)
    );

    regfile u_regfile (
        .clk(clk),
        .rst(rst),
        .reg_write(reg_write),
        .rd_addr(rd),
        .rd_data(writeback_data),
        .rs1_addr(rs1),
        .rs2_addr(rs2),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );

    imm_gen u_imm_gen (
        .instr(instr),
        .imm_src(imm_src),
        .imm(imm_ext)
    );

    alu_decoder u_alu_decoder (
        .alu_op(alu_op),
        .funct3(funct3),
        .funct7_5(funct7_5),
        .opcode_5(opcode_5),
        .alu_ctrl(alu_ctrl)
    );

    // Mux for ALU Input A: selects rs1_data (or 0 for LUI) or PC (for AUIPC)
    mux2 #(.WIDTH(32)) u_src_a_mux (
        .d0(rs1_data),
        .d1(pc_current),
        .sel(alu_src_a),
        .y(alu_in_a)
    );

    // Mux for ALU Input B: selects rs2_data or immediate
    mux2 #(.WIDTH(32)) u_src_b_mux (
        .d0(rs2_data),
        .d1(imm_ext),
        .sel(alu_src_b),
        .y(alu_in_b)
    );

    alu u_alu (
        .a(alu_in_a),
        .b(alu_in_b),
        .alu_ctrl(alu_ctrl),
        .result(alu_result),
        .zero(alu_zero)          // FIXED: connected zero output (was unconnected)
    );

    branch_unit u_branch_unit (
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .funct3(funct3),
        .branch(branch),
        .branch_taken(branch_taken)
    );

    lsu u_lsu (
        .store_data(rs2_data),
        .mem_rdata(data_rdata),
        .addr_lsb(alu_result[1:0]),
        .funct3(funct3),
        .mem_write(mem_write),
        .mem_wdata(lsu_mem_wdata),
        .wstrb(lsu_wstrb),
        .load_data(lsu_load_data)
    );

    // Writeback multiplexer driving rd input:
    // 00: ALU result, 01: Data Memory load, 10: PC + 4 (JAL/JALR)
    mux4 #(.WIDTH(32)) u_writeback_mux (
        .d0(alu_result),
        .d1(lsu_load_data),
        .d2(pc_plus4),
        .d3(32'd0),
        .sel(result_src),
        .y(writeback_data)
    );

    // --- INSTRUCTION EXECUTION TRACE MONITOR ---
    always @(posedge clk) begin
        if (!rst) begin
            $display("TIME=%0t | PC=%h | Instr=%h | Opcode=%b | rd=x%0d | ALU_Res=%0d | WriteData=%0d | RegWr=%b", 
                     $time, pc_current, instr, opcode, rd, alu_result, writeback_data, reg_write);
        end
    end

endmodule