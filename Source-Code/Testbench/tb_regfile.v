`timescale 1ns / 1ps

module tb_regfile();

    reg         clk;
    reg         rst;
    reg         reg_write;
    reg  [4:0]  rd_addr;
    reg  [31:0] rd_data;
    reg  [4:0]  rs1_addr;
    reg  [4:0]  rs2_addr;
    wire [31:0] rs1_data;
    wire [31:0] rs2_data;

    regfile uut (
        .clk(clk),
        .rst(rst),
        .reg_write(reg_write),
        .rd_addr(rd_addr),
        .rd_data(rd_data),
        .rs1_addr(rs1_addr),
        .rs2_addr(rs2_addr),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );

    // 10ns Clock Period
    always #5 clk = ~clk;

    initial begin
        clk       = 0;
        rst       = 1;
        reg_write = 0;
        rd_addr   = 5'd0;
        rd_data   = 32'd0;
        rs1_addr  = 5'd0;
        rs2_addr  = 5'd0;

        $monitor("Time=%0t | rst=%b we=%b rd=%0d wdata=%h | rs1=%0d rdata1=%h | rs2=%0d rdata2=%h",
                 $time, rst, reg_write, rd_addr, rd_data, rs1_addr, rs1_data, rs2_addr, rs2_data);

        // 1. Release reset
        #20;
        rst = 0;
        #10;

        // 2. Write to x5 and x6
        @(posedge clk);
        reg_write = 1;
        rd_addr   = 5'd5;
        rd_data   = 32'hDEAD_BEEF;

        @(posedge clk);
        rd_addr   = 5'd6;
        rd_data   = 32'hCAFE_BABE;

        // 3. Attempt to write to x0
        @(posedge clk);
        rd_addr   = 5'd0;
        rd_data   = 32'hFFFF_FFFF;

        @(posedge clk);
        reg_write = 0;

        // 4. Test same-cycle read/write timing on x5 (Question 2 verification)
        #2;
        rs1_addr = 5'd5; // Combinational read observes old value 0xDEADBEEF
        rd_addr  = 5'd5;
        rd_data  = 32'h1234_5678;
        reg_write = 1;

        #3; // Mid-cycle check: rs1_data must remain 0xDEADBEEF
        @(posedge clk); // Clock edge commits new data
        #1;             // Post-edge check: rs1_data now reflects 0x12345678
        reg_write = 0;

        // 5. Verify x0 immutability under direct read
        #5;
        rs1_addr = 5'd0;
        rs2_addr = 5'd6;

        #20;
        $finish;
    end

endmodule