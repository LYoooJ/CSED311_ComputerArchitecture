module immediate_generator (input [31:0] part_of_inst, 
                            output reg [31:0] imm_gen_out);

    assign imm_gen_out = {{21{part_of_inst[11]}}, part_of_inst[10:5], part_of_inst[4:1], 1'b0};

endmodule
