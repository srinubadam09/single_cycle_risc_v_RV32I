module branch_unit(
    input  wire [31:0] rs1,
    input  wire [31:0] rs2,
    input  wire [2:0]  funct3,
    output reg         take_branch
);
    always @(*) begin
        case (funct3)
            3'b000: take_branch = (rs1 == rs2);                    // BEQ
            3'b001: take_branch = (rs1 != rs2);                    // BNE
            3'b100: take_branch = ($signed(rs1) <  $signed(rs2));  // BLT
            3'b101: take_branch = ($signed(rs1) >= $signed(rs2));  // BGE
            default: take_branch = 1'b0;
        endcase
    end
endmodule