module Adder (input [31:0] input_1, 
              input [31:0] input_2, 
              output reg [31:0] sum);

always @(*) begin
    sum = input_1 + input_2;
end

endmodule
