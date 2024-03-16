`include "opcodes.v"

module control_unit(
    input [6:0] part_of_inst,  // input
    output reg is_jal,        // output
    output reg is_jalr,       // output
    output reg branch,        // output
    output reg mem_read,      // output
    output reg mem_to_reg,    // output
    output reg mem_write,     // output
    output reg alu_src,       // output
    output reg write_enable,  // output // regWrite
    output reg pc_to_reg,     // output
    output reg is_ecall, // output (ecall inst));
    output reg pc_src_1
    );     

    always@(*) begin
      //initialize
      is_jal = 0; 
      is_jalr = 0; 
      branch = 0;
      mem_read = 0; 
      mem_to_reg = 0;
      mem_write = 0; 
      alu_src = 0; 
      write_enable = 0; 
      pc_to_reg = 0; 
      is_ecall = 0;
      pc_src_1 = 0;
      //opcode[6:0]에 따라서 control signal 부여
      case(part_of_inst)
      `ARITHMETIC: begin 
        write_enable = 1;
      end  
      `ARITHMETIC_IMM: begin
        write_enable = 1;
        alu_src = 1;
      end
      `LOAD: begin
        write_enable = 1;
        alu_src = 1;
        mem_to_reg = 1;
        mem_read = 1;
      end
      `JALR: begin
        is_jalr = 1;
        write_enable = 1;
        pc_to_reg = 1;
        alu_src = 1;
      end
      `STORE: begin
        mem_write = 1;
        alu_src = 1;
      end
      `BRANCH: begin
        //
        branch = 1;
      end
      `ECALL: begin
        is_ecall = 1;
      end
      
      default: begin end
      endcase

    end


endmodule
