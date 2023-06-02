module execute(clk, valE, cnd, CC_out, icode, ifun, valC, valA, valB, CC_in);

    output reg [63:0] valE;
    output reg cnd;
    output reg [2:0] CC_out;

    input [3:0] icode, ifun;
    input clk;
    input signed [63:0] valC, valA, valB;
    input [2:0] CC_in;              // ZF, SF, OF 

    wire opq_of;
    reg prev_PC;           

    wire zeroflag, signflag, overflow;
    assign zeroflag = CC_in[0];
    assign signflag = CC_in[1];
    assign overflow = CC_in[2];

    wire [63:0] valE_AB, valE_CB, valE_OP, valE_INC, valE_DEC;
    wire dummmy;

    always @(posedge clk) begin
        if(icode==2 | icode==7)begin
            case (ifun)
                4'h0: cnd = 1;                              // unconditional
                4'h1: cnd = (overflow^signflag)|zeroflag;   // le
                4'h2: cnd = overflow^signflag;              // l
                4'h3: cnd = zeroflag;                       // e
                4'h4: cnd = ~zeroflag;                      // ne
                4'h5: cnd = ~(signflag^overflow);           // ge
                4'h6: cnd = ~(signflag^overflow)&~zeroflag; // g
            endcase
        end
    end

    alu aluAB(.out(valE_AB), .overflow(dummy), .control(2'b0), .a(valA), .b(valB));
    alu aluOP(.out(valE_OP), .overflow(opq_of), .control(ifun[1:0]), .a(valA), .b(valB));
    alu aluCB(.out(valE_CB), .overflow(dummy), .control(2'b0), .a(valC), .b(valB));
    alu aluIN(.out(valE_INC), .overflow(dummy), .control(2'b0), .b(64'd1), .a(valB));
    alu aluDE(.out(valE_DEC), .overflow(dummy), .control(2'b1), .b(64'd1), .a(valB));


    always@*
    begin
        
        case (icode)

        4'h2:   valE = valE_AB;     // cmovx
        4'h3:   valE = valE_CB;     // irmovq
        4'h4:   valE = valE_CB;     // rmmovq
        4'h5:   valE = valE_CB;     // mrmovq
        4'h6:begin                  // opq
                valE = valE_OP;
                CC_out[2] <= opq_of;
                CC_out[1] <= valE[63];
                if(valE == 0) begin
                    CC_out[0] <= 1;
                end
                else begin
                    CC_out[0] <= 0;
                end
        end
        4'h8: valE = valE_DEC;        // call
        4'h9: valE = valE_INC;        // ret
        4'hA: valE = valE_DEC;        // pushq
        4'hB: valE = valE_INC;        // popq
        default: valE = 0;
        
        endcase

    end
endmodule