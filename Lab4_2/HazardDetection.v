`include "opcodes.v"

module HazardDetection (input [4:0] ID_rs1, 
                        input [4:0] ID_rs2,
                        input [4:0] EX_rd, 
                        input [4:0] MEM_rd,
                        input EX_mem_read, 
                        input EX_reg_write,
                        input MEM_mem_read,
                        input [6:0] ID_opcode, 
                        output reg PCWrite, 
                        output reg IF_ID_write, 
                        output reg is_hazard);

reg use_rs1;
reg use_rs2;

always @(*) begin
    use_rs1 = 0;
    use_rs2 = 0;
    
    if (ID_rs1 != 5'b0) begin
        use_rs1 = 1;
    end
    if ((ID_opcode == `ARITHMETIC || ID_opcode == `STORE) && ID_rs2 != 5'b0) begin
        use_rs2 = 1;
    end
end

always @(*) begin
    PCWrite = 1;
    IF_ID_write = 1;
    is_hazard = 0;

    if (ID_opcode == `ECALL) begin
        if (EX_rd == 17 && EX_reg_write == 1) begin
            PCWrite = 0;
            IF_ID_write = 0;
            is_hazard = 1;
        end
        else if (MEM_rd == 17 && MEM_mem_read == 1) begin
            PCWrite = 0;
            IF_ID_write = 0;
            is_hazard = 1;        
        end
    end
    else begin
        if((((ID_rs1 == EX_rd) && use_rs1 == 1)||((ID_rs2 == EX_rd) && use_rs2 == 1)) && (EX_mem_read == 1'b1)) begin
            PCWrite = 0;
            IF_ID_write = 0;
            is_hazard = 1;
        end
    end
end
endmodule
