`include "CLOG2.v"
`include "cache_state.v"

module Cache #(parameter LINE_SIZE = 16, //block size
               parameter NUM_SETS = 16, //8개의 set
               parameter NUM_WAYS = 1) (
    //cache size = 16 * 16 * 1 = 256 byte cache
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

  integer i;
  integer ways = NUM_WAYS;

  // Wire declarations
  wire [3:0] idx; //16 sets (4)
  wire [1:0] block_offset; //(2)
  wire [23:0] tag; //32-(4+2+2) = 24

  wire mem_read;
  wire mem_write;

  wire block_0_valid;

  // Register declarations
  reg [LINE_SIZE*8-1:0] data_bank [NUM_SETS-1:0];
  reg valid_bank [NUM_SETS-1:0];
  reg dirty_bank [NUM_SETS-1:0];
  reg [23:0] tag_bank [NUM_SETS-1:0];

  reg [LINE_SIZE*8-1:0] read_data;
  reg [LINE_SIZE*8-1:0] write_data;

  reg [2:0] current_state;

  reg cache_hit;
  reg set_status;  

  // ****** Data Memory ******
  reg mem_input_valid;
  reg [31:0] mem_addr;
  reg _mem_read;
  reg _mem_write;
  reg [LINE_SIZE*8-1:0] mem_din;
  wire mem_output_valid;
  wire [LINE_SIZE*8-1:0] data_out;
  wire is_data_mem_ready;

  // Data Memory address shift value
  reg [3:0] clog2;
  assign clog2 = `CLOG2(LINE_SIZE);


  assign block_offset = addr[3:2];
  assign idx = addr[7:4];
  assign tag = addr[31:8];

  assign mem_read = mem_rw == 0 ? 1'b1 : 1'b0;
  assign mem_write = mem_rw == 1 ? 1'b1 : 1'b0;
  assign block_0_valid = valid_bank[idx] == 1'b1 ? 1'b1 : 1'b0;

  assign is_ready = current_state == `Idle ? 1'b1 : 1'b0;
  assign is_output_valid = ((current_state == `Compare_Tag && cache_hit == `Cache_Hit) || current_state == `Idle);
  assign is_hit = (cache_hit == `Cache_Hit) ? 1'b1 : 1'b0;


  always @(posedge clk) begin
    if (reset) begin // Initialization
      for(i = 0; i < NUM_SETS; i = i + 1) begin
        tag_bank[i] <= 0;
        data_bank[i] <= 0;
        valid_bank[i] <= 0;
        dirty_bank[i] <= 0;
      end
      current_state <= `Idle; 
    end
    else begin
      case(current_state) 
        `Idle: begin
          if (is_input_valid) begin // Load/Store 
            current_state <= `Compare_Tag;
          end
        end
        `Compare_Tag: begin 
          if (cache_hit == `Cache_Hit) begin
            if (mem_write) begin
              data_bank[idx] <= write_data;
              dirty_bank[idx] <= 1;
            end 
            current_state <= `Idle;
          end
          else begin
            if (set_status == `Empty_Block) begin // Set is not full
              current_state <= `Allocate;
            end
            else begin  // Set is full
              if (dirty_bank[idx] == 1) begin
                current_state <= `Write_Back;
              end 
              else begin
                current_state <= `Allocate;
              end
            end
          end
        end
        `Write_Back: begin
          if (is_data_mem_ready) begin
            current_state <= `Write_Back_Delay;
          end
        end
        `Write_Back_Delay: begin
          if (is_data_mem_ready) begin
            current_state <= `Allocate;
          end
        end
        `Allocate: begin
          if (is_data_mem_ready) begin
            current_state <= `Allocate_Delay;
          end
        end
        `Allocate_Delay: begin
          if (mem_output_valid) begin
            data_bank[idx] <= data_out;
            tag_bank[idx] <= tag;
            valid_bank[idx] <= 1;
            dirty_bank[idx] <= 0;
            current_state <= `Compare_Tag;
          end          
        end
        default: begin
        end
      endcase
    end
  end
  
  always @(*) begin
    mem_input_valid = 0;
    mem_din = 0;
    mem_addr = 0;
    _mem_read = 0;
    _mem_write = 0;
    case(current_state) 
      `Idle: begin
        mem_input_valid = 0;
        mem_din = 0;
        mem_addr = 0;
        _mem_read = 0;
        _mem_write = 0;
      end
      `Compare_Tag: begin
        mem_input_valid = 0;
        mem_din = 0;
        mem_addr = 0;
        _mem_read = 0;
        _mem_write = 0;
      end
      `Write_Back: begin
        mem_input_valid = 1;
        mem_din = data_bank[idx];
        mem_addr = {tag_bank[idx], idx, block_offset, 2'b00};
        _mem_read = 0;
        _mem_write = 1; 
      end
      `Write_Back_Delay: begin
        mem_input_valid = 0;
        mem_din = 0;
        mem_addr = 0;
        _mem_read = 0;
        _mem_write = 0;        
      end
      `Allocate: begin  
        mem_input_valid = 1;
        mem_din = 0;
        mem_addr = addr;
        _mem_read = 1;
        _mem_write = 0;
      end
      `Allocate_Delay: begin
        mem_input_valid = 0;
        mem_din = 0;
        mem_addr = 0;
        _mem_read = 0;
        _mem_write = 0;        
      end
      default: begin
      end
    endcase
  end

  // Cache hit check
  always @(*) begin
    if (valid_bank[idx] == 1'b1 && tag_bank[idx] == tag) begin
      cache_hit = `Cache_Hit;
    end
    else begin
      cache_hit = `Cache_Miss;
    end
  end

  // read data, write data
  always @(*) begin
    read_data = data_bank[idx];
    write_data = read_data;

    //write din assign
    case(block_offset)
      2'b00: write_data[31:0] = din;
      2'b01: write_data[63:32] = din;
      2'b10: write_data[95:64] = din;
      2'b11: write_data[127:96] = din;
    endcase

    case(block_offset)
      2'b00: dout = read_data[31:0];
      2'b01: dout = read_data[63:32];
      2'b10: dout = read_data[95:64];
      2'b11: dout = read_data[127:96];
    endcase
  end

  
  always @(*) begin
    if (block_0_valid) begin
      set_status = `No_Empty_Block;
    end
    else begin
      set_status = `Empty_Block;
    end
  end

  // Instantiate data memory
  DataMemory #(.BLOCK_SIZE(LINE_SIZE)) data_mem(
    .reset(reset),
    .clk(clk),

    .is_input_valid(mem_input_valid), 
    .addr(mem_addr >> clog2),        // NOTE: address must be shifted by CLOG2(LINE_SIZE)
    .mem_read(_mem_read),
    .mem_write(_mem_write),
    .din(mem_din),

    // is output from the data memory valid?
    .is_output_valid(mem_output_valid),
    .dout(data_out),
    // is data memory ready to accept request?
    .mem_ready(is_data_mem_ready)
  );

endmodule
