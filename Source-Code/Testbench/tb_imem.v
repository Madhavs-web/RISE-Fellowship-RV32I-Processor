`timescale 1ns / 1ps

module tb_imem();

    reg  [31:0] addr;
    wire [31:0] rdata;

    // Instantiate imem with program.hex
    imem #(
        .DEPTH(64),
        .INIT_FILE("program.hex")
    ) uut (
        .addr(addr),
        .rdata(rdata)
    );

    integer i;

    initial begin
        $display("--- Testing Normal Word-Aligned Fetch (mem[addr[31:2]]) ---");
        // Read the 6 instructions sequentially by incrementing PC by 4
        for (i = 0; i < 6; i = i + 1) begin
            addr = i * 4;
            #10;
            $display("PC = 0x%08h | Instruction = 0x%08h", addr, rdata);
        end

        #20;
        $finish;
    end

endmodule