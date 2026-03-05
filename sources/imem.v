module imem #(
    parameter WORDS    = 256,
    parameter INIT_HEX = ""
)(
    input  wire [31:0] addr,
    output wire [31:0] instr
);
    reg [31:0] mem [0:WORDS-1];

    assign instr = mem[addr[31:2]]; // word aligned

`ifndef SYNTHESIS
    integer i;
    initial begin
        if (INIT_HEX != "") $readmemh(INIT_HEX, mem);
        else for (i=0; i<WORDS; i=i+1) mem[i] = 32'h00000013; // NOP = addi x0,x0,0
    end
`endif

endmodule