`include "opcodes.v"

module immediate_generator (input [31:0] inst, 
                            output reg [31:0] imm_gen_out);

reg [6:0] opcode;
always @(*) begin
    imm_gen_out = 0;
    opcode = inst[6:0];
    case(opcode)
        `ARITHMETIC_IMM: begin
            imm_gen_out = {{21{inst[31]}}, inst[30:20]};
        end
        `LOAD: begin
            imm_gen_out = {{21{inst[31]}}, inst[30:20]};
        end
        `STORE: begin
            imm_gen_out = {{21{inst[31]}}, inst[30:25], inst[11:7]};
        end
        `JAL: begin
            imm_gen_out = {{12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0};
        end
        `JALR: begin
            imm_gen_out = {{21{inst[31]}}, inst[30:21], 1'b0};
        end
        `BRANCH: begin
            imm_gen_out = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
        end
        default: begin
            imm_gen_out = 0;
        end
    endcase
end

endmodule
