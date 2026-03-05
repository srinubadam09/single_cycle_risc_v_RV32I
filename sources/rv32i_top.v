module rv32i_top #(
    parameter IMEM_WORDS = 256,
    parameter DMEM_WORDS = 256,
    parameter IMEM_HEX   = "program.hex",
    parameter DMEM_HEX   = ""
)(
    input  wire clk,
    input  wire reset
);

    // -------------------------
    // Fetch
    // -------------------------
    wire [31:0] pc, pc_next, instr;
    wire [31:0] pc_plus4 = pc + 32'd4;

    pc u_pc (
        .clk(clk),
        .reset(reset),
        .pc_next(pc_next),
        .pc(pc)
    );

    imem #(.WORDS(IMEM_WORDS), .INIT_HEX(IMEM_HEX)) u_imem (
        .addr(pc),
        .instr(instr)
    );

    // -------------------------
    // Decode fields
    // -------------------------
    wire [6:0] opcode = instr[6:0];
    wire [2:0] funct3 = instr[14:12];
    wire [6:0] funct7 = instr[31:25];
    wire [4:0] rs1    = instr[19:15];
    wire [4:0] rs2    = instr[24:20];
    wire [4:0] rd     = instr[11:7];

    // -------------------------
    // Control signals
    // -------------------------
    wire        RegWrite, MemWrite, ALUSrc, Branch, Jump, Jalr, ASrc;
    wire [1:0]  ResultSrc;
    wire [2:0]  ImmSrc;
    wire [1:0]  ALUOp;

    control_main u_ctrl (
        .opcode(opcode),
        .RegWrite(RegWrite),
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
        .Branch(Branch),
        .Jump(Jump),
        .Jalr(Jalr),
        .ASrc(ASrc),
        .ResultSrc(ResultSrc),
        .ImmSrc(ImmSrc),
        .ALUOp(ALUOp)
    );

    // -------------------------
    // Register file
    // -------------------------
    wire [31:0] rs1_data, rs2_data, wb_data;

    regfile u_rf (
        .clk(clk),
        .we(RegWrite),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .wd(wb_data),
        .rd1(rs1_data),
        .rd2(rs2_data)
    );

    // -------------------------
    // Immediate generator
    // -------------------------
    wire [31:0] imm;

    immgen u_imm (
        .instr(instr),
        .ImmSrc(ImmSrc),
        .imm(imm)
    );

    // -------------------------
    // Execute (ALU)
    // -------------------------
    wire [3:0]  alu_ctrl;
    wire [31:0] alu_a = (ASrc) ? pc : rs1_data;
    wire [31:0] alu_b;

    mux2 u_mux_b (
        .a(rs2_data),
        .b(imm),
        .sel(ALUSrc),
        .y(alu_b)
    );

    alu_control u_aluctrl (
        .ALUOp(ALUOp),
        .funct3(funct3),
        .funct7(funct7),
        .alu_ctrl(alu_ctrl)
    );

    wire [31:0] alu_result;
    wire        zero;

    alu u_alu (
        .a(alu_a),
        .b(alu_b),
        .alu_ctrl(alu_ctrl),
        .result(alu_result),
        .zero(zero)
    );

    // -------------------------
    // Branch decision
    // -------------------------
    wire take_branch;

    branch_unit u_branch (
        .rs1(rs1_data),
        .rs2(rs2_data),
        .funct3(funct3),
        .take_branch(take_branch)
    );

    wire do_branch = Branch & take_branch;

    // Branch target and jump targets
    wire [31:0] pc_branch = pc + imm; // imm is B-type when Branch=1
    wire [31:0] pc_jal    = pc + imm; // imm is J-type when Jump=1
    wire [31:0] pc_jalr   = (rs1_data + imm) & 32'hFFFF_FFFE; // I-type imm when Jalr=1

    // PC select priority: JALR > JAL > BRANCH > PC+4
    assign pc_next = (Jalr)      ? pc_jalr  :
                     (Jump)      ? pc_jal   :
                     (do_branch) ? pc_branch:
                                   pc_plus4;

    // -------------------------
    // Memory
    // -------------------------
    wire [31:0] mem_rdata;

    dmem #(.WORDS(DMEM_WORDS), .INIT_HEX(DMEM_HEX)) u_dmem (
        .clk(clk),
        .we(MemWrite),
        .addr(alu_result),
        .wd(rs2_data),
        .rd(mem_rdata)
    );

    // -------------------------
    // Writeback
    // ResultSrc:
    // 00 = ALU result
    // 01 = memory read data (LW)
    // 10 = PC+4 (JAL/JALR link)
    // 11 = imm (LUI)
    // -------------------------
    mux4 u_wb (
        .a(alu_result),
        .b(mem_rdata),
        .c(pc_plus4),
        .d(imm),
        .sel(ResultSrc),
        .y(wb_data)
    );

endmodule