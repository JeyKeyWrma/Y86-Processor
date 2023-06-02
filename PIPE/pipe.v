`include "../AL_Unit/ALU/alu.v"
`include "../AL_Unit/ADD/add_64bit.v"
`include "../AL_Unit/ADD/add_1bit.v"
`include "../AL_Unit/SUB/sub_64bit.v"
`include "../AL_Unit/XOR/xor_64bit.v"
`include "../AL_Unit/AND/and_64bit.v"
`include "fetch.v"
`include "decode.v"
`include "execute.v"
`include "memory.v"
`include "PIPE_con.v"

module PIPE();

    reg clk;

    // F pipeline register
    reg [63:0] F_predPC = 0;

    // D pipeline register
    reg [3:0] D_stat = 4'b1000;
    reg [3:0] D_icode = 1;
    reg [3:0] D_ifun = 0;
    reg [3:0] D_rA = 0;
    reg [3:0] D_rB = 0;
    reg signed [63:0] D_valC = 0;
    reg [63:0] D_valP = 0;

    // E pipeline register
    reg [3:0] E_stat = 4'b1000;
    reg [3:0] E_icode = 1;
    reg [3:0] E_ifun = 0;
    reg signed [63:0] E_valC = 0;
    reg signed [63:0] E_valA = 0;
    reg signed [63:0] E_valB = 0;
    reg [3:0] E_dstE = 0;
    reg [3:0] E_dstM = 0;
    reg [3:0] E_srcA = 0;
    reg [3:0] E_srcB = 0;
    wire ZF;
    wire OF;
    wire SF;

    // M pipeline register
    reg [3:0] M_stat = 4'b1000;
    reg [3:0] M_icode = 1;
    reg M_Cnd = 0;
    reg signed [63:0] M_valE = 0;
    reg signed [63:0] M_valA = 0;
    reg [3:0] M_dstE = 0;
    reg [3:0] M_dstM = 0;

    // W pipeline register
    reg [3:0] W_stat = 4'b1000;
    reg [3:0] W_icode = 1;
    reg signed [63:0] W_valE = 0;
    reg signed [63:0] W_valM = 0;  
    reg [3:0] W_dstE = 0;
    reg [3:0] W_dstM = 0;

    // Fetch 
    wire [3:0] f_stat;
    wire [3:0] f_icode, f_ifun;
    wire [3:0] f_rA, f_rB;
    wire signed [63:0] f_valC;
    wire [63:0] f_valP, f_predPC;

    // Decode 
    wire [3:0] d_stat;
    wire [3:0] d_icode, d_ifun;
    wire signed [63:0] d_valC, d_valA, d_valB;
    wire [3:0] d_dstE, d_dstM;
    wire [3:0] d_srcA, d_srcB;

    // Registers
    wire signed [63:0] reg_file0;
    wire signed [63:0] reg_file1;
    wire signed [63:0] reg_file2;
    wire signed [63:0] reg_file3;
    wire signed [63:0] reg_file4;
    wire signed [63:0] reg_file5;
    wire signed [63:0] reg_file6;
    wire signed [63:0] reg_file7;
    wire signed [63:0] reg_file8;
    wire signed [63:0] reg_file9;
    wire signed [63:0] reg_file10;
    wire signed [63:0] reg_file11;
    wire signed [63:0] reg_file12;
    wire signed [63:0] reg_file13;
    wire signed [63:0] reg_file14;

    // Execute
    wire [3:0] e_stat;
    wire [3:0] e_icode;
    wire e_Cnd;
    wire signed [63:0] e_valE, e_valA;
    wire [3:0] e_dstE, e_dstM;

    // Memory 
    wire [3:0] m_stat;
    wire [3:0] m_icode;
    wire signed [63:0] m_valE, m_valM;
    wire [3:0] m_dstE, m_dstM;

    wire [3:0] Stat;

    // Passing inputs to FETCH stage
    fetch f(
        // Inputs from F register
        .F_predPC(F_predPC),

        // Inputs forwarded from M register
        .M_icode(M_icode),
        .M_Cnd(M_Cnd),
        .M_valA(M_valA),

        // Inputs forwarded from W register
        .W_icode(W_icode),
        .W_valM(W_valM),

        // Outputs
        .f_stat(f_stat),
        .f_icode(f_icode),
        .f_ifun(f_ifun),
        .f_rA(f_rA),
        .f_rB(f_rB),
        .f_valC(f_valC),
        .f_valP(f_valP),
        .f_predPC(f_predPC)
            );

    decode d(
        .clk(clk),
        
        // Inputs from D register
        .D_stat(D_stat),
        .D_icode(D_icode),
        .D_ifun(D_ifun),
        .D_rA(D_rA),
        .D_rB(D_rB),
        .D_valC(D_valC),
        .D_valP(D_valP),

        // Inputs forwarded from execute stage
        .e_dstE(e_dstE),
        .e_valE(e_valE),

        // inputs forwarded from M register and memory stage
        .M_dstE(M_dstE),
        .M_valE(M_valE),
        .M_dstM(M_dstM),
        .m_valM(m_valM),

        // Inputs forwarded from W register
        .W_dstM(W_dstM),
        .W_valM(W_valM),
        .W_dstE(W_dstE),
        .W_valE(W_valE),

        // Outputs
        .d_stat(d_stat),
        .d_icode(d_icode),
        .d_ifun(d_ifun),
        .d_valC(d_valC),
        .d_valA(d_valA),
        .d_valB(d_valB),
        .d_dstE(d_dstE),
        .d_dstM(d_dstM),
        .d_srcA(d_srcA),
        .d_srcB(d_srcB),
        .reg_file0(reg_file0),
        .reg_file1(reg_file1),
        .reg_file2(reg_file2),
        .reg_file3(reg_file3),
        .reg_file4(reg_file4),
        .reg_file5(reg_file5),
        .reg_file6(reg_file6),
        .reg_file7(reg_file7),
        .reg_file8(reg_file8),
        .reg_file9(reg_file9),
        .reg_file10(reg_file10),
        .reg_file11(reg_file11),
        .reg_file12(reg_file12),
        .reg_file13(reg_file13),
        .reg_file14(reg_file14)
    );

    execute e(
        .clk(clk),

        // Inputs
        .E_stat(E_stat),
        .E_icode(E_icode),
        .E_ifun(E_ifun),
        .E_valC(E_valC),
        .E_valA(E_valA),
        .E_valB(E_valB),
        .E_dstE(E_dstE),
        .E_dstM(E_dstM),
        .W_stat(W_stat),
        .m_stat(m_stat),

        // Outputs
        .e_stat(e_stat),
        .e_icode(e_icode),
        .e_Cnd(e_Cnd),
        .e_valE(e_valE),
        .e_valA(e_valA),
        .e_dstE(e_dstE),
        .e_dstM(e_dstM),
        .ZF(ZF),
        .OF(OF),
        .SF(SF)
    );

    memory m(
        .clk(clk),

        // Inputs
        .M_stat(M_stat),
        .M_icode(M_icode),
        .M_valE(M_valE),
        .M_valA(M_valA),
        .M_dstE(M_dstE),
        .M_dstM(M_dstM),

        // Outputs
        .m_stat(m_stat),
        .m_icode(m_icode),
        .m_valE(m_valE),
        .m_valM(m_valM),
        .m_dstE(m_dstE),
        .m_dstM(m_dstM)
    );

    // Stat Code
    assign Stat = W_stat;

    // Control Logic
    wire W_stall, D_stall, F_stall;
    wire M_bubble, E_bubble, D_bubble;

    PIPE_con pipe_con(
        // Inputs
        .D_icode(D_icode),
        .d_srcA(d_srcA),
        .d_srcB(d_srcB),
        .E_icode(E_icode),
        .E_dstM(E_dstM),
        .e_Cnd(e_Cnd),
        .M_icode(M_icode),
        .m_stat(m_stat),
        .W_stat(W_stat),

        // Outputs
        .W_stall(W_stall),
        .M_bubble(M_bubble),
        .E_bubble(E_bubble),
        .D_bubble(D_bubble),
        .D_stall(D_stall),
        .F_stall(F_stall)
    );


    // F register 
    always @(posedge clk) 
    begin
        if (F_stall != 1) 
            begin
                F_predPC <= f_predPC;
            end
    end

    // D register 
    always @(posedge clk) 
    begin
        if (D_stall == 0) 
            begin
                if (D_bubble == 0) 
                begin
                    D_stat  <= f_stat;
                    D_icode <= f_icode;
                    D_ifun  <= f_ifun;
                    D_rA    <= f_rA;
                    D_rB    <= f_rB;
                    D_valC  <= f_valC;
                    D_valP  <= f_valP;
                end
                else 
                begin
                    D_stat  <= 4'b1000;
                    D_icode <= 1;
                    D_ifun  <= 0;
                    D_rA    <= 0;
                    D_rB    <= 0;
                    D_valC  <= 0;
                    D_valP  <= 0;
                end
            end       
    end

    // E register
    always @(posedge clk) 
    begin
        if (E_bubble == 1) 
            begin
                E_stat  <= 4'b1000;
                E_icode <= 1;
                E_ifun  <= 0;
                E_valC  <= 0;
                E_valA  <= 0;
                E_valB  <= 0;
                E_dstE  <= 0;
                E_dstM  <= 0;
                E_srcA  <= 0;
                E_srcB  <= 0;
            end
        else 
            begin
                E_stat  <= d_stat;
                E_icode <= d_icode;
                E_ifun  <= d_ifun;
                E_valC  <= d_valC;
                E_valA  <= d_valA;
                E_valB  <= d_valB;
                E_dstE  <= d_dstE;
                E_dstM  <= d_dstM;
                E_srcA  <= d_srcA;
                E_srcB  <= d_srcB;
            end
    end

    // M register
    always @(posedge clk) 
    begin
        if (M_bubble == 1) 
            begin
                M_stat  <= 4'b1000;
                M_icode <= 1;
                M_Cnd   <= 0;
                M_valE  <= 0;
                M_valA  <= 0;
                M_dstE  <= 0;
                M_dstM  <= 0;
            end
        else 
            begin
                M_stat  <= e_stat;
                M_icode <= e_icode;
                M_Cnd   <= e_Cnd;
                M_valE  <= e_valE;
                M_valA  <= e_valA;
                M_dstE  <= e_dstE;
                M_dstM  <= e_dstM;
            end
    end

    // W register
    always @(posedge clk) 
    begin
        if (W_stall != 1) 
            begin
                W_stat  <= m_stat;
                W_icode <= m_icode;
                W_valE  <= m_valE;
                W_valM  <= m_valM;
                W_dstE  <= m_dstE;
                W_dstM  <= m_dstM;
            end
    end

    initial begin
        
        $dumpfile("pipe_tb.vcd");
        
    end

    initial begin
        clk <= 0;
        forever begin
            #10 clk <= ~clk;
        end
    end

    initial begin
        $monitor("time=%0d, clk=%0d, f_pc=%0d, f_icode=%0d, f_ifun=%0d, f_rA=%0d, f_rB=%0d, f_valP=%0d, f_valC=%0d, D_icode=%0d, E_icode=%0d, M_icode=%0d, W_icode=%0d Stat=%d reg1=%d reg2=%d reg3=%d reg4=%d reg5=%d reg6=%d reg7=%d reg8=%d reg9=%d reg10=%d reg11=%d reg12=%d reg13=%d reg14=%d reg15=%d ZF=%d SF=%d OF=%d W_valM=%d M_valA=%d, e_valE=%d\n", 
            $time, clk, f_predPC, f_icode, f_ifun, f_rA, f_rB, f_valP, f_valC, D_icode, E_icode, M_icode, W_icode, Stat, reg_file0, reg_file1, reg_file2, reg_file3, reg_file4, reg_file5, reg_file6, reg_file7, reg_file8, reg_file9, reg_file10, reg_file11, reg_file12, reg_file13, reg_file14, ZF, SF, OF, W_valM, M_valA, e_valE);
    end

    always @(*)
    begin 
        if(Stat == 4'b0100)
            begin
                $finish;
            end
    end


endmodule