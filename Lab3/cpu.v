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
           ); // Whether to finish simulation

  /***** Wire declarations *****/

  //control unit
  wire PCWriteNotCond;
  wire PCWrite;
  wire IorD;
  wire MemRead;
  wire MemWrite;
  wire MemtoReg;
  wire IRWrite;
  wire PCSource;
  wire [1:0] ALUOp;
  wire [1:0] ALUSrcB;
  wire ALUSrcA;
  wire RegWrite;
  wire is_ecall;

  wire ALUOutUpdate;

  /*****pc wire *****/
  wire [31:0] current_pc;
  wire PCUpdate;

  /*****register wire *****/
  wire [31:0] rs1_dout;
  wire [31:0] rs2_dout;

  /*****MemData wire *****/
  wire [31:0] MemData;

  /*****mux wire *****/
  wire [31:0] IorD_out;
  wire [31:0] MemtoReg_out;
  wire [31:0] ALU_src_A_out;
  wire [31:0] ALU_src_B_out;
  wire [31:0] PC_source_out;

  /*** Imm_gen_out wire *****/
  wire [31:0]imm_gen_out;

  /***** ALU *****/
  wire bcond; //output
  wire [3:0] alu_control_lines; //control
  wire [31:0] alu_result;

  //
  /***** Register declarations *****/
  reg [31:0] IR; // instruction register
  reg [31:0] MDR; // memory data register
  reg [31:0] A; // Read 1 data register
  reg [31:0] B; // Read 2 data register
  reg [31:0] ALUOut; // ALU output register
  // Do not modify and use registers declared above.

  // assign IR = MemData;
  // assign MDR = MemData;
  // assign ALUOut = alu_result;
  reg branch_taken;


  // ---------- Update program counter ----------
  // PC must be updated on the rising edge (positive edge) of the clock.
  PC pc(
    .clk(clk),
    .reset(reset),              // input (Use reset to initialize PC. Initial value must be 0)
    .PCUpdate(PCUpdate),        // input
    .next_pc(PC_source_out),          // input
    .current_pc(current_pc)     // output
  );

  // ---------- Register File ----------
  RegisterFile reg_file(
    .reset(reset),              // input
    .clk(clk),                  // input
    .rs1(IR[19:15]),            // input
    .rs2(IR[24:20]),            // input
    .rd(IR[11:7]),              // input
    .rd_din(MemtoReg_out),      // input
    .write_enable(RegWrite),    // input
    .rs1_dout(rs1_dout),               // output
    .rs2_dout(rs2_dout),               // output
    .print_reg(print_reg)       // output (TO PRINT REGISTER VALUES IN TESTBENCH)
  );

  // ---------- Memory ----------
  Memory memory(
    .reset(reset),                    // input
    .clk(clk),                        // input
    .addr(IorD_out),                  // input
    .din(B),                          // input
    .mem_read(MemRead),               // input
    .mem_write(MemWrite),             // input
    .dout(MemData)                    // output
  );

  // ---------- Control Unit ----------
  ControlUnit ctrl_unit(
    .part_of_inst(IR[6:0]),           // input
    .bcond(branch_taken),
    .clk(clk),
    .reset(reset),
    .is_ecall(is_ecall),
    .PCWriteNotCond(PCWriteNotCond),  // output
    .PCWrite(PCWrite),                // output
    .IorD(IorD),                      // output
    .MemRead(MemRead),                // output
    .MemWrite(MemWrite),              // output
    .MemtoReg(MemtoReg),              // output
    .IRWrite(IRWrite),                // output
    .PCSource(PCSource),              // output
    .ALUOp(ALUOp),                    // output
    .ALUSrcB(ALUSrcB),                // output
    .ALUSrcA(ALUSrcA),                // output
    .RegWrite(RegWrite),               // output
    .ALUOutUpdate(ALUOutUpdate)
  );

  // ---------- Immediate Generator ----------
  ImmediateGenerator imm_gen(
    .part_of_inst(IR[31:0]),                  // input
    .imm_gen_out(imm_gen_out)                 // output
  );

  // ---------- ALU Control Unit ----------
  ALUControlUnit alu_ctrl_unit(
    .part_of_inst(IR[31:0]),                  // input
    .alu_op(ALUOp),                           // input
    .alu_control_lines(alu_control_lines)     // output
  );

  // ---------- ALU ----------
  ALU alu(
    .alu_op(alu_control_lines),       // input
    .alu_in_1(ALU_src_A_out),         // input  
    .alu_in_2(ALU_src_B_out),         // input
    .alu_result(alu_result),          // output
    .alu_bcond(bcond)                 // output
  );

 // ---------- IorD ----------
  mux_2x1 IorD_mux(
    .input_1(current_pc),              // input
    .input_2(ALUOut),                  // input
    .control(IorD),                    // input
    .mux_out(IorD_out)                 // output
  );

 // ---------- MemToReg Mux ----------
  mux_2x1 MemToReg_mux(
    .input_1(ALUOut),               // input
    .input_2(MDR),                  // input
    .control(MemtoReg),                 // input
    .mux_out(MemtoReg_out)          // output
  );

 // ----------ALU_src_A_mux ----------
  mux_2x1 ALU_src_A_mux(
    .input_1(current_pc),           // input
    .input_2(A),                    // input
    .control(ALUSrcA),              // input
    .mux_out(ALU_src_A_out)         // output
  );

 // ---------- ALU_src_B_mux ----------
  mux_4x1 ALU_src_B_mux(
    .input_1(B),                    // input
    .input_2(4),                    // input
    .input_3(imm_gen_out),          // input
    .input_4(0),                    // input
    .control(ALUSrcB),              // input
    .mux_out(ALU_src_B_out)         // output
  );

 // ---------- PC_source_mux ----------
  mux_2x1 PC_source_mux(
    .input_1(alu_result),              // input
    .input_2(ALUOut),             // input
    .control(PCSource),           // input
    .mux_out(PC_source_out)        // output
  );

  halt_unit halt_unit(
    .rf17(print_reg[17]),
    .is_ecall(is_ecall),
    .is_halted(is_halted)
  );

  assign PCUpdate = (PCWriteNotCond & ~bcond) | PCWrite;

  always @(posedge clk) begin
    if (ALUOutUpdate) begin
      ALUOut <= alu_result;
    end
    branch_taken <= bcond;
    A <= rs1_dout;
    B <= rs2_dout; 

    if (!IorD && IRWrite) begin
      IR <= MemData;
      $display("IR: %x", IR);
    end
    if (IorD) begin
      MDR <= MemData;
    end
  end

endmodule
