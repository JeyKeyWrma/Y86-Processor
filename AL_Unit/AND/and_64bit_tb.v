`timescale 1ns/1ps

module and_64bit_tb;

    reg signed [63:0]a;
    reg signed [63:0]b;
    wire [63:0]out;

    and_64bit f(a, b, out);

    initial begin
        $dumpfile("and_64bit_tb.vcd");
        $dumpvars(0, and_64bit_tb);

        a = 64'b0;
        b = 64'b0;
    end

    initial 
		$monitor("a   = %b\nb   = %b\nout = %b\n\n",a ,b ,out);

endmodule