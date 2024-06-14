`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.06.2024 17:08:53
// Design Name: 
// Module Name: next_PC
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


module next_PC(
	// PC source
    input [31:0] ID_EXE_fallback_PC,
    input [31:0] add_PC_4_out,
    input [31:0] add_branch_out,
    input [31:0] add_jal_out,
    input [31:0] add_jalr_out,
	input [31:0] PC_out,
    // control signal
    input misprediction,
    input [1:0] branch,
	input prediction,
    // PC output
    output reg [31:0] next_PC,
    output reg [31:0] fallback_PC
    );
    always @(*) begin
        fallback_PC = 32'h00000013; // default fallback_PC = NOP;
		// prioritize misprediction
        if (misprediction == 1)
			next_PC = ID_EXE_fallback_PC;
		else case(branch)
			// non flow ctrl inst
			2'b00: next_PC = add_PC_4_out;
			// branch
			2'b01: 
				if (prediction == 0) begin	// predict NT
					next_PC = add_PC_4_out;
					fallback_PC = add_branch_out;
				end
				else begin					// predict T
					next_PC = add_branch_out;
					fallback_PC = PC_out;
				end
			// jal
			2'b10: next_PC = add_jal_out;
			// jalr
			2'b11: next_PC = add_jalr_out;
		endcase
    end
endmodule
