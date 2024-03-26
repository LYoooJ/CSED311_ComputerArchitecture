// Submit this file with other files you created.
// Do not touch port declarations of the module 'CPU'.

// Guidelines
// 1. It is highly recommened to `define opcodes and something useful.
// 2. You can modify the module.
// (e.g., port declarations, remove modules, define new modules, ...)
// 3. You might need to describe combinational logics to drive them into the module (e.g., mux, and, or, ...)
// 4. `include files if required

module cpu(input reset,       // positive reset signal
           input clk,         // clock signal
           output is_halted,
           output [31:0]print_reg[0:31]
           ); // Whehther to finish simulation
  /***** Wire declarations *****/
  wire [31:0] next_pc;
  wire [31:0] current_pc;

  wire PCWriteNotCond;
  wire PCWrite;
  wire IorD;
  wire MemRead;
  wire MemWrite;
  wire MemtoReg;
  wire IRWrite;
  wire PCSource;
  wire ALUOp;
  wire [1:0] ALUSrcB;
  wire ALUSrcA;
  wire RegWrite;

  /*****pc wire *****/
  wire [31:0] next_pc;
  wire [31:0] current_pc;

  /*****MemData wire *****/
  
  /*****Instruction *****/
  wire [31:0] inst;

  /*****register wire *****/
  wire [31:0] rd_din;
  wire [31:0] rs1_dout;
  wire [31:0] rs2_dout;

  /*** Imm_gen_out wire *****/
  wire [31:0]imm_gen_out;

  /***** ALU *****/
  wire [31:0] alu_in_2;
  wire bcond;
  wire [3:0] alu_op;

  wire [31:0] alu_result;

  wire and_result;
  wire or_result;
  
  //
  /***** Register declarations *****/
  reg [31:0] IR; // instruction register
  reg [31:0] MDR; // memory data register
  reg [31:0] A; // Read 1 data register
  reg [31:0] B; // Read 2 data register
  reg [31:0] ALUOut; // ALU output register
  // Do not modify and use registers declared above.

  // ---------- Update program counter ----------
  // PC must be updated on the rising edge (positive edge) of the clock.
  PC pc(
    .reset(reset),       // input (Use reset to initialize PC. Initial value must be 0)
    .clk(clk),         // input
    .next_pc(next_pc),     // input
    .current_pc(current_pc)   // output
  );

  // ---------- Register File ----------
  RegisterFile reg_file(
    .reset(reset),        // input
    .clk(clk),          // input
    .rs1(IR[19:15]),          // input
    .rs2(IR[24:20]),          // input
    .rd(IR[11:7]),           // input
    .rd_din(),       // input
    .write_enable(),  // input
    .rs1_dout(),     // output
    .rs2_dout(),      // output
    .print_reg()     // output (TO PRINT REGISTER VALUES IN TESTBENCH)
  );

  // ---------- Memory ----------
  Memory memory(
    .reset(reset),      // input
    .clk(clk),          // input
    .addr(),            // input
    .din(),             // input
    .mem_read(MemRead),     // input
    .mem_write(MemWrite),    // input
    .dout()          // output
  );

  // ---------- Control Unit ----------
  ControlUnit ctrl_unit(
    .part_of_inst(IR[6:0]),  // input
    .PCWriteNotCond(PCWriteNotCond),
    .PCWrite(PCWrite),
    .IorD(IorD),
    .MemRead(MemRead),
    .MemWrite(MemWrite),
    .MemtoReg(MemtoReg),
    .IRWrite(IRWrite),
    .PCSource(PCSource),
    .ALUOp(ALUOp),
    .ALUSrcB(ALUSrcB),
    .ALUSrcA(ALUSrcA),
    .RegWrite(RegWrite)
  );

  // ---------- Immediate Generator ----------
  ImmediateGenerator imm_gen(
    .part_of_inst(IR[31:0]),  // input
    .imm_gen_out(imm_gen_out)    // output
  );

  // ---------- ALU Control Unit ----------
  ALUControlUnit alu_ctrl_unit(
    .part_of_inst({IR[30], IR[14:12]}),  // input
    .alu_op(),                           // input
    .alu_control_lines()                 // output
  );

  // ---------- ALU ----------
  ALU alu(
    .alu_op(),      // input
    .alu_in_1(),    // input  
    .alu_in_2(),    // input
    .alu_result(alu_result),  // output
    .alu_bcond()     // output
  );

 // ---------- IorD ----------
  2x1_mux IorD_mux(
    .input_1(),       // input
    .input_2(),    // input
    .control(),        // input
    .mux_out()        // output
  );

 // ---------- MemToReg Mux ----------
  2x1_mux MemToReg_mux(
    .input_1(),       // input
    .input_2(),    // input
    .control(),        // input
    .mux_out()        // output
  );

 // ----------ALU_src_A_mux ----------
  2x1_mux ALU_src_A_mux(
    .input_1(),       // input
    .input_2(),    // input
    .control(),        // input
    .mux_out()        // output
  );

 // ---------- ALU_src_B_mux ----------
  4x1_mux ALU_src_B_mux(
    .input_1(),       // input
    .input_2(),    // input
    .input_3(),
    .input_4(),
    .control(),        // input
    .mux_out()        // output
  );

 // ---------- PC_source_mux ----------
  2x1_mux PC_source_mux(
    .input_1(),       // input
    .input_2(),    // input
    .control(),        // input
    .mux_out()        // output
  );

endmodule
