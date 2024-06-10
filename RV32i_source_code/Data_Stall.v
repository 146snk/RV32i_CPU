`timescale 1ps / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/03/12 08:46:15
// Design Name: 
// Module Name: data_stall
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


module data_stall(
        input [4:0] IF_ID_read_reg1,
        input [4:0] IF_ID_read_reg2,
		
        input [4:0] ID_EXE_written_reg,
		input [1:0] ID_EXE_data_to_reg,
        
        output reg PC_dstall,
        output reg IF_ID_dstall,
        output reg ID_EXE_dstall       
    );
    always @ (*) begin
        PC_dstall = 0;
        IF_ID_dstall = 0;
        ID_EXE_dstall = 0;
        if (ID_EXE_data_to_reg == 2'b01 && ID_EXE_written_reg != 0 && (ID_EXE_written_reg == IF_ID_read_reg1 || ID_EXE_written_reg == IF_ID_read_reg2)) begin
                PC_dstall = 1;
                IF_ID_dstall = 1;
                ID_EXE_dstall = 1;
        end
    end
endmodule
