module PC (input reset,
           input clk,
           input PCwrite,
           input [31:0] next_pc,
           input stall,
           output reg [31:0] current_pc);

always @(posedge clk) begin
    if (reset) begin
        current_pc <= 32'b0;
    end
    else if (stall) begin
        //do nothing
    end
    else begin
        if (PCwrite) begin
            current_pc <= next_pc;
        end
    end
end
endmodule
