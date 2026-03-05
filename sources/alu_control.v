module alu_control(
    input  wire [1:0] ALUOp,
    input  wire [2:0] funct3,
    input  wire [6:0] funct7,
    output reg  [3:0] alu_ctrl
);
    always @(*) begin
        case (ALUOp)
            2'b00: alu_ctrl = 4'h0; // ADD (address/addi default)
            2'b01: alu_ctrl = 4'h1; // SUB (optional for branch compare)
            2'b10: begin
                // R-type / I-type ALU
                case (funct3)
                    3'b000: begin
                        // ADD/SUB for R-type, ADDI for I-type
                        if (funct7[5] && (funct7 == 7'b0100000))
                            alu_ctrl = 4'h1; // SUB
                        else
                            alu_ctrl = 4'h0; // ADD
                    end
                    3'b111: alu_ctrl = 4'h2; // AND/ANDI
                    3'b110: alu_ctrl = 4'h3; // OR/ORI
                    3'b100: alu_ctrl = 4'h4; // XOR/XORI
                    3'b010: alu_ctrl = 4'h8; // SLT/SLTI
                    3'b001: alu_ctrl = 4'h5; // SLL/SLLI
                    3'b101: begin
                        // SRL/SRA (check funct7[5])
                        if (funct7 == 7'b0100000)
                            alu_ctrl = 4'h7; // SRA
                        else
                            alu_ctrl = 4'h6; // SRL
                    end
                    default: alu_ctrl = 4'h0;
                endcase
            end
            default: alu_ctrl = 4'h0;
        endcase
    end
endmodule