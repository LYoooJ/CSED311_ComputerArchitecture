`include "opcodes.v"
`include "state_def.v"

module ControlUnit (input [6:0] part_of_inst,
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
                    output reg RegWrite,
                    output reg ALUOutUpdate);

reg [2:0] current_state;
wire [2:0] next_state;

micro_controller micro_controller(
    .current_state(current_state),
    .opcode(part_of_inst),
    .branch_taken(bcond),
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
    .RegWrite(RegWrite),
    .ALUOutUpdate(ALUOutUpdate)
);  

calculate_next_state calculate_next_state(
    .opcode(part_of_inst),
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
