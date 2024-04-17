`include opcodes.v

module ForwardingUnit (input [4:0] EX_rs1,
                       input [4:0] EX_rs2,
                       input [4:0] MEM_rd,
                       input [4:0] WB_rd,
                       input MEM_RegWrite,
                       input WB_RegWrite,
                       output reg [1:0] ForwardA,
                       output reg [1:0] ForwardB);

always @(*) begin
    if (EX_rs1 != 5'b0 && EX_rs1 == MEM_rd && MEM_RegWrite) begin
        ForwardA = 2'b01;
    end
    else if (EX_rs1 != 5'b0 && EX_rs1 == WB_rd && WB_RegWrite) begin
        ForwardA = 2'b10;
    end
    else begin
        ForwardA = 2'b00;
    end
end

always @(*) begin
    if (EX_rs2 != 5'b0 && EX_rs2 == MEM_rd && MEM_RegWrite) begin
        ForwardB = 2'b01;
    end
    else if (EX_rs2 != 5'b0 && EX_rs2 == WB_rd && WB_RegWrite) begin
        ForwardB = 2'b10;
    end
    else begin
        ForwardB = 2'b00;
    end
end

endmodule