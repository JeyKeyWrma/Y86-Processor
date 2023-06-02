module fetch(icode, ifun, rA, rB, valC, valP, imem_error, instr_valid, clk, PC, instr, halt_flag);

    input clk;                              // clock
    input [63:0] PC;                        // Program counter
    input [0:79] instr;                     // Current instruction
    output reg [3:0] icode, ifun;           // icode is the type of instruction out of the 12 types and ifun gives the exact instruction
    output reg [3:0] rA, rB;                // register addresses
    output reg signed [63:0] valC;          // 8 byte values i.e F
    output reg [63:0] valP;                 // incremented PC
    output reg imem_error = 0;              // unaccessible memory error flag
    output reg instr_valid = 1;             // invalid instruction flag
    output reg halt_flag = 0;               // halt flag

    always@(*) 
    begin 

        if(PC > 255)
        begin
            imem_error = 1;
            $finish;
        end

        {icode, ifun} = instr[0:7];

        case (icode)
        4'h0:begin                       //halt
            valP = PC + 1;
            halt_flag = 1;
        end             

        4'h1:valP = PC + 1;              // nop

        4'h2:begin                       // cmovq
                {rA, rB}=instr[8:15];
                valP = PC + 2;
        end

        4'h3:begin                       // irmovq
                {rA, rB, valC} = instr[8:79];
                valP = PC + 10;
        end

        4'h4:begin                       // rmmovq
            {rA, rB, valC} = instr[8:79];
            valP = PC + 10;
        end

        4'h5:begin                       // mrmovq
            {rA, rB, valC} = instr[8:79];
            valP = PC + 10;
        end

        4'h6:begin                       // OPq
            {rA, rB} = instr[8:15];
            valP = PC + 2;
        end

        4'h7:begin                       //jxx
            valC = instr[8:71];
            valP = PC + 9;
        end

        4'h8:begin                       //call
            valC = instr[8:71];
            valP = PC + 9;
        end

        4'h9:                            //ret
            valP = PC + 1;

        4'hA:begin                       //pushq
            {rA, rB} = instr[8:15];
            valP = PC + 2;
        end

        4'hB:begin                       //popq
            {rA, rB} = instr[8:15];
            valP = PC + 2;
        end

        default:                         // invalid instruction
            instr_valid = 1'b0;
    endcase
    end

endmodule