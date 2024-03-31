`include "state_def.v"

module calculate_next_state (input [6:0] IR_opcode,
                             input [6:0] inst_opcode,
                             input bcond,
                             input [2:0] current_state,
                             output reg [2:0] next_state);

always @(*) begin
    next_state = `IF;

    case (current_state) 
        `IF: begin
            if (inst_opcode == `JAL || inst_opcode == `JALR) begin
                next_state = `EX_1;
            end
            else begin
                next_state = `ID;
            end
        end
        `ID: begin
            if(IR_opcode == `ECALL) begin
               next_state = `IF;
            end
            next_state = `EX_1;
        end
        `EX_1: begin
            if (IR_opcode == `ARITHMETIC || IR_opcode == `ARITHMETIC_IMM || IR_opcode == `JALR || IR_opcode == `JAL) begin
                next_state = `WB;
            end
            else if (IR_opcode == `LOAD || IR_opcode == `STORE) begin
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
            if (IR_opcode == `LOAD) begin
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
