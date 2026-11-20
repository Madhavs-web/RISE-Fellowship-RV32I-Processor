`timescale 1ns / 1ps

module imem #(
    parameter DEPTH     = 1024,
    parameter INIT_FILE = "p3_fib.hex"
)(
    input  wire [31:0] addr,
    output wire [31:0] rdata
);

    reg [31:0] mem [0:DEPTH-1];
    integer i;

    initial begin
        for (i = 0; i < DEPTH; i = i + 1) begin
            mem[i] = 32'h0000_0013;
        end
       
        $readmemh(INIT_FILE, mem);
    end

    
    assign rdata = mem[addr[31:2]];

endmodule