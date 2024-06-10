`timescale 1ps / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/03/10 19:39:55
// Design Name: 
// Module Name: RV32iPCPU
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


module RV32iPCPU(
    input clk,
    input rst,
    input [31:0] data_in,   // MEM
    input [31:0] inst_in,   // IF, from PC_out
    
    output [31:0] ALU_out,  // From MEM, address out, for fetching data_in
    output [31:0] data_out, // From MEM, to be written into data memory
    output mem_w,           // From MEM, write valid, for store instructions
    output [31:0] PC_out    // From IF
    );
    wire V5;
    wire N0;
    wire [31:0] imm_32;
	wire [31:0] add_PC_4_out;
    wire [31:0] add_branch_out;
    wire [31:0] add_jal_out;
    wire [31:0] add_jalr_out;

    wire [31:0] wt_data;
    wire [31:0] rd_data_A;
    wire [31:0] rd_data_B;
    wire [31:0] PC_wb;
    wire [31:0] ALU_A;
    wire [31:0] ALU_B;
    assign V5 = 1'b1;
    assign N0 = 1'b0;
    
	// forwarding
	wire [31:0] forwarding_ALU_A;
	wire [31:0] forwarding_ALU_B;
	wire [31:0] forwarding_data_out;
	wire PC_dstall;
	wire IF_ID_dstall;
	wire ID_EXE_dstall;
	
	// branch_prediction
	wire [31:0] fallback_PC;
    wire [31:0] ID_EXE_fallback_PC;
	wire [1:0] ID_EXE_branch;
	wire misprediction;
	wire IF_ID_cstall;
	wire ID_EXE_cstall;
	
    wire zero;              // ID
    wire [1:0] branch;      // ID
    wire ALU_src_A;          // EXE
    wire [1:0] ALU_src_B;    // EXE
    wire [4:0] ALU_control; // EXE
    wire reg_write;          // WB
    wire [1:0] data_to_reg;   // WB
    
    wire [1:0] B_H_W;       // WB // not used yet
    wire sign;              // WB // not used yet
//    wire RegDst; // WB
//    wire Jal; // WB
    
    // IF_ID
    wire [31:0] IF_ID_inst_in;
    wire [31:0] IF_ID_PC;
    wire [31:0] IF_ID_data_out;
    wire IF_ID_mem_w;
    wire [4:0] IF_ID_written_reg;
    wire [4:0] IF_ID_read_reg1;
    wire [4:0] IF_ID_read_reg2;
    
    // ID_EXE
    wire [31:0] ID_EXE_inst_in;
    wire [31:0] ID_EXE_PC;
    wire [31:0] ID_EXE_ALU_A;
    wire [31:0] ID_EXE_ALU_B;
    wire [4:0] ID_EXE_ALU_control;
    wire [31:0] ID_EXE_data_out;
    wire ID_EXE_mem_w;
    wire [1:0] ID_EXE_data_to_reg;
    wire ID_EXE_reg_write;
    wire [4:0] ID_EXE_written_reg;
    wire [4:0] ID_EXE_read_reg1;
    wire [4:0] ID_EXE_read_reg2;
    
    wire [31:0] ID_EXE_ALU_out;

    // EXE_MEM
    wire [31:0] EXE_MEM_inst_in;
    wire [31:0] EXE_MEM_PC;
    wire [31:0] EXE_MEM_ALU_out;
    wire [31:0] EXE_MEM_data_out;
    wire EXE_MEM_mem_w;
    wire [1:0] EXE_MEM_data_to_reg;
    wire EXE_MEM_reg_write;
    wire [4:0] EXE_MEM_written_reg;
    wire [4:0] EXE_MEM_read_reg1;
    wire [4:0] EXE_MEM_read_reg2;
    
    // MEM_WB
    wire [31:0] MEM_WB_inst_in;
    wire [31:0] MEM_WB_PC;
    wire [31:0] MEM_WB_ALU_out;
    wire [1:0] MEM_WB_data_to_reg;
    wire MEM_WB_reg_write;
	wire [4:0] MEM_WB_written_reg;
	wire [31:0] MEM_WB_data_in;
      
    data_stall _dstall_ (
        .IF_ID_read_reg1(IF_ID_read_reg1),
        .IF_ID_read_reg2(IF_ID_read_reg2),
		
        .ID_EXE_written_reg(ID_EXE_written_reg),
		.ID_EXE_data_to_reg(ID_EXE_data_to_reg),

        .PC_dstall(PC_dstall),
        .IF_ID_dstall(IF_ID_dstall),
        .ID_EXE_dstall(ID_EXE_dstall)
	);
        
    control_stall _cstall_ (
        .branch(branch[1:0]),
		.ID_EXE_branch(ID_EXE_branch[1:0]),
		.misprediction(misprediction),
		
        .IF_ID_cstall(IF_ID_cstall),
		.ID_EXE_cstall(ID_EXE_cstall)
	);

    assign ALU_out = EXE_MEM_ALU_out;
    assign data_out = EXE_MEM_data_out;
    assign mem_w = EXE_MEM_mem_w;
    
    // IF:-------------------------------------------------------------------------------------------
    // Control Signals:
    //   1. branch - MUX5 : ID
    // References:
    //   1. inst_in - MUX5 : ID
    //   2. rd_data_A - MUX5 : ID
    //   3. imm_32 - ADD_Branch : ID
    // Pass-on:
    //   1. inst_in (combinatorial)
    //   2. PC
    // Out:
    //   1. PC_out: for fetching inst_in
    REG32 _pc_ (
        .CE(V5),
        .clk(clk),
        .D(PC_wb[31:0]),
        .rst(rst),
        .Q(PC_out[31:0]),
        .PC_dstall(PC_dstall)
	);
		
	add_32 _add_PC_4_ (				// PC+4
		.a(PC_out[31:0]),
		.b(32'b0100),
		.c(add_PC_4_out[31:0])
	);
	
    add_32 _add_branch_ (
        .a(IF_ID_PC[31:0]),         // use the "PC" from ID stage
        .b(imm_32[31:0]),           // From ID stage
        .c(add_branch_out[31:0])    // actually this part belongs to IF_ID
	);  
	
    add_32 _add_jal_ (
        .a(IF_ID_PC),               // MIPS: PC+4, RISC-V: PC!!!
        .b({{11{IF_ID_inst_in[31]}}, IF_ID_inst_in[31], IF_ID_inst_in[19:12], IF_ID_inst_in[20], IF_ID_inst_in[30:21], 1'b0}), 
        .c(add_jal_out[31:0])
	);
	
    add_32 _add_jalr_ (
        .a(rd_data_A[31:0]), 
        .b({{20{IF_ID_inst_in[31]}}, IF_ID_inst_in[31:20]}), 
        .c(add_jalr_out[31:0])
	);
	
//    Mux4to1b32 _mux5_ (
//        .I0(add_PC_4_out[31:0]),   		// From IF stage
//        .I1(add_branch_out[31:0]),      // Containing "PC" from ID stage
//        .I2(add_jal_out[31:0]),         // From ID stage
//        .I3(add_jalr_out[31:0]),        // From ID stage
//        .s(branch[1:0]),                // From ID
//        .o(PC_wb[31:0])
//	);
    
    next_PC _next_PC_(
		// PC source
		.ID_EXE_fallback_PC(ID_EXE_fallback_PC),	// From EX stage
		.add_PC_4_out(add_PC_4_out[31:0]),			// From IF stage
		.add_branch_out(add_branch_out[31:0]),		// Containing "PC" from ID stage
		.add_jal_out(add_jal_out[31:0]),			// From ID stage
		.add_jalr_out(add_jalr_out[31:0]),			// From ID stage
		// control signal
		.misprediction(misprediction),				// From EX
		.branch(branch[1:0]),						// From ID
		// PC output
		.next_PC(PC_wb[31:0]),
		.fallback_PC(fallback_PC[31:0])
	);

    REG_IF_ID _if_id_ (
        .clk(clk), .rst(rst), .CE(V5),
        .IF_ID_dstall(IF_ID_dstall), .IF_ID_cstall(IF_ID_cstall),
        // Input
        .inst_in(inst_in),
        .PC(PC_out),
        // Output
        .IF_ID_inst_in(IF_ID_inst_in),
        .IF_ID_PC(IF_ID_PC)
	);

   // ID:-------------------------------------------------------------------------------------------
   // From IF:
   //   1. inst_in
   //   2. PC
   // Control Signals:
   //   1. reg_write - Regs : WB
   //   2. ALU_src_A / ALU_src_B (stops here)
   // References:
   //   None
   // Pass-on:
   //   1. inst_in
       //   Control_signals {
       //   2. ALU_control
       //   3. data_to_reg
       //   4. mem_w
       //   5. reg_write
       //   }
   //   6. ALU_A
   //   7. ALU_B
   //   8. data_out
   //   9. PC
   // Out:
   //   None
   
    get_rw_regs _rw_regs_ (
        .inst_in(IF_ID_inst_in[31:0]),
        .written_reg(IF_ID_written_reg),
        .read_reg1(IF_ID_read_reg1),
        .read_reg2(IF_ID_read_reg2)
	);
	
    controller  _ctrl_unit_ (
        // Input:
        .OPcode(IF_ID_inst_in[6:0]),
        .Fun1(IF_ID_inst_in[14:12]),
        .Fun2(IF_ID_inst_in[31:25]),
        // Output:
        .ALU_src_A(ALU_src_A),
        .ALU_src_B(ALU_src_B[1:0]),
        .ALU_control(ALU_control[4:0]),
        .branch(branch[1:0]),
        .data_to_reg(data_to_reg[1:0]),
        .mem_w(IF_ID_mem_w),
        .reg_write(reg_write),
        .B_H_W(B_H_W),                  // not used yet
        .sign(sign)                     // not used yet
	);

    Regs _U2_ (.clk(clk),
		.rst(rst),
		.L_S(MEM_WB_reg_write),             // From Write-Back stage
		.rd_addr_A(IF_ID_read_reg1[4:0]),   // ID
		.rd_addr_B(IF_ID_read_reg2[4:0]),   // ID
		.wt_addr(MEM_WB_written_reg[4:0]),            // From Write-Back stage
		.wt_data(wt_data[31:0]),           // From Write-Back stage
		.rd_data_A(rd_data_A[31:0]),
		.rd_data_B(rd_data_B[31:0])
    
	);
	
    sign_ext _signed_ext_ (.inst_in(IF_ID_inst_in), .imm_32(imm_32));

    Mux2to1b32  _alu_source_A_ (
        .I0(rd_data_A[31:0]),
        .I1(imm_32[31:0]),   // not used 
        .s(ALU_src_A),
        .o(ALU_A[31:0])
	);

    Mux4to1b32  _alu_source_B_ (
        .I0(rd_data_B[31:0]),
        .I1(imm_32[31:0]),
        .I2(),
        .I3(),
        .s(ALU_src_B[1:0]),
        .o(ALU_B[31:0])
	);
	
    assign IF_ID_data_out = rd_data_B;
	

    REG_ID_EXE _id_exe_ (
        .clk(clk), .rst(rst), .CE(V5), .ID_EXE_dstall(ID_EXE_dstall), .ID_EXE_cstall(ID_EXE_cstall),
        // Input
        .inst_in(IF_ID_inst_in),
        .PC(IF_ID_PC),
        //// To EXE stage, ALU Operands A & B
        .ALU_A(ALU_A),
        .ALU_B(ALU_B),
        //// To EXE stage, ALU operation control signal
        .ALU_control(ALU_control),
        //// To MEM stage, for sw instruction, data from rs2 register written into memory
        .data_out(IF_ID_data_out),
        //// To MEM stage, for sw instruction, memor write enable signal
        .mem_w(IF_ID_mem_w),
        //// To WB stage, for choosing different data written back to register file
        .data_to_reg(data_to_reg),
        //// To WB stage, register file write valid
        .reg_write(reg_write),
        //// For Data Hazard
        .written_reg(IF_ID_written_reg), .read_reg1(IF_ID_read_reg1), .read_reg2(IF_ID_read_reg2),
        //// For branch prediction
		.fallback_PC(fallback_PC),
		.branch(branch),
		
        // Output
        .ID_EXE_inst_in(ID_EXE_inst_in),
        .ID_EXE_PC(ID_EXE_PC),
        .ID_EXE_ALU_A(ID_EXE_ALU_A),
        .ID_EXE_ALU_B(ID_EXE_ALU_B),
        .ID_EXE_ALU_control(ID_EXE_ALU_control),
        .ID_EXE_data_out(ID_EXE_data_out),
        .ID_EXE_mem_w(ID_EXE_mem_w),
        .ID_EXE_data_to_reg(ID_EXE_data_to_reg),
        .ID_EXE_reg_write(ID_EXE_reg_write),
        //// For Data Hazard
        .ID_EXE_written_reg(ID_EXE_written_reg),
		.ID_EXE_read_reg1(ID_EXE_read_reg1),
		.ID_EXE_read_reg2(ID_EXE_read_reg2),
		//// For branch prediction
		.ID_EXE_fallback_PC(ID_EXE_fallback_PC),
		.ID_EXE_branch(ID_EXE_branch)
	);

    // EXE:-------------------------------------------------------------------------------------------
    // From ID:
    //   1. inst_in
        //   Control_signals {
        //   2. ALU_control (stops here)
        //   3. mem_w
        //   4. data_to_reg
        //   5. reg_write
        //   }
    //   6. ALU_A (stops here)
    //   7. ALU_B (stops here)
    //   8. data_out
    //   9. PC
    // Control Signals:
    //   1. ALU_control
    // References:
    //   None
    // Pass-on:
    //   1. inst_in
        //   Control_signals {
        //   2. data_to_reg (WB)
        //   3. mem_w (MEM)
        //   4. reg_write (WB)
        //   }
    //   5. data_out (used at MEM together with mem_w)
    //   6. ALU_out (Addr_out outside) (used at both MEM and WB)
    //   7. PC
    // Out:
    //   None
	
	forwarding_unit _forwarding_unit_ (
		.ID_EXE_read_reg1(ID_EXE_read_reg1),
		.ID_EXE_read_reg2(ID_EXE_read_reg2),
		.ID_EXE_ALU_A(ID_EXE_ALU_A),
		.ID_EXE_ALU_B(ID_EXE_ALU_B),
		.ID_EXE_data_out(ID_EXE_data_out),
		.ID_EXE_mem_w(ID_EXE_mem_w),
		
		.EXE_MEM_reg_write(EXE_MEM_reg_write),
		.EXE_MEM_written_reg(EXE_MEM_written_reg),
		.EXE_MEM_ALU_out(EXE_MEM_ALU_out),
		
		.MEM_WB_reg_write(MEM_WB_reg_write),
		.MEM_WB_written_reg(MEM_WB_written_reg),
		.WB_wt_data(wt_data),
		
		.forwarding_ALU_A(forwarding_ALU_A),
		.forwarding_ALU_B(forwarding_ALU_B),
		.forwarding_data_out(forwarding_data_out)
	);

    ALU _alualu_ (
        .A(forwarding_ALU_A[31:0]),
        .B(forwarding_ALU_B[31:0]),
        .ALU_operation(ID_EXE_ALU_control[4:0]),
        .res(ID_EXE_ALU_out[31:0]),
        .overflow(),
        .zero(zero)
    ); 
	
	branch_verification _verification_(
		// input
		.branch(ID_EXE_branch[1:0]),
		.Fun1(ID_EXE_inst_in[14:12]),
		.zero(zero),
		// output
		.taken(taken),
		.misprediction(misprediction)
	);
	
	
    REG_EXE_MEM _exe_mem_ (
        .clk(clk), .rst(rst), .CE(V5),
        // Input
        .inst_in(ID_EXE_inst_in),
        .PC(ID_EXE_PC),
        //// To MEM stage
        .ALU_out(ID_EXE_ALU_out),
        .data_out(forwarding_data_out),
        .mem_w(ID_EXE_mem_w),
        //// To WB stage
        .data_to_reg(ID_EXE_data_to_reg),
        .reg_write(ID_EXE_reg_write),
        
        .written_reg(ID_EXE_written_reg), .read_reg1(ID_EXE_read_reg1), .read_reg2(ID_EXE_read_reg2),
        
        // Output
        .EXE_MEM_inst_in(EXE_MEM_inst_in),
        .EXE_MEM_PC(EXE_MEM_PC),
        .EXE_MEM_ALU_out(EXE_MEM_ALU_out),
        .EXE_MEM_data_out(EXE_MEM_data_out),
        .EXE_MEM_mem_w(EXE_MEM_mem_w),
        .EXE_MEM_data_to_reg(EXE_MEM_data_to_reg),
        .EXE_MEM_reg_write(EXE_MEM_reg_write),
        
        .EXE_MEM_written_reg(EXE_MEM_written_reg), .EXE_MEM_read_reg1(EXE_MEM_read_reg1), .EXE_MEM_read_reg2(EXE_MEM_read_reg2)
	);

    // MEM:-------------------------------------------------------------------------------------------
    // From EXE:
    //   1. inst_in
        //   Control_signals {
        //   2. data_to_reg (WB)
        //   3. mem_w (stops here)
        //   4. reg_write (WB)
        //   }
    //   5. data_out (stops here)
    //   6. ALU_out (Addr_out outside) (used at both MEM and WB)
    //   7. PC
    // Control Signals:
    //   1. mem_w
    // Pass-on:
    //   1. inst_in
        //   Control_signals {
        //   2. data_to_reg (WB)
        //   3. reg_write (WB)
        //   }
    //   4. ALU_out (Addr_out outside) (used at both MEM and WB)
    //   5. PC
    //   6. data_in
    // Out:
    //   data_out & mem_w, ALU_out(as Addr_out)
    
    REG_MEM_WB _mem_wb_ (
        .clk(clk), .rst(rst), .CE(V5),
        // Input
        .inst_in(EXE_MEM_inst_in),
        .PC(EXE_MEM_PC),
        .ALU_out(EXE_MEM_ALU_out),
        .data_to_reg(EXE_MEM_data_to_reg),
        .reg_write(EXE_MEM_reg_write),
		.written_reg(EXE_MEM_written_reg),
        //// Comes from data memory
        .data_in(data_in),
        
        // Output
        .MEM_WB_inst_in(MEM_WB_inst_in),
        .MEM_WB_PC(MEM_WB_PC),
        .MEM_WB_ALU_out(MEM_WB_ALU_out),
        .MEM_WB_data_to_reg(MEM_WB_data_to_reg),
        .MEM_WB_reg_write(MEM_WB_reg_write),
		.MEM_WB_written_reg(MEM_WB_written_reg),
        .MEM_WB_data_in(MEM_WB_data_in)
	);

    // WB:-------------------------------------------------------------------------------------------
    // From EXE:
    //   1. inst_in
       //   Control_signals {
       //   2. data_to_reg (WB)
       //   3. reg_write (WB)
       //   }
    //   4. ALU_out (Addr_out outside) (used at both MEM and WB)
    // Local:
    wire [31:0] LoA_data;

    LUI_or_AUIPC _loa_ (
        .inst_in(MEM_WB_inst_in[31:0]),
        .PC(MEM_WB_PC),
        .data(LoA_data[31:0])
	);
	
    Mux4to1b32  _mux3_ (
        .I0(MEM_WB_ALU_out[31:0]),          // Others
        .I1(MEM_WB_data_in[31:0]),          // Load
        .I2(LoA_data[31:0]),                // LUI and AUIPC
        .I3(MEM_WB_PC[31:0] + 32'b0100),    // jal and jalr: PC + 4
        .s(MEM_WB_data_to_reg[1:0]),
        .o(wt_data[31:0]));
    
endmodule
