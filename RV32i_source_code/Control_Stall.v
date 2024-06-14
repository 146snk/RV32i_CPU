`timescale 1ps / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/03/12 08:45:29
// Design Name: 
// Module Name: control_stall
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


module control_stall(
        input [1:0] branch,
		input [1:0] ID_EXE_branch,
		input misprediction,
		input prediction,
		
        output reg IF_ID_cstall,
		output reg ID_EXE_cstall
    );
    always @ (*) begin
        IF_ID_cstall = 1'b0;
		ID_EXE_cstall = 1'b0;
		if (misprediction == 1) begin		// misprediction
			IF_ID_cstall = 1'b1;
			ID_EXE_cstall = 1'b1;
		end
		else if (branch[1] == 1'b1) begin 	// jump
            IF_ID_cstall = 1'b1;
        end
		else if (branch == 2'b01 && prediction == 1) begin		// branch
			IF_ID_cstall = 1'b1;
		end
    end
endmodule
