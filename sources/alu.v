module alu(
    input  wire [31:0] a,
    input  wire [31:0] b,
    input  wire [3:0]  alu_ctrl,
    output reg  [31:0] result,
    output wire        zero
);
    always @(*) begin
        case (alu_ctrl)
            4'h0: result = a + b;                         // ADD
            4'h1: result = a - b;                         // SUB
            4'h2: result = a & b;                         // AND
            4'h3: result = a | b;                         // OR
            4'h4: result = a ^ b;                         // XOR
            4'h5: result = a << b[4:0];                   // SLL
            4'h6: result = a >> b[4:0];                   // SRL
            4'h7: result = $signed(a) >>> b[4:0];         // SRA
            4'h8: result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0; // SLT
            4'h9: result = (a < b) ? 32'd1 : 32'd0;       // SLTU (optional)
            default: result = 32'h0;
        endcase
    end

    assign zero = (result == 32'h0);
endmodule