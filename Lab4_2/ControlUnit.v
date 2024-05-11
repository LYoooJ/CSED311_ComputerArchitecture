`include "opcodes.v"

module ControlUnit(input [6:0] part_of_inst,
                   output reg mem_read,       
                   output reg mem_to_reg,      
                   output reg mem_write,       
                   output reg alu_src,         
                   output reg write_enable,
                   output reg [1:0] alu_op,
                   output reg is_ecall,
                   output reg is_jal,
                   output reg is_jalr,
                   output reg branch,
                   output reg pc_to_reg);     

    always@(*) begin
      mem_read = 0; 
      mem_to_reg = 0;
      mem_write = 0; 
      alu_src = 0; 
      write_enable = 0; 
      alu_op = 2'b00;
      is_ecall = 0;
      is_jal = 0;
      is_jalr = 0;
      branch = 0;
      pc_to_reg = 0;

      case(part_of_inst)
        `ARITHMETIC: begin 
            write_enable = 1;
            alu_op = 2'b10;
        end  
        `ARITHMETIC_IMM: begin
            write_enable = 1;
            alu_src = 1;
            alu_op = 2'b10;
        end
        `LOAD: begin
            write_enable = 1;
            alu_src = 1;
            mem_to_reg = 1;
            mem_read = 1;
            alu_op = 2'b00;
        end
        `STORE: begin
            mem_write = 1;
            alu_src = 1;
            alu_op = 2'b00;
        end
        `JALR: begin
            is_jalr = 1;
            write_enable = 1;
            pc_to_reg = 1;
            alu_src = 1;
            alu_op = 2'b00; 
        end
        `JAL: begin
            is_jal = 1;
            pc_to_reg = 1;
            write_enable = 1;
            alu_op = 2'b00; 
        end
        `BRANCH: begin
            branch = 1;
            alu_op = 2'b10;
        end
        `ECALL: begin
            is_ecall = 1;
        end
        default: begin
        end
      endcase
    end
endmodule
