`timescale 1ns/1ps
module tb_32;

    reg clk, reset;

    rv32i_top #(
        .IMEM_WORDS(256),
        .DMEM_WORDS(256),
        .IMEM_HEX("program.hex")
    ) dut (
        .clk(clk),
        .reset(reset)
    );

    // 100MHz clock
    always #5 clk = ~clk;

    // helper: read regfile (simulation only)
    function [31:0] get_reg;
        input integer idx;
        begin
            get_reg = dut.u_rf.rf[idx];
        end
    endfunction

    integer i;
    initial begin
        // dump waves
        $dumpfile("tb_32.vcd");
        $dumpvars(0, tb_32);
    end
    initial begin
        clk = 0;
        reset = 1;

        repeat(5) @(posedge clk);
        reset = 0;

        // run some cycles
        for (i=0; i<50; i=i+1) begin
            @(posedge clk);
        end

        $display("x1=%0d x2=%0d x3=%0d x4=%0d x5=%0d",
            get_reg(1), get_reg(2), get_reg(3), get_reg(4), get_reg(5)
        );

        // expected from sample program:
        // x1=10, x2=20, x3=30, x4=30, x5=2
        $finish;
    end
endmodule