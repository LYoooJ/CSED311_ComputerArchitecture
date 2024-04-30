module saturation_counter (input reset,
                           input clk,
                           input is_control_inst,
                           input actual_taken,
                           output reg prediction);

reg [2:0] state;

always @(posedge clk) begin
    if (reset) begin
        stated = 2'b00;
    end else begin
        if (is_control_inst) begin
            if (actual_taken) begin
                if (state != 2'b11) begin
                    state -= 1;
                end 
            end else begin
                    if (state != 2'b00) begin
                        state += 1;
                    end
            end
        end
    end
end

endmodule
