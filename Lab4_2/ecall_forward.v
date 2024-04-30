`include "opcodes.v"

module ecall_forward (input [6:0] opcode,
                      input [4:0] MEM_rd,
                      input [4:0] WB_rd,
                      input MEM_RegWrite,
                      input WB_RegWrite,
                      output reg [1:0] control);

always @(*) begin
    if(opcode == `ECALL) begin
        if(MEM_rd == 17 && MEM_RegWrite) begin
            control = 2'b01;
        end
        else if(WB_rd == 17 && WB_RegWrite) begin
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
