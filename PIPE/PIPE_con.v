module PIPE_con(D_icode, d_srcA, d_srcB, E_icode, E_dstM, e_Cnd, M_icode, m_stat, W_stat,
                W_stall, M_bubble, E_bubble, D_bubble, D_stall, F_stall);
    // Inputs
    input [3:0] D_icode, E_icode, M_icode;
    input [3:0] d_srcA, d_srcB;
    input [3:0] E_dstM;
    input e_Cnd;
    input [3:0] m_stat, W_stat;

    // Outputs
    output reg W_stall, D_stall, F_stall;
    output reg M_bubble, E_bubble, D_bubble;

    // Hazard flags
    wire Ret;
    wire Miss_Pred;
    wire LU_Haz;

    assign Ret = (D_icode == 9 || E_icode == 9 || M_icode == 9) ? 1 : 0;
    assign LU_Haz = ((E_icode == 5 || E_icode == 11) && (E_dstM == d_srcA || E_dstM == d_srcB)) ? 1 : 0;
    assign Miss_Pred = (E_icode == 7 && e_Cnd == 0) ? 1 : 0;

    // F_stall
    always @(*) 
    begin        
        if(Ret == 1 || LU_Haz == 1) 
            begin
                F_stall <= 1;
            end
        else if (Ret == 1 && Miss_Pred == 1) 
            begin
                F_stall <= 1;
            end
        else 
            begin
                F_stall <= 0;
            end
    end

    // D_stall
    always @(*) 
    begin
        if (LU_Haz == 1 && Ret == 1) 
            begin
                D_stall <= 1;
            end
        else if (LU_Haz == 1) 
            begin
                D_stall <= 1;
            end
        else 
            begin
                D_stall <= 0;
            end
    end

    // D_bubble
    always @(*) 
    begin
        if (D_stall == 0) 
        begin
            if (Ret == 1 || Miss_Pred == 1) 
                begin
                    D_bubble <= 1;
                end
            else 
                begin
                    D_bubble <= 0;
                end
        end
        else 
            begin
                D_bubble <= 0;
            end
    end

    // E_bubble
    always @(*) 
    begin
        if (LU_Haz == 1 && Ret == 1) 
            begin
                E_bubble <= 1;
            end
        else if (Ret == 1 && Miss_Pred == 1) 
            begin
                E_bubble <= 1;
            end
        else if (LU_Haz == 1) 
            begin
                E_bubble <= 1;
            end
        else if (Miss_Pred == 1) 
            begin
                E_bubble <= 1;
            end
        else 
            begin
                E_bubble <= 0;
            end
    end

    // M_bubble
    always @(*) 
    begin
        if (m_stat != 4'b1000) 
            begin
                M_bubble <= 1;
            end
        else if (W_stat != 4'b1000) 
            begin
                M_bubble <= 1;
            end
        else 
            begin
                M_bubble <= 0;
            end
    end

    // W_stall
    always @(*) 
    begin
        if (W_stat != 4'b1000) 
            begin
                W_stall <= 1;
            end
        else
            begin
                W_stall <= 0;
            end
    end

endmodule