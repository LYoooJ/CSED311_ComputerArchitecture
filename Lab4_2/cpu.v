// Submit this file with other files you created.
// Do not touch port declarations of the module 'CPU'.

// Guidelines
// 1. It is highly recommened to `define opcodes and something useful.
// 2. You can modify modules (except InstMemory, DataMemory, and RegisterFile)
// (e.g., port declarations, remove modules, define new modules, ...)
// 3. You might need to describe combinational logics to drive them into the module (e.g., mux, and, or, ...)
// 4. `include files if required

module cpu(input reset,       // positive reset signal
           input clk,         // clock signal
           output is_halted, // Whehther to finish simulation
           output [31:0]print_reg[0:31]); // Whehther to finish simulation
  /***** Wire declarations *****/
  /***** pc wire *****/
  wire [31:0] current_pc;
  wire [31:0] next_pc;
  wire [31:0] inst;

  /***** register wire *****/
  wire [31:0] rs1_dout;
  wire [31:0] rs2_dout;
  wire [31:0] rd_din;

  /***** Imm_gen_out wire *****/
  wire [31:0] imm_gen_out;

  /***** ALU wire *****/
  wire [31:0] alu_in_1;
  wire [31:0] alu_in_2;
  wire [31:0] alu_result;

  /***** control unit wire *****/
  wire MemRead;
  wire MemWrite;
  wire MemtoReg;
  wire RegWrite;
  wire ALUSrc;
  wire is_ecall;
  wire [1:0] ALUOp;

  /***** hazard detection unit wire *****/
  wire hazardout;
  wire IFIDwrite;
  wire PCwrite;

  /***** Forwarding Unit wire *****/
  wire [1:0] ForwardA;
  wire [1:0] ForwardB;

  /***** mux wire *****/
  wire mux_control_out;
  wire mux_MemtoReg_out;
  wire [31:0] mux_isEcall_out;
  wire [31:0] mux_forwardA_out;
  wire [31:0] mux_forwardB_out;
  wire [31:0] mux_forward_out;
  wire [1:0] forward17;
  

  /***** alu control *****/
  wire [3:0] alu_control_lines; //output wire
  wire alu_bcond;
  
  /***** Dmem *****/
  wire [31:0] ReadData;

  /***** Halt *****/
  wire halted_check;

  /**** Gshare ****/
  wire taken;
  assign taken = alu_bcond & ID_EX_is_branch;


  /***** Register declarations *****/
  // You need to modify the width of registers
  // In addition, 
  // 1. You might need other pipeline registers that are not described below
  // 2. You might not need registers described below
  /***** IF/ID pipeline registers *****/
  reg [31:0] IF_ID_inst;           // will be used in ID stage
  /***** ID/EX pipeline registers *****/
  // From the control unit
  reg [1:0] ID_EX_alu_op;   // will be used in EX stage
  reg ID_EX_alu_src;        // will be used in EX stage
  reg ID_EX_mem_write;      // will be used in MEM stage
  reg ID_EX_mem_read;       // will be used in MEM stage
  reg ID_EX_mem_to_reg;     // will be used in WB stage
  reg ID_EX_reg_write;      // will be used in WB stage
  //추가
  reg ID_EX_is_branch;

  // From others
  reg [31:0] ID_EX_rs1_data;
  reg [31:0] ID_EX_rs2_data;
  reg [31:0] ID_EX_imm;
  reg [31:0] ID_EX_ALU_ctrl_unit_input;
  reg [4:0] ID_EX_rd;
  reg [4:0] ID_EX_rs1;
  reg [4:0] ID_EX_rs2;
  reg [31:0] ID_EX_inst;

  /***** EX/MEM pipeline registers *****/
  // From the control unit
  reg EX_MEM_mem_write;     // will be used in MEM stage
  reg EX_MEM_mem_read;      // will be used in MEM stage
  //reg EX_MEM_is_branch;     // will be used in MEM stage
  reg EX_MEM_mem_to_reg;    // will be used in WB stage
  reg EX_MEM_reg_write;     // will be used in WB stage
  // From others
  reg [31:0] EX_MEM_alu_out;
  reg [31:0] EX_MEM_dmem_data;
  reg [4:0] EX_MEM_rd;

  /***** MEM/WB pipeline registers *****/
  // From the control unit
  reg MEM_WB_mem_to_reg;    // will be used in WB stage
  reg MEM_WB_reg_write;     // will be used in WB stage
  // From others
  reg [31:0] MEM_WB_mem_to_reg_src_1;
  reg [31:0] MEM_WB_mem_to_reg_src_2;
  reg [4:0] MEM_WB_rd;
  
  reg ID_EX_is_halted;
  reg EX_MEM_is_halted;
  reg MEM_WB_is_halted;
  reg halt_signal;

  assign halted_check = ((mux_forward_out == 10) && is_ecall && !hazardout) ? 1 : 0;
  assign is_halted = MEM_WB_is_halted;
  
  // ---------- Update program counter ----------
  // PC must be updated on the rising edge (positive edge) of the clock.
  PC pc(
    .reset(reset),            // input (Use reset to initialize PC. Initial value must be 0)
    .clk(clk),                // input
    .PCwrite(PCwrite),        // input
    .next_pc(next_pc),        // input
    .current_pc(current_pc)   // output
  );
  
  // ---------- Instruction Memory ----------
  InstMemory imem(
    .reset(reset),            // input
    .clk(clk),                // input
    .addr(current_pc),        // input
    .dout(inst[31:0])         // output
  );

  // Update IF/ID pipeline registers here
  always @(posedge clk) begin
    if (reset) begin
      IF_ID_inst <= 32'b0;
    end
    else begin
      if(IFIDwrite == 1) begin
        IF_ID_inst <= inst;
      end
    end
  end

  // ---------- Register File ----------
  RegisterFile reg_file (
    .reset (reset),                     // input
    .clk (clk),                         // input
    .rs1 (mux_isEcall_out[4:0]),        // input
    .rs2 (IF_ID_inst[24:20]),           // input
    .rd (MEM_WB_rd),                    // input
    .rd_din (rd_din),                   // input
    .write_enable (MEM_WB_reg_write),   // input
    .rs1_dout (rs1_dout),               // output
    .rs2_dout (rs2_dout),               // output
    .print_reg(print_reg)               // output
  );


  // ---------- Control Unit ----------
  ControlUnit ctrl_unit (
    .part_of_inst(IF_ID_inst[6:0]),     // input
    .mem_read(MemRead),                 // output
    .mem_to_reg(MemtoReg),              // output
    .mem_write(MemWrite),               // output
    .alu_src(ALUSrc),                   // output
    .write_enable(RegWrite),            // output
    .alu_op(ALUOp),                     // output
    .is_ecall(is_ecall),                 // output (ecall inst)
    .is_jal(is_jal),
    .is_jalr(is_jalr),
    .branch(branch),
    .pc_to_reg(pc_to_reg)
  );

  // ---------- Immediate Generator ----------
  ImmediateGenerator imm_gen(
    .part_of_inst(IF_ID_inst[31:0]),    // input
    .imm_gen_out(imm_gen_out)           // output
  );

  // Update ID/EX pipeline registers here
  always @(posedge clk) begin
    if (reset) begin
      ID_EX_alu_op <= 0;        
      ID_EX_alu_src <= 0;    // will be used in EX stage
      ID_EX_mem_write <= 0;     // will be used in MEM stage
      ID_EX_mem_read <= 0;     // will be used in MEM stage
      ID_EX_mem_to_reg <= 0;     // will be used in WB stage
      ID_EX_reg_write <= 0;     // will be used in WB stage
      ID_EX_rs1_data <= 0;
      ID_EX_rs2_data <= 0;
      ID_EX_imm <= 0;
      ID_EX_ALU_ctrl_unit_input <= 0;
      ID_EX_rd <= 0;
      ID_EX_rs1 <= 0;
      ID_EX_rs2 <= 0;      
      ID_EX_is_halted <= 0;
      ID_EX_inst <= 0;
      /*****************************추가****************/
      ID_EX_is_branch <=0;
    end
    else begin
      // From others 
      ID_EX_inst <= IF_ID_inst;
      ID_EX_rs1_data <= mux_forward_out;
      ID_EX_rs2_data <= rs2_dout;
      ID_EX_imm <= imm_gen_out;
      ID_EX_ALU_ctrl_unit_input <= IF_ID_inst;
      ID_EX_rd <= IF_ID_inst[11:7];
      ID_EX_rs1 <= IF_ID_inst[19:15];
      ID_EX_rs2 <= IF_ID_inst[24:20];
      ID_EX_is_halted <= halted_check;
      /*****************************추가****************/
      ID_EX_is_branch <=branch;

      if(hazardout == 1) begin 
        ID_EX_alu_op <= 0;        
        ID_EX_alu_src <= 0;   
        ID_EX_mem_write <= 0;     
        ID_EX_mem_read <= 0;     
        ID_EX_mem_to_reg <= 0;     
        ID_EX_reg_write <= 0;  
      end
      else begin 
        ID_EX_alu_op <= ALUOp;        
        ID_EX_alu_src <= ALUSrc ;   
        ID_EX_mem_write <= MemWrite;     
        ID_EX_mem_read <= MemRead;     
        ID_EX_mem_to_reg <= MemtoReg;     
        ID_EX_reg_write <= RegWrite;     
      end
    end
  end

  // ---------- ALU Control Unit ----------
  ALUControlUnit alu_ctrl_unit (
    .part_of_inst(ID_EX_inst),            // input
    .alu_op(ID_EX_alu_op),                // input
    .alu_control_lines(alu_control_lines) // output
  );

  // ---------- ALU ----------
  ALU alu (
    .alu_op(alu_control_lines),           // input
    .alu_in_1(alu_in_1),                  // input  
    .alu_in_2(alu_in_2),                  // input
    .alu_result(alu_result),              // output
    .alu_bcond(alu_bcond)                 // output
  );

  // Update EX/MEM pipeline registers here
  always @(posedge clk) begin
    if (reset) begin
      EX_MEM_mem_write <= 0;     
      EX_MEM_mem_read <= 0;      
      //EX_MEM_is_branch <= 0;     
      EX_MEM_mem_to_reg <= 0;    
      EX_MEM_alu_out <= 0;
      EX_MEM_dmem_data <= 0;
      EX_MEM_rd <= 0;
      EX_MEM_is_halted <= 0;
    end
    else begin
      EX_MEM_mem_write <= ID_EX_mem_write;     
      EX_MEM_mem_read <= ID_EX_mem_read;      
      EX_MEM_mem_to_reg <= ID_EX_mem_to_reg;   
      EX_MEM_reg_write <= ID_EX_reg_write;     
      EX_MEM_alu_out <= alu_result;
      EX_MEM_dmem_data <= mux_forwardB_out;
      EX_MEM_rd <= ID_EX_rd;
      EX_MEM_is_halted <= ID_EX_is_halted;
    end
  end

  // ---------- Data Memory ----------
  DataMemory dmem(
    .reset (reset),                 // input
    .clk (clk),                     // input
    .addr (EX_MEM_alu_out),         // input
    .din (EX_MEM_dmem_data),        // input
    .mem_read (EX_MEM_mem_read),    // input
    .mem_write (EX_MEM_mem_write),  // input
    .dout (ReadData)                // output
  );

  // Update MEM/WB pipeline registers here
  always @(posedge clk) begin
    if (reset) begin
      MEM_WB_mem_to_reg <= 0;    
      MEM_WB_reg_write <= 0;     
      MEM_WB_mem_to_reg_src_1 <= 0;
      MEM_WB_mem_to_reg_src_2 <= 0;
      MEM_WB_rd <= 0;
      MEM_WB_is_halted <= 0;
    end
    else begin
      MEM_WB_mem_to_reg <= EX_MEM_mem_to_reg;   
      MEM_WB_reg_write <= EX_MEM_reg_write;   
      MEM_WB_mem_to_reg_src_1 <= EX_MEM_alu_out;
      MEM_WB_mem_to_reg_src_2 <= ReadData;
      MEM_WB_rd <= EX_MEM_rd;
      MEM_WB_is_halted <= EX_MEM_is_halted;
    end
  end

  // ---------- Hazard Detection Unit ----------
  HazardDetection HazardDetection(
    .ID_rs1(IF_ID_inst[19:15]),       // input
    .ID_rs2(IF_ID_inst[24:20]),       // input
    .EX_rd(ID_EX_rd),                 // input
    .MEM_rd(EX_MEM_rd),               // input
    .EX_mem_read(ID_EX_mem_read),     // input
    .EX_reg_write(ID_EX_reg_write),   // input
    .MEM_mem_read(EX_MEM_mem_read),   // input
    .ID_opcode(IF_ID_inst[6:0]),      // input
    .PCWrite(PCwrite),                // output
    .IF_ID_write(IFIDwrite),          // output
    .is_hazard(hazardout)             // output
  );

  // ---------- Forwarding Unit ----------
  ForwardingUnit ForwardingUnit(
    .EX_rs1(ID_EX_rs1),               // input
    .EX_rs2(ID_EX_rs2),               // input
    .MEM_rd(EX_MEM_rd),               // input
    .WB_rd(MEM_WB_rd),                // input
    .MEM_RegWrite(EX_MEM_reg_write),  // input
    .WB_RegWrite(MEM_WB_reg_write),   // input
    .ForwardA(ForwardA),              // output
    .ForwardB(ForwardB)               // output
  );

  // ---------- Ecall forwarding Unit ----------
  ecall_forward ecall_forward(
    .opcode(IF_ID_inst[6:0]),         // input
    .MEM_rd(EX_MEM_rd),               // input
    .WB_rd(MEM_WB_rd),                // input
    .MEM_RegWrite(EX_MEM_reg_write),  // input
    .WB_RegWrite(MEM_WB_reg_write),   // input
    .control(forward17)               // output
  );

  // ---------- PC increment Adder ----------
  Adder Adder(
    .input_1(current_pc),             // input
    .input_2(4),                      // input
    .sum(next_pc)                     // output
  );

  // ---------- isEcall Mux ----------
  mux_2x1 mux_2x1_isEcall(
    .input_1({27'b0, IF_ID_inst[19:15]}),   // input
    .input_2(17),                           // input
    .control(is_ecall),                     // input
    .mux_out(mux_isEcall_out)               // output
  );

  // ---------- MemtoReg Mux ----------
  mux_2x1 mux_2x1_MemtoReg(
    .input_1(MEM_WB_mem_to_reg_src_1),      // input
    .input_2(MEM_WB_mem_to_reg_src_2),      // input
    .control(MEM_WB_mem_to_reg),            // input
    .mux_out(rd_din)                        // output
  );

  // ---------- ALUSrc Mux ----------
  mux_2x1 mux_2x1_ALUSrc(
    .input_1(mux_forwardB_out),             // input
    .input_2(ID_EX_imm),                    // input
    .control(ID_EX_alu_src),                // input
    .mux_out(alu_in_2)                      // output
  );

  // ---------- Forward A Mux ----------
  mux_4x1 mux_4x1_A(
    .input_1(ID_EX_rs1_data),               // input
    .input_2(EX_MEM_alu_out),               // input
    .input_3(rd_din),                       // input
    .input_4(0),                            // input
    .control(ForwardA),                     // input
    .mux_out(alu_in_1)                      // output
  );

  // ---------- Forward B Mux ----------
  mux_4x1 mux_4x1_B(
    .input_1(ID_EX_rs2_data),               // input
    .input_2(EX_MEM_alu_out),               // input
    .input_3(rd_din),                       // input
    .input_4(0),                            // input
    .control(ForwardB),                     // input
    .mux_out(mux_forwardB_out)              // output
  );

  // ---------- Forward 17 Mux ----------
    mux_4x1 mux_4x1_forward(
    .input_1(rs1_dout),                     // input
    .input_2(EX_MEM_alu_out),                   // input
    .input_3(rd_din),                     // input
    .input_4(0),                            // input    
    .control(forward17),                    // input
    .mux_out(mux_forward_out)               // output
  );

  //---------- Gshare ----------
  Gshare gshare(
    .reset(reset),
    .clk(clk),
    .is_branch(),
    .is_jal(is_jal),
    .is_jalr(is_jalr),
    .actual_branch_target(),
    .actual_taken(),
    .prediction_correct(),
    .current_pc(current_pc),
    .next_pc(),
);

endmodule
