`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: USTC ESLAB 
// Engineer: Wu Yuzhang
// 
// Design Name: RISCV-Pipline CPU
// Module Name: ControlUnit
// Target Devices: Nexys4
// Tool Versions: Vivado 2017.4.1
// Description: RISC-V Instruction Decoder
//////////////////////////////////////////////////////////////////////////////////
//功能和接口说明
    //ControlUnit       是本CPU的指令译码器，组合逻辑电路
//输入
    // Op               是指令的操作码部分
    // Fn3              是指令的func3部分
    // Fn7              是指令的func7部分
//输出
    // JalD==1          表示Jal指令到达ID译码阶段
    // JalrD==1         表示Jalr指令到达ID译码阶段
    // RegWriteD        表示ID阶段的指令对应的寄存器写入模式
    // MemToRegD==1     表示ID阶段的指令需要将data memory读取的值写入寄存器,
    // MemWriteD        共4bit，为1的部分表示有效，对于data memory的32bit字按byte进行写入,MemWriteD=0001表示只写入最低1个byte，和xilinx bram的接口类似
    // LoadNpcD==1      表示将NextPC输出到ResultM
    // RegReadD         表示A1和A2对应的寄存器值是否被使用到了，用于forward的处理
    // BranchTypeD      表示不同的分支类型，所有类型定义在Parameters.v中
    // AluContrlD       表示不同的ALU计算功能，所有类型定义在Parameters.v中
    // AluSrc2D         表示Alu输入源2的选择
    // AluSrc1D         表示Alu输入源1的选择
    // ImmType          表示指令的立即数格式
//实验要求  
    //补全模块  

`include "Parameters.v"   
module ControlUnit(
    input wire [6:0] Op,
    input wire [2:0] Fn3,
    input wire [6:0] Fn7,
    output wire JalD,
    output wire JalrD,
    output reg [2:0] RegWriteD,
    output wire MemToRegD,
    output reg [3:0] MemWriteD,
    output wire LoadNpcD,
    output reg [1:0] RegReadD,
    output reg [2:0] BranchTypeD,
    output reg [3:0] AluContrlD,
    output wire [1:0] AluSrc2D,
    output wire AluSrc1D,
    output reg [2:0] ImmType        
    ); 
    
    // 请补全此处代码
    always@(*)
        begin
            if(Op == U_LUI)
                begin
                    JalD = 0;
                    JalrD = 0;
                    RegWriteD = `WB;
                    MemToRegD = 0;
                    MemWriteD = 4'b0000;
                    LoadNpcD = 0;
                    RegReadD = 2'b00;
                    BranchTypeD = `U_LUI;
                    AluContrlD = `LUI;
                    AluSrc1D = 0;
                    AluSrc2D = 2'b10;
                    ImmType = `UTYPE;
                end
            else if(Op == U_AUIPC)
                begin
                    JalD = 0;
                    JalrD = 0;
                    RegWriteD = `WB;
                    MemToRegD = 0;
                    MemWriteD = 4'b0000;
                    LoadNpcD = 0;
                    RegReadD = 2'b00;
                    BranchTypeD = `U_AUIPC;
                    AluContrlD = `AUIPC;
                    AluSrc1D = 1'b1;
                    AluSrc2D = 2'b10;
                    ImmType = `UTYPE;
                end
            else if(Op == J_JAL)
                begin
                    JalD = 1;
                    JalrD = 0;
                    RegWriteD = `NOREGWRITE;
                    MemToRegD = 0;
                    MemWriteD = 4'b0000;
                    LoadNpcD = 1;
                    RegReadD = 2'b00;
                    BranchTypeD = `JAL;
                    AluContrlD = `Jal;
                    AluSrc1D = 1'b1;
                    AluSrc2D = 2'b11;
                    ImmType = `JTYPE;
                end
            else if(Op == J_JALR)
                begin 
                    JalD = 0;
                    JalrD = 1;
                    RegWrite = `NOREGWRITE;
                    MemToRegD = 0;
                    MemWriteD = 4'b0000;
                    LoadNpcD = 1;
                    RegReadD = 2'b10; //读取rs1
                    BranchTypeD = `JALR;
                    AluContrlD = `JALR;
                    AluSrc1D = 1'b0;
                    AluSrc2D = 2'b10;
                    ImmType = `ITYPE;
                end
            else if(Op == `B_TYPE)
            begin
                JalD = 0;
                JalrD = 0;
                RegWrite = `NOREGWRITE;
                MemToRegD = 0;
                MemWriteD = 4'b0000;
                LoadNpcD = 0;
                RegReadD = 2'b11; //  读取rs1,rs2
                AluSrc1D = 0;
                AluSrc2D = 2'b00; 
                ImmType = `BTYPE;
                case(Fn3)
                    `B_BEQ: BranchTypeD = `BEQ;
                    `B_BNE: BranchTypeD = `BNE;
                    `B_BLT: BranchTypeD = `BLT;
                    `B_BGE: BranchTypeD = `BGE;
                    `B_BLTU: BranchTypeD = `BLTU;
                    `B_BGEU: BranchTypeD = `BGEU;
                    default: BranchTypeD =  `NOBRANCH;
                endcase
            end
            else if(Op == `I_LOAD)
            begin
                JalD = 0;
                JalrD = 0;
                MemToRegD = 1;
                MemWriteD = 4'b0000;
                LoadNpcD = 0;
                RegReadD = 2'b10; //读取rs1
                AluSrc1D = 0;
                AluSrc2D = 2'b10;
                BranchTypeD = `NOBRANCH;
                ImmType = `ITYPE;
                case(Fn3)
                    `I_LB: RegWriteD = `LB;
                    `I_LH: RegWriteD = `LH;
                    `I_LW: RegWriteD = `LW;
                    `I_LBU: RegWriteD = `LBU;
                    `I_LHU: RegWriteD = `LHU;
                    default: RegWriteD = `NOREGWRITE,
                endcase
            end
            else if(Op == `I_ARI)
                begin
                    JalD = 0;
                    JalrD = 0;
                    MemToRegD = 0;
                    MemWriteD = 4'b0000;
                    RegWriteD = `WB;
                    LoadNpcD = 0;
                    RegReadD = 2'b10; //读取rs1
                    AluSrc1D = 0;
                    AluSrc2D = 2'b10;
                    BranchTypeD = `NOBRANCH;
                    ImmType = `ITYPE;
                    case(Fn3)
                        `I_ADDI:AluContrlD = `ADD;
                        `I_SLTI:AluContrlD = `SLT;
                        `I_SLTIU:AluContrlD = `SLTU;
                        `I_XORI:AluContrlD = `XOR;
                        `I_ORI: AluContrlD = `OR;
                        `I_ANDI:AluContrlD = `AND;
                        `I_SLLI:AluContrlD = `SLL;
                        `I_SR:begin
                                if(Fn7 == `I_SRAI)
                                    AluContrlD = `SRA;
                                else if(Fn7 == `I_SRLI)
                                    AluContrlD = `SRL;
                                else 
                                    RegWriteD = `NOREGWRITE;
                                end
                        default: AluContrlD = 4'd11;
                    endcase
                end
            else if(Op == `S_TYPE)
                begin
                    JalD = 0;
                    JalrD = 0;
                    MemToRegD = 0;
                    RegWriteD = `NOREGWRITE;
                    LoadNpcD = 0;
                    RegReadD = 2'b01;  //读取rs2
                    AluSrc1D = 0;
                    AluSrc2D = 2'b00;
                    BranchTypeD = `NOBRANCH;
                    ImmType = `STYPE;
                    AluContrlD = `LUI;
                    case(Fn3)
                        `S_SB:MemWriteD = 4'b0001;
                        `S_SH:MemWriteD = 4'b0011;
                        `S_SW:MemWriteD = 4'b1111;
                        default: MemWriteD = 4'b0000;
                    endcase
                end
            else if(Op == `R_TYPE)
                begin 
                    Jal = 0;
                    JalrD = 0;
                    MemToRegD = 0;
                    MemWriteD = 4'b0000;
                    RegWriteD = `WB;
                    LoadNpcD = 0;
                    RegReadD = 2'b11;
                    AluSrc1D = 0;
                    AluSrc2D = 2'b00;
                    BranchTypeD = `NOBRANCH;
                    ImmType = `RTYPE;
                    if(Fn3 == `R_AS)
                    begin
                        if(Fn7 == R_ADD)
                        begin 
                            AluContrlD = `ADD;
                        end
                        else if(Fn7 == R_SUB)
                        begin 
                            AluContrlD = `SUB;
                        end
                        else
                        begin 
                            AluContrlD = 0;
                            RegWriteD = `NOREGWRITE;
                        end
                    end
                    else if(Fn3 == `R_SLL)
                        begin
                            AluContrlD = `SLL;
                        end
                    else if(Fn3 == `R_SLT)
                        begin
                            AluContrlD = `SLT;
                        end
                    else if(Fn3 == `R_SLTU)
                        begin
                            AluContrlD = `SLTU;
                        end
                    else if(Fn3 == `R_XOR)
                        begin
                            AluContrlD = `XOR;
                        end
                    else if(Fn3 == `R_SR)
                        begin
                            if(Fn7 == `R_SRL)
                                begin
                                    AluContrlD = `SRL;
                                end
                            else if(Fn7 == `R_SRA)
                                begin
                                    AluContrlD = `SRA;
                                end
                            else
                                begin
                                    AluContrlD = 0;
                                    RegWriteD = `NOREGWRITE;
                                end
                        end
                    else if(Fn3 == `R_OR)
                        begin
                            AluContrlD = `OR;
                        end
                    else if(Fn3 == `R_AND)
                        begin
                            AluContrlD = `AND;
                        end
                    else
                        begin
                          AluSrc1D = 0;
                          RegWriteD = `NOREGWRITE;
                        end
                end
            
        end

endmodule

