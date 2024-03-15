module mux (input_1, input_2, control, mux_out);

    input [31:0] input_1;
    input [31:0] input_2;
    input reg control;
    output reg [31:0] mux_out;

    always @(*) begin
        if (control == 1'b0) mux_out = input_1;
        else mux_out = input_2;
end
endmodule
