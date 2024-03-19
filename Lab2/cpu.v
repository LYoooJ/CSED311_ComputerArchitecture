// Submit this file with other files you created.
// Do not touch port declarations of the module 'cpu'.

// Guidelines
// 1. It is highly recommened to `define opcodes and something useful.
// 2. You can modify the module.
// (e.g., port declarations, remove modules, define new modules, ...)
// 3. You might need to describe combinational logics to drive them into the module (e.g., mux, and, or, ...)
// 4. `include files if required

module cpu(input reset,                     // positive reset signal
           input clk,                       // clock signal
           output is_halted,                // Whehther to finish simulation
           output [31:0] print_reg [0:31]); // TO PRINT REGISTER VALUES IN TESTBENCH (YOU SHOULD NOT USE THIS)
  /***** Wire declarations *****/
  wire [31:0] next_pc;
  wire [31:0] current_pc;

  wire [31:0] branch_target;
  wire [31:0] incremented_pc;

  wire[31:0] inst;

  wire [31:0] rd_din;
  wire [31:0] rs1_dout;
  wire [31:0] rs2_dout;

  wire[31:0] mem_dout;

  wire is_jal;
  wire is_jalr; 
  wire branch;
  wire mem_read;
  wire mem_to_reg;
  wire mem_write;
  wire alu_src;
  wire write_enable;
  wire pc_to_reg;
  wire is_ecall;
  wire pc_src_1;

  wire [31:0]imm_gen_out;
  
  wire [31:0] alu_in_2;
  wire [3:0] alu_op;
  wire [31:0] alu_result;
  wire bcond;

  wire and_result;
  wire [31:0] pc_src1_mux_out;
  wire [31:0] mem_to_reg_mux_out;
 
  /***** Register declarations *****/

  // ---------- Update program counter ----------
  // PC must be updated on the rising edge (positive edge) of the clock.
  pc pc(
    .reset(reset),            // input (Use reset to initialize PC. Initial value must be 0)
    .clk(clk),                // input
    .next_pc(next_pc),        // input
    .current_pc(current_pc)   // output
  );
  
  // ---------- Instruction Memory ----------
  instruction_memory imem(
    .reset(reset),            // input
    .clk(clk),                // input
    .addr(current_pc),        // input
    .dout(inst)               // output
  );

  // ---------- Register File ----------
  register_file reg_file (
    .reset (reset),               // input
    .clk (clk),                   // input
    .rs1 (inst[19:15]),           // input
    .rs2 (inst[24:20]),           // input
    .rd (inst[11:7]),             // input
    .rd_din (rd_din),             // input
    .write_enable (write_enable), // input
    .is_ecall(is_ecall),          // input
    .is_halted(is_halted),        // output
    .rs1_dout (rs1_dout),         // output
    .rs2_dout (rs2_dout),         // output
    .print_reg (print_reg)  //DO NOT TOUCH THIS
  );


  // ---------- Control Unit ----------
  control_unit ctrl_unit (
    .part_of_inst(inst[6:0]),     // input
    .is_jal(is_jal),              // output
    .is_jalr(is_jalr),            // output
    .branch(branch),              // output
    .mem_read(mem_read),          // output
    .mem_to_reg(mem_to_reg),      // output
    .mem_write(mem_write),        // output
    .alu_src(alu_src),            // output
    .write_enable(write_enable),  // output
    .pc_to_reg(pc_to_reg),        // output
    .is_ecall(is_ecall)          // output (ecall inst)    
  );

  // ---------- Immediate Generator ----------
  immediate_generator imm_gen(
    .part_of_inst(inst),          // input
    .imm_gen_out(imm_gen_out)     // output
  );

  // ---------- ALU Control Unit ----------
  alu_control_unit alu_ctrl_unit (
    .opcode(inst[6:0]),     // input
    .funct3(inst[14:12]),   // input
    .sign(inst[30]),        // input
    .alu_op(alu_op)         // output
  );

  // ---------- ALU ----------
  alu alu (
    .alu_op(alu_op),          // input
    .alu_in_1(rs1_dout),      // input  
    .alu_in_2(alu_in_2),      // input
    .alu_result(alu_result),  // output
    .alu_bcond(bcond)         // output
  );

  // ---------- Data Memory ----------
  data_memory dmem(
    .reset (reset),           // input
    .clk (clk),               // input
    .addr (alu_result),       // input
    .din (rs2_dout),          // input
    .mem_read (mem_read),     // input
    .mem_write (mem_write),   // input
    .dout (mem_dout)          // output
  );

  // ---------- ALUSrc Mux ----------
  mux ALUSrc_mux(
    .input_1(rs2_dout),       // input
    .input_2(imm_gen_out),    // input
    .control(alu_src),        // input
    .mux_out(alu_in_2)        // output
  );

 // ---------- MemToReg Mux ----------
  mux MemToReg_mux(
    .input_1(alu_result),         // input
    .input_2(mem_dout),           // input
    .control(mem_to_reg),         // input
    .mux_out(mem_to_reg_mux_out)  // output
  );

 // ---------- PCToReg Mux ----------
  mux PCtoReg_mux(
    .input_1(mem_to_reg_mux_out),   // input
    .input_2(incremented_pc),       // input
    .control(pc_to_reg),            // input
    .mux_out(rd_din)                // output
  );

 // ---------- PCSrc1 Mux ----------
  mux PCSrc1_mux(
    .input_1(incremented_pc),       // input
    .input_2(branch_target),        // input
    .control(pc_src_1),             // input
    .mux_out(pc_src1_mux_out)            // output
  );

 // ---------- PCSrc2 Mux ----------
  mux PCSrc2_mux(
    .input_1(pc_src1_mux_out),           // input
    .input_2(alu_result),           // input
    .control(is_jalr),              // input
    .mux_out(next_pc)               // output
  );

 // ---------- PC increment Adder ----------
  adder incremented_pc_adder(
    .input_1(current_pc),           // input
    .input_2(4),                    // input
    .sum(incremented_pc)            // output
  );

 // ---------- branch target Adder ----------
  adder branch_target_adder (
    .input_1(current_pc),           // input
    .input_2(imm_gen_out),          // input
    .sum(branch_target)             // output
  );

 // ---------- AND Gate ----------
  and_gate and_gate(
    .input_1(branch),       // input
    .input_2(bcond),        // input
    .out(and_result)        // output
  );

 // ---------- OR Gate ----------
  or_gate or_gate(
    .input_1(is_jal),       // input
    .input_2(and_result),   // input  
    .out(pc_src_1)          // output
  );

endmodule
