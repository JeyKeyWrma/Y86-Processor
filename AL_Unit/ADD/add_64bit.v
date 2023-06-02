module add_64bit(a, b, sum, overflow);

    input signed [63:0] a;
    input signed [63:0] b;
    output signed [63:0] sum;
    output overflow;

    wire [64:0] carry;

    assign carry[0] = 1'b0;

    genvar i;

    generate
        for(i = 0; i < 64; i = i+1)
            begin
              add_1bit f1(a[i], b[i], carry[i], sum[i], carry[i+1]);
            end
    endgenerate

    wire overflow1, overflow2, a_bar, b_bar, sum_bar;
    not(sum_bar, sum[63]);
    not(b_bar, b[63]);
    not(a_bar, a[63]);
    and(overflow1, a[63], b[63], sum_bar);
    and(overflow2, a_bar, b_bar, sum[63]);
    or(overflow, overflow1, overflow2);

endmodule