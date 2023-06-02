`include "fetch.v"

module fetch_tb;

    reg clk;
    reg [63:0] PC;
    
    wire [3:0] icode, ifun, rA, rB;
    wire [63:0] valC, valP;
    wire imem_error, instr_valid, halt_flag;
    reg [7:0] instr_mem[0:255];
    reg [0:79] instr;

    fetch fetch(
        .icode(icode),
        .ifun(ifun),
        .rA(rA),
        .rB(rB),
        .valC(valC),
        .valP(valP),
        .clk(clk),
        .PC(PC),
        .imem_error(imem_error),
        .instr_valid(instr_valid),
        .instr(instr),
        .halt_flag(halt_flag)
    );
    
    always@(PC) begin        
        instr={instr_mem[PC],instr_mem[PC+1],instr_mem[PC+2],instr_mem[PC+3],instr_mem[PC+4],instr_mem[PC+5],instr_mem[PC+6],instr_mem[PC+7],instr_mem[PC+8],instr_mem[PC+9]};
    end

    always @(icode) begin
        if(icode == 0 && ifun == 0) 
            $finish;
    end

    always@(imem_error) begin 
        if(imem_error == 1)begin
            $finish;
    end
    end

    always@(instr_valid) begin 
        if(instr_valid == 0)begin
            PC = PC + 1;
        end
    end

    always #10 clk = ~clk;
    always @(posedge clk) PC <= valP;

    initial begin
        $dumpfile("fetch_tb.vcd");
        $dumpvars(0, fetch_tb);
        clk = 0;
        PC = 64'd00;
    end

    initial begin

        instr_mem[0]  = 8'h10; //nop pc = 1

        instr_mem[1]  = 8'h20; //rrmovq
        instr_mem[2]  = 8'h01; //ra = 0 and rb =1 and pc = pc + 2 = 3

        instr_mem[3]  = 8'h30; //irmovq
        instr_mem[4]  = 8'h02; //F and rb = 2
        instr_mem[5]  = 8'h00; //8bytes
        instr_mem[6]  = 8'h00;
        instr_mem[7]  = 8'h00;
        instr_mem[8]  = 8'h00;
        instr_mem[9]  = 8'h00;
        instr_mem[10]  = 8'h00;
        instr_mem[11]  = 8'h00;
        instr_mem[12]  = 8'h01; //pc = pc +10 = 13

        instr_mem[13]  = 8'h60; //opq add
        instr_mem[14]  = 8'h23; //ra and rb pc = pc +2  = 15   

        instr_mem[15]  = 8'h70; //jmp
        instr_mem[16]  = 8'h00; //8bytes address
        instr_mem[17]  = 8'h00;
        instr_mem[18]  = 8'h00;
        instr_mem[19]  = 8'h00;
        instr_mem[20]  = 8'h00;
        instr_mem[21]  = 8'h00;
        instr_mem[22]  = 8'h11;
        instr_mem[23]  = 8'h10; //pc = pc+9 = 24

        instr_mem[24]  = 8'h80; //call
        instr_mem[25]  = 8'h00;//8byte destination
        instr_mem[26]  = 8'h00;
        instr_mem[27]  = 8'h00;
        instr_mem[28]  = 8'h10;
        instr_mem[29]  = 8'h00;
        instr_mem[30]  = 8'h10;
        instr_mem[31]  = 8'h00;
        instr_mem[32]  = 8'h00; //pc = pc+9 = 33
        
        instr_mem[33]  = 8'h90;//return and pc = pc+1 = 34; 
        
        instr_mem[34]  = 8'hA0; //pushq
        instr_mem[35]  = 8'h30; //ra and rb pc = pc+2 = 36

        instr_mem[36]  = 8'hB0; //popq
        instr_mem[37]  = 8'h30; //ra and rb pc = pc+2 = 38

        instr_mem[38]  = 8'hC0; //invalid instruction

        instr_mem[39]  = 8'h00; //halt
        
    end
    initial 
        $monitor("clk = %d, PC = %3d, icode = %b, ifun = %b, rA = %b, rB = %b, valC = %3d, valP = %3d\n", clk, PC, icode, ifun, rA, rB, valC, valP);
endmodule