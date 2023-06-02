module pc_update(PC, clk, icode, cnd, valC, valM, valP);

    input [3:0] icode;
    input cnd, clk;
    input signed [63:0] valC, valM;
    input [63:0] valP;

    output reg [63:0] PC;

    always@(posedge clk)begin
        case(icode)
            4'h0: PC <= 0;
            4'h1: PC <= valP;
            4'h2: PC <= valP;
            4'h3: PC <= valP;
            4'h4: PC <= valP;
            4'h5: PC <= valP;
            4'h6: PC <= valP;
            4'h7: PC <= cnd ? valC:valP;
            4'h8: PC <= valC;
            4'h9: PC <= valM;
            4'hA: PC <= valP;
            4'hB: PC <= valP;
        endcase
    end

endmodule