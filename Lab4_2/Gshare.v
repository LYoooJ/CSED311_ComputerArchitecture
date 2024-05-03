module Gshare(input reset,
              input clk,
              input is_branch,
              input is_jal,
              input is_jalr,
              input [31:0] actual_branch_target,
              input actual_taken,
              input prediction_correct,
              input [4:0] pht_update_index,
              input [31:0] current_pc,
              input [31:0] ID_EX_pc,
              output reg [4:0] accessed_pht_index,
              output reg [31:0] next_pc);

reg [31:0] taken;                   // 실제로 taken 되었는지
reg [31:0] counter_update;          // counter update 신호
reg [31:0] prediction;              // 각 counter의 prediction
reg [4:0] bhsr;                     // branch history shift register
reg [31:0] tag_table [31:0];        // tag table
reg [31:0] btb [31:0];              // branch target buffer

wire [4:0] btb_index;               // btb에서 접근할 index
wire [4:0] pht_index;               // pht에서 접근할 counter의 index
wire [31:0] branch_target;          // btb에서 읽은 branch target
wire [31:0] tag;                    // 현재 pc의 tag 값
wire pht_prediction;                // pht에서 가져온 예측 값
wire gshare_taken;                  // 예측한 taken 여부

integer k;

assign tag = current_pc[31:0];
assign btb_index = current_pc[6:2];
assign pht_index = bhsr ^ btb_index;
assign branch_target = btb[btb_index];
assign pht_prediction = prediction[pht_index];
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
            tag_table[k] <= 32'b0;
            btb[k] <= 32'b0;
            taken[k] <= 1'b0;
            counter_update[k] <= 1'b0;
        end
    end
    else begin
        if (is_branch) begin // branch
            if (!prediction_correct) begin
                btb[ID_EX_pc[6:2]] <= actual_branch_target;
                $display("[0x%x] btb[%d]: 0x%x", ID_EX_pc, ID_EX_pc[6:2], actual_branch_target);
                tag_table[ID_EX_pc[6:2]] <= tag;
            end
            for (k = 0; k < 32; k = k + 1) begin
                if (k == {27'b0, pht_update_index}) begin
                    taken[k] <= actual_taken;
                    counter_update[k] <= 1'b1;
                end 
                else begin
                    taken[k] <= 1'b0;
                    counter_update[k] <= 1'b0;
                end
            end
            bhsr <= {actual_taken, bhsr[4:1]};
            // bhsr <= {bhsr[3:0], actual_taken};
        end
        else begin
            if (is_jal || is_jalr) begin // JAL or JALR ???
                btb[ID_EX_pc[6:2]] <= actual_branch_target;
                tag_table[ID_EX_pc[6:2]] <= tag;        
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

always @(*) begin
    //(tag == tag_table[btb_index]);
    if (gshare_taken) begin
        $display("current_pc: 0x%x", current_pc);
        $display("branch_target: 0x%x", branch_target);
        $display("pht prediction: %d", pht_prediction);
        $display("tag: 0x%x", tag);
        $display("tag table[%d]: 0x%x", btb_index, tag_table[btb_index]);
    end
end

endmodule
