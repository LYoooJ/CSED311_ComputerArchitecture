`include "state_def.v"

module calculate_next_state (input [6:0] opcode,
                             input clk,
                             input [3:0] current_state,
                             output reg [3:0] next_state);

always @(posedge clk) begin
    case (current_state) 
    `IF_1: begin
        next_state <= `IF_2;
    end
    `IF_2: begin
        next_state <= `IF_3;
    end
    `IF_3: begin
        next_state <= `IF_4;
    end
    `IF_4: begin
        if (opcode == `JAL) begin
            next_state <= `EX_1;
        end
        else begin
            next_state <= `ID;
        end
    end
    `ID: begin
        next_state <= `EX_1;
    end
    `EX_1: begin
        next_state <= `EX_2;
    end
    `EX_2: begin
        if (opcode == `ARITHMETIC || opcode == `ARITHMETIC_IMM || opcode == `JALR || opcode == `JAL) begin
            next_state <= `WB;
        end
        else if (opcode == `LOAD || opcode == `STORE) begin
            next_state <= `MEM_1;
        end
        else begin //Bxx
            next_state <= `IF_1;
        end
    end
    `MEM_1: begin
        next_state <= `MEM_2;
    end
    `MEM_2: begin
        next_state <= `MEM_3;
    end
    `MEM_3: begin
        next_state <= `MEM_4;
    end
    `MEM_4: begin
        if (opcode == `LOAD) begin
            next_state <= `WB;
        end
        else begin //STORE
            next_state <= `IF_1;
        end
    end
    `WB: begin
        next_state <= `IF_1;
    end
    default: begin
    end
    endcase
end    

endmodule
