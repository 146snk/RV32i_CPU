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
        input clk,
        input rst,
        input CE,
        input ID_EXE_dstall,
        
        input [31:0] inst_in,
        input [31:0] PC,
        input [31:0] ALU_A,
        input [31:0] ALU_B,
        input [4:0] ALU_control,
        input [31:0] data_out,
        input mem_w,
        input [1:0] data_to_reg,
        input reg_write,
        
        input [4:0] written_reg,
        input [4:0] read_reg1,
        input [4:0] read_reg2,
        
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
        output reg [4:0] ID_EXE_read_reg2
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
            ID_EXE_data_to_reg    <= 2'b00;
            ID_EXE_reg_write     <= 1'b0;
            
            ID_EXE_written_reg  <= 5'b00000;
            ID_EXE_read_reg1    <= 5'b00000;
            ID_EXE_read_reg2    <= 5'b00000;
        end
        else if (CE) begin
            ID_EXE_inst_in      <= inst_in;
            ID_EXE_PC           <= PC;
            ID_EXE_ALU_A        <= ALU_A;
            ID_EXE_ALU_B        <= ALU_B;
            ID_EXE_ALU_control  <= ALU_control;
            ID_EXE_data_out     <= data_out;
            ID_EXE_mem_w        <= mem_w;
            ID_EXE_data_to_reg    <= data_to_reg;
            ID_EXE_reg_write     <= reg_write;
            
            ID_EXE_written_reg  <= written_reg;
            ID_EXE_read_reg1    <= read_reg1;
            ID_EXE_read_reg2    <= read_reg2;
        end
    end   
endmodule
