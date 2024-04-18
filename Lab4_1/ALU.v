`include "alu_opcode.v"

module ALU (input [3:0] alu_op,
            input [31:0] alu_in_1,
            input [31:0] alu_in_2,
            output reg [31:0] alu_result,
            output reg alu_bcond);   // 여기 고치기

always @(*) begin
    alu_bcond = 0;
    alu_result = 0;

    case(alu_op)
        //branch condition
        `BEQ: begin
            if((alu_in_1 - alu_in_2) == 0) begin
                alu_bcond = 1; // 같으면 jump
            end
        end
        `BNE: begin
            if((alu_in_1 - alu_in_2) != 0) begin
                alu_bcond =1; // 다르면 jump
            end
        end
        `BLT: begin
            if(alu_in_1 < alu_in_2) begin 
                alu_bcond = 1; // rs1_dout < rs2_dout 이면 jump
            end
        end
        `BGE: begin
            if(alu_in_1 >= alu_in_2) begin
                alu_bcond = 1; 
            end
        end
        `ADD: begin
            alu_result = alu_in_1 + alu_in_2;
            //$display("ADD");
        end
        `SUB: begin
            alu_result = alu_in_1 - alu_in_2;
        end
        `SLL: begin
            alu_result = alu_in_1 << alu_in_2;
        end
        `XOR: begin
            alu_result = alu_in_1 ^ alu_in_2;
        end
        `OR: begin
            alu_result = alu_in_1 | alu_in_2;
        end
        `AND: begin
            alu_result = alu_in_1 & alu_in_2;
        end
        `SRL: begin
            alu_result = alu_in_1 >> alu_in_2;
        end
        default: begin
            alu_result = 0;
        end
    endcase
    $display("alu_in1: 0x%x, alu_in2: 0x%x, alu_result: 0x%x\n", alu_in_1, alu_in_2, alu_result);
end
endmodule
