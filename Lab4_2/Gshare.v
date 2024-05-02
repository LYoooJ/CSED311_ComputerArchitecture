module Gshare(input reset,
              input clk,
              input is_branch,
              input is_jal,
              input is_jalr,
              input [31:0] actual_branch_target,
              input actual_taken,
              input prediction_correct,
              input [31:0] current_pc,
              output reg [31:0] next_pc);

// JAL, JALR 처리??
reg [31:0] taken;
reg [31:0] counter_update;
reg [31:0] prediction;
reg [4:0] bhsr;
reg [24:0] tag_table [31:0];
reg [31:0] btb [31:0]; 

wire [4:0] btb_index;
wire [4:0] pht_index;
wire [31:0] branch_target;
wire [24:0] tag;
wire pht_prediction;
wire gshare_taken;

integer k;

assign tag = current_pc[31:7];
assign btb_index = current_pc[6:2];
assign pht_index = bhsr ^ btb_index;
assign branch_target = btb[btb_index];
assign pht_prediction = prediction[pht_index]; // ??
assign gshare_taken = pht_prediction && (tag == tag_table[btb_index]);

// ***** generate pattern history table *****
genvar i;

generate
    for (i = 0; i < 32; i = i + 1) begin
        saturation_counter predictor(
            .reset(reset),
            .clk(clk),
            .counter_update(counter_update[i]),
            .actual_taken(taken[i]),
            .prediction(prediction[i])
        );
    end
endgenerate

// ***** Branch Prediction ***** 
always @(posedge clk) begin
    if (reset) begin // initialization
        bhsr <= 5'b0;
        for (k = 0; k < 32; k = k + 1) begin
            tag_table[k] <= 25'b0;
            btb[k] <= 32'b0;
            taken[k] <= 1'b0;
            //prediction[k] <= 1'b0;
            counter_update[k] <= 1'b0;
        end
    end
    else begin
        if (is_branch) begin // branch
            if (!prediction_correct) begin
                btb[btb_index] <= actual_branch_target;
                tag_table[btb_index] <= tag;
            end
            for (k = 0; k < 32; k = k + 1) begin
                if (k == {27'b0, pht_index}) begin
                    taken[k] <= actual_taken;
                    counter_update[k] <= 1'b1;
                end 
                else begin
                    taken[k] <= 1'b0;
                    counter_update[k] <= 1'b0;
                end
            end
            bhsr <= {bhsr[3:0], actual_taken};
        end
        else begin
            if (is_jal || is_jalr) begin // JAL or JALR ???
                btb[btb_index] <= actual_branch_target;
                tag_table[btb_index] <= tag;        
            end
        end
    end
end

// ***** next pc Mux *****
mux_2x1 next_pc_mux(
    .input_1(current_pc + 4),
    .input_2(branch_target),
    .control(gshare_taken),
    .mux_out(next_pc)
);

// always @(posedge clk) begin
//     $display("branch_target: 0x%x", branch_target);
//     $display("current_tc: 0x%x", current_pc + 4);
//     $display("gshare taken: %d", gshare_taken);
//     $display("next_pc: 0x%x", next_pc);
// end

endmodule
