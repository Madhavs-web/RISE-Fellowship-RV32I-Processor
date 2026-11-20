`timescale 1ns / 1ps

module tb_rv32i;

    reg clk;
    reg rst;

    reg [31:0] cycle_count;
    reg [31:0] prev_pc;

    parameter clk_period = 10;
    parameter [31:0] MAX_CYCLES = 5000;
    
    // Default test program (portable relative filename, no hardcoded PC paths!)
    // To test another program, change this to "p1_arraysum.hex", "p2_gcd.hex", etc.
    parameter PROGRAM = "p3_fib.hex";

    // Instantiate Top-Level Design
    rv32i_top #(
        .INIT_FILE(PROGRAM)
    ) dut (
        .clk(clk),
        .rst(rst)
    );

    // Clock Generation
    always #(clk_period / 2) clk = ~clk;

    // Cycle Counter, Timeout & Auto-Stop Logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cycle_count <= 32'd0;
            prev_pc <= 32'hFFFF_FFFF;
        end else begin
            cycle_count <= cycle_count + 1;
            prev_pc <= dut.u_core.u_pc.pc;
            
            // AUTO-DETECT PROGRAM END:
            // All test programs end with an infinite loop (e.g. `done: beq x0, x0, done`).
            // If the PC hasn't changed from the previous cycle, the program is finished!
            if (dut.u_core.u_pc.pc == prev_pc && cycle_count > 5) begin
                finish_simulation();
            end
            
            // Timeout condition (safety net)
            if (cycle_count >= MAX_CYCLES) begin
                $display("----------------------------------------");
                $display("TIMEOUT: Program did not complete within %0d cycles.", MAX_CYCLES);
                $display("----------------------------------------");
                $finish;
            end
        end
    end

    // Reset Sequence
    initial begin
        clk = 0;
        rst = 1;
        #(clk_period * 5);
        rst = 0;
        $display("IMEM: Successfully loaded hex file: %s", PROGRAM);
    end

    // Task to gracefully end simulation and verify results
    task finish_simulation;
        integer r;
        begin
            $display("----------------------------------------");
            $display("PROGRAM FINISHED AT CYCLE %0d (Infinite loop detected at PC=%h)", cycle_count, dut.u_core.u_pc.pc);
            $display("----------------------------------------");
            
            // PROGRAM-SPECIFIC VERIFICATION
            // Matches relative filenames cleanly regardless of machine or directory structure
            if (PROGRAM == "p1_arraysum.hex" || PROGRAM == "sw/p1_arraysum.hex") begin
                if (dut.u_core.u_regfile.regs[10] == 550) $display("PASS: p1_arraysum x10 = 550");
                else $display("FAIL: p1_arraysum x10 = %0d (Expected 550)", dut.u_core.u_regfile.regs[10]);
            end 
            else if (PROGRAM == "p3_fib.hex" || PROGRAM == "sw/p3_fib.hex") begin
                if (dut.u_core.u_regfile.regs[10] == 15) $display("PASS: p3_fib x10 = 15");
                else $display("FAIL: p3_fib x10 = %0d (Expected 15)", dut.u_core.u_regfile.regs[10]);
            end
            else if (PROGRAM == "p2_gcd.hex" || PROGRAM == "sw/p2_gcd.hex") begin
                if (dut.u_core.u_regfile.regs[10] == 21) $display("PASS: p2_gcd x10 = 21");
                else $display("FAIL: p2_gcd x10 = %0d (Expected 21)", dut.u_core.u_regfile.regs[10]);
            end
            else if (PROGRAM == "p4_memcpy.hex" || PROGRAM == "sw/p4_memcpy.hex") begin
                if (dut.u_core.u_regfile.regs[10] == 13) $display("PASS: p4_memcpy x10 = 13");
                else $display("FAIL: p4_memcpy x10 = %0d (Expected 13)", dut.u_core.u_regfile.regs[10]);
            end
            else if (PROGRAM == "p5_coverage.hex" || PROGRAM == "sw/p5_coverage.hex") begin
                if (dut.u_core.u_regfile.regs[10] == 63) $display("PASS: p5_coverage x10 = 63 (0x3F)");
                else $display("FAIL: p5_coverage x10 = %0d (Expected 63)", dut.u_core.u_regfile.regs[10]);
            end
            else if (PROGRAM == "p6_gapfill.hex" || PROGRAM == "sw/p6_gapfill.hex") begin
                if (dut.u_core.u_regfile.regs[10] == 32'hFFFFFFD0) $display("PASS: p6_gapfill x10 = 0xFFFFFFD0");
                else $display("FAIL: p6_gapfill x10 = 0x%h (Expected 0xFFFFFFD0)", dut.u_core.u_regfile.regs[10]);
            end
            
            $display("========================================");
            $display("       REGISTER FILE DUMP AT END        ");
            $display("========================================");
            for (r = 0; r < 32; r = r + 1) begin
                $display("x%0d = %0d (0x%h)", r, dut.u_core.u_regfile.regs[r], dut.u_core.u_regfile.regs[r]);
            end
            $display("========================================");
            
            $finish;
        end
    endtask

endmodule