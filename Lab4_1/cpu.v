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

  wire [4:0] mux_isEcall_out;

  /***** register wire *****/
  wire [31:0] rs1_dout;
  wire [31:0] rs2_dout;

  /***** Imm_gen_out wire *****/
  wire [31:0] imm_gen_out;

  /***** control unit wire *****/
  wire MemRead;
  wire MemWrite;
  wire MemtoReg;
  wire RegWrite;
  wire ALUsrc;
  wire is_ecall;
  wire [1:0] ALUOp;

  /***** hazard detection unit wire *****/
  wire hazardout;
  wire IFIDwrite;
  wire PCwrite;

  /***** mux wire *****/
  wire mux_control_out;
  wire mux_MemtoReg_out;
  wire mux_A_out;
  wire mux_B_out;

  /***** alu wire *****/
  wire alu_result;
  wire alu_bcond;

  /***** alu control *****/
  wire alu_control_lines; //output wire
  
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
    .part_of_inst(inst[31:0]),  // input
    .alu_op(),      // output
    .alu_control_lines(alu_control_lines) // output
  );

  // ---------- ALU ----------
  ALU alu (
    .alu_op(alu_control_lines),      // input
    .alu_in_1(mux_A_out),    // input  
    .alu_in_2(mux_B_out),    // input
    .alu_result(alu_result),  // output
    .alu_bcond(alu_bcond)     // output
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
    .reset (),      // input
    .clk (),        // input
    .addr (),       // input
    .din (),        // input
    .mem_read (),   // input
    .mem_write (),  // input
    .dout ()        // output
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

  );

  Adder Adder(
    .input_1(current_pc),
    .input_2(4),
    .output(next_pc)
  );

  mux_2x1 mux_2x1_isEcall(
    .input_1(17),           // input
    .input_2(IF_ID_inst[19:15]),           // input
    .control(is_ecall),              // input
    .mux_out(mux_isEcall_out)               // output
  );

  mux_2x1 mux_2x1_MemtoReg(
    .input_1(),           // input
    .input_2(),           // input
    .control(),              // input
    .mux_out(mux_MemtoReg_out)               // output
  );

    mux_2x1 mux_2x1_control(
    .input_1(),           // input
    .input_2(0),           // input
    .control(),              // input
    .mux_out(mux_control_out)               // output
  );

  mux_4x1 mux_4x1_A(
    .input_1(),           // input
    .input_2(),           // input
    .input_3(),           // input
    .input_4(),           // input
    .control(),              // input
    .mux_out(mux_A_out)               // output
  );

  mux_4x1 mux_4x1_B(
    .input_1(),           // input
    .input_2(),           // input
    .input_3(),           // input
    .input_4(),           // input
    .control(),              // input
    .mux_out(mux_B_out)               // output
  );
  
endmodule
