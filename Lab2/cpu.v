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

  //instruction module
  wire[31:0] addr;
  wire[31:0] dout;

  //register file
  wire[31:0] rs1_dout;
  wire[31:0] rs2_dout;
  //reg or wire
  reg write_enable;
  wire[31:0] writeData;

  //data memory
  wire[31:0] mem_addr; //data memory module Addr
  wire[31:0] din; // Write data input
  wire mem_read;
  wire mem_write;
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
  wire[31:0] alu_in_1;
  wire[31:0] alu_in_2;
  wire[3:0] alu_op;
  wire[31:0] alu_result;
  wire bcond;
 
  /***** Register declarations *****/

  // ---------- Update program counter ----------
  // PC must be updated on the rising edge (positive edge) of the clock.
  pc pc(
    .reset(),       // input (Use reset to initialize PC. Initial value must be 0)
    .clk(),         // input
    .next_pc(),     // input
    .current_pc()   // output
  );
  
  // ---------- Instruction Memory ----------
  instruction_memory imem(
    .reset(),   // input
    .clk(),     // input
    .addr(),    // input
    .dout()     // output
  );

  // ---------- Register File ----------
  register_file reg_file (
    .reset (),        // input
    .clk (),          // input
    .rs1 (),          // input
    .rs2 (),          // input
    .rd (),           // input
    .rd_din (),       // input
    .write_enable (), // input
    .rs1_dout (),     // output
    .rs2_dout (),     // output
    .print_reg (print_reg)  //DO NOT TOUCH THIS
  );


  // ---------- Control Unit ----------
  control_unit ctrl_unit (
    .part_of_inst(),  // input
    .is_jal(),        // output
    .is_jalr(),       // output
    .branch(),        // output
    .mem_read(),      // output
    .mem_to_reg(),    // output
    .mem_write(),     // output
    .alu_src(),       // output
    .write_enable(),  // output
    .pc_to_reg(),     // output
    .is_ecall(),       // output (ecall inst)
    .pc_src_1()
  );

  // ---------- Immediate Generator ----------
  immediate_generator imm_gen(
    .part_of_inst(),  // input
    .imm_gen_out()    // output
  );

  // ---------- ALU Control Unit ----------
  alu_control_unit alu_ctrl_unit (
    .part_of_inst(),  // input
    .alu_op()         // output
  );

  // ---------- ALU ----------
  alu alu (
    .alu_op(),      // input
    .alu_in_1(),    // input  
    .alu_in_2(),    // input
    .alu_result(),  // output
    .alu_bcond()    // output
  );

  // ---------- Data Memory ----------
  data_memory dmem(
    .reset (),      // input
    .clk (),        // input
    .addr (),       // input
    .din (),        // input
    .mem_read (),   // input
    .mem_write (),  // input
    .dout ()        // output
  );
endmodule
