`include "fetch.v"
`include "decode.v"
`include "execute.v"
`include "../AL_Unit/ALU/alu.v"
`include "../AL_Unit/ADD/add_64bit.v"
`include "../AL_Unit/ADD/add_1bit.v"
`include "../AL_Unit/SUB/sub_64bit.v"
`include "../AL_Unit/XOR/xor_64bit.v"
`include "../AL_Unit/AND/and_64bit.v"


module execute_tb;

    reg clk;
    reg [63:0] PC;
    wire [3:0] icode, ifun, rA, rB;
    wire signed [63:0] valA, valB, valC, valE, valM;
    wire  [63:0] valP;
    wire halt_flag, instr_valid, cnd; 
    reg [7:0] instruction_memory[0:20480];
    reg [0:79] instruction;
    reg [2:0] CC_in;
    wire zeroflag, signflag, overflow;
    wire signed [63:0] reg_0, reg_1, reg_2, reg_3, reg_4, reg_5, reg_6, reg_7, reg_8, reg_9, reg_10, reg_11, reg_12, reg_13, reg_14; 
    wire [2:0] CC_out;

    fetch fetch(.icode(icode), .ifun(ifun), .rA(rA), .rB(rB), .valC(valC), .valP(valP), .imem_error(imem_error), .instr_valid(instr_valid), .clk(clk), .PC(PC), .halt_flag(halt_flag), .instr(instruction)) ;
    decode decodec(.clk(clk), .icode(icode), .rA(rA), .rB(rB), .reg_0(reg_0), .reg_1(reg_1), .reg_2(reg_2), .reg_3(reg_3), .reg_4(reg_4), .reg_5(reg_5), .reg_6(reg_6), .reg_7(reg_7), .reg_8(reg_8), .reg_9(reg_9), .reg_10(reg_10), .reg_11(reg_11), .reg_12(reg_12), .reg_13(reg_13), .reg_14(reg_14), .valA(valA), .valB(valB), .cnd(cnd), .valM(valM), .valE(valE));
    execute execute(.icode(icode), .ifun(ifun), .valA(valA), .valB(valB), .valC(valC), .valE(valE), .cnd(cnd), .CC_in(CC_in), .CC_out(CC_out));

    always@(PC) begin
        instruction = {
            instruction_memory[PC],instruction_memory[PC+1],instruction_memory[PC+2],instruction_memory[PC+3],instruction_memory[PC+4],instruction_memory[PC+5],instruction_memory[PC+6],instruction_memory[PC+7],instruction_memory[PC+8],instruction_memory[PC+9]
        };
    end

    always@(icode) begin 
        if(halt_flag == 1)begin
            $display("halt...\n");
            $finish;
        end
    end

    always@(imem_error) begin 
        if(imem_error == 1)begin
            $display("PC limit exceded\n");
            $finish;
        end
    end

    always@(instr_valid) begin 
        if(instr_valid == 0) begin
            $display("Invald Instruction\n");
            PC = PC + 1;
        end
    end

    always @(posedge clk) begin
        if(icode==6)CC_in = CC_out;
    end

    always #10
        begin 
            clk = ~clk;
        end

    always @(posedge clk) 
        begin 
            PC <= valP; 
        end

    initial begin
        $dumpfile("execute_tb.vcd");
        $dumpvars(0, execute_tb);
        clk = 0;
        PC = 64'd0;

    end

    always @(posedge clk)
        begin 
            $display("clk=%d, icode=%h, ifun=%h, rA=%d, rB=%d, valC=%d, valP=%d, valA = %d, valB = %d, valE = %d", clk, icode, ifun, rA, rB, valC, valP, valA, valB, valE); 
        end

    initial begin

    instruction_memory[0]  = 8'h10; //nop pc = 1

    instruction_memory[1] = 8'h20; //rrmovq
    instruction_memory[2]  = 8'h01; //ra = 0 and rb =1 and pc = pc + 2 = 3

    instruction_memory[3]  = 8'h30; //irmovq
    instruction_memory[4]  = 8'h02; //F and rb = 2
    instruction_memory[5]  = 8'hFF; //8bytes
    instruction_memory[6]  = 8'hFF;
    instruction_memory[7]  = 8'hFF;
    instruction_memory[8]  = 8'hFF;
    instruction_memory[9]  = 8'hFF;
    instruction_memory[10]  = 8'hFF;
    instruction_memory[11]  = 8'hFF;
    instruction_memory[12]  = 8'hFF; //pc = pc +10 = 13

    instruction_memory[13]  = 8'h60; //opq add
    instruction_memory[14]  = 8'h23; //ra and rb pc = pc +2  = 15   

    instruction_memory[15]  = 8'h70; //jmp
    instruction_memory[16]  = 8'h00; //8bytes address
    instruction_memory[17]  = 8'h00;
    instruction_memory[18]  = 8'h00;
    instruction_memory[19]  = 8'h00;
    instruction_memory[20]  = 8'h00;
    instruction_memory[21]  = 8'h00;
    instruction_memory[22]  = 8'h11;
    instruction_memory[23]  = 8'h10; //pc = pc+9 = 24

    instruction_memory[24]  = 8'h80; //call
    instruction_memory[25]  = 8'h00;//8byte destination
    instruction_memory[26]  = 8'h00;
    instruction_memory[27]  = 8'h00;
    instruction_memory[28]  = 8'h10;
    instruction_memory[29]  = 8'h00;
    instruction_memory[30]  = 8'h00;
    instruction_memory[31]  = 8'h00;
    instruction_memory[32]  = 8'h01; //pc = pc+9 = 33
    
    instruction_memory[33]  = 8'h90;//return and pc = pc+1 = 34; 
    
    instruction_memory[34]  = 8'hA0; //pushq
    instruction_memory[35]  = 8'h30; //ra and rb pc = pc+2 = 36

    instruction_memory[36]  = 8'hB0; //popq
    instruction_memory[37]  = 8'h30; //ra and rb pc = pc+2 = 38

    instruction_memory[38]  = 8'h10; //invalid instruction

    instruction_memory[39]  = 8'hB0; //popq
    instruction_memory[40]  = 8'h30; //ra and rb pc = pc+2 = 38

    
    instruction_memory[41]  = 8'h61; //opq sub
    instruction_memory[42]  = 8'h9A; //ra and rb pc = pc +2  = 15

    instruction_memory[43]  = 8'h63; //opq add
    instruction_memory[44]  = 8'h56;

    instruction_memory[45]  = 8'h00; //halt
    
    end    

endmodule