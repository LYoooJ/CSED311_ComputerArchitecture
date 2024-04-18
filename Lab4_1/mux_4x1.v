module mux_4x1 (input [31:0] input_1, 
                input [31:0] input_2,
                input [31:0] input_3,
                input [31:0] input_4,
                input [1:0] control, 
                output reg [31:0] mux_out);

always @(*) begin
    if (control == 2'b00) begin 
        mux_out = input_1;
        //$display("mux out: %d", mux_out);
    end
    else if(control == 2'b01) begin
        mux_out = input_2;
    end
    else if(control == 2'b10) begin
        mux_out = input_3;
    end
    else begin 
        mux_out = input_4;
    end
end
endmodule
