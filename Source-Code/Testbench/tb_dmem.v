`timescale 1ns / 1ps

module tb_dmem();

    reg         clk;
    reg         mem_write;
    reg  [3:0]  wstrb;
    reg  [31:0] addr;
    reg  [31:0] wdata;
    wire [31:0] rdata;

    dmem #(.DEPTH(64)) uut (
        .clk(clk),
        .mem_write(mem_write),
        .wstrb(wstrb),
        .addr(addr),
        .wdata(wdata),
        .rdata(rdata)
    );

    always #5 clk = ~clk;

    initial begin
        clk       = 0;
        mem_write = 0;
        wstrb     = 4'b0000;
        addr      = 32'd0;
        wdata     = 32'd0;

        #10;
        // 1. Write full 32-bit word 0x11223344 at address 0
        @(posedge clk);
        mem_write = 1;
        wstrb     = 4'b1111;
        addr      = 32'h0000_0000;
        wdata     = 32'h1122_3344;

        // 2. Modify ONLY Byte 1 (wstrb = 4'b0010) with 0xFF
        @(posedge clk);
        wstrb     = 4'b0010;
        wdata     = 32'h0000_FF00;

        @(posedge clk);
        mem_write = 0;
        wstrb     = 4'b0000;

        // Result at address 0 should now be 0x1122_FF44 (only byte 1 changed)
        #5;
        $display("Memory[0] after byte-store: 0x%08h", rdata);

        #10;
        $finish;
    end

endmodule