module memory(valM, mem_error, clk, icode, valE, valA, valP);

    input clk;
    input [3:0] icode;
    input signed [63:0] valE, valA;
    input [63:0] valP;

    output reg [63:0] valM;
    output reg mem_error;

    reg [63:0] memory [16383:0];

    always@*
    begin
        mem_error = 0;
        if(valE > 16383) begin
            mem_error = 1; 
        end
        case(icode)
            4'h5:  valM = memory[valE];   // mrmovq
            4'h9:  valM = memory[valA];   // ret
            4'hB:  valM = memory[valA];   // popq
        endcase
    end

    always@(posedge clk)
    begin 
        mem_error = 0;
        if(valE > 16383) begin
            mem_error = 1; 
        end
        case(icode)
            4'h4:  memory[valE] <= valA;  // rmmovq
            4'h8:  memory[valE] <= valP;  // call
            4'hA:  memory[valE] <= valA;  // pushq
        endcase
    end

endmodule