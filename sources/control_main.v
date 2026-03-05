module control_main(
    input  wire [6:0] opcode,
    output reg        RegWrite,
    output reg        MemWrite,
    output reg        ALUSrc,
    output reg        Branch,
    output reg        Jump,
    output reg        Jalr,
    output reg        ASrc,          // 0: rs1, 1: PC (for AUIPC/branches/jumps)
    output reg [1:0]  ResultSrc,     // 00 ALU, 01 MEM, 10 PC+4, 11 IMM (LUI)
    output reg [2:0]  ImmSrc,        // 000 I, 001 S, 010 B, 011 U, 100 J
    output reg [1:0]  ALUOp          // to alu_control
);
    always @(*) begin
        // defaults (avoid latches)
        RegWrite  = 1'b0;
        MemWrite  = 1'b0;
        ALUSrc    = 1'b0;
        Branch    = 1'b0;
        Jump      = 1'b0;
        Jalr      = 1'b0;
        ASrc      = 1'b0;
        ResultSrc = 2'b00;
        ImmSrc    = 3'b000;
        ALUOp     = 2'b00;

        case (opcode)
            7'b0110011: begin // R-type
                RegWrite  = 1'b1;
                ALUSrc    = 1'b0;
                ResultSrc = 2'b00;
                ALUOp     = 2'b10;
            end

            7'b0010011: begin // I-type ALU (ADDI, ANDI, ORI, XORI, SLTI, shifts)
                RegWrite  = 1'b1;
                ALUSrc    = 1'b1;
                ImmSrc    = 3'b000; // I
                ResultSrc = 2'b00;
                ALUOp     = 2'b10;
            end

            7'b0000011: begin // LOAD (LW)
                RegWrite  = 1'b1;
                ALUSrc    = 1'b1;
                ImmSrc    = 3'b000; // I
                ResultSrc = 2'b01;  // MEM
                ALUOp     = 2'b00;  // ADD for address
            end

            7'b0100011: begin // STORE (SW)
                MemWrite  = 1'b1;
                ALUSrc    = 1'b1;
                ImmSrc    = 3'b001; // S
                ALUOp     = 2'b00;  // ADD for address
            end

            7'b1100011: begin // BRANCH (BEQ/BNE/BLT/BGE)
                Branch    = 1'b1;
                ALUSrc    = 1'b0;
                ImmSrc    = 3'b010; // B
                ALUOp     = 2'b01;  // (optional) compare via SUB if you want
            end

            7'b1101111: begin // JAL
                Jump      = 1'b1;
                RegWrite  = 1'b1;
                ImmSrc    = 3'b100; // J
                ResultSrc = 2'b10;  // PC+4
            end

            7'b1100111: begin // JALR
                Jalr      = 1'b1;
                RegWrite  = 1'b1;
                ALUSrc    = 1'b1;
                ImmSrc    = 3'b000; // I
                ResultSrc = 2'b10;  // PC+4
                ALUOp     = 2'b00;  // address calc (rs1 + imm)
            end

            7'b0110111: begin // LUI
                RegWrite  = 1'b1;
                ImmSrc    = 3'b011; // U
                ResultSrc = 2'b11;  // imm
            end

            7'b0010111: begin // AUIPC
                RegWrite  = 1'b1;
                ASrc      = 1'b1;   // A = PC
                ALUSrc    = 1'b1;   // B = imm
                ImmSrc    = 3'b011; // U
                ResultSrc = 2'b00;  // ALU result = PC + imm
                ALUOp     = 2'b00;  // ADD
            end

            default: begin
                // keep defaults
            end
        endcase
    end
endmodule