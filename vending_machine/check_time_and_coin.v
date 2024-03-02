`include "vending_machine_def.v"

	

module check_time_and_coin(i_input_coin,i_select_item,clk,reset_n,i_trigger_return,wait_time,current_total,o_return_coin);
	input clk;
	input reset_n;
	input i_trigger_return; //input 추가
	input [`kNumCoins-1:0] i_input_coin;
	input [`kNumItems-1:0]	i_select_item;
	input [`kNumCoins-1:0] current_total; // o_return coin에서 반환해야할 때 자판기에 남은 돈을 전부 리턴해야하므로 current total input에 추가
	output reg  [`kNumCoins-1:0] o_return_coin;
	output reg [31:0] wait_time;

	integer x, y, z;
	integer temp;

	// initiate values
	initial begin
		// TODO: initiate values
		//wait_time =0;
		o_return_coin <=0;
		temp <=0;
		x <=0;
		y <=0;
		z <=0;
	end


	// update coin return time
	always @(i_input_coin, i_select_item) begin
		// TODO: update coin return time
		// if i_input coin exist or i_select_item is 1, update the return time
		if( i_input_coin || (i_select_item ==1)) wait_time <= 10;
	end

	always @(*) begin
		// TODO: o_return_coin
		//각각 필요한 동전의 개수
		x <= current_total/1000;
		y <= (current_total%1000)/500;
		z <= ((current_total%1000)%500)/100;

		if(wait_time == 0 || i_trigger_return) begin //o_return_coin을 업데이트 해준다.

			if(x > 0) begin
				temp <= 3'b100;
				//x --;
			end
			else if(y>0) begin
				temp <= 3'b010;
				//y--;
			end
			else if(z>0) begin
				temp <= 3'b001;
				//z--;
			end

			for(integer i =0; i<3; i++) begin
				o_return_coin <= o_return_coin + temp;
			end
		end
	end

	always @(posedge clk ) begin
		if (!reset_n) begin
		// TODO: reset all states.
		wait_time <=0;
		o_return_coin <=0;
		end
		else begin
		// TODO: update all states.
		if(wait_time > 0) wait_time <= wait_time-1; // decrease waiting time (10,9,8, 로 내려감)
		end
	end
endmodule 
