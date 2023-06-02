module fetch(F_predPC, M_icode, M_Cnd, M_valA, W_icode, W_valM, f_stat, f_icode, f_ifun, f_rA, f_rB, f_valC, f_valP, f_predPC);

    // inputs
    input [63:0] F_predPC;
    input [3:0] M_icode, W_icode;
    input M_Cnd;
    input signed [63:0] M_valA, W_valM;

    // outputs
    output reg [3:0] f_stat;
    output reg [3:0] f_icode, f_ifun;
    output reg [3:0] f_rA, f_rB;
    output reg signed [63:0] f_valC;
    output reg [63:0] f_valP;
    output reg [63:0] f_predPC;
    // output reg [3:0]Stat;
    // Setting up instruction memory
    reg [7:0] inst_mem[0:1023];

    initial begin
        inst_mem[0] = 8'h10;
        inst_mem[1] = 8'h10; //nop
        // inst_mem[2] = 8'h10; //halt

        inst_mem[2] = 8'h20; //rrmovq
        inst_mem[3] = 8'h12;
        // inst_mem[4]= 8'h00;

        inst_mem[4] = 8'h30; //irmovq
        inst_mem[5] = 8'hF2;
        inst_mem[6] = 8'h00;
        inst_mem[7] = 8'h00;
        inst_mem[8] = 8'h00;
        inst_mem[9] = 8'h00;
        inst_mem[10] = 8'h00;
        inst_mem[11] = 8'h00;
        inst_mem[12] = 8'h00;
        inst_mem[13] = 8'b00000010;
        // inst_mem[14]=8'h00;

        inst_mem[14] = 8'h40; //rmmovq
        inst_mem[15] = 8'h24;
        {inst_mem[16],inst_mem[17],inst_mem[18],inst_mem[19],inst_mem[20],inst_mem[21],inst_mem[22],inst_mem[23]} = 64'd1;
        // inst_mem[24]=8'h00;

        inst_mem[24] = 8'h40; //rmmovq
        inst_mem[25] = 8'h53;
        {inst_mem[26],inst_mem[27],inst_mem[28],inst_mem[29],inst_mem[30],inst_mem[31],inst_mem[32],inst_mem[33]} = 64'd0;
        // inst_mem[34] = 8'h00;
        inst_mem[34] = 8'h50; //mrmovq
        inst_mem[35] = 8'h53;
        {inst_mem[36],inst_mem[37],inst_mem[38],inst_mem[39],inst_mem[40],inst_mem[41],inst_mem[42],inst_mem[43]} = 64'd0;
        // inst_mem[44]=8'h00;

        inst_mem[44] = 8'h60; //opq
        inst_mem[45] = 8'h9A;
                // inst_mem[46]  = 8'h10; //nop
        // inst_mem[46] = 8'h00; //halt



        inst_mem[46] = 8'h73; //jmp
        // {inst_mem[47],inst_mem[48],inst_mem[49],inst_mem[50],inst_mem[51],inst_mem[52],inst_mem[53],inst_mem[54]} = 64'd56;
        inst_mem[54]=8'd56;
        {inst_mem[47],inst_mem[48],inst_mem[49],inst_mem[50],inst_mem[51],inst_mem[52],inst_mem[53]}=56'd0;

        inst_mem[55] = 8'h00; //halt

        inst_mem[56] = 8'hA0; // pushq
        inst_mem[57] = 8'h9F;

        inst_mem[58] = 8'hB0; //popq
        inst_mem[59] = 8'h9F;

        inst_mem[60] = 8'h80; //call
        {inst_mem[61],inst_mem[62],inst_mem[63],inst_mem[64],inst_mem[65],inst_mem[66],inst_mem[67],inst_mem[68]} = 64'd80;

        inst_mem[69] = 8'h60; //opq
        inst_mem[70] = 8'h56;

        // inst_mem[71] = 8'h00;
        inst_mem[71] = 8'h72; //jmp
        {inst_mem[72],inst_mem[73],inst_mem[74],inst_mem[75],inst_mem[76],inst_mem[77],inst_mem[78],inst_mem[79]} = 64'd46;

        // inst_mem[80]=8'h10;
        inst_mem[80] = 8'h63; //opq
        inst_mem[81] = 8'hDE;
        // inst_mem[80] = 8'h10;

        inst_mem[82]=8'h90;
    end


    // Select PC
    reg [63:0] PC;

    always @(*) 
    begin        
        if (M_icode == 7 && M_Cnd == 0) 
            begin
                PC <= M_valA;
            end
        else if (W_icode == 9) 
            begin    
                PC <= W_valM;
            end
        else 
            begin
                PC <= F_predPC;
            end
    end


    // Select f_icode, f_ifun, imem_error
    reg imem_error;

    always @(*) 
    begin
        if (PC >= 0 && PC < 4096) 
            begin 
                f_icode    <= inst_mem[PC][7:4];
                f_ifun     <= inst_mem[PC][3:0];
                imem_error <= 0;
            end
        else 
            begin
                f_icode    <= 1;
                f_ifun     <= 0;
                imem_error <= 1;
            end
    end

    // instr_valid flag
    reg instr_valid;
    
    always @(*) 
    begin
        if (f_icode >= 0 && f_icode <= 11) 
            begin
                instr_valid <= 1;
            end
        else 
            begin
                instr_valid <= 0;
            end
    end

    // Setting rA, rB, valC, valP
    always @(*) begin
        case (f_icode)
            4'h2: begin                 // cmov
                    f_rA            = inst_mem[PC + 1][7:4];
                    f_rB            = inst_mem[PC + 1][3:0];
                    f_valC          = 0;
                    f_valP          = PC + 2;
                end
            4'h3: begin                 // irmovq
                    f_rA            = inst_mem[PC + 1][7:4];
                    f_rB            = inst_mem[PC + 1][3:0];
                    f_valC          = {inst_mem[PC+2],inst_mem[PC+3],inst_mem[PC+4],inst_mem[PC+5],inst_mem[PC+6],inst_mem[PC+7],inst_mem[PC+8],inst_mem[PC+9]};
                    f_valP          = PC + 10;
                end
            4'h4: begin                 // rmmovq
                    f_rA            = inst_mem[PC + 1][7:4];
                    f_rB            = inst_mem[PC + 1][3:0];
                    f_valC          = {inst_mem[PC+2],inst_mem[PC+3],inst_mem[PC+4],inst_mem[PC+5],inst_mem[PC+6],inst_mem[PC+7],inst_mem[PC+8],inst_mem[PC+9]};
                    f_valP          = PC + 10;
                end
            4'h5: begin                 // mrmovq
                    f_rA            = inst_mem[PC + 1][7:4];
                    f_rB            = inst_mem[PC + 1][3:0];
                    f_valC          = {inst_mem[PC+2],inst_mem[PC+3],inst_mem[PC+4],inst_mem[PC+5],inst_mem[PC+6],inst_mem[PC+7],inst_mem[PC+8],inst_mem[PC+9]};
                    f_valP          = PC + 10;
                end
            4'h6: begin                 // OPq
                    f_rA            = inst_mem[PC + 1][7:4];
                    f_rB            = inst_mem[PC + 1][3:0];
                    f_valC          = 0;
                    f_valP          = PC + 2;
                end
            4'h7: begin                 // jxx
                    f_valC          = {inst_mem[PC+1],inst_mem[PC+2],inst_mem[PC+3],inst_mem[PC+4],inst_mem[PC+5],inst_mem[PC+6],inst_mem[PC+7],inst_mem[PC+8]};
                    f_valP          = PC + 9;
                end
            4'h8: begin                 // call
                    f_valC          = {inst_mem[PC+1],inst_mem[PC+2],inst_mem[PC+3],inst_mem[PC+4],inst_mem[PC+5],inst_mem[PC+6],inst_mem[PC+7],inst_mem[PC+8]};
                    f_valP          = PC + 9;
                end
            4'h9: begin                 // ret
                    f_valP          = PC + 1; 
                end
            4'hA: begin                 // pushq
                    f_rA    = inst_mem[PC + 1][7:4];
                    f_rB    = inst_mem[PC + 1][3:0];
                    f_valC  = 0;
                    f_valP  = PC + 2;
                end
            4'hB: begin                 // popq
                    f_rA    = inst_mem[PC + 1][7:4];
                    f_rB    = inst_mem[PC + 1][3:0];
                    f_valC  = 0;
                    f_valP  = PC + 2;
                end
            
            default: begin
                    f_rA    <= 15;
                    f_rB    <= 15;
                    f_valP  <= PC + 1;
                end 
        endcase
    end

    // Predicting the PC
    always @(*) begin 
        case (f_icode)
            4'h7:   f_predPC <= f_valC;
            4'h8:   f_predPC <= f_valC; 
            default:f_predPC <= f_valP;
        endcase
    end

    // Generating Stat Codes
    always @(*) 
    begin
        if (imem_error == 1) 
            begin
                f_stat <= 4'b0010;
            end 
        else if (instr_valid == 0) 
            begin
                f_stat <= 4'b0001;
            end
        else if (f_icode == 0) 
            begin
                f_stat <= 4'b0100;
            end
        else 
            begin
                f_stat <= 4'b1000;
            end
    end

endmodule   