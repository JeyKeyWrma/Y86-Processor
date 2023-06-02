module and_64bit(a, b, out);

    input signed [63:0] a;
    input signed [63:0] b;
    output signed [63:0] out;

    genvar i;

    generate
        for(i = 0; i < 64; i = i+1)
            begin
              and(out[i], a[i], b[i]);
            end
    endgenerate

endmodule