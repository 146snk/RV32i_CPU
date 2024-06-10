`timescale 1ps / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/03/11 22:00:28
// Design Name: 
// Module Name: REG_ID_EXE
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


module REG_ID_EXE(
		// ctrl
        input clk,
        input rst,
        input CE,
        input ID_EXE_dstall,
		input ID_EXE_cstall,
        // Input
        input [31:0] inst_in,
        input [31:0] PC,
		//// To EXE stage, ALU Operands A & B
        input [31:0] ALU_A,
        input [31:0] ALU_B,
		//// To EXE stage, ALU operation control signal
        input [4:0] ALU_control,
		//// To MEM stage, for sw instruction, data from rs2 register written into memory
        input [31:0] data_out,
		//// To MEM stage, for sw instruction, memor write enable signal
        input mem_w,
		//// To WB stage, for choosing different data written back to register file
        input [1:0] data_to_reg,
		//// To WB stage, register file write valid
        input reg_write,
        //// For Data Hazard
        input [4:0] written_reg,
        input [4:0] read_reg1,
        input [4:0] read_reg2,
        //// For branch prediction
		input [31:0] fallback_PC,
		input [1:0] branch,
		
        output reg [31:0] ID_EXE_inst_in,
        output reg [31:0] ID_EXE_PC = 0,
        output reg [31:0] ID_EXE_ALU_A,
        output reg [31:0] ID_EXE_ALU_B,
        output reg [4:0] ID_EXE_ALU_control,
        output reg [31:0] ID_EXE_data_out,
        output reg ID_EXE_mem_w,
        output reg [1:0] ID_EXE_data_to_reg,
        output reg ID_EXE_reg_write,
        
        output reg [4:0] ID_EXE_written_reg,
        output reg [4:0] ID_EXE_read_reg1,
        output reg [4:0] ID_EXE_read_reg2,
		
		output reg [31:0] ID_EXE_fallback_PC,
		output reg [1:0] ID_EXE_branch
    );

    always @ (posedge clk or posedge rst) begin
        if (rst == 1 || ID_EXE_dstall == 1) begin
            ID_EXE_inst_in      <= 32'h00000013;
            ID_EXE_PC           <= 32'h00000000;
            ID_EXE_ALU_A        <= 32'h00000000;
            ID_EXE_ALU_B        <= 32'h00000000;
            ID_EXE_ALU_control  <= 5'b00000;
            ID_EXE_data_out     <= 32'h00000000;
            ID_EXE_mem_w        <= 1'b0;
            ID_EXE_data_to_reg  <= 2'b00;
            ID_EXE_reg_write    <= 1'b0;
            
            ID_EXE_written_reg  <= 5'b00000;
            ID_EXE_read_reg1    <= 5'b00000;
            ID_EXE_read_reg2    <= 5'b00000;
			ID_EXE_fallback_PC 	<= 32'h00000013;
			ID_EXE_branch 		<= 2'b00;
        end
		else if (ID_EXE_cstall == 1) begin
			ID_EXE_inst_in      <= 32'h00000013;
            ID_EXE_PC           <= 32'h00000000;
            ID_EXE_ALU_A        <= 32'h00000000;
            ID_EXE_ALU_B        <= 32'h00000000;
            ID_EXE_ALU_control  <= 5'b00000;
            ID_EXE_data_out     <= 32'h00000000;
            ID_EXE_mem_w        <= 1'b0;
            ID_EXE_data_to_reg  <= 2'b00;
            ID_EXE_reg_write    <= 1'b0;
            
            ID_EXE_written_reg  <= 5'b00000;
            ID_EXE_read_reg1    <= 5'b00000;
            ID_EXE_read_reg2    <= 5'b00000;
			ID_EXE_fallback_PC 	<= 32'h00000013;
			ID_EXE_branch 		<= 2'b00;
		end
        else if (CE) begin
            ID_EXE_inst_in      <= inst_in;
            ID_EXE_PC           <= PC;
            ID_EXE_ALU_A        <= ALU_A;
            ID_EXE_ALU_B        <= ALU_B;
            ID_EXE_ALU_control  <= ALU_control;
            ID_EXE_data_out     <= data_out;
            ID_EXE_mem_w        <= mem_w;
            ID_EXE_data_to_reg  <= data_to_reg;
            ID_EXE_reg_write    <= reg_write;
            
            ID_EXE_written_reg  <= written_reg;
            ID_EXE_read_reg1    <= read_reg1;
            ID_EXE_read_reg2    <= read_reg2;
			ID_EXE_fallback_PC 	<= fallback_PC;
			ID_EXE_branch 		<= branch;
        end
    end   
endmodule
