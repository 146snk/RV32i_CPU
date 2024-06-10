`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.05.2024 12:59:54
// Design Name: 
// Module Name: forwarding_unit
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


module forwarding_unit(
		input [4:0] ID_EXE_read_reg1,
		input [4:0] ID_EXE_read_reg2,
		input [31:0] ID_EXE_ALU_A,
		input [31:0] ID_EXE_ALU_B,
		input [31:0] ID_EXE_data_out,
		input ID_EXE_mem_w,
		
		input EXE_MEM_reg_write,
		input [4:0] EXE_MEM_written_reg,
		input [31:0] EXE_MEM_ALU_out,
		
		input MEM_WB_reg_write,
		input [4:0] MEM_WB_written_reg,
		input [31:0] WB_wt_data,
		
		output reg [31:0] forwarding_ALU_A_out,
		output reg [31:0] forwarding_ALU_B_out,
		output reg [31:0] forwarding_data_out
    );
	
	reg forwarding_flag_A;
	reg forwarding_flag_B;
	reg forwarding_flag_data;
	
	always @(*)begin
		// Default no forwarding
		forwarding_ALU_A_out = ID_EXE_ALU_A;
		forwarding_ALU_B_out = ID_EXE_ALU_B;
		forwarding_data_out = ID_EXE_data_out;
		
		forwarding_flag_A=0;
		forwarding_flag_B=0;
		forwarding_flag_data=0;
		// forwarding for read1
		/// forwarding EXE_MEM -> EXE
		if (EXE_MEM_reg_write == 1'b1 && EXE_MEM_written_reg != 0 && 
		  EXE_MEM_written_reg == ID_EXE_read_reg1) begin
			forwarding_ALU_A_out = EXE_MEM_ALU_out;
			forwarding_flag_A=1;
		end
		/// forwarding MEM_WB -> EXE
		else if (MEM_WB_reg_write == 1'b1 && MEM_WB_written_reg != 0 && 
		  MEM_WB_written_reg == ID_EXE_read_reg1) begin
			forwarding_ALU_A_out = WB_wt_data;
			forwarding_flag_A=1;
		end	
		// forwarding for read2
		/// forwarding EXE_MEM -> EXE
		if (EXE_MEM_reg_write == 1'b1 && EXE_MEM_written_reg != 0 && 
		  EXE_MEM_written_reg == ID_EXE_read_reg2) begin
			if (ID_EXE_mem_w == 0) begin // ~sw
				forwarding_ALU_B_out = EXE_MEM_ALU_out;
				forwarding_flag_B=1;
			end
			else begin // sw
				forwarding_data_out = EXE_MEM_ALU_out;
				forwarding_flag_data=1;
			end
		end
		/// forwarding MEM_WB -> EXE
		else if (MEM_WB_reg_write == 1'b1 && MEM_WB_written_reg != 0 && 
		  MEM_WB_written_reg == ID_EXE_read_reg2)
			if (ID_EXE_mem_w == 0) begin // ~sw
				forwarding_ALU_B_out = WB_wt_data;
				forwarding_flag_B=1;
			end
			else begin // sw
				forwarding_data_out = WB_wt_data;
				forwarding_flag_data=1;
			end
	end
endmodule