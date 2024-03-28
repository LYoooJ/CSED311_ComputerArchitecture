`include "state_def.v"

`define pc 1'b0
`define A 1'b1
`define B 2'b00
`define four 2'b01
`define imm 2'b10

module micro_controller (input [3:0] current_state,
                         input [6:0] opcode,
                         input clk,
                         input reset,
                         input branch_taken,
                         output reg is_ecall,
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

always @(posedge clk) begin
    if (reset) begin
    PCWriteNotCond <= 0;
    PCWrite <= 0;
    IorD <= 0;
    MemRead <= 0;
    MemWrite <= 0;
    MemtoReg <= 0;
    IRWrite <= 0;
    PCSource <= 0;
    ALUOp <= 2'b00;
    ALUSrcB <= `B;
    ALUSrcA <= `pc;
    RegWrite <= 0;
    is_ecall <= 0;
    end else begin
    case(current_state)
        //IF: Memory로부터 instruction을 읽고, IR register에 저장
        `IF_1: begin
            //$display("===== IF start=====");
            MemRead = 1;
            IRWrite = 1;
            IorD = 0;
        end
        `IF_2: begin
            MemRead <= 1;
            IRWrite <= 1;
            IorD <= 0;   
        end
        `IF_3: begin
            MemRead <= 1;
            IRWrite <= 1;
            IorD <= 0;
        end
        `IF_4: begin
            MemRead <= 1;
            IRWrite <= 1;
            IorD <= 0;
            //$display("IF done");
        end
        // instruction decode, read register values
        `ID: begin
            
            if (opcode == `ECALL) begin
                is_ecall <= 1;
            end
            ALUSrcA <= `pc;
            ALUSrcB <= `four;
            ALUOp <= 2'b00; //ADD
            
        end
        `EX_1: begin
            if (opcode == `ARITHMETIC) begin
                ALUSrcA <= `A;
                ALUSrcB <= `B;
                ALUOp <= 2'b10;
            end
            else if (opcode == `ARITHMETIC_IMM) begin
                ALUSrcA <= `A;
                ALUSrcB <= `imm;
                ALUOp <= 2'b10;
            end
            else if (opcode == `LOAD || opcode == `STORE) begin
                ALUSrcA <= `A;
                ALUSrcB <= `imm;
                ALUOp <= 2'b00;
            end
            else if (opcode == `BRANCH) begin
                //branch 
                ALUSrcA <= `A;
                ALUSrcB <=`B;
                ALUOp <= 2'b10;
                PCWriteNotCond <= 1;
                PCSource <= 1;
            end
            else if (opcode == `JALR) begin
                ALUSrcA <= `pc;
                ALUSrcB <= `four;
                ALUOp <= 2'b00;    
            end
            else begin //JAL
                ALUSrcA <= `pc;
                ALUSrcB <= `four;
                ALUOp <= 2'b00;                
            end
        end
        `EX_2: begin
            if (opcode == `ARITHMETIC) begin
                ALUSrcA <= `A;
                ALUSrcB <= `B;
                ALUOp <= 2'b10;
            end
            else if (opcode == `ARITHMETIC_IMM) begin
                ALUSrcA <= `A;
                ALUSrcB <= `imm;
                ALUOp <= 2'b10;
            end
            else if (opcode == `LOAD || opcode == `STORE) begin
                ALUSrcA <= `A;
                ALUSrcB <= `imm;
                ALUOp <= 2'b00;
            end
            else if (opcode == `BRANCH) begin
                if (branch_taken) begin
                    ALUSrcA <= `pc;
                    ALUSrcB <= `imm;
                    ALUOp <= 2'b00;
                    PCSource <= 0;
                    PCWrite <= 1;
                end
            end
            else if (opcode == `JALR) begin
                ALUSrcA <= `pc;
                ALUSrcB <= `four;
                ALUOp <= 2'b00;    
            end
            else begin //JAL
                ALUSrcA <= `pc;
                ALUSrcB <= `four;
                ALUOp <= 2'b00;                
            end
        end
        `MEM_1: begin
            if (opcode == `LOAD) begin
                MemRead <= 1;
                IorD <= 1;
            end
            else begin //STORE
                MemWrite <= 1;
                IorD <= 1;
            end
        end
        `MEM_2: begin
            if (opcode == `LOAD) begin
                MemRead <= 1;
                IorD <= 1;
            end
            else begin //STORE
                MemWrite <= 1;
                IorD <= 1;
            end
        end
        `MEM_3: begin
            if (opcode == `LOAD) begin
                MemRead <= 1;
                IorD <= 1;
            end
            else begin //STORE
                MemWrite <= 1;
                IorD <= 1;
            end
        end
        `MEM_4: begin
            if (opcode == `LOAD) begin
                MemRead <= 1;
                IorD <= 1;
            end
            else begin //STORE
                MemWrite <= 1;
                IorD <= 1;
                ALUSrcA <= `pc;
                ALUSrcB <= `four;
                ALUOp <= 2'b00; //
                PCSource <= 0;
                PCWrite <= 1;
            end
        end
        `WB: begin
            if (opcode == `ARITHMETIC || opcode == `ARITHMETIC_IMM) begin
                PCWrite <= 1;
                MemtoReg <= 0; //ALUOut
                RegWrite <= 1;
                ALUSrcA <= `pc;
                ALUSrcB <= `four;
                ALUOp <= 2'b00; //
                PCSource <= 0;

            end
            else if (opcode == `LOAD) begin
                PCWrite <= 1;
                MemtoReg <= 1; 
                RegWrite <= 1;
                ALUSrcA <= `pc;
                ALUSrcB <= `four;
                ALUOp <= 2'b00;
                PCSource <= 0;
            end
            else if (opcode == `JAL) begin
                PCWrite <= 1;
                MemtoReg <= 0; //ALUOut
                RegWrite <= 1;
                ALUSrcA <= `pc;
                ALUSrcB <= `imm;
                ALUOp <= 2'b00;
                PCSource <= 0;
            end
            else if (opcode == `JALR) begin
                PCWrite <= 1;
                MemtoReg <= 0; //ALUOut
                RegWrite <= 1;
                ALUSrcA <= `A;
                ALUSrcB <= `imm;
                ALUOp <= 2'b00;
                PCSource <= 0;
            end
        end
        default: begin
        end
    endcase
    end
end

/***
 always @(opcode) begin
     case (opcode)
     `ARITHMETIC: begin
         $display("ARITHMETIC");
     end
     `ARITHMETIC_IMM: begin
         $display("ARITHMETIC_IMM");
     end
     `LOAD: begin
         $display("LOAD");
     end
     `JALR: begin
         $display("JALR");
     end
     `STORE: begin
         $display("STORE");
     end 
     `BRANCH: begin
         $display("BRANCH");
     end
     `JAL: begin
         $display("JAL");
     end
     `ECALL: begin
         $display("ECALL");
     end
     default: begin
     end
     endcase
 end
***/
endmodule
