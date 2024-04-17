`include "opcodes.v"

module HazardDetection (
  input [4:0] input_1, // ID_rs1
  input [4:0] input_2, // ID_rs2
  input [4:0] input_3, // EX_rd
  input input_4, // ID_EX_mem_read
  output reg output_1, //PCWrite
  output reg output_2, //IFIDWrite
  output reg output_3 //IDEXWrite
);

always @(*) begin
    output_1 = 0;
    output_2 = 0;
    output_3 = 0;

    if((((input_1 == input_3) && (input_1 != 5'b0))||((input_2 == input_3) && (input_2 != 5'b0))) && (input_4 == 1'b1)) begin
        output_1 = 1;
        output_2 = 1;
        output_3 = 1;
    end
end
endmodule
