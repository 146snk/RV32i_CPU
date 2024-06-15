`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.06.2024 13:37:54
// Design Name: 
// Module Name: saturating_counter_2bit
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


module saturating_counter_2bit(
    input [1:0] counter_reg,
	input taken,
	output reg [1:0] counter_update
    );
	always @(*) begin
		counter_update = counter_reg;
		case(counter_reg)
			2'b00:
				// if not taken no change
				if (taken == 1)
					counter_update = 2'b01;
			2'b01:
				if (taken == 0)
					counter_update = 2'b00;
				else
					counter_update = 2'b10;
			2'b10:
				if (taken == 0)
					counter_update = 2'b01;
				else
					counter_update = 2'b11;
			2'b11:
				if (taken == 0)
					counter_update = 2'b10;
				// if taken no change
		endcase
	end
endmodule
