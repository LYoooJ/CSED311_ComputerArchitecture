module and_gate(input input_1,
               input input_2,
               output reg out);
always @(*) begin
    out = input_1 & input_2;
end

endmodule
