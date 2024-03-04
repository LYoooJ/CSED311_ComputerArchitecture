`include "vending_machine_def.v"

	

module check_time_and_coin(i_input_coin,o_output_item,i_select_item,i_trigger_return,clk,reset_n, wait_time,current_total,coin_value,o_return_coin);
	input clk;
	input reset_n;
	input i_trigger_return; //input 추가
	input [`kNumCoins-1:0] i_input_coin;
	input [`kNumItems-1:0] i_select_item;
	input [`kNumItems-1:0] o_output_item;
	input [`kTotalBits-1:0] current_total; // o_return coin에서 반환해야할 때 자판기에 남은 돈을 전부 리턴해야하므로 current total input에 추가
	input [31:0] coin_value[`kNumCoins-1:0];
	output reg  [`kNumCoins-1:0] o_return_coin;
	output reg [31:0] wait_time;

	// initiate values
	initial begin
		// TODO: initiate values
		o_return_coin = 0;
		wait_time = `kWaitTime; // 시작을 10초로 시작
	end


	// update coin return time
	always @(i_input_coin, o_output_item, i_trigger_return) begin
		// TODO: update coin return time // 여기 다시 생각해야함
		// if i_input coin exist or i_select_item is 1, update the return time
		if((i_input_coin != 0) || (o_output_item != 0))begin //output item이 있거나, input coin이 들어갔을 때 10초로 다시 갱신
			wait_time <= `kWaitTime;
		end
		if(i_trigger_return) begin //triger return 된다면 wait time =0 으로 초기화
			wait_time <=0;
		end

	end

	always @(*) begin
		// TODO: o_return_coin

		if((wait_time == 0 || i_trigger_return) && current_total >0) begin //o_return_coin을 업데이트 해주어야 하는 조건... 수정해야할지도

			if(current_total >= coin_value[2]) begin
				o_return_coin = 3'b100;
			end
			if(current_total - coin_value[2] >= coin_value[1]) begin
				o_return_coin = o_return_coin + 3'b010;
			end
			if(current_total - coin_value[2]- coin_value[1] >= coin_value[0]) begin
				o_return_coin = o_return_coin+ 3'b001;
			end

		end
	end

	always @(posedge clk ) begin
		if (!reset_n) begin
		// TODO: reset all states.
		//처음 initial이랑 똑같이 초기화 시켜줌 post edge에 맞춰서
		wait_time <=`kWaitTime;
		o_return_coin <= 0;
		end

		if(wait_time > 0) begin // wait time 0이면 0
			wait_time <= wait_time -1;
		end

	end
endmodule 
