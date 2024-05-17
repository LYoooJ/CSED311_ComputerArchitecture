`include "CLOG2.v"

module Cache #(parameter LINE_SIZE = 16, //block size
               parameter NUM_SETS = 8, //8개의 set
               parameter NUM_WAYS = 2) (
    //cache size = 16 * 8 * 2 = 256 byte cache
    input reset,
    input clk,

    input is_input_valid,
    input [31:0] addr,
    input mem_rw, // read = 0, write = 1
    input [31:0] din, //write data

    output is_ready,
    output reg is_output_valid,
    output reg [31:0] dout,
    output reg is_hit);

  // Wire declarations
  integer i;
  /////////////address wire////////////////
  wire is_data_mem_ready;
  wire [2:0] idx; //8 sets (3)
  wire [1:0] block_offset; //(2)
  //wire [1:0] word_offset; (2)
  wire [24:0] tag; //32-(3+2+2) = 25
  //wire way;
  //////////

  // Reg declarations
  /////////////bank registers////////////////
  reg [LINE_SIZE-1:0] data_bank [NUM_SETS-1:0][NUM_WAYS-1:0];
  reg valid_bank [NUM_SETS-1:0][NUM_WAYS-1:0];
  reg dirty_bank [NUM_SETS-1:0][NUM_WAYS-1:0];
  reg lru_bank [NUM_SETS-1:0][NUM_WAYS-1:0];
  reg [24:0] tag_bank [NUM_SETS-1:0][NUM_WAYS-1:0];

  /////////////data mem reg signal regs////////////////
  reg [LINE_SIZE*8-1:0] data_out; //data memory output
  reg [31:0] mem_addr; //data memory address
  reg _mem_rw; 
  reg mem_input_valid; 

  reg[LINE_SIZE*8 -1:0] read_data;
  reg[LINE_SIZE*8 -1:0] write_data;

  reg [1:0] current_state; //00(invalid), 01(tagcompare), 10(write back), 11(write allocate)
  reg [1:0] next_state;

  // You might need registers to keep the status.
  assign is_ready = is_data_mem_ready;
  //assign word_offset = addr[1:0];
  assign block_offset = addr[3:2];
  assign idx = addr[6:4];
  assign tag = addr[31:7];

  // Instantiate cache controller
  always @(posedge clk) begin
    if (reset) begin
      for(i=0; i<NUM_SETS; i=i+1) begin
        tag_bank[i][0] <= 25'h1;
        tag_bank[i][1] <= 25'h1;
        data_bank[i][0] <=  16'b1111111111111111;
        data_bank[i][1] <= 16'b1111111111111111;
        valid_bank[i][0] <= 0;
        valid_bank[i][0] <=0;
        dirty_bank[i][0] <= 0;
        dirty_bank[i][1] <= 0;
        lru_bank[i][0] <= 1'b0;
        lru_bank[i][1] <= 1'b1;
      end
    end
  end

  always @(*) begin
    read_data = {data_bank[idx][0], data_bank[idx][1]};
    write_data = read_data;

    //write din assign
    case(block_offset)
      0: write_data[31:0] = din;
      1: write_data[63:32] = din;
      2: write_data[95:64] = din;
      3: write_data[127:96] =din;
    endcase

    case(block_offset)
      0: dout = read_data[31:0];
      1: dout = read_data[63:32];
      2: dout = read_data[95:64];
      3: dout = read_data[127:96];
    endcase

    case(current_state)
      2'b00: begin //invalid
        if(is_input_valid) begin 
          next_state = 2'b01; //valid 되면 next state tag compare
        end
      end

      2'b01: begin //tag compare
          //cache hit
            if(valid_bank[idx][0] == 1'b1 && tag_bank[idx][0] == tag) begin  //read hit
              lru_bank[idx][0] = 1'b1;
              is_hit =1;
              is_output_valid =1;
              //way =0;

              if(mem_rw == 1'b1 && dirty_bank[idx][0] == 0) begin //write hit way 0
                data_bank[idx][0] = write_data;
                dirty_bank[idx][0] = 1;
                next_state = 2'b00;
              end
            if(mem_rw == 1'b1 && valid_bank[idx][0] == 1'b1) begin 
              next_state = 2'b10;
            end
          end
          else if(valid_bank[idx][1] && tag_bank[idx][1] == tag) begin
            is_hit = 1;
            is_output_valid = 1;
            lru_bank[idx][1] =1'b1;
            if(mem_rw == 1'b1 && dirty_bank[idx][1] == 0) begin //write hit way 1
              data_bank[idx][1] = write_data;
              dirty_bank[idx][1] = 1;
              next_state = 2'b00;
            end
            else if(mem_rw == 1'b1 && valid_bank[idx][1] == 1'b1) begin
              next_state = 2'b10;
            end
            else begin // cache miss
            is_hit =0;
            is_output_valid =0;

            if(valid_bank[idx][0] || dirty_bank[idx][0] || valid_bank[idx][1] || dirty_bank[idx][1])begin
              next_state = 2'b10; //write back
            end
            else begin
              next_state = 2'b11; // write allocate
            end
            end
          end
      end
          
      2'b10: begin //write back 메모리가 준비 되었을 때 쓰는 작업
        if(is_data_mem_ready) begin
          mem_addr = {tag_bank[idx], idx, block_offset, 2'b00};
          _mem_rw = 1'b1; //write
          if(is_ready) begin
            mem_input_valid =1;
            next_state = 2'b11;
          end
        end
      end
      2'b11: begin // write allocate 읽어오기
        if(is_data_mem_ready) begin
          mem_addr = {tag, idx, block_offset, 2'b00};
          if(is_ready) begin
            mem_input_valid =1;
            _mem_rw = 1'b0; //read
            if(is_output_valid) begin
              write_data = data_out;
              tag_bank[idx] = tag;
              valid_bank[idx] = 1;
              dirty_bank[idx] = 0;
              mem_input_valid = 0;
              next_state = 2'b01;
            end
          end
        end
      end
    endcase
  end

  always @(posedge clk) begin
    if(reset) current_state <= 2'b00;
    else current_state <= next_state;
  end

  // Instantiate data memory
  DataMemory #(.BLOCK_SIZE(LINE_SIZE)) data_mem(
    .reset(reset),
    .clk(clk),

    .is_input_valid(is_input_valid), //다시
    .addr(mem_addr >> 4),        // NOTE: address must be shifted by CLOG2(LINE_SIZE)
    .mem_read(mem_rw == 1'b1),
    .mem_write(mem_rw == 1'b0),
    .din(din), //써야 할 data

    // is output from the data memory valid?
    .is_output_valid(is_output_valid),
    .dout(data_out),
    // is data memory ready to accept request?
    .mem_ready(is_data_mem_ready)
  );
endmodule
