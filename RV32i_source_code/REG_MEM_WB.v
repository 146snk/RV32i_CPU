`timescale 1ps / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/03/12 08:12:16
// Design Name: 
// Module Name: REG_MEM_WB
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


module REG_MEM_WB(
        input clk,
        input rst,
        input CE,
        // Input
        input [31:0] inst_in,
        input [31:0] PC,
        input [31:0] ALU_out,
        input [1:0] data_to_reg,
        input reg_write,
		input [4:0] written_reg,
        input [31:0] data_in,
        // Output
        output reg [31:0] MEM_WB_inst_in,
        output reg [31:0] MEM_WB_PC = 0,
        output reg [31:0] MEM_WB_ALU_out,
        output reg [1:0] MEM_WB_data_to_reg,
        output reg MEM_WB_reg_write,
		output reg [4:0] MEM_WB_written_reg,
        output reg [31:0] MEM_WB_data_in
    );
    always @ (posedge clk or posedge rst) begin
        if (rst == 1) begin
            MEM_WB_inst_in      <= 32'h00000013;
            MEM_WB_PC           <= 32'h00000000;
            MEM_WB_ALU_out      <= 32'h00000000;
            MEM_WB_data_to_reg    <= 2'b00;
            MEM_WB_reg_write     <= 1'b0;
			MEM_WB_written_reg <= 5'b00000;
            MEM_WB_data_in      <= 32'h00000000;
        end
        else if (CE) begin
            MEM_WB_inst_in      <= inst_in;
            MEM_WB_PC           <= PC;
            MEM_WB_ALU_out      <= ALU_out;
            MEM_WB_data_to_reg    <= data_to_reg;
            MEM_WB_reg_write     <= reg_write;
			MEM_WB_written_reg <= written_reg;
            MEM_WB_data_in      <= data_in;
        end
    end
endmodule
