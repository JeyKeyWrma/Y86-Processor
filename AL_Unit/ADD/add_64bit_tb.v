`timescale 1ns/1ps
`include "../ADD/add_64bit.v"

module add_64bit_tb;

    reg signed [63:0] a;
    reg signed [63:0] b;
    wire signed [63:0] sum;
    wire overflow;

    add_64bit f1(a, b, sum, overflow);

    initial begin
        $dumpfile("add_64bit_tb.vcd");
        $dumpvars(0, add_64bit_tb);

        $monitor("a\t= %b\t%d\nb\t= %b\t%d\nsum\t= %b\t%d\noverflow= %d\n", a, a, b, b, sum, sum, overflow);

        a = 64'd39;
        b = 64'd9033830;

    end

endmodule