`timescale 1ns / 1ps

module tb_pc_reg();

    reg         clk;
    reg         rst;
    reg  [31:0] pc_next;
    wire [31:0] pc;

    // Instantiate with a custom reset vector (e.g., 0x8000_0000)
    pc_reg #(
        .RESET_VECTOR(32'h8000_0000)
    ) uut (
        .clk(clk),
        .rst(rst),
        .pc_next(pc_next),
        .pc(pc)
    );

    always #5 clk = ~clk;

    initial begin
        clk     = 0;
        rst     = 1;
        pc_next = 32'h0000_0004;

        #15;
        rst = 0; // PC should now be 32'h8000_0000

        @(posedge clk);
        pc_next = 32'h8000_0004;

        @(posedge clk);
        pc_next = 32'h8000_0008;

        @(posedge clk);
        rst = 1; // Trigger reset again

        #10;
        $finish;
    end

endmodule