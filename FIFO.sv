`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Michigan ECE (IC&VLSI)
// Engineer: Yen-Cheng Lin
// 
// Create Date: 2024/07/01 13:17:33
// Design Name: 
// Module Name: FIFO
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Synchronous FIFO Design & Verification
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module FIFO(
    input clk, rst, wr_en, rd_en,
    input [7:0] din,
    output reg [7:0] dout,
    output empty, full, almost_empty, almost_full
    );
    
    reg [3:0] wptr = 0, rptr = 0; // set wirte and read pointer, because FIFO has maximum 16 data to store, so it needs 4 bits to do pointing.
    reg [5:0] cnt = 0; // this counter is to count the location of the current data in the FIFO, so it needs 5 bits to make sure the last location presenting in the FIFO is correctly read and write.
    reg [7:0] memory [15:0]; // memory store 16 data in 8 bits.
    
    always@(posedge clk)
    begin
        if(rst == 1'b1) // reset
          begin
            wptr <= 0;
            rptr <= 0;
            cnt <= 0;
          end
        else if(wr_en && !full) // want to write and the FIFO is not full yet.
          begin
            memory[wptr] <= din;
            wptr <= wptr + 1;
            cnt <= cnt + 1;
          end
        else if(rd_en && !empty) // want to read and the FIFO is not empty yet.
          begin
            dout <= memory[rptr];
            rptr <= rptr + 1;
            cnt <= cnt -1;
          end
    end // end always block
    
    assign empty = (cnt == 0) ? 1'b1 : 1'b0;
    assign full = (cnt == 16) ? 1'b1 : 1'b0;
    assign almost_empty = (cnt == 1) ? 1'b1 : 1'b0;
    assign almost_full = (cnt == 15) ? 1'b1 : 1'b0;
    
endmodule

////////////////////// Interface /////////////////////////

interface FIFO_if;
    
    logic clk, rst, rd_en, wr_en, full, empty, almost_full, almost_empty;
    logic [7:0] din;
    logic [7:0] dout;

endinterface
