`timescale 1ps / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/03/10 21:16:48
// Design Name: 
// Module Name: controller
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


module controller(
		input [6:0] OPcode,
		input [2:0] Fun1,
		input [6:0] Fun2,
		input wire zero,
		output reg ALU_src_A,
		output reg [1:0] ALU_src_B,
		output reg [1:0] data_to_reg,
		output reg [1:0] branch,
		output reg reg_write,
		output reg mem_w,
		output reg [4:0] ALU_control,
		output reg [1:0] B_H_W,
		output reg sign
		);
	always @(*) begin
		ALU_src_B = 0;
		ALU_src_A = 0;
		data_to_reg = 2'b0;
		branch = 0;
		reg_write = 0;
		mem_w = 0;
		B_H_W = 2'b0; // default: immediate is a word
		sign = 1'b1; // default: signed extension to "write_data"
		case(OPcode)
		    // R
			7'b0110011: begin 
				reg_write = 1;
				case(Fun1)
				    3'b000: begin
				        case (Fun2)
				            7'b0000000: ALU_control = 5'b00010; // ADD
				            7'b0100000: ALU_control = 5'b00011; // SUB
				            default: ALU_control = 5'b11111;
				        endcase
				    end
				    3'b001: begin // SLL
				        ALU_control = 5'b00111;
				    end
				    3'b010: ALU_control = 5'b00101; // SLT
				    3'b011: ALU_control = 5'b00110; // SLTU
				    3'b100: ALU_control = 5'b00100; // XOR
				    3'b101: begin
				        case (Fun2)
				            7'b0000000: begin // SRL
                                ALU_control = 5'b01000;
                            end
                            7'b0100000: begin // SRA
                                ALU_control = 5'b01001;
                            end
                            default: ALU_control = 5'b11111;
				        endcase
				    end
				    3'b110: ALU_control = 5'b00001; // OR
				    3'b111: ALU_control = 5'b00000; // AND
					default: ALU_control = 5'b11111;
				endcase
			end
			// I
			7'b0010011: begin
			    reg_write = 1;
			    case (Fun1)
			        3'b000: begin
			            ALU_control = 5'b00010; // ADDI                   
                        ALU_src_B = 2'b01;    
			        end
			        3'b010: begin
			            ALU_control = 5'b00101; // SLTI
			            ALU_src_B = 2'b01;
			        end
			        3'b011: begin
			            ALU_control = 5'b00110; // SLTIU
                        ALU_src_B = 2'b01;
			        end
			        3'b100: begin
                        ALU_control = 5'b00100; // XORI
                        ALU_src_B = 2'b01;
			        end
			        3'b110: begin
                        ALU_control = 5'b00001; // ORI
                        ALU_src_B = 2'b01;
			        end
			        3'b111: begin
                        ALU_control = 5'b00000; // ANDI
                        ALU_src_B = 2'b01; 
			        end
			        3'b001: begin
			            ALU_control = 5'b00111; // SLLI
                        ALU_src_B = 2'b01;
			        end
			        3'b101: begin
			            ALU_src_B = 2'b01;
			            case (Fun2)
			                7'b0000000: ALU_control = 5'b01000; // SRLI
			                7'b0100000: ALU_control = 5'b01001; // SRAI
			            endcase
			        end
			    endcase
			end
			7'b0000011: begin	// l
				ALU_control = 5'b00010;
				ALU_src_B = 2'b01;
				data_to_reg = 2'b01;
				reg_write = 1;
				case (Fun1)
				    3'b000: begin // LB
				        B_H_W = 2'b01; // byte
				    end
				    3'b001: begin // LH
				        B_H_W = 2'b10; // half word
				    end
				    3'b100: begin // LBU
				        B_H_W = 2'b01; // byte
				        sign = 1'b0;
				    end
				    3'b101: begin // LHU
				        B_H_W = 2'b10; // half word
				        sign = 1'b0;
				    end
				    // 3'b010:; // LW
				endcase
			end
			7'b0100011: begin   // S
			    ALU_control = 5'b00010;
			    ALU_src_B = 2'b01;
			    mem_w = 1;
			    case (Fun1)
			        3'b000: begin
			            B_H_W = 2'b01; // byte
			        end
			        3'b001: begin
			            B_H_W = 2'b10; // half word
			        end
			        // 3'b010: ; // SW
			    endcase
			end
			7'b1100011: begin	// Branch
			    case (Fun1)
			        3'b000: begin // BEQ
			            ALU_control = 5'b00011; 
			            branch = {1'b0, zero};
			        end 
			        3'b001: begin // BNE
			            ALU_control = 5'b00011;
			            branch = {1'b0, ~zero};
			        end
			        3'b100: begin // BLT
			            ALU_control = 5'b00101;
			            branch = {1'b0, zero};
			        end
			        3'b101: begin // BGE
			            ALU_control = 5'b01010;
			            branch = {1'b0, zero};
			        end
			        3'b110: begin // BLTU
			            ALU_control = 5'b00110;
			            branch = {1'b0, zero}; 
			        end
			        3'b111: begin // BGEU
			            ALU_control = 5'b01011;
			            branch = {1'b0, zero};
			        end
			    endcase
			end
			7'b1101111: begin	// jal
				branch = 2'b10;
				data_to_reg = 2'b11;
				reg_write = 1;
			end
            7'b1100111: begin   // jalr
                branch = 2'b11;
                data_to_reg = 2'b11;
                reg_write = 1;
            end
            7'b0110111: begin    // lui
                data_to_reg = 2'b10;
                reg_write = 1;
            end
            7'b0010111: begin   // AUIPC
                data_to_reg = 2'b10;
                reg_write = 1;
            end
			default: ALU_control = 5'b11111;
		endcase
	end
endmodule

