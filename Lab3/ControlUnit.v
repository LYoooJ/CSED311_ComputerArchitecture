module ControlUnit (input [6:0] part_of_inst,
                    input bcond,
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

reg [3:0] current_state;
wire [3:0] next_state;

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
    .RegWrite(RegWrite)
);  

calculate_next_state calculate_next_state(
    .opcode(part_of_inst),
    .clk(clk),
    .current_state(current_state),
    .next_state(next_state)
);

always @(next_state) begin
    current_state <= next_state;
end

endmodule
