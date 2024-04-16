module halt_unit (input [31:0] rf_17,
                  input is_ecall,
                  output is_halted);

assign is_halted = (is_ecall && rf_17 == 10) ? 1 : 0;

endmodule
