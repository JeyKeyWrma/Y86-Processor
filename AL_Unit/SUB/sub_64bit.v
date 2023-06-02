module sub_64bit(a, b, out, overflow);

    input signed [63:0] a;
    input signed [63:0] b;
    output signed [63:0] out;
    output overflow;

    wire g1, g2;
    wire [63:0] buffer1;
    wire [63:0] buffer2;

    genvar i;
    generate
        for(i = 0; i < 64; i = i+1)
            begin
              not(buffer1[i], b[i]);
            end
    endgenerate

    add_64bit f1(buffer1, 64'b1, buffer2, g1);
    add_64bit f2(a, buffer2, out, g2);

    wire overflow1, overflow2, a_bar, b_bar, out_bar;
    not(out_bar, out[63]);
    not(b_bar, b[63]);
    not(a_bar, a[63]);
    and(overflow1, a[63], b_bar, out_bar);
    and(overflow2, a_bar, b[63], out[63]);
    or(overflow, overflow1, overflow2);

endmodule