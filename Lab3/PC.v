module PC (input reset,
           input PCUpdate,
           input [31:0] next_pc,
           output reg [31:0] current_pc);

always @(*) begin
    if (reset) begin
        current_pc = 32'b0;
    end
end 

always @(PCUpdate) begin
    if (PCUpdate) begin
        current_pc = next_pc;
    end
end  
endmodule
