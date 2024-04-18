`include "opcodes.v"

module HazardDetection (
  input [4:0] input_1, // ID_rs1
  input [4:0] input_2, // ID_rs2
  input [4:0] input_3, // EX_rd
  input input_4, // ID_EX_mem_read
  input [6:0] opcode, 
  output reg output_1, //PCWrite
  output reg output_2, //IFIDWrite
  output reg output_3 //IDEXWrite
);

reg use_rs1;
reg use_rs2;

always @(*) begin
    use_rs1 = 0;
    use_rs2 = 0;
    
    if (input_1 != 5'b0) begin
        use_rs1 = 1;
    end
    if ((opcode == `ARITHMETIC || opcode == `STORE) && input_2 != 5'b0) begin
        use_rs2 = 1;
    end
end

always @(*) begin
    output_1 = 1;
    output_2 = 1;
    output_3 = 0;

    if((((input_1 == input_3) && use_rs1 == 1)||((input_2 == input_3) && use_rs2 == 1)) && (input_4 == 1'b1)) begin
        output_1 = 0;
        output_2 = 0;
        output_3 = 1;
    end
end
endmodule
