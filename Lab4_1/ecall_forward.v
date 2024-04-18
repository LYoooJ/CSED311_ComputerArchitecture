`include "opcodes.v"

module ecall_forward (input [6:0] opcode,
                      input [4:0] EX_rd,
                      input [4:0] MEM_rd,
                      input EX_RegWrite,
                      input MEM_RegWrite,
                      output reg [1:0] control);

always @(*) begin
    if(opcode == `ECALL) begin
        if(EX_rd == 17 && EX_RegWrite) begin
            control = 2'b01;
        end
        else if(MEM_rd == 17 && MEM_RegWrite) begin
            control = 2'b10;
        end
        else begin
            control = 2'b00;
        end
    end
    else begin
        control = 2'b00;
    end
end
endmodule
