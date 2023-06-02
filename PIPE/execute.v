module execute(clk, E_stat, E_icode, E_ifun, E_valA, E_valB, E_valC, E_dstE, E_dstM, W_stat, m_stat,
               e_stat, e_icode, e_Cnd, e_valE, e_valA, e_dstE, e_dstM, ZF, SF, OF);

    input clk;
    
    // Inputs
    input [3:0] E_stat;
    input [3:0] E_icode, E_ifun;
    input signed [63:0] E_valC, E_valA, E_valB;
    input [3:0] E_dstE, E_dstM;
    input [3:0] W_stat, m_stat;

    // Outputs
    output reg[3:0] e_stat;
    output reg[3:0] e_icode;
    output reg e_Cnd;
    output reg signed [63:0] e_valE;
    output reg signed[63:0] e_valA;
    output reg[3:0] e_dstE;
    output reg[3:0] e_dstM;
    output reg ZF, SF, OF;

    // No change wires
    always @(*) 
    begin    
        e_stat  <= E_stat;
        e_icode <= E_icode;
        e_valA  <= E_valA;
        e_dstM  <= E_dstM;
    end

    wire signed [63:0] ans;
    reg signed [63:0] aluA, aluB;
    wire overflow, set_cc;
    // ask
    assign set_cc = ((e_icode == 6) && (m_stat == 4'b1000) && (W_stat == 4'b1000)) ? 1 : 0;
    reg [1:0] control;
    // ask
    alu alu1(.control(control), .a(aluA), .b(aluB), .overflow(overflow), .out(ans));

    always @(*) 
    begin
        case(e_icode)
        4'b0010:                    // cmovXX rA, rB
            begin    
                e_Cnd = 0;        
                case(E_ifun)
                4'b0000:                // cmove(unconditional) 
                    begin 
                        e_Cnd = 1;       
                    end
                4'b0001:                // cmovle
                    begin     
                        if((SF^OF)|ZF)
                            e_Cnd = 1;
                    end
                4'b0010:                // cmovl 
                    begin 
                        if(SF^OF)
                            e_Cnd = 1;
                    end
                4'b0011:                // cmove 
                    begin 
                        if(ZF)
                            e_Cnd = 1;
                    end
                4'b0100:                // cmovne 
                    begin 
                        if(!ZF)
                            e_Cnd = 1;
                    end
                4'b0101:                // cmovge 
                    begin   
                        if(!(SF^OF))
                            e_Cnd = 1;
                    end
                4'b0110:                // cmovg 
                    begin 
                        if(!(SF^OF))
                            begin
                                if(!ZF)
                                    e_Cnd = 1;
                            end
                    end
                endcase
                aluA = E_valA;
                aluB = 64'd0;
                control = 2'b00;        // valE = valA + 0
            end
        4'b0011:                        // irmovq V, rB 
            begin 
                aluA = E_valC;              
                aluB = 64'd0;
                control = 2'b00;        // valE = 0 + valC
            end
        4'b0100:                        // rmmovq rA, D(rB)
            begin                 
                aluA = E_valC;          
                aluB = E_valB;
                control = 2'b00;        // valE = valB + valC
            end     
        4'b0101:                        // mrmovq D(rB), rA
            begin 
                aluA = E_valC;
                aluB = E_valB;
                control = 2'b00;        // valE = valB + valC
            end
        4'b0110:                        // Opq rA, rB
            begin
                aluA = E_valB;
                aluB = E_valA;
                control = E_ifun[1:0];
            end
        4'b0111:                        // jXX Dest
            begin
                e_Cnd = 0;
                case(E_ifun)
                    4'b0000:            // jmp 
                        begin
                            e_Cnd = 1;  // unconditional jump
                        end
                    4'b0001:            // jle 
                        begin 
                            if((SF^OF)|ZF)
                                e_Cnd = 1;
                        end 
                    4'b0010:            // jl 
                        begin 
                            if(SF^OF)
                                e_Cnd = 1;
                        end
                    4'b0011:            // je
                        begin 
                            if(ZF)
                                e_Cnd = 1;
                            else
                                e_Cnd = 0;
                        end
                    4'b0100:            // jne
                        begin 
                            if(!ZF)
                                e_Cnd = 1;
                        end
                    4'b0101:            // jge 
                        begin 
                            if(!(SF^OF))
                                e_Cnd = 1;
                        end
                    4'b0110:            // jg
                        begin                         
                            if(!(SF^OF)&(!ZF))
                                e_Cnd = 1;
                        end
                    endcase
            end
        4'b1000:                        // call Dest 
            begin 
                aluA = -64'd8;
                aluB = E_valB;
                control = 2'b00;        // valE = valB - 8
            end
        4'b1001:                        // ret 
            begin 
                aluA = 64'd8;
                aluB = E_valB;
                control = 2'b00;        // valE = valB + 8
            end
        4'b1010:                        // pushq rA 
            begin 
                aluA = -64'd8;
                aluB = E_valB;
                control = 2'b00;        // valE = valB - 8
            end
        4'b1011:                        // popq rA
            begin 
                aluA = 64'd8;
                aluB = E_valB;
                control = 2'b00;        // valE = valB + 8
            end
        endcase
        e_valE = ans;
    end

    always @(posedge clk ) 
    begin
        if(set_cc == 1)
            begin
                ZF = (e_valE == 64'b0); // zero flag
                SF = (e_valE[63] == 1); // signed flag
                OF = (aluA[63] == aluB[63]) && (e_valE[63] != aluA[63]); // overflow flag
            end
    end

    // e_dstE
    always @(*) begin
        if (e_icode == 2 && e_Cnd == 0) 
            begin
                e_dstE <= 15;    
            end
        else
            begin
                e_dstE <= E_dstE;
            end
    end

endmodule