module Cache #(parameter LINE_SIZE = 16,
               parameter NUM_SETS = 16/* Your choice */
               parameter NUM_WAYS = 1) (
    input reset,
    input clk,

    input is_input_valid,
    input [31:0] addr,
    input mem_read,
    input mem_write,
    input [31:0] din,

    output is_ready,
    output is_output_valid,
    output [31:0] dout,
    output is_hit);
  // Wire declarations
  wire is_data_mem_ready;
  wire[3:0] idx;
  wire[23:0] tag;
  wire [1:0] block_offset;

  // Reg declarations
  // You might need registers to keep the status.

  assign is_ready = is_data_mem_ready;
  assign tag = addr[31:8];
  assign idx = addr[7:4];
  assign block_offset = addr[3:2];

  // Instantiate data memory
  DataMemory #(.BLOCK_SIZE(LINE_SIZE)) data_mem(
    .reset(reset),
    .clk(clk),

    .is_input_valid(is_input_valid),
    .addr(addr),        // NOTE: address must be shifted by CLOG2(LINE_SIZE)
    .mem_read(mem_read),
    .mem_write(mem_write),
    .din(/**/),

    // is output from the data memory valid?
    .is_output_valid(),
    .dout(),
    // is data memory ready to accept request?
    .mem_ready(is_data_mem_ready)
  );


endmodule
