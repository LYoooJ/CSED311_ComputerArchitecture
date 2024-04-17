`include "opcodes.v"

module ControlUnit(
    input [6:0] part_of_inst,   // input
    output reg mem_read,        // output
    output reg mem_to_reg,      // output
    output reg mem_write,       // output
    output reg alu_src,         // output
    output reg write_enable,    // output
    output reg [1:0] alu_op,    // output
    output reg is_ecall         // output
    );     

    always@(*) begin
      mem_read = 0; 
      mem_to_reg = 0;
      mem_write = 0; 
      alu_src = 0; 
      write_enable = 0; 
      alu_op = 2'b00;
      is_ecall = 0;

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
        `ECALL: begin
            is_ecall = 1;
        end
        default: begin
        end
      endcase
    end
endmodule
