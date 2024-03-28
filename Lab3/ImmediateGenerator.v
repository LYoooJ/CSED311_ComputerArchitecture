`include "opcodes.v"

module ImmediateGenerator (input [31:0] part_of_inst,
                           output reg [31:0] imm_gen_out); 
    reg [6:0] opcode;
    always @(*) begin
        imm_gen_out = 0;
        opcode = part_of_inst[6:0];
        
        case(opcode)
            `ARITHMETIC_IMM: begin
                imm_gen_out = {{21{part_of_inst[31]}}, part_of_inst[30:20]};
            end
            `LOAD: begin
                imm_gen_out = {{21{part_of_inst[31]}}, part_of_inst[30:20]};
            end
            `JALR: begin
                imm_gen_out = {{21{part_of_inst[31]}}, part_of_inst[30:21], 1'b0};
            end
            `STORE: begin
                imm_gen_out = {{21{part_of_inst[31]}}, part_of_inst[30:25], part_of_inst[11:7]};
            end
            `BRANCH: begin
                imm_gen_out = {{20{part_of_inst[31]}}, part_of_inst[7], part_of_inst[30:25], part_of_inst[11:8], 1'b0};
            end
            `JAL: begin
                imm_gen_out = {{12{part_of_inst[31]}}, part_of_inst[19:12], part_of_inst[20], part_of_inst[30:21], 1'b0};
            end
            default: begin
                imm_gen_out = 0;
            end
        endcase
    end

    endmodule
