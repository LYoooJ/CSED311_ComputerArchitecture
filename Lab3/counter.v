module counter (input clk,
                input counter_reset,
                output [3:0] count);

always @(posedge clk) begin
    if (counter_reset) begin
        count <= 0;
    end
    else begin
        count <= count + 1;
    end
end
endmodule