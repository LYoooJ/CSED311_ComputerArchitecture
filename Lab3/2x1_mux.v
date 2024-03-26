module 2x1_mux (input [31:0] input_1, 
            input [31:0] input_2, 
            input control, 
            output reg [31:0] mux_out);

always @(*) begin
    if (control == 1'b0) begin 
        mux_out = input_1;
    end
    else begin 
        mux_out = input_2;
    end
end
endmodule
