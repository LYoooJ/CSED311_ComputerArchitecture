`include "opcodes.v"
`include "alu_opcodes.v"

//check the type of inst (4types): R, I, S ,SB 
module alu_control_unit(opcode, funct3, sign, alu_op);

    //input [31:0] part_of_inst; 
    output reg [3:0] alu_op; //4 bit alu control signal

    input [6:0] opcode;
    input [2:0] funct3;
    input sign;
    //reg [6:0] opcode;
    //reg [2:0] funct3;
    //reg sign; // 부호 [30] 덧셈에서 sign이 없어야
    //R-Type에서 ADD와 SUB이 Funct3이 같음, ADD Funct7 = 0000000, SUB Funct7 = 0100000

    always@(*) begin
        // opcode = part_of_inst[6:0];
        // funct3 = part_of_inst[14:12];
        // sign = part_of_inst[30];
        alu_op = 4'b1111; //Latch warning 때문에 임시로 추가
        case(opcode)
        `ARITHMETIC: begin
            if(funct3 == `FUNCT3_ADD && sign == 0) alu_op = `ADD;
            else if(funct3 == `FUNCT3_SUB && sign == 1) alu_op = `SUB;
            else if(funct3 == `FUNCT3_SLL) alu_op = `SLL;
            else if(funct3 == `FUNCT3_XOR) alu_op = `XOR;
            else if(funct3 == `FUNCT3_OR) alu_op = `OR;
            else if(funct3 == `FUNCT3_AND) alu_op = `AND;
            else if(funct3 == `FUNCT3_SRL) alu_op = `SRL;
            else begin end
        end
        `ARITHMETIC_IMM: begin
            if(funct3 == `FUNCT3_ADD) alu_op = `ADD;
            else if(funct3 == `FUNCT3_SUB) alu_op = `SUB;
            else if(funct3 == `FUNCT3_SLL) alu_op = `SLL;
            else if(funct3 == `FUNCT3_XOR) alu_op = `XOR;
            else if(funct3 == `FUNCT3_OR) alu_op = `OR;
            else if(funct3 == `FUNCT3_AND) alu_op = `AND;
            else if(funct3 == `FUNCT3_SRL) alu_op = `SRL;
            else begin end
        end
        `LOAD: begin
            alu_op = `ADD;
        end
        `JALR: begin
            alu_op = `ADD;
        end
        `STORE: begin
            alu_op = `ADD;
        end
        `BRANCH: begin
            if(funct3 == `FUNCT3_BEQ) alu_op = `BEQ; //SUB
            else if(funct3 == `FUNCT3_BNE) alu_op = `BNE;
            else if(funct3 == `FUNCT3_BLT) alu_op = `BLT;
            else if(funct3 == `FUNCT3_BGE) alu_op = `BGE;
            else begin end
        end
        default: begin 
            //alu_op = 4'b1111;
        end
        endcase
    end
endmodule
