module add_1bit(input a, input b, input c, output sum, output carry);

    wire w1, w2, w3;

    xor(w1, a, b);
    and(w2, a, b);
    xor(sum, w1, c);
    and(w3, w1, c);
    or(carry, w2, w3);

endmodule