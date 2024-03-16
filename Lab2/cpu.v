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
  //pc
  wire [31:0] next_pc;
  wire [31:0] current_pc;

  wire [31:0] branch_next_pc;
  wire [31:0] add_next_pc;

  //instruction module
  //wire[31:0] addr;
  wire[31:0] dout;

  //register file
  wire [31:0] rd_din;
  wire[31:0] rs1_dout;
  wire[31:0] rs2_dout;
  //reg or wire
  //reg write_enable;
  //wire[31:0] writeData;

  //data memory
  //wire[31:0] mem_addr; //data memory module Addr
  //wire[31:0] din; // Write data input
  //wire mem_read;
  //wire mem_write;
  wire[31:0] mem_dout; //dout of Data memory

  //ControlUnit
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
  wire pc_src_1; // and, or gate 처리

  //immediate_generator
  wire[31:0]imm_gen_out;
  
  //alu
  //wire[31:0] alu_in_1;
  wire[31:0] alu_in_2;
  wire[3:0] alu_op;
  wire[31:0] alu_result;
  wire bcond;
 
  /***** Register declarations *****/

  // ---------- Update program counter ----------
  // PC must be updated on the rising edge (positive edge) of the clock.
  pc pc(
    .reset(reset),       // input (Use reset to initialize PC. Initial value must be 0)
    .clk(clk),         // input
    .next_pc(next_pc),     // input
    .current_pc(current_pc)   // output
  );
  
  // ---------- Instruction Memory ----------
  instruction_memory imem(
    .reset(reset),   // input
    .clk(clk),     // input
    .addr(current_pc),    // input
    .dout(dout)     // output
  );

  // ---------- Register File ----------
  register_file reg_file (
    .reset (reset),        // input
    .clk (clk),          // input
    .rs1 (dout[19:15]),          // input
    .rs2 (dout[24:20]),          // input
    .rd (dout[11:7]),           // input
    .rd_din (rd_din),       // input
    .write_enable (write_enable), // input
    .rs1_dout (rs1_dout),     // output
    .rs2_dout (rs2_dout),     // output
    .print_reg (print_reg)  //DO NOT TOUCH THIS
  );


  // ---------- Control Unit ----------
  control_unit ctrl_unit (
    .part_of_inst(dout[6:0]),  // input
    .is_jal(is_jal),        // output
    .is_jalr(is_jalr),       // output
    .branch(branch),        // output
    .mem_read(mem_read),      // output
    .mem_to_reg(mem_to_reg),    // output
    .mem_write(mem_write),     // output
    .alu_src(alu_src),       // output
    .write_enable(write_enable),  // output
    .pc_to_reg(pc_to_reg),     // output
    .is_ecall(is_ecall),       // output (ecall inst)
    .pc_src_1(pc_src_1)
  );

  // ---------- Immediate Generator ----------
  immediate_generator imm_gen(
    .part_of_inst(dout),  // input
    .imm_gen_out(imm_gen_out)    // output
  );

  // ---------- ALU Control Unit ----------
  alu_control_unit alu_ctrl_unit (
    .part_of_inst(dout),  // input
    .alu_op(alu_op)         // output
  );

  // ---------- ALU ----------
  alu alu (
    .alu_op(alu_op),      // input
    .alu_in_1(rs1_dout),    // input  
    .alu_in_2(alu_in_2),    // input
    .alu_result(alu_result),  // output
    .alu_bcond(bcond)    // output
  );

  // ---------- Data Memory ----------
  data_memory dmem(
    .reset (reset),      // input
    .clk (clk),        // input
    .addr (alu_result),       // input
    .din (rs2_dout),        // input
    .mem_read (mem_read),   // input
    .mem_write (mem_write),  // input
    .dout (mem_dout)        // output
  );

  // ---------- Mux ----------
  mux alu_in_2_mux(
    .input_1(rs2_dout),
    .input_2(imm_gen_out),
    .control(alu_src),
    .mux_out(alu_in_2)
  );

  mux write_data_mux(
    .input_1(mem_dout),
    .input_2(alu_result),
    .control(mem_to_reg),
    .mux_out(rd_din) //Write data for register file
  );

  mux next_pc_mux(
    .input_1(add_next_pc),
    .input_2(branch_next_pc),
    .control(pc_src_1),
    .mux_out(next_pc)
  );

  adder pc_adder(
    .input_1(current_pc),
    .input_2(4),
    .sum(add_next_pc)
  );

  adder branch_pc_adder (
    .input_1(current_pc),
    .input_2(imm_gen_out),
    .sum(branch_next_pc)
  );

endmodule
