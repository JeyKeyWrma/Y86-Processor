module decode(clk, icode, ifun, rA, rB, valA, valB, cnd, valE, valM, reg_0, reg_1, reg_2, reg_3, reg_4, reg_5, reg_6, reg_7, reg_8, reg_9, reg_10, reg_11, reg_12, reg_13, reg_14);

    input clk, cnd;
    input [3:0] icode, ifun;
    input [3:0] rA, rB;
    input signed[63:0] valE, valM;

    output reg signed [63:0] valA, valB;

    output reg signed [63:0] reg_0;
    output reg signed [63:0] reg_1;
    output reg signed [63:0] reg_2;
    output reg signed [63:0] reg_3;
    output reg signed [63:0] reg_4;
    output reg signed [63:0] reg_5;
    output reg signed [63:0] reg_6;
    output reg signed [63:0] reg_7;
    output reg signed [63:0] reg_8;
    output reg signed [63:0] reg_9;
    output reg signed [63:0] reg_10;
    output reg signed [63:0] reg_11;
    output reg signed [63:0] reg_12;
    output reg signed [63:0] reg_13;
    output reg signed [63:0] reg_14;

    reg [63:0] reg_mem[0:14];

    always@(*)

    begin

        reg_mem[0]  = 64'd1;
        reg_mem[1]  = 64'd2;
        reg_mem[2]  = 64'd3;
        reg_mem[3]  = 64'd3;
        reg_mem[4]  = 64'd5;
        reg_mem[5]  = 64'd1;
        reg_mem[6]  = 64'd2;
        reg_mem[7]  = 64'd3;
        reg_mem[8]  = 64'd4;
        reg_mem[9]  = 64'd62;
        reg_mem[10] = 64'd1;
        reg_mem[11] = 64'd2;
        reg_mem[12] = 64'd3;
        reg_mem[13] = 64'd4;
        reg_mem[14] = 64'd5;

        case(icode)

        4'b0010 : begin //cmovxx
        valB = 0;
        valA = reg_mem[rA]; 
        end

        4'b0100 : begin //rmmovq
            valA = reg_mem[rA];
            valB = reg_mem[rB];
        end  

        4'b0101 : begin //mrmovq
            valA = 0;
            valB = reg_mem[rB];
        end

        4'b0110 : begin //OPq
            valA = reg_mem[rA];
            valB = reg_mem[rB];
        end

        4'b1000 : begin //call
            valB = reg_mem[4];
        end 

        4'b1001 : begin //ret
            valA = reg_mem[4];
            valB = reg_mem[4];
        end

        4'b1010 : begin //pushq
            valA = reg_mem[rA];
            valB = reg_mem[4];
        end

        4'b1011 : begin //popq
            valA = reg_mem[4];
            valB = reg_mem[4];
        end

        endcase 

        reg_0 = reg_mem[0];
        reg_1 = reg_mem[1];
        reg_2 = reg_mem[2];
        reg_3 = reg_mem[3];
        reg_4 = reg_mem[4];
        reg_5 = reg_mem[5];
        reg_6 = reg_mem[6];
        reg_7 = reg_mem[7];
        reg_8 = reg_mem[8];
        reg_9 = reg_mem[9];
        reg_10 = reg_mem[10];
        reg_11 = reg_mem[11];
        reg_12 = reg_mem[12];
        reg_13 = reg_mem[13];
        reg_14 = reg_mem[14];
        
    end

    always@(posedge clk)
    begin
        case(icode)

        4'b0010 : begin //cmovxx
            if(cnd == 1'b1)
            begin
                reg_mem[rB] = valE;
            end
        end

        4'b0011 : begin //irmovq
            reg_mem[rB] = valE;
        end  

        4'b0101 : begin //mrmovq
            reg_mem[rA] = valM;
        end

        4'b0110 : begin //OPq
            reg_mem[rB] = valE;
        end

        4'b1000 : begin //call
            reg_mem[4] = valE;
        end 

        4'b1001 : begin //ret
            reg_mem[4] = valE;
        end

        4'b1010 : begin //pushq
            reg_mem[4] = valE;
        end

        4'b1011 : begin //popq
            reg_mem[4] = valE;
            reg_mem[rA] = valM;
        end

        endcase

        reg_0 <= reg_mem[0];
        reg_1 <= reg_mem[1];
        reg_2 <= reg_mem[2];
        reg_3 <= reg_mem[3];
        reg_4 <= reg_mem[4];
        reg_5 <= reg_mem[5];
        reg_6 <= reg_mem[6];
        reg_7 <= reg_mem[7];
        reg_8 <= reg_mem[8];
        reg_9 <= reg_mem[9];
        reg_10 <= reg_mem[10];
        reg_11 <= reg_mem[11];
        reg_12 <= reg_mem[12];
        reg_13 <= reg_mem[13];
        reg_14 <= reg_mem[14];
    end

endmodule