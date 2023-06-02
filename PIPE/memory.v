module memory(clk, M_stat, M_icode, M_valE, M_valA, M_dstE, M_dstM,
              m_stat, m_icode, m_valE, m_valM, m_dstE, m_dstM);
              
    input clk;

    // Inputs
    input [3:0] M_stat;
    input [3:0] M_icode;
    input signed [63:0] M_valE, M_valA;
    input [3:0] M_dstE, M_dstM;

    // Outputs
    output reg[3:0] m_stat;
    output reg[3:0] m_icode;
    output reg signed[63:0] m_valE, m_valM;
    output reg[3:0] m_dstE, m_dstM;

    // Initiating data memory
    reg [63:0] Data_Mem[0:4095];
    integer i;

    initial begin
        for (i = 0; i < 4096; i = i+1) 
        begin
            Data_Mem[i] <= 0;
        end

        $dumpvars(0, Data_Mem[0], Data_Mem[1], Data_Mem[2], Data_Mem[3], Data_Mem[4], Data_Mem[5], Data_Mem[6], Data_Mem[7], Data_Mem[8]);
    end

    // No change wires
    always @(*) 
    begin    
        m_icode <= M_icode;
        m_valE  <= M_valE;
        m_dstE  <= M_dstE;
        m_dstM  <= M_dstM;
    end

    // Mem_write block
    reg Mem_write;

    always @(*) 
    begin
        case (m_icode)
            4'h4:   Mem_write <= 1;
            4'h8:   Mem_write <= 1;
            4'hA:   Mem_write <= 1;
            default:Mem_write <= 0; 
        endcase
    end

    // Mem_read block
    reg Mem_read;

    always @(*) 
    begin
        case (m_icode)
            4'h5:   Mem_read <= 1;
            4'h9:   Mem_read <= 1;
            4'hB:   Mem_read <= 1;
            default:Mem_read <= 0; 
        endcase
    end

    // Selecting Address
    reg [63:0] m_addr;

    always @(*) 
    begin
        case (m_icode)
            4'h4:   m_addr <= m_valE;
            4'h5:   m_addr <= m_valE;
            4'h8:   m_addr <= m_valE;
            4'h9:   m_addr <= M_valA;
            4'hA:   m_addr <= m_valE;
            4'hB:   m_addr <= M_valA;
            default:m_addr <= 4095; 
        endcase
    end

    // Checking memory error
    reg dmem_error;     // Memory error flag

    always @(*) 
    begin
        if (m_addr < 4096 && m_addr >= 0) 
            begin
                dmem_error <= 0;
            end
        else 
            begin
                dmem_error <= 1;
            end
    end

    wire [63:0] m_data_in;

    assign m_data_in = M_valA;

    // Writing back to memory
    always @(posedge clk) 
    begin
        if (dmem_error == 0 && Mem_write == 1) 
            begin
                Data_Mem[m_addr] <= m_data_in;
            end
    end

    // Reading from memory
    always @(*) 
    begin
        if (dmem_error == 0 && Mem_read == 1) 
            begin
                m_valM <= Data_Mem[m_addr];
            end
        else 
            begin
                m_valM <= 0;
            end
    end

    // m_stat
    always @(*) 
    begin        
        if (dmem_error == 1) 
            begin
                m_stat <= 4'b0010;
            end 
        else 
            begin
                m_stat <= M_stat;
            end
    end

endmodule