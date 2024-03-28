module PC (input clk,
           input reset,
           input PCUpdate,
           input [31:0] next_pc,
           output reg [31:0] current_pc); 

always @(posedge clk) begin
    //$display("current_pc: ", current_pc);
    if (reset) begin
        current_pc <= 32'b0;
    end
    else begin
        if (PCUpdate) begin
            current_pc <= next_pc;
        end;
    end
end

endmodule
