`include "state_def.v"

module calculate_next_state (input [6:0] opcode,
                             input [2:0] current_state,
                             output reg [2:0] next_state);

always @(*) begin
    next_state = `IF;

    case (current_state) 
        `IF: begin
            if (opcode == `JAL) begin
                next_state = `EX;
            end
            else if(opcode == `ECALL) begin
                $display("ECALL");
                next_state = `IF;
            end
            else begin
                next_state = `ID;
            end
        end
        `ID: begin
            next_state = `EX;
        end
        `EX: begin
            if (opcode == `ARITHMETIC || opcode == `ARITHMETIC_IMM || opcode == `JALR || opcode == `JAL) begin
                next_state = `WB;
            end
            else if (opcode == `LOAD || opcode == `STORE) begin
                next_state = `MEM;
            end
            else begin //Bxx
                next_state = `IF;
            end
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
