`include "state_def.v"

module calculate_next_state (input [6:0] opcode,
                             input bcond,
                             input [2:0] current_state,
                             output reg [2:0] next_state);

always @(*) begin
    next_state = `IF;

    case (current_state) 
        `IF: begin
            if (opcode == `JAL) begin
                next_state = `EX_1;
            end
            else begin
                next_state = `ID;
            end
        end
        `ID: begin
            if(opcode == `ECALL) begin
               next_state = `IF;
            end
            next_state = `EX_1;
        end
        `EX_1: begin
            if (opcode == `ARITHMETIC || opcode == `ARITHMETIC_IMM || opcode == `JALR || opcode == `JAL) begin
                next_state = `WB;
            end
            else if (opcode == `LOAD || opcode == `STORE) begin
                next_state = `MEM;
            end
            else begin //Bxx
                if (bcond) begin
                    next_state = `EX_2;
                end
                else begin
                    next_state = `IF;
                end
            end
        end
        `EX_2: begin
            next_state = `IF;
        end
        `MEM: begin
            if (opcode == `LOAD) begin
                next_state = `WB;
            end
            else begin //STORE
                next_state = `IF;
            end
        end
        `WB: begin
            next_state = `IF;
        end
        default: begin
        end
    endcase
end 

endmodule
