`timescale 1ns/1ps

module tb_arith_core();
    reg clk;
    reg rst;
    integer i, passed, failed;
    
    // Array to hold the hand-calculated expected values
    reg [31:0] expected [0:13];

    // Instantiate the core
    arith_core dut (
        .clk(clk),
        .rst(rst)
    );

    // Generate clock
    always #5 clk = ~clk;

    initial begin
        // Set up expected values for x0 through x13
        expected[0]  = 0;
        expected[1]  = 15;
        expected[2]  = -3;
        expected[3]  = 12;
        expected[4]  = 18;
        expected[5]  = 13;
        expected[6]  = -1;
        expected[7]  = -14;
        expected[8]  = 1;
        expected[9]  = 0;
        expected[10] = 240;
        expected[11] = 32'h0FFFFFFF; // 268435453
        expected[12] = -1;
        expected[13] = 7;

        clk = 0;
        rst = 1;
        passed = 0;
        failed = 0;
        
        #10 rst = 0;

        // Wait enough clock cycles for the 14 instructions to finish fetching and executing
        #150; 

        // Read hierarchical paths to compare core registers against expectations
        for (i = 0; i <= 13; i = i + 1) begin
            if (dut.u_regfile.regs[i] === expected[i]) begin
                $display("PASS: x%0d = %0d (Hex: %h)", i, dut.u_regfile.regs[i], dut.u_regfile.regs[i]);
                passed = passed + 1;
            end else begin
                $display("FAIL: x%0d = %0d (Hex: %h) | Expected: %0d (Hex: %h)", 
                          i, dut.u_regfile.regs[i], dut.u_regfile.regs[i], expected[i], expected[i]);
                failed = failed + 1;
            end
        end
        
        $display("--------------------------------");
        $display("FINAL TALLY: %0d PASSED, %0d FAILED", passed, failed);
        $display("--------------------------------");
        $finish;
    end
endmodule