module saturation_counter (input reset,
                           input clk,
                           input counter_update,
                           input actual_taken,
                           output reg prediction);

reg [1:0] state;

always @(posedge clk) begin
    if (reset) begin
        state <= 2'b00;
    end else begin
        if (counter_update) begin
            if (actual_taken) begin
                if (state != 2'b11) begin
                    state <= state - 1;
                end 
            end 
            else begin
                if (state != 2'b00) begin
                    state <= state + 1;
                end
            end
        end
    end
end

always @(*) begin
    if (state == 2'b00 || state == 2'b01) begin
        prediction = 1'b0;
    end 
    else begin
        prediction = 1'b1;
    end
end
endmodule
