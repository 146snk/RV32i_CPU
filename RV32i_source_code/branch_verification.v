`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.06.2024 17:47:13
// Design Name: 
// Module Name: branch_verification
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


module branch_verification(
    input [1:0] branch,
    input [2:0] Fun1,
    input zero,
	input prediction,
    
    output reg taken,
    output reg misprediction
    );
    always @(*) begin
        if (branch == 2'b01) begin
			case (Fun1)
				3'b000: // BEQ
					taken = zero;
				3'b001: // BNE
					taken = ~zero;
				3'b100: // BLT
					taken = zero;
				3'b101: // BGE
					taken = zero;
				3'b110: // BLTU
					taken = zero; 
				3'b111: // BGEU
					taken = zero;
			endcase
			misprediction = prediction ^ taken;
		end
		else begin
			taken = 0;
			misprediction = 0;
		end
	end
endmodule
