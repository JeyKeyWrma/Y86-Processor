module alu(control, a, b, out, overflow);

    input [1:0] control;
    input signed [63:0] a;
    input signed [63:0] b;
    output signed [63:0] out;
    output overflow;
    
    reg overflow;
    reg signed [63:0] out;
  
    wire signed [63:0] out0;
    wire signed [63:0] out1;
    wire signed [63:0] out2;
    wire signed [63:0] out3;
    wire overflow0, overflow1;

    add_64bit f0(a, b, out0, overflow0);
    sub_64bit f1(a, b, out1, overflow1);
    and_64bit f2(a, b, out2);
    xor_64bit f3(a, b, out3);

    always @(*) begin
        case (control)
            2'b00: begin
              out = out0;
              overflow = overflow0;
            end 

            2'b01: begin
              out = out1;
              overflow = overflow1;
            end

            2'b10: begin
              out = out2;
              overflow = 1'b0;
            end

            2'b11: begin
              out = out3;
              overflow = 1'b0;
            end
        endcase
    end

endmodule