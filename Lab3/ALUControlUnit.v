`include "opcodes.v"
`include "alu_opcode.v"

module ALUControlUnit (input [31:0] part_of_inst,
                       input [1:0] alu_op,
                       output reg[3:0] alu_control_lines); 

    reg sign = part_of_inst[30];
    reg [2:0] funct3 = part_of_inst[14:12]; 
    reg [6:0] opcode = part_of_inst[6:0];

    always@(*) begin
        alu_control_lines = 4'b1111;

        if(alu_op == 2'b00) begin
            alu_control_lines = `ADD;
        end
        else if(alu_op == 2'b01) begin
            alu_control_lines = `SUB;
        end
        else begin 
            case(opcode)
                    `ARITHMETIC: begin
                        $display("ARITHMETIC");
                        if(funct3 == `FUNCT3_ADD && sign == 0) alu_control_lines = `ADD;
                        else if(funct3 == `FUNCT3_SUB && sign == 1) alu_control_lines = `SUB;
                        else if(funct3 == `FUNCT3_SLL) alu_control_lines = `SLL;
                        else if(funct3 == `FUNCT3_XOR) alu_control_lines = `XOR;
                        else if(funct3 == `FUNCT3_OR) alu_control_lines = `OR;
                        else if(funct3 == `FUNCT3_AND) alu_control_lines = `AND;
                        else if(funct3 == `FUNCT3_SRL) alu_control_lines = `SRL;
                        else begin end
                    end
                    `ARITHMETIC_IMM: begin
                        $display("ARITHMETIC_IMM");
                        if(funct3 == `FUNCT3_ADD) alu_control_lines = `ADD;
                        else if(funct3 == `FUNCT3_SLL) alu_control_lines = `SLL;
                        else if(funct3 == `FUNCT3_XOR) alu_control_lines = `XOR;
                        else if(funct3 == `FUNCT3_OR) alu_control_lines = `OR;
                        else if(funct3 == `FUNCT3_AND) alu_control_lines = `AND;
                        else if(funct3 == `FUNCT3_SRL) alu_control_lines = `SRL;
                        else begin end
                    end
                    // `LOAD: begin
                    //     alu_control_lines = `ADD;
                    // end
                    // `JALR: begin
                    //     alu_control_lines = `ADD;
                    // end
                    // `JAL: begin
                    //     alu_control_lines = `ADD;
                    // end
                    // `STORE: begin
                    //     alu_control_lines = `ADD;
                    // end
                    `BRANCH: begin
                        $display("BRANCH");
                        if(funct3 == `FUNCT3_BEQ) alu_control_lines = `BEQ; //SUB
                        else if(funct3 == `FUNCT3_BNE) alu_control_lines = `BNE;
                        else if(funct3 == `FUNCT3_BLT) alu_control_lines = `BLT;
                        else if(funct3 == `FUNCT3_BGE) alu_control_lines = `BGE;
                        else begin end
                    end
                    default: begin end
            endcase
        end
    end
endmodule

