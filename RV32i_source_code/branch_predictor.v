`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.06.2024 21:46:19
// Design Name: 
// Module Name: branch_predictor
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


module branch_predictor 
#(parameter SAT_COUNT_BITS = 2)(
	input clk,
	input rst,
	input [1:0] ID_EXE_branch,
	input taken,
	
    output prediction
    );
	reg [1:0] counter_reg;
	wire [1:0] counter_update;
    assign prediction = counter_reg[1];
	
	always @(posedge rst or negedge clk) begin
		if (rst == 1)
			counter_reg <= 2'b01;
		else if (ID_EXE_branch == 2'b01)
			counter_reg <= counter_update;
	end
	
	saturating_counter_2bit _sat_count_ (
		.counter_reg(counter_reg),
		.taken(taken),
		.counter_update(counter_update)
	);
endmodule
