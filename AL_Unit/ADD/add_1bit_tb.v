`timescale 1ns/1ps
`include "add_1bit.v"

module add_1bit_tb;

    reg a, b, c;
    wire sum;
    wire carry;

    add_1bit f(a, b, c, sum, carry);

    initial begin
        $dumpfile("add_1bit_tb.vcd");
        $dumpvars(0, add_1bit_tb);

        a = 1'b0;
        b = 1'b0;
        c = 1'b0;

        #20
        a=1'b0;b=1'b0;c=1'b0;
        #20 
        a=1'b0;b=1'b0;c=1'b1;
        #20 
        a=1'b0;b=1'b1;c=1'b0;
        #20 
        a=1'b0;b=1'b1;c=1'b1;
        #20
        a=1'b1;b=1'b0;c=1'b0;
        #20 
        a=1'b1;b=1'b0;c=1'b1;
        #20 
        a=1'b1;b=1'b1;c=1'b0;
        #20 
        a=1'b1;b=1'b1;c=1'b1;
    end

    initial begin 
		$monitor("a = ", a, " b = ", b, " c = ", c, " sum = ", sum, " carry = ", carry, "\n");
	end

endmodule