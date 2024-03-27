`include "state_def.v"

module micro_controller (input [3:0] current_state,
                         input [6:0] opcode,
                         output reg PCWriteNotCond,
                         output reg PCWrite,
                         output reg IorD,
                         output reg MemRead,
                         output reg MemWrite,
                         output reg MemtoReg,
                         output reg IRWrite,
                         output reg PCSource,
                         output reg [1:0] ALUOp,
                         output reg [1:0] ALUSrcB,
                         output reg ALUSrcA,
                         output reg RegWrite);


always @(*) begin
    PCWriteNotCond = 0;
    PCWrite = 0;
    IorD = 0;
    MemRead = 0;
    MemWrite = 0;
    MemtoReg = 0;
    IRWrite = 0;
    PCSource = 0;
    ALUOp = 2'b00;
    ALUSrcB = 2'b00;
    ALUSrcA = 0;
    RegWrite = 0;
    case(current_state)
        `IF_1: begin
            ALUSrcA = 1;
            MemRead = 1;
            IRWrite = 1;
            ALUSrcB = 2'b01;
            PCWrite = 1;
        end
        `IF_2: begin
            ALUSrcA = 1;
            MemRead = 1;
            IRWrite = 1;
            ALUSrcB = 2'b01;
            PCWrite = 1;            
        end
        `IF_3: begin
            ALUSrcA = 1;
            MemRead = 1;
            IRWrite = 1;
            ALUSrcB = 2'b01;
            PCWrite = 1;  
        end
        `IF_4: begin
            ALUSrcA = 1;
            MemRead = 1;
            IRWrite = 1;
            ALUSrcB = 2'b01;
            PCWrite = 1;  
        end
        `ID: begin
            ALUSrcB = 2'b10;
        end
        `EX_1: begin
            if (opcode == `ARITHMETIC) begin
                ALUSrcA = 1;
                ALUOp = 2'b10;
                ALUSrcB = 2'b00;
            end
            else if (opcode == `ARITHMETIC_IMM) begin
                ALUSrcA = 1;
                ALUOp = 2'b10;
                ALUSrcB = 2'b10;
            end
            else if (opcode == `LOAD || opcode == `STORE) begin
                ALUSrcA = 1;
                ALUOp = 2'b00;
                ALUSrcB = 2'b10;
            end
            else if (opcode == `BRANCH) begin
                ALUSrcA = 1;
                ALUSrcB = 2'b00;
                ALUOp = 2'b01;
                PCWriteNotCond = 1;
                PCSource = 1;
            end
        end
        `EX_2: begin
        end
        `MEM_1: begin
        end
        `MEM_2: begin
        end
        `MEM_3: begin
        end
        `MEM_4: begin
        end
        `WB: begin
        end
    endcase
end

endmodule
