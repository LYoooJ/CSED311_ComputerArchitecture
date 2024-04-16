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

  wire[31:0] inst;

  wire PCwrite;
  wire IFIDwrite;
  wire [4:0] mux_isEcall_out;
  wire [31:0] mux_forwardA_out;
  wire [31:0] mux_forwardB_out;

  /***** register wire *****/
  wire [31:0] rs1_dout;
  wire [31:0] rs2_dout;
  wire [31:0] rd_din;

  /***** Imm_gen_out wire *****/
  wire [31:0] imm_gen_out;

  /***** ALU wire *****/
  wire [31:0] alu_in_1;
  wire [31:0] alu_in_2;

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

  /***** forwarding unit wire *****/  
  wire [1:0] ForwardB;

  /***** Register declarations *****/
  // You need to modify the width of registers
  // In addition, 
  // 1. You might need other pipeline registers that are not described below
  // 2. You might not need registers described below
  /***** IF/ID pipeline registers *****/
  reg [31:0] IF_ID_inst;           // will be used in ID stage
  /***** ID/EX pipeline registers *****/
  // From the control unit
  reg ID_EX_alu_op;         // will be used in EX stage
  reg ID_EX_alu_src;        // will be used in EX stage
  reg ID_EX_mem_write;      // will be used in MEM stage
  reg ID_EX_mem_read;       // will be used in MEM stage
  reg ID_EX_mem_to_reg;     // will be used in WB stage
  reg ID_EX_reg_write;      // will be used in WB stage
  // From others
  reg ID_EX_rs1_data;
  reg ID_EX_rs2_data;
  reg ID_EX_imm;
  reg ID_EX_ALU_ctrl_unit_input;
  reg ID_EX_rd;
  //추가
  reg ID_EX_rs1;
  reg ID_EX_rs2;

  /***** EX/MEM pipeline registers *****/
  // From the control unit
  reg EX_MEM_mem_write;     // will be used in MEM stage
  reg EX_MEM_mem_read;      // will be used in MEM stage
  reg EX_MEM_is_branch;     // will be used in MEM stage
  reg EX_MEM_mem_to_reg;    // will be used in WB stage
  reg EX_MEM_reg_write;     // will be used in WB stage
  // From others
  reg EX_MEM_alu_out;
  reg EX_MEM_dmem_data;
  reg EX_MEM_rd;

  /***** MEM/WB pipeline registers *****/
  // From the control unit
  reg MEM_WB_mem_to_reg;    // will be used in WB stage
  reg MEM_WB_reg_write;     // will be used in WB stage
  // From others
  reg MEM_WB_mem_to_reg_src_1;
  reg MEM_WB_mem_to_reg_src_2;
  //추가
  reg MEM_WB_rd;

  // ---------- Update program counter ----------
  // PC must be updated on the rising edge (positive edge) of the clock.
  PC pc(
    .reset(reset),       // input (Use reset to initialize PC. Initial value must be 0)
    .clk(clk),         // input
    .next_pc(next_pc),     // input
    .current_pc(current_pc)   // output
  );
  
  // ---------- Instruction Memory ----------
  InstMemory imem(
    .reset(reset),   // input
    .clk(clk),     // input
    .addr(current_pc),    // input
    .dout(inst[31:0])     // output
  );

  // Update IF/ID pipeline registers here
  always @(posedge clk) begin
    if (reset) begin

    end
    else begin
      if(IFIDwrite == 1) begin
        IF_ID_inst <= inst;
      end


    end
  end

  // ---------- Register File ----------
  RegisterFile reg_file (
    .reset (reset),        // input
    .clk (clk),          // input
    .rs1 (mux_isEcall_out),          // input
    .rs2 (IF_ID_inst[24:20]),          // input
    .rd (IF_ID_inst[11:7]),           // input
    .rd_din (),       // input
    .write_enable (),    // input
    .rs1_dout (rs1_dout),     // output
    .rs2_dout (rs2_dout),      // output
    .print_reg(print_reg)
  );


  // ---------- Control Unit ----------
  ControlUnit ctrl_unit (
    .part_of_inst(IF_ID_inst[6:0]),  // input
    .mem_read(MemRead),      // output
    .mem_to_reg(MemToReg),    // output
    .mem_write(MemWrite),     // output
    .alu_src(ALUsrc),       // output
    .write_enable(RegWrite),  // output
    //.pc_to_reg(),     // output
    .alu_op(ALUOp),        // output
    .is_ecall(is_ecall)       // output (ecall inst)
  );

  // ---------- Immediate Generator ----------
  ImmediateGenerator imm_gen(
    .part_of_inst(IF_ID_inst[31:0]),  // input
    .imm_gen_out(imm_gen_out)    // output
  );

  // Update ID/EX pipeline registers here
  always @(posedge clk) begin
    if (reset) begin
    end
    else begin
      if(hazardout ==1) begin 
        ID_EX_alu_op = 0;        
        ID_EX_alu_src = 0;    // will be used in EX stage
        ID_EX_mem_write = 0;     // will be used in MEM stage
        ID_EX_mem_read = 0;     // will be used in MEM stage
        ID_EX_mem_to_reg = 0;     // will be used in WB stage
        ID_EX_reg_write = 0;     // will be used in WB stage
        // From others //아닐수도
        ID_EX_rs1_data = 0;
        ID_EX_rs2_data = 0;
        ID_EX_imm = 0;
        ID_EX_ALU_ctrl_unit_input = 0;
        ID_EX_rd = 0;
      end
      else begin 
      end
    end
  end

  // ---------- ALU Control Unit ----------
  ALUControlUnit alu_ctrl_unit (
    .part_of_inst(),  // input
    .alu_op()         // output
  );

  // ---------- ALU ----------
  ALU alu (
    .alu_op(),      // input
    .alu_in_1(),    // input  
    .alu_in_2(),    // input
    .alu_result(),  // output
    .alu_zero()     // output
  );

  // Update EX/MEM pipeline registers here
  always @(posedge clk) begin
    if (reset) begin
    end
    else begin
    end
  end

  // ---------- Data Memory ----------
  DataMemory dmem(
    .reset (reset),      // input
    .clk (clk),        // input
    .addr (EX_MEM_alu_out),       // input
    .din (EX_MEM_dmem_data),        // input
    .mem_read (MemRead),   // input
    .mem_write (MemWrite),  // input
    .dout (MEM_WB_mem_to_reg_src_2)        // output
  );

  // Update MEM/WB pipeline registers here
  always @(posedge clk) begin
    if (reset) begin
    end
    else begin
    end
  end

  //
  HazardDetection HazardDetection(
    .input_1(IF_ID_inst[19:15]),
    .input_2(IF_ID_inst[24:20]),
    .input_3(ID_EX_mem_read),

    .output_1(PCwrite),
    .output_2(IFIDwrite),
    .output_3(hazardout)
  );

  ForwardingUnit ForwardingUnit(
    .EX_rs1(ID_EX_rs1),
    .EX_rs2(ID_EX_rs2),
    .MEM_rd(EX_MEM_rd),
    .WB_rd(MEM_WB_rd),
    .MEM_RegWrite(EX_MEM_reg_write),
    .WB_RegWrite(MEM_WB_reg_write),
    .ForwardA(ForwardA),
    .ForwardB(ForwardB)
  );

  Adder Adder(
    .input_1(current_pc),
    .input_2(4),
    .sum(next_pc)
  );

  mux_2x1 mux_2x1_isEcall(
    .input_1(17),           // input
    .input_2(IF_ID_inst[19:15]),           // input
    .control(is_ecall),              // input
    .mux_out(mux_isEcall_out)               // output
  );

  mux_2x1 mux_2x1_MemtoReg(
    .input_1(MEM_WB_mem_to_reg_src_1),           // input
    .input_2(MEM_WB_mem_to_reg_src_2),           // input
    .control(MEM_WB_mem_to_reg),              // input
    .mux_out(rd_din)               // output
  );

  mux_2x1 mux_2x1_ALUSrc(
    .input_1(mux_forwardB_out),           // input
    .input_2(imm_gen_out),           // input
    .control(ALUSrc),              // input
    .mux_out(alu_in_2)               // output
  );

  //   mux_2x1 mux_2x1_control(
  //   .input_1(),           // input
  //   .input_2(0),           // input
  //   .control(),              // input
  //   .mux_out()               // output
  // );

  mux_4x1 mux_4x1_A(
    .input_1(ID_EX_rs1_data),      // input
    .input_2(EX_MEM_alu_out),           // input
    .input_3(rd_din),
    .input_4(0),
    .control(ForwardA),              // input
    .mux_out(alu_in_1)               // output
  );

  mux_4x1 mux_4x1_B(
    .input_1(ID_EX_rs2_data),           // input
    .input_2(EX_MEM_alu_out),           // input
    .input_3(rd_din),
    .input_4(0),
    .control(ForwardB),              // input
    .mux_out(mux_forwardB_out)               // output
  );

endmodule
