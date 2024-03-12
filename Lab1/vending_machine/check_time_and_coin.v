`include "vending_machine_def.v"

	

module check_time_and_coin(i_input_coin,o_output_item,i_trigger_return,clk,reset_n, wait_time,current_total,coin_value,o_return_coin);
	input clk;
	input reset_n;
	input i_trigger_return;
	input [`kNumCoins-1:0] i_input_coin;
	input [`kNumItems-1:0] o_output_item;
	input [`kTotalBits-1:0] current_total; // o_return coin에서 반환해야할 때 자판기에 남은 돈을 전부 리턴해야하므로 current total input에 추가
	input [31:0] coin_value[`kNumCoins-1:0];
	output reg [`kNumCoins-1:0] o_return_coin;
	output reg [31:0] wait_time;

	reg [31:0] wait_cycle;
	reg return_finished;

	// initiate values
	initial begin
		// TODO: initiate values
		o_return_coin = 3'b000;
		wait_time = `kWaitTime; // 시작을 10초로 시작
		wait_cycle = 0;
		return_finished = 0;
	end

	always @(*) begin
		// TODO: o_return_coin
		o_return_coin = 3'b000;
		return_finished = 0;

		if(wait_time == 0 || i_trigger_return) begin //o_return_coin을 업데이트 해주어야 하는 조건
			if (current_total > 0 && wait_cycle >= 3) begin // wait_cycle >= 3이어야 코인 반환 시작
				if(current_total >= coin_value[2]) begin
					o_return_coin[2] = 1'b1;
				end
				else begin o_return_coin[2] = 1'b0; end

				if(current_total - coin_value[2] * o_return_coin[2] >= coin_value[1]) begin
					o_return_coin[1] = 1'b1;
				end
				else begin o_return_coin[1] = 1'b0; end

				if(current_total - coin_value[2] * o_return_coin[2] - coin_value[1] * o_return_coin[1] >= coin_value[0]) begin
					o_return_coin[0] = 1'b1;
				end
				else begin o_return_coin[0] = 1'b0; end

				if(current_total - coin_value[2] * o_return_coin[2] - coin_value[1] * o_return_coin[1] - coin_value[0] * o_return_coin[0] == 0) begin
					return_finished = 1;
				end
			end 
			else begin
				o_return_coin = 0;
			end
		end
	end

	always @(posedge clk ) begin
		if (!reset_n) begin
		// TODO: reset all states.
			wait_time <= `kWaitTime; //처음 initial이랑 똑같이 초기화 시켜줌 post edge에 맞춰서
		end
		if((i_input_coin != 0) || (o_output_item != 0))begin //output item이 있거나, input coin이 들어갔을 때 10초로 다시 갱신
			wait_time <= `kWaitTime;
		end
		else if(i_trigger_return) begin //triger return 된다면 wait time =0 으로 초기화
			wait_cycle <= wait_cycle + 1; // wait cycle 증가 시작
		end
		else begin
			if (wait_time > 0) begin // wait time 0이면 0
				wait_time <= wait_time - 1;
			end
			else begin // wait time이 0이면 wait cycle 증가 시작
				wait_cycle <= wait_cycle + 1;
			end
		end

		if (return_finished) begin // coin 반환이 종료되었을 때
			wait_cycle <= 0; // wait cycle 초기화
			wait_time <= `kWaitTime; //wait time 초기화
		end
	end
endmodule 
