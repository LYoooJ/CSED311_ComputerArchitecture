`include "alu_func.v"

module alu #(parameter data_width = 16) (
	input [data_width - 1 : 0] A, 
	input [data_width - 1 : 0] B, 
	input [3 : 0] FuncCode,
       	output reg [data_width - 1: 0] C,
       	output reg OverflowFlag);
// Do not use delay in your implementation.

// You can declare any variables as needed.

initial begin
	C = 0;
	OverflowFlag = 0;
end   	

// TODO: You should implement the functionality of ALU!
// (HINT: Use 'always @(...) begin ... end')

always@(*) begin
		case(FuncCode)
			`FUNC_ADD:
				begin 
					C = A + B;
					if((~(A[data_width-1] ^ B[data_width-1]) & ((C[data_width-1]) ^ A[data_width-1])) == 0) begin
						//if overflow doesn't occur
						OverflowFlag = 0;
					end
					else begin
						//if overflow occurs
						OverflowFlag =1;
					end
				end
			`FUNC_SUB:
				begin
					C = A - B;
					if(((A[data_width-1] ^ B[data_width-1]) & ((C[data_width-1]) ^ A[data_width-1])) == 0) begin
						//if overflow doesn't occur
						OverflowFlag = 0;
					end
					else begin
						//if overflow occurs
						OverflowFlag =1;
					end
				end
			`FUNC_ID:
				begin
					C = A;
					OverflowFlag = 0;
				end
			`FUNC_NOT:
				begin
					C = ~A;
					OverflowFlag = 0;
				end
			`FUNC_AND:
				begin
					C = A & B;
					OverflowFlag = 0;
				end
			`FUNC_OR:
				begin
					C = A | B;
					OverflowFlag = 0;
				end
			`FUNC_NAND:
				begin
					C = ~(A & B);
					OverflowFlag = 0;
				end
			`FUNC_NOR:
				begin
					C = ~(A | B);
					OverflowFlag = 0;
				end
			`FUNC_XOR:
				begin
					C = A ^ B;
					OverflowFlag = 0;
				end
			`FUNC_XNOR:
				begin
					C = ~(A ^ B);
					OverflowFlag = 0;
				end
			`FUNC_LLS:
				begin
					C = A << 1;
					OverflowFlag = 0;
				end
			`FUNC_LRS:
				begin
					C = A >> 1;
					OverflowFlag = 0;
				end
			`FUNC_ALS:
				begin
					C = A <<< 1;
					OverflowFlag = 0;
				end
			`FUNC_ARS:
				begin
					C= $signed(A) >>> 1;
					OverflowFlag = 0;
				end
			`FUNC_TCP:
				begin
					C = ~A + 1;
					OverflowFlag = 0;
				end
			`FUNC_ZERO:
				begin
					C = 0;
					OverflowFlag = 0;
				end
		endcase
	end
endmodule
