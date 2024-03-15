module immediate_generator (input [11:0] part_of_inst, 
                            output [31:0] imm_gen_out);

    assign imm_gen_out = {part_of_inst[11], part_of_inst[10:5], part_of_inst[4:1], 1'b0};
endmodule