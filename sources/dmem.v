module dmem #(
    parameter WORDS    = 256,
    parameter INIT_HEX = ""
)(
    input  wire        clk,
    input  wire        we,
    input  wire [31:0] addr,
    input  wire [31:0] wd,
    output wire [31:0] rd
);
    reg [31:0] mem [0:WORDS-1];

    wire [31:0] waddr = addr[31:2]; // word aligned
    assign rd = mem[waddr];

    always @(posedge clk) begin
        if (we) mem[waddr] <= wd;
    end

`ifndef SYNTHESIS
    integer i;
    initial begin
        if (INIT_HEX != "") $readmemh(INIT_HEX, mem);
        else for (i=0; i<WORDS; i=i+1) mem[i] = 32'h0;
    end
`endif

endmodule