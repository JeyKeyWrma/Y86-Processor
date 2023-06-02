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
`include "pc_update.v"

module processor;

    reg clk;
    reg [63:0] PC;
    wire [63:0] PC_next;
    reg [0:3] stat = 4'b1000;     // AOK, HLT, ADR, INS
    
    reg [2:0] CC_in;
    reg [0:79] instr;
    reg [7:0] instr_mem[20480:0];

    wire cnd;
    wire mem_error;
    wire [2:0] CC_out;
    wire instr_valid, imem_error;
    wire [3:0] icode, ifun, rA, rB;
    wire signed [63:0] valA, valB, valC, valE, valM;
    wire [63:0] valP;
    wire [63:0] reg_0, reg_1, reg_2, reg_3, reg_4, reg_5, reg_6, reg_7, reg_8, reg_9, reg_10, reg_11, reg_12, reg_13, reg_14;

    always@(instr_valid, imem_error, mem_error, icode) begin

        if(instr_valid==0)
        stat = 4'b0001;
        else if(imem_error==1)
        stat = 4'b0010;
        else if(mem_error==1)
        stat = 4'b0010;
        else if(icode==4'b0000)
        stat = 4'b0100;
        else
        stat = 4'b1000;

    end  

    always@(stat) begin
        if(stat==4'b0100) begin
        $display("Halting");
        $finish;
        end
        else if(stat==4'b0010) begin
        $display("Address Error");
        $finish;
        end
        else if(stat==4'b0001) begin
        $display("Instruction Error");
        $finish;
        end
    end
   
    always@(PC) begin
        
        instr = {
            instr_mem[PC],instr_mem[PC+1],instr_mem[PC+2],instr_mem[PC+3],instr_mem[PC+4],instr_mem[PC+5],instr_mem[PC+6],instr_mem[PC+7],instr_mem[PC+8],instr_mem[PC+9]
        };
    end

    always #10 clk = ~clk;

    always @* PC = PC_next;

    fetch fetch(.icode(icode), .ifun(ifun), .rA(rA), .rB(rB), .valC(valC), .valP(valP), .imem_error(imem_error), .instr_valid(instr_valid), .clk(clk), .PC(PC), .instr(instr));

    decode decode(.clk(clk), .icode(icode), .rA(rA), .rB(rB), .cnd(cnd), .valA(valA), .valB(valB), .valE(valE), .valM(valM),
                    .reg_0(reg_0), .reg_1(reg_1), .reg_2(reg_2), .reg_3(reg_3), .reg_4(reg_4), .reg_5(reg_5), .reg_6(reg_6), .reg_7(reg_7), .reg_8(reg_8), .reg_9(reg_9), .reg_10(reg_10), .reg_11(reg_11), .reg_12(reg_12), .reg_13(reg_13), .reg_14(reg_14));

    execute execute(.clk(clk),.valE(valE), .cnd(cnd), .CC_out(CC_out), .icode(icode), .ifun(ifun), .valA(valA), .valB(valB), .valC(valC), .CC_in(CC_in));

    always @(posedge clk) begin
        if(icode==6)CC_in = CC_out;
    end

    memory memory(.valM(valM), .mem_error(mem_error), .clk(clk), .icode(icode), .valE(valE), .valA(valA), .valP(valP));

    pc_update pc_update(.PC(PC_next), .clk(clk), .icode(icode), .cnd(cnd), .valC(valC), .valM(valM), .valP(valP));

    initial begin

    $monitor("clk=%d PC=%4d icode=%b ifun=%b cnd=%d CC_out=%b rA=%b rB=%b ,valA=%d,valB=%d, valP=%d, valE=%d, valC=%d, valM=%d\n", clk, PC, icode, ifun, cnd, CC_out, rA, rB, valA, valB, valP, valE, valC, valM);

    clk=1;
    PC=64'd0;

    //cmovxx
    instr_mem[0]=8'b00100000; //2 fn
    instr_mem[1]=8'b00010011; //rA rB

    //irmovq
      instr_mem[2]=8'b00110000; //3 0
      instr_mem[3]=8'b00000010; //F rB
      instr_mem[4]=8'b00000000; //V
      instr_mem[5]=8'b00000000; //V
      instr_mem[6]=8'b00000000; //V
      instr_mem[7]=8'b00000000; //V
      instr_mem[8]=8'b00000000; //V
      instr_mem[9]=8'b00000000; //V
      instr_mem[10]=8'b00000000; //V
      instr_mem[11]=8'b00010001; //V=17

    //rmmovq
      instr_mem[12]=8'b01000000; //4 0
      instr_mem[13]=8'b01010010; //rA rB
      instr_mem[14]=8'b00000000; //D
      instr_mem[15]=8'b00000000; //D
      instr_mem[16]=8'b00000000; //D
      instr_mem[17]=8'b00000000; //D
      instr_mem[18]=8'b00000000; //D
      instr_mem[19]=8'b00000000; //D
      instr_mem[20]=8'b00000000; //D
      instr_mem[21]=8'b00000001; //D

    //mrmovq
      instr_mem[22]=8'b01010000; //5 0
      instr_mem[23]=8'b00000111; //rA rB
      instr_mem[24]=8'b00000000; //D
      instr_mem[25]=8'b00000000; //D
      instr_mem[26]=8'b00000000; //D
      instr_mem[27]=8'b00000000; //D
      instr_mem[28]=8'b00000000; //D
      instr_mem[29]=8'b00000000; //D
      instr_mem[30]=8'b00000000; //D
      instr_mem[31]=8'b00000001; //D

    //OPq
        instr_mem[32]=8'b01100001; //6 fn
        instr_mem[33]=8'b00100011; //rA rB


    //cmovxx
        instr_mem[34]=8'b00100000; //2 fn
        instr_mem[35]=8'b00110100; //rA rB

        instr_mem[36]=8'b00100101; // 2 ge
        instr_mem[37]=8'b01010011; // rA rB

    //nop
        instr_mem[38]=8'b00010000; // 1 0

    //je
        instr_mem[39]=8'b01110011; // 7 je
        instr_mem[40]=8'b00000000; //D
        instr_mem[41]=8'b00000000; //D
        instr_mem[42]=8'b00000000; //D
        instr_mem[43]=8'b00000000; //D
        instr_mem[44]=8'b00000000; //D
        instr_mem[45]=8'b00000000; //D
        instr_mem[46]=8'b00000000; //D
        instr_mem[47]=8'd49; //D

    //halt
        instr_mem[48]=8'b00000000; // 0 0

    //pushq
        instr_mem[49]=8'b10100000; // 10 0
        instr_mem[50]=8'b10011111; // 9 F

    //popq
        instr_mem[51]=8'b10110000; // 10 0
        instr_mem[52]=8'b10011111; // 9 F

    //call
        instr_mem[53]=8'h80;
        instr_mem[54]=8'b00000000; //D
        instr_mem[55]=8'b00000000; //D
        instr_mem[56]=8'b00000000; //D
        instr_mem[57]=8'b00000000; //D
        instr_mem[58]=8'b00000000; //D
        instr_mem[59]=8'b00000000; //D
        instr_mem[60]=8'b00000000; //D
        instr_mem[61]=8'd62; //D

    //halt
        instr_mem[62]=8'b00000000; // 0 0

    end
endmodule