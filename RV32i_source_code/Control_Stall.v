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
        output reg IF_ID_cstall
    );
    always @ (*) begin
        IF_ID_cstall = 1'b0;
        if (branch[1:0] != 2'b00) begin
            IF_ID_cstall = 1'b1;
        end
    end
endmodule
