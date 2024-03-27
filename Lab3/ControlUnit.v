module ControlUnit (input part_of_inst,
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
  
endmodule
