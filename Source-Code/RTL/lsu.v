`timescale 1ns / 1ps

module lsu (
    input  wire [31:0] store_data, // the full 32-bit rs2 data
    input  wire [31:0] mem_rdata,  // aligned word from dmem
    input  wire [1:0]  addr_lsb,   // bottom 2 bits of address
    input  wire [2:0]  funct3,
    input  wire        mem_write,
    output reg  [31:0] mem_wdata,
    output reg  [3:0]  wstrb,
    output reg  [31:0] load_data
);

    // ==========================================
    // STORE SIDE LOGIC
    // ==========================================
    always @(*) begin
        // Default to not writing anything.
        // This handles the requirement that wstrb must be 4'b0000 
        // whenever mem_write is low.
        wstrb = 4'b0000;
        mem_wdata = 32'h00000000;

        if (mem_write == 1'b1) begin
            case (funct3)
                3'b000: begin // SB: Store Byte (1 lane selected by addr_lsb)
                    if (addr_lsb == 2'b00) begin
                        wstrb = 4'b0001;
                        mem_wdata[7:0] = store_data[7:0];
                    end
                    else if (addr_lsb == 2'b01) begin
                        wstrb = 4'b0010;
                        mem_wdata[15:8] = store_data[7:0];
                    end
                    else if (addr_lsb == 2'b10) begin
                        wstrb = 4'b0100;
                        mem_wdata[23:16] = store_data[7:0];
                    end
                    else if (addr_lsb == 2'b11) begin
                        wstrb = 4'b1000;
                        mem_wdata[31:24] = store_data[7:0];
                    end
                end
                
                3'b001: begin // SH: Store Halfword (2 lanes selected by addr_lsb[1])
                    if (addr_lsb[1] == 1'b0) begin
                        wstrb = 4'b0011;
                        mem_wdata[15:0] = store_data[15:0];
                    end
                    else begin
                        wstrb = 4'b1100;
                        mem_wdata[31:16] = store_data[15:0];
                    end
                end
                
                3'b010: begin // SW: Store Word (all 4 lanes)
                    wstrb = 4'b1111;
                    mem_wdata = store_data;
                end
                
                default: wstrb = 4'b0000;
            endcase
        end
    end

    // ==========================================
    // LOAD SIDE LOGIC
    // ==========================================
    always @(*) begin
        load_data = 32'h00000000; // safe default
        
        case (funct3)
            3'b000: begin // LB: Sign extend byte[cite: 3]
                if (addr_lsb == 2'b00) load_data = {{24{mem_rdata[7]}}, mem_rdata[7:0]};
                else if (addr_lsb == 2'b01) load_data = {{24{mem_rdata[15]}}, mem_rdata[15:8]};
                else if (addr_lsb == 2'b10) load_data = {{24{mem_rdata[23]}}, mem_rdata[23:16]};
                else if (addr_lsb == 2'b11) load_data = {{24{mem_rdata[31]}}, mem_rdata[31:24]};
            end
            
            3'b100: begin // LBU: Zero extend byte[cite: 3]
                if (addr_lsb == 2'b00) load_data = {24'h000000, mem_rdata[7:0]};
                else if (addr_lsb == 2'b01) load_data = {24'h000000, mem_rdata[15:8]};
                else if (addr_lsb == 2'b10) load_data = {24'h000000, mem_rdata[23:16]};
                else if (addr_lsb == 2'b11) load_data = {24'h000000, mem_rdata[31:24]};
            end
            
            3'b001: begin // LH: Sign extend halfword[cite: 3]
                if (addr_lsb[1] == 1'b0) load_data = {{16{mem_rdata[15]}}, mem_rdata[15:0]};
                else load_data = {{16{mem_rdata[31]}}, mem_rdata[31:16]};
            end
            
            3'b101: begin // LHU: Zero extend halfword[cite: 3]
                if (addr_lsb[1] == 1'b0) load_data = {16'h0000, mem_rdata[15:0]};
                else load_data = {16'h0000, mem_rdata[31:16]};
            end
            
            3'b010: begin // LW: No extension needed[cite: 3]
                load_data = mem_rdata;
            end
            
            default: load_data = 32'h00000000;
        endcase
    end

endmodule