`timescale 1ps / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/03/10 21:20:59
// Design Name: 
// Module Name: Regs
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Regs(
		input clk,
		input rst,
		input [4:0] rd_addr_A, 
		input [4:0] rd_addr_B, 
		input [4:0] wt_addr, 
		input [31:0] wt_data, 
		input L_S,  // we
		output [31:0] rd_data_A, 
		output [31:0] rd_data_B
		);

	reg [31:0] register [1:31]; 					// r1 - r31
	integer i;
	assign rd_data_A = (rd_addr_A == 0) ? 0 : register[rd_addr_A]; 	  // read
	assign rd_data_B = (rd_addr_B == 0) ? 0 : register[rd_addr_B];    // read
	
	always @(negedge clk or posedge rst) begin
		if (rst == 1) begin 							// reset
		    for (i=1; i<32; i=i+1)
				register[i] <= 0;
		end 
		else begin
		    if ((wt_addr != 0) && (L_S == 1)) // write
		        register[wt_addr] <= wt_data;
		end
	end
endmodule
