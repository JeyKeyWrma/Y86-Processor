`include "fetch.v"
`include "decode.v"

module decode_tb;

    reg clk;
    reg [63:0] PC;

    wire [3:0] icode, ifun, rA, rB;
    wire signed[63:0] valC;
    wire [63:0] valP;
    wire imem_error, instr_valid, halt;
    reg [7:0] instr_memory[0:255];      //memory that contains all the instructions
    reg [0:79] instr;                   //instruction with 10bytes
    wire signed [63:0] valA, valB, valE, valM;

    wire cnd = 1;
    wire signed[63:0] reg_0, reg_1, reg_2, reg_3, reg_4, reg_5, reg_6, reg_7, reg_8, reg_9, reg_10, reg_11, reg_12, reg_13, reg_14;

    fetch fetchc(.clk(clk), .icode(icode), .ifun(ifun), .rA(rA), .rB(rB), .valC(valC), .valP(valP), .PC(PC), .instr_valid(instr_valid), .imem_error(imem_error), .instr(instr), .halt_flag(halt));
    
    decode decodec(.clk(clk), .icode(icode), .rA(rA), .rB(rB), .reg_0(reg_0), .reg_1(reg_1), .reg_2(reg_2), .reg_3(reg_3), .reg_4(reg_4), .reg_5(reg_5), .reg_6(reg_6), .reg_7(reg_7), .reg_8(reg_8), .reg_9(reg_9), .reg_10(reg_10), .reg_11(reg_11), .reg_12(reg_12), .reg_13(reg_13), .reg_14(reg_14), .valA(valA), .valB(valB), .cnd(cnd), .valM(valM), .valE(valE));
    
    always @(icode) begin
        if(icode == 0 && ifun == 0) 
            $finish;
    end

    always @(PC) begin
        instr = {instr_memory[PC],instr_memory[PC+1],instr_memory[PC+2],instr_memory[PC+3],instr_memory[PC+4],instr_memory[PC+5],instr_memory[PC+6],instr_memory[PC+7],instr_memory[PC+8],instr_memory[PC+9]};  
    end

    always@(icode) begin 
        if(halt == 1)begin
            $finish;
        end
    end

    always@(imem_error) begin 
        if(imem_error == 1)begin
            $display("Memory Full!\n");
            $finish;
        end
    end
    
    always@(instr_valid) begin 
        if(instr_valid == 0)begin
            $display("Invald Instruction\nPC = %d", PC+1, "\n");
            PC = PC + 1;
        end
    end

    always #10 begin 
        clk = ~clk;
    end

    always @(posedge clk) begin 
        PC <= valP; 
    end

    initial begin
        $dumpfile("decode_tb.vcd");
        $dumpvars(0, decode_tb);
        clk = 0;
        PC = 64'd02;

    end

    always @(posedge clk) begin 
        $display("clk=%d icode=%h ifun=%h rA=%d rB=%d, valC=%15d, valP=%15d, valA = %15d and valB = %15d\n", clk, icode, ifun, rA, rB, valC, valP, valA, valB); 
    end

    initial begin

        instr_memory[2]  = 8'h10; //nop 

        instr_memory[3]  = 8'h20; //rrmovq
        instr_memory[4]  = 8'h01; //ra = 0 and rb =1 

        instr_memory[5]  = 8'h60; //opq add
        instr_memory[6]  = 8'h23; //ra and rb

        instr_memory[7]  = 8'h80; //call
        instr_memory[8]  = 8'h00; //8byte destination
        instr_memory[9]  = 8'h00;
        instr_memory[10]  = 8'h00;
        instr_memory[11]  = 8'h10;
        instr_memory[12]  = 8'h00;
        instr_memory[13]  = 8'h00;
        instr_memory[14]  = 8'h00;
        instr_memory[15]  = 8'h01; //pc        

        instr_memory[16]  = 8'h60; //opq add
        instr_memory[17]  = 8'h9A; //ra and rb

        instr_memory[18]  = 8'h60; //opq add
        instr_memory[19]  = 8'h56;

        instr_memory[20]  = 8'h80; //call
        instr_memory[21]  = 8'h00; //8byte destination
        instr_memory[22]  = 8'h00;
        instr_memory[23]  = 8'h00;
        instr_memory[24]  = 8'h10;
        instr_memory[25]  = 8'h00;
        instr_memory[26]  = 8'h00;
        instr_memory[27]  = 8'h11;
        instr_memory[28]  = 8'h01; //pc
        
        instr_memory[29]  = 8'h00; //halt
        
    end
    
endmodule