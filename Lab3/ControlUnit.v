`include "opcodes.v"
`include "state_def.v"

module ControlUnit (input [6:0] IR_opcode,
                    input [6:0] inst_opcode,
                    input bcond,
                    input reset,
                    input clk,
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

reg [2:0] current_state;
wire [2:0] next_state;

micro_code_controller micro_code_controller(
    .current_state(current_state),
    .opcode(IR_opcode),
    .is_ecall(is_ecall),
    .PCWriteNotCond(PCWriteNotCond),
    .PCWrite(PCWrite),
    .IorD(IorD),
    .MemRead(MemRead),
    .MemWrite(MemWrite),
    .MemtoReg(MemtoReg),
    .IRWrite(IRWrite),
    .PCSource(PCSource),
    .ALUOp(ALUOp),
    .ALUSrcB(ALUSrcB),
    .ALUSrcA(ALUSrcA),
    .RegWrite(RegWrite)
);  

calculate_next_state calculate_next_state(
    .IR_opcode(IR_opcode),
    .inst_opcode(inst_opcode),
    .bcond(bcond),
    .current_state(current_state),
    .next_state(next_state)
);

always @(posedge clk) begin
    if (reset) begin
        current_state <= `IF;
    end
    else begin
        current_state <= next_state;
    end
end

endmodule
