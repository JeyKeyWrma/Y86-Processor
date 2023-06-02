module decode(clk, D_stat, D_icode, D_ifun, D_rA, D_rB, D_valC, D_valP, e_dstE, e_valE,
              M_dstE, M_dstM, M_valE, m_valM, W_dstM, W_dstE, W_valM, W_valE,
              d_stat, d_icode, d_ifun, d_valC, d_valA, d_valB, d_dstE, d_dstM, d_srcA, d_srcB,
              reg_file0, reg_file1, reg_file2, reg_file3, reg_file4, reg_file5, reg_file6, reg_file7,
              reg_file8, reg_file9, reg_file10, reg_file11, reg_file12, reg_file13, reg_file14);

    input clk;

    // Inputs from D register
    input [3:0] D_stat;
    input [3:0] D_icode, D_ifun;
    input [3:0] D_rA, D_rB;
    input signed [63:0] D_valC;
    input [63:0] D_valP;

    // Inputs forwarded from execute stage
    input [3:0] e_dstE;
    input signed [63:0] e_valE;

    // Inputs forwarded from M register and memory stage
    input [3:0] M_dstE, M_dstM;
    input signed [63:0] M_valE, m_valM;

    // Inputs forwarded from W register
    input [3:0] W_dstM, W_dstE;
    input signed [63:0] W_valM, W_valE;

    // Outputs
    output reg[3:0] d_stat;
    output reg[3:0] d_icode, d_ifun;
    output reg signed[63:0] d_valA, d_valB, d_valC;
    output reg[3:0] d_dstE, d_dstM;
    output reg[3:0] d_srcA, d_srcB;

    // Output Registers
    output reg signed [63:0] reg_file0;
    output reg signed [63:0] reg_file1;
    output reg signed [63:0] reg_file2;
    output reg signed [63:0] reg_file3;
    output reg signed [63:0] reg_file4;
    output reg signed [63:0] reg_file5;
    output reg signed [63:0] reg_file6;
    output reg signed [63:0] reg_file7;
    output reg signed [63:0] reg_file8;
    output reg signed [63:0] reg_file9;
    output reg signed [63:0] reg_file10;
    output reg signed [63:0] reg_file11;
    output reg signed [63:0] reg_file12;
    output reg signed [63:0] reg_file13;
    output reg signed [63:0] reg_file14;


    // Initiating register arrays
    reg [63:0] reg_array[0:15];

    always @(*) 
    begin
        reg_file0 = reg_array[0];
        reg_file1 = reg_array[1];
        reg_file2 = reg_array[2];
        reg_file3 = reg_array[3];
        reg_file4 = reg_array[4];
        reg_file5 = reg_array[5];
        reg_file6 = reg_array[6];
        reg_file7 = reg_array[7];
        reg_file8 = reg_array[8];
        reg_file9 = reg_array[9];
        reg_file10 = reg_array[10];
        reg_file11 = reg_array[11];
        reg_file12 = reg_array[12];
        reg_file13 = reg_array[13];
        reg_file14 = reg_array[14];      
    end

    initial 
    begin
        reg_array[0] = 64'd12;        
        reg_array[1] = 64'd10;        
        reg_array[2] = 64'd101;       
        reg_array[3] = 64'd3;         
        reg_array[4] = 64'd254;       
        reg_array[5] = 64'd50;        
        reg_array[6] = -64'd143;      
        reg_array[7] = 64'd10000;     
        reg_array[8] = 64'd990000;    
        reg_array[9] = -64'd12345;    
        reg_array[10] = 64'd12345;    
        reg_array[11] = 64'd10112;    
        reg_array[12] = 64'd0;        
        reg_array[13] = 64'd1567;     
        reg_array[14] = 64'd8643;     
        reg_array[15] = 64'd0;        
    end
   
    // No change wires
    always @(*) 
    begin        
        d_stat  <= D_stat;
        d_icode <= D_icode;
        d_ifun  <= D_ifun;
        d_valC  <= D_valC;
    end

    // Updating register file at positive edge of clock
    always @(posedge clk) 
    begin        
        reg_array[W_dstM] <= W_valM;
        reg_array[W_dstE] <= W_valE;
    end

    // d_dstE
    always @(*) 
    begin
        case (d_icode)
            4'h2:   d_dstE <= D_rB;
            4'h3:   d_dstE <= D_rB;
            4'h6:   d_dstE <= D_rB;
            4'h8:   d_dstE <= 4;
            4'h9:   d_dstE <= 4;
            4'hA:   d_dstE <= 4;
            4'hB:   d_dstE <= 4;
            default:d_dstE <= 15;
        endcase
    end

    // d_dstM
    always @(*) 
    begin
        case (d_icode)
            4'h5:   d_dstM <= D_rA;
            4'hB:   d_dstM <= D_rA;
            default:d_dstM <= 15;
        endcase
    end

    // d_srcA
    always @(*) 
    begin
        case (d_icode)
            4'h2:   d_srcA <= D_rA; 
            4'h4:   d_srcA <= D_rA; 
            4'h6:   d_srcA <= D_rA; 
            4'h9:   d_srcA <= 4; 
            4'hA:   d_srcA <= 4; 
            4'hB:   d_srcA <= 4; 
            default:d_srcA <= 15;    
        endcase
    end

    // d_srcB
    always @(*) 
    begin
        case (d_icode)
            4'h4:   d_srcB <= D_rB; 
            4'h5:   d_srcB <= D_rB; 
            4'h6:   d_srcB <= D_rB; 
            4'h8:   d_srcB <= 4; 
            4'h9:   d_srcB <= 4; 
            4'hA:   d_srcB <= 4; 
            4'hB:   d_srcB <= 4; 
            default:d_srcB <= 15;    
        endcase
    end

    // Data forwarding of A 
    always @(*) begin
        if (d_icode == 7 || d_icode == 8) 
            begin
                d_valA <= D_valP;
            end
        else if (d_srcA == e_dstE) 
            begin
                d_valA <= e_valE;
            end
        else if (d_srcA == M_dstM) 
            begin
                d_valA <= m_valM;
            end
        else if (d_srcA == M_dstE) 
            begin
                d_valA <= M_valE;
            end
        else if (d_srcA == W_dstM) 
            begin
                d_valA <= W_valM;
            end
        else if (d_srcA == W_dstE) 
            begin
                d_valA <= W_valE;
            end
        else 
            begin    
                d_valA <= reg_array[d_srcA];
            end
    end

    // Data forwarding of B
    always @(*) begin

        if (d_srcB == e_dstE) 
            begin
                d_valB <= e_valE;
            end
        else if (d_srcB == M_dstM) 
            begin
                d_valB <= m_valM;
            end
        else if (d_srcB == M_dstE) 
            begin
                d_valB <= M_valE;
            end
        else if (d_srcB == W_dstM) 
            begin
                d_valB <= W_valM;
            end
        else if (d_srcB == W_dstE) 
            begin
                d_valB <= W_valE;
            end
        else 
            begin    
                d_valB <= reg_array[d_srcB];
            end
    end

endmodule