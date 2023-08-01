/*                                                                      
 Copyright 2018-2020 Nuclei System Technology, Inc.                
                                                                         
 Licensed under the Apache License, Version 2.0 (the "License");         
 you may not use this file except in compliance with the License.        
 You may obtain a copy of the License at                                 
                                                                         

     http://www.apache.org/licenses/LICENSE-2.0                          

  Unless required by applicable law or agreed to in writing, software    
 distributed under the License is distributed on an "AS IS" BASIS,       
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and     
 limitations under the License.                                          
 */

//=====================================================================
//
// Designer   : LZB
//
// Description:
//  The Module to realize a simple NICE core
//
// ====================================================================
`include "e203_defines.v"

`ifdef E203_HAS_NICE//{
module e203_subsys_nice_core (
    // System	
    input                         nice_clk             ,
    input                         nice_rst_n	          ,
    output                        nice_active	      ,
    output                        nice_mem_holdup	  ,
//    output                        nice_rsp_err_irq	  ,
    // Control cmd_req
    input                         nice_req_valid       ,
    output                        nice_req_ready       ,
    input  [`E203_XLEN-1:0]       nice_req_inst        ,
    input  [`E203_XLEN-1:0]       nice_req_rs1         ,
    input  [`E203_XLEN-1:0]       nice_req_rs2         ,
    // Control cmd_rsp	
    output                        nice_rsp_valid       ,
    input                         nice_rsp_ready       ,
    output [`E203_XLEN-1:0]       nice_rsp_rdat        ,
    output                        nice_rsp_err    	  ,
    // Memory lsu_req	
    output                        nice_icb_cmd_valid   ,
    input                         nice_icb_cmd_ready   ,
    output [`E203_ADDR_SIZE-1:0]  nice_icb_cmd_addr    ,
    output                        nice_icb_cmd_read    ,
    output [`E203_XLEN-1:0]       nice_icb_cmd_wdata   ,
//    output [`E203_XLEN_MW-1:0]     nice_icb_cmd_wmask   ,  // 
    output [1:0]                  nice_icb_cmd_size    ,
    // Memory lsu_rsp	
    input                         nice_icb_rsp_valid   ,
    output                        nice_icb_rsp_ready   ,
    input  [`E203_XLEN-1:0]       nice_icb_rsp_rdata   ,
    input                         nice_icb_rsp_err	

);
   localparam PIPE_NUM = 3;


// here we only use custom3: 
// CUSTOM0 = 7'h0b, R type
// CUSTOM1 = 7'h2b, R tpye
// CUSTOM2 = 7'h5b, R type
// CUSTOM3 = 7'h7b, R type

// RISC-V format  
//	.insn r  0x33,  0,  0, a0, a1, a2       0:  00c58533[ 	]+add [ 	]+a0,a1,a2
//	.insn i  0x13,  0, a0, a1, 13           4:  00d58513[ 	]+addi[ 	]+a0,a1,13
//	.insn i  0x67,  0, a0, 10(a1)           8:  00a58567[ 	]+jalr[ 	]+a0,10 (a1)
//	.insn s   0x3,  0, a0, 4(a1)            c:  00458503[ 	]+lb  [ 	]+a0,4(a1)
//	.insn sb 0x63,  0, a0, a1, target       10: feb508e3[ 	]+beq [ 	]+a0,a1,0 target
//	.insn sb 0x23,  0, a0, 4(a1)            14: 00a58223[ 	]+sb  [ 	]+a0,4(a1)
//	.insn u  0x37, a0, 0xfff                18: 00fff537[ 	]+lui [ 	]+a0,0xfff
//	.insn uj 0x6f, a0, target               1c: fe5ff56f[ 	]+jal [ 	]+a0,0 target
//	.insn ci 0x1, 0x0, a0, 4                20: 0511    [ 	]+addi[ 	]+a0,a0,4
//	.insn cr 0x2, 0x8, a0, a1               22: 852e    [ 	]+mv  [ 	]+a0,a1
//	.insn ciw 0x0, 0x0, a1, 1               24: 002c    [ 	]+addi[ 	]+a1,sp,8
//	.insn cb 0x1, 0x6, a1, target           26: dde9    [ 	]+beqz[ 	]+a1,0 target
//	.insn cj 0x1, 0x5, target               28: bfe1    [ 	]+j   [ 	]+0 targe

   ////////////////////////////////////////////////////////////
   // decode
   ////////////////////////////////////////////////////////////
   wire [6:0] opcode      = {7{nice_req_valid}} & nice_req_inst[6:0];
   wire [2:0] rv32_func3  = {3{nice_req_valid}} & nice_req_inst[14:12];
   wire [6:0] rv32_func7  = {7{nice_req_valid}} & nice_req_inst[31:25];

   wire opcode_custom0 = (opcode == 7'b0001011); 
//   wire opcode_custom1 = (opcode == 7'b0101011); 
//   wire opcode_custom2 = (opcode == 7'b1011011); 
   wire opcode_custom3 = (opcode == 7'b1111011); 

   wire rv32_func3_000 = (rv32_func3 == 3'b000); 
   wire rv32_func3_001 = (rv32_func3 == 3'b001); 
   wire rv32_func3_010 = (rv32_func3 == 3'b010); 
   wire rv32_func3_011 = (rv32_func3 == 3'b011); 
   wire rv32_func3_100 = (rv32_func3 == 3'b100); 
   wire rv32_func3_101 = (rv32_func3 == 3'b101); 
   wire rv32_func3_110 = (rv32_func3 == 3'b110); 
   wire rv32_func3_111 = (rv32_func3 == 3'b111); 

   wire rv32_func7_0000000 = (rv32_func7 == 7'b0000000); 
   wire rv32_func7_0000001 = (rv32_func7 == 7'b0000001); 
   wire rv32_func7_0000010 = (rv32_func7 == 7'b0000010); 
   wire rv32_func7_0000011 = (rv32_func7 == 7'b0000011); 
   wire rv32_func7_0000100 = (rv32_func7 == 7'b0000100); 
   wire rv32_func7_0000101 = (rv32_func7 == 7'b0000101); 
   wire rv32_func7_0000110 = (rv32_func7 == 7'b0000110); 
   wire rv32_func7_0000111 = (rv32_func7 == 7'b0000111);
   wire rv32_func7_0001000 = (rv32_func7 == 7'b0001000);  
  

   ////////////////////////////////////////////////////////////
   // custom3:
   // Supported format: only R type here
   // Supported instr:
   //  1. custom3 lbuf: load data(in memory) to row_buf
   //     lbuf (a1)
   //     .insn r opcode, func3, func7, rd, rs1, rs2    
   //  2. custom3 sbuf: store data(in row_buf) to memory
   //     sbuf (a1)
   //     .insn r opcode, func3, func7, rd, rs1, rs2    
   //  3. custom3 acc rowsum: load data from memory(@a1), accumulate row datas and write back 
   //     rowsum rd, a1, x0
   //     .insn r opcode, func3, func7, rd, rs1, rs2    
    //  4. custom3 acc rowmult: load data from memory(@a1), accumulate row datas and write back 
   //     rowsum rd, a1, x0
   //     .insn r opcode, func3, func7, rd, rs1, rs2    
   ////////////////////////////////////////////////////////////


   wire custom3_jlsd     = opcode_custom3 & rv32_func3_010 & rv32_func7_0000000; //从rs1地址中加载图像数据
   wire custom3_fconv    = opcode_custom3 & rv32_func3_010 & rv32_func7_0000001; //从rs1地址中加载卷积核参数，第一个数为偏置参数
   wire custom3_sconv    = opcode_custom3 & rv32_func3_010 & rv32_func7_0000010; //第二层卷积跟第一层一样
   wire custom3_jact     = opcode_custom3 & rv32_func3_011 & rv32_func7_0000110;//激活函数 rs1 :源值  rd:存储的地方
   wire custom3_jconv    = opcode_custom3 & rv32_func3_001 & rv32_func7_0000111;//卷积类型
   ////////////////////////////////////////////////////////////
   //  mult-cyc op 
   ////////////////////////////////////////////////////////////
   wire custom_mult_cyc_op = custom3_jlsd | custom3_fconv | custom3_sconv | custom3_jact| custom3_jconv;
   // need access memory
   wire custom_mem_op =  custom3_jlsd | custom3_fconv | custom3_sconv  |custom3_jlweight|custom3_jconv;


   ////////////////////////////////////////////////////////////
   // NICE FSM 
   ////////////////////////////////////////////////////////////
   parameter NICE_FSM_WIDTH = 4; 
   parameter IDLE     = 4'd0; 
   parameter JLSD     = 4'd1; 
   parameter FCONV     = 4'd2; 
   parameter JACT  = 4'd3;
   parameter JCONV   = 4'd4;   
   
   wire [NICE_FSM_WIDTH-1:0] state_r; 
   wire [NICE_FSM_WIDTH-1:0] nxt_state; 
   wire [NICE_FSM_WIDTH-1:0] state_idle_nxt; 
   wire [NICE_FSM_WIDTH-1:0] state_jlsd_nxt; 
   wire [NICE_FSM_WIDTH-1:0] state_fconv_nxt;
   wire [NICE_FSM_WIDTH-1:0] state_sconv_nxt; 
   wire [NICE_FSM_WIDTH-1:0] state_jact_nxt;
//   wire [NICE_FSM_WIDTH-1:0] state_sconv_nxt;
   wire [NICE_FSM_WIDTH-1:0] state_jact_nxt ;
   wire [NICE_FSM_WIDTH-1:0] state_jconv_nxt;
     

   wire nice_req_hsked;
   wire nice_rsp_hsked;
   wire nice_icb_rsp_hsked;
   assign nice_rsp_hsked = nice_rsp_valid & nice_rsp_ready; 
   assign nice_icb_rsp_hsked = nice_icb_rsp_valid & nice_icb_rsp_ready;
   wire illgel_instr = ~(custom_mult_cyc_op);

   wire state_idle_exit_ena; 
   wire state_jlsd_exit_ena; 
   wire state_fconv_exit_ena;
   wire state_jact_exit_ena; 
   wire state_sconv_exit_ena;
   wire state_jconv_exit_ena;

   
 
   wire state_ena; 

   wire state_is_idle     = (state_r == IDLE); 
   wire state_is_jlsd    = (state_r == JLSD); 
   wire state_is_fconv     = (state_r == FCONV); 
   wire state_is_sconv   = (state_r == SCONV);
   wire state_is_jact  = (state_r == JACT); 
   wire state_is_jconv      = (state_r == JCONV);  


   assign state_idle_exit_ena = state_is_idle & nice_req_hsked & ~illgel_instr; 
   assign state_idle_nxt =  custom3_jlsd    ? JLSD   : 
                            custom3_fconv    ? FCONV   :
                            custom3_sconv  ? SCONV :
                            custom3_jact  ? JACT :
                            custom3_jconv  ? JCONV :
			    IDLE;

   wire   jlsd_icb_rsp_hsked_last; 
   wire   fconv_icb_rsp_hsked_last;
   wire   sconv_icb_rsp_hsked_last;
   wire   jact_icb_rsp_hsked_last;//
   wire  act_done;
   wire  jconv_done;
   assign state_jlsd_exit_ena = state_is_jlsd & jlsd_icb_rsp_hsked_last; 
   assign state_fconv_exit_ena = state_is_fconv & fconv_icb_rsp_hsked_last;
   assign state_sconv_exit_ena = state_is_sconv & sconv_icb_rsp_hsked_last;
   assign state_jact_exit_ena = state_is_jact & act_done;
   assign state_jconv_exit_ena = state_is_jconv & conv_done;
   assign state_jlsd_nxt = IDLE;
   assign state_fconv_nxt = IDLE;
   assign state_sconv_nxt = IDLE ;
   assign state_jact_nxt = IDLE;
   assign state_jconv_nxt = IDLE;



/////////////////////////////////////////////////////////////////////////////////////////
   assign nxt_state =   ({NICE_FSM_WIDTH{state_idle_exit_ena   }} & state_idle_nxt   )
                      | ({NICE_FSM_WIDTH{state_jlsd_exit_ena   }} & state_jlsd_nxt   ) 
                      | ({NICE_FSM_WIDTH{state_fconv_exit_ena   }} & state_fconv_nxt   )
                      | ({NICE_FSM_WIDTH{state_sconv_exit_ena   }} & state_sconv_nxt   )
                      | ({NICE_FSM_WIDTH{state_jact_exit_ena   }} & state_jact_nxt   )  
                      | ({NICE_FSM_WIDTH{state_jconv_exit_ena   }} & state_jconv_nxt   )             
                      ;

   assign state_ena =   state_idle_exit_ena | state_jlsd_exit_ena|state_fconv_exit_ena|state_jact_exit_ena|state_jconv_exit_ena;

   sirv_gnrl_dfflr #(NICE_FSM_WIDTH)   state_dfflr (state_ena, nxt_state, state_r, nice_clk, nice_rst_n);
 
   ////////////////////////////////////////////////////////////
   // instr EXU
   ////////////////////////////////////////////////////////////
   parameter P_LENGTH=256;
   parameter P_WIDTH =256;
   parameter data_num = P_LENGTH*P_WIDTH;
   //////////// 1.   jlsd
   wire [`E203_XLEN-1:0] jlsd_cnt_r;   //32位存储器计数器      map:256*256       
   wire [`E203_XLEN-1:0] jlsd_cnt_nxt; 
   wire jlsd_cnt_clr;
   wire jlsd_cnt_incr;
   wire jlsd_cnt_ena;
   wire jlsd_cnt_last;
   wire jlsd_icb_rsp_hsked;
   wire nice_rsp_valid_jlsd;
   wire nice_icb_cmd_valid_jlsd;
   
   assign jlsd_icb_rsp_hsked = state_is_jlsd & nice_icb_rsp_hsked;
   assign jlsd_icb_rsp_hsked_last = jlsd_icb_rsp_hsked & jlsd_cnt_last;
   assign jlsd_cnt_last = (lbuf_cnt_r == data_num);
   assign jlsd_cnt_clr = custom3_jlsd & nice_req_hsked;
   assign jlsd_cnt_incr = jlsd_icb_rsp_hsked & ~jlsd_cnt_last;
   assign jlsd_cnt_ena = jlsd_cnt_clr | jlsd_cnt_incr;
   assign jlsd_cnt_nxt =   ({`E203_XLEN{lbuf_cnt_clr }} & {`E203_XLEN{1'b0}})
                         | ({`E203_XLEN{lbuf_cnt_incr}} & (lbuf_cnt_r + 1'b1) )
                         ;

   sirv_gnrl_dfflr #(`E203_XLEN)   lbuf_cnt_dfflr (lbuf_cnt_ena, lbuf_cnt_nxt, lbuf_cnt_r, nice_clk, nice_rst_n);

   // nice_rsp_valid wait for nice_icb_rsp_valid in jlsd
   assign nice_rsp_valid_jlsd = state_is_jlsd & jlsd_cnt_last & nice_icb_rsp_valid;

   // nice_icb_cmd_valid sets when jlsd_cnt_r is not full in jlsd
   assign nice_icb_cmd_valid_jlsd = (state_is_jlsd & (jlsd_cnt_r < data_num));

   //picbuf  only for picture_data write
   ////////////////////////////////////////////////////
   wire [`E203_XLEN-1:0] picbuf_r      [data_num-1:0];
   wire [`E203_XLEN-1:0] picbuf_wdat   [data_num-1:0];
   wire [15:0]  picbuf_we;
   wire [`E203_XLEN-1:0] picbuf_dat;
   wire [`E203_XLEN-1:0] picbuf_idx; 
   wire  picbuf_wr;


   wire [`E203_XLEN-1:0] jlsd_idx = jlsd_cnt_r; 
   wire jlsd_wr = jlsd_icb_rsp_hsked; 
   wire [`E203_XLEN-1:0] jlsd_wdata = nice_icb_rsp_rdata;

   assign picbuf_dat = (jlsd_wdata&{`E203_XLEN{jlsd_wr}});
   assign picbuf_wr  = jlsd_wr;
   assign picbuf_idx = (jlsd_idx&{`E203_XLEN{jlsd_wr}});
   genvar i;
   generate 
     for (i=0; i<65536; i=i+1) begin:gen_picbuf
       assign picbuf_we[i] =   (picbuf_wr& (picbuf_idx == i[`E203_XLEN-1:0]))
                             ;
  
       assign picbuf_wdat[i] =   ({`E203_XLEN{picbuf_we[i]}} & picbuf_dat )
                               ;
  
       sirv_gnrl_dfflr #(`E203_XLEN) picbuf_dfflr (picbuf_we[i], picbuf_wdat[i], picbuf_wdat[i], nice_clk, nice_rst_n);
     end
   endgenerate
// //2.fconv  3*3 的矩阵卷积核 9
//   wire  nice_rsp_valid_fconv = state_is_fconv & fconv_cnt_last & nice_icb_rsp_valid;
//   wire  nice_icb_cmd_valid_fconv = (state_is_fconv &~ mem_cnt_last);
  
//    wire [2:0] conv_mem_idx; //
//   wire [`E203_XLEN-1:0] conv_mem [2:0];
//   wire [`E203_XLEN-1:0] conv_mem_wdat [2:0]; //32位宽的数据
//   wire fconv_wdat ={`E203_XLEN{fconv_icb_rsp_hsked}}&nice_icb_rsp_rdata;
//   assign conv_mem_idx = ({3{fconv_icb_rsp_hsked}} & mem_cnt_r);
//   wire  conv_mem_wr =fconv_icb_rsp_hsked;
 

  

//  wire [2:0]  conv_mem_we;

//    genvar j;
//    generate 
//      for (j=0; j<3; j=j+1) begin:gen_conv_buf
//        assign conv_mem_we[j] =   (conv_mem_wr & (conv_mem_idx == j[2:0]))
//                              ;
  
//        assign conv_mem_wdat[j] =   ({`E203_XLEN{conv_mem[j]}} & fconv_wdat   )
//                                ;
  
//        sirv_gnrl_dfflr #(`E203_XLEN) conv_mem_dfflr (conv_mem_we[j], conv_mem_wdat[j], conv_mem[j], nice_clk, nice_rst_n);
//      end
//    endgenerate

  
//   //3. jlweight   6*5 一共30个数据  最后五个前两个是偏置 
//   wire  nice_rsp_valid_jlweight = state_is_jlweight & jlweight_cnt_last & nice_icb_rsp_valid;//mem响应有效
//   wire  nice_icb_cmd_valid_jlweight = (state_is_jlweight  &~ mem_cnt_last);  //icb 命令有效

// //
  
//    wire [4:0] weight_mem_idx; //
//   wire [`E203_XLEN-1:0] weight_mem [4:0];
//   wire [`E203_XLEN-1:0] weight_mem_wdat [4:0]; //32位宽的数据
//   wire jlweight_wdat ={`E203_XLEN{fconv_icb_rsp_hsked}}&nice_icb_rsp_rdata;
//   assign weight_mem_idx = ({5{fconv_icb_rsp_hsked}} & mem_cnt_r);
//   wire  weiht_mem_wr =jlweight_icb_rsp_hsked;
  
//  wire [4:0]  weight_mem_we;

//    genvar k;
//    generate 
//      for (k=0; k<5; k=k+1) begin:gen_weight_mem
//        assign weight_mem_we[k] =   (weiht_mem_wr & (weight_mem_idx == k[4:0]))
//                              ;
  
//        assign weight_mem_wdat[k] =   ({`E203_XLEN{weight_mem_we[k]}} & jlweight_wdat   )
//                                ;
  
//        sirv_gnrl_dfflr #(`E203_XLEN) conv_mem_dfflr (weight_mem_we[k], weight_mem_wdat[k], weight_mem[k], nice_clk, nice_rst_n);
//      end
//    endgenerate

 
// //4.CNN模块     jconv 卷积7*9卷积3*3  需要35次coonv》5*7   步长为一 max 3*3池化3*5     fc 全连接 3*5卷积5*3 -》3*3      sresult  取出结果到rd
//   wire  nice_rsp_valid_jconv=state_is_jconv&(~conv_done);//完成的条件
//   wire  nice_rsp_valid_max=state_is_max&(~max_done);
//   wire  nice_rsp_valid_fc=state_is_fc&(~fc_done);
//  wire [5:0]conv_cnt_r;
//  wire [5:0]conv_cnt_nxt;
//  wire conv_cnt_ena;
//   wire conv_cnt_clr;
//    wire conv_cnt_incr;
//    wire conv_cnt_last;
   
// //   wire nice_rsp_valid_conv = state_is_jconv & (conv_cnt_r == 35)&~conv_done;
// //   wire  conv_rsp_hsked  = nice_rsp_valid_conv & nice_rsp_ready;
//    assign conv_cnt_last = (conv_cnt_r == 35);
//    assign conv_cnt_clr =   conv_cnt_last&state_is_jconv;
//    assign conv_cnt_incr = ~conv_cnt_last&state_is_jconv;
//    assign conv_cnt_ena = conv_cnt_clr | conv_cnt_incr;
   
//   assign conv_cnt_nxt =   ({6{conv_cnt_clr }} & {6{1'b0}})
//                            | ({6{conv_cnt_incr}} & (conv_cnt_r + 1'b1))
//                            ;
//     sirv_gnrl_dfflr #(6)   conv_cnt_dfflr (conv_cnt_ena, conv_cnt_nxt, conv_cnt_r, nice_clk, nice_rst_n);
//    wire [`E203_XLEN-1:0] conv_r;
//    wire [`E203_XLEN-1:0] conv_nxt;
//    wire [`E203_XLEN-1:0] conv;
//    wire conv_ena;
//    wire conv_set;
//    wire conv_flg;
//    wire [`E203_XLEN-1:0] cnn_res[34:0] ;
//    assign conv_set = state_is_jconv ;
//    assign conv_flag = state_is_jconv & ~conv_cnt_last;
   
//   wire [`E203_XLEN-1:0] selectedInput1, selectedInput2;

   
//    genvar n;
   
// generate //generating n convolution units where n is half the number of pixels in one row of the output image      fmap_1_mem*conv_mem_idx
// 	for (n = 0; n <35; n = n + 1) begin 
// 	assign selectedInput1=  fmap_1_mem[n];
// 	assign selectedInput2= conv_mem[n];
// 	 processingelement  pe1(
// 		.clk(nice_clk),
// 		.reset(nice_rst_n),
// 		.A(selectedInput1),
// 		.B(selectedInput2),
// 		.result(result)
// 	);
// 	end
// endgenerate
   
 
   
//    wire sresult_icb_cmd_hsked;//与memory握手成功，已发送读写地址和数据信号
//    wire sresult_icb_rsp_hsked;//与memory握手成功，已接收反馈信号
//    wire nice_rsp_valid_sresult;//反馈cpu请求信号
//    wire nice_icb_cmd_valid_sresult;//读写memory请求信号






//    assign nice_icb_cmd_valid_sresult  =(state_is_sresult|state_jconv_exit_ena )&nice_icb_cmd_hsked;
// //   assign nice_rsp_valid_sresult=0;
   
   
   
   
//    //5.tan模块
   
//     wire [`E203_XLEN-1:0] conv_r;
//    wire [`E203_XLEN-1:0] conv_nxt;
//    wire [`E203_XLEN-1:0] conv;
//    wire conv_ena;
//    wire conv_set;
//    wire conv_flg;
//    wire [`E203_XLEN-1:0] tan_res[34:0] ;

//  UsingTheTanh  tan_module(35,nice_clk,tan_res,nice_rst_n,tan_done);
  //////////// mem aacess addr management
   wire [`E203_XLEN-1:0] maddr_acc_r; 
   assign nice_icb_cmd_hsked = nice_icb_cmd_valid & nice_icb_cmd_ready; 
   // custom3_jlsd
   //wire [`E203_XLEN-1:0] lbuf_maddr    = state_is_idle ? nice_req_rs1 : maddr_acc_r ; 
   wire jlsd_maddr_ena    =   (state_is_idle & custom3_jlsd & nice_icb_cmd_hsked)
                            | (state_is_jlsd & nice_icb_cmd_hsked)
                            ;

   // // custom3_fconv
   // //wire [`E203_XLEN-1:0] sbuf_maddr    = state_is_idle ? nice_req_rs1 : maddr_acc_r ; 
   // wire fconv_maddr_ena    =   (state_is_idle & custom3_fconv & nice_icb_cmd_hsked)
   //                          | (state_is_fconv & nice_icb_cmd_hsked)
   //                          ;

   // // custom3_jlweight
   // //wire [`E203_XLEN-1:0] rowsum_maddr  = state_is_idle ? nice_req_rs1 : maddr_acc_r ; 
   // wire jlweight_maddr_ena  =   (state_is_jlweight & custom3_jlweight & nice_icb_cmd_hsked)
   //                          | (state_is_jlweight & nice_icb_cmd_hsked)
                            ;

   // maddr acc 
   //wire  maddr_incr = lbuf_maddr_ena | sbuf_maddr_ena | rowsum_maddr_ena | rbuf_maddr_ena;
   wire  maddr_ena = jlsd_maddr_ena ;
   wire  maddr_ena_idle = maddr_ena & state_is_idle;

   wire [`E203_XLEN-1:0] maddr_acc_op1 = maddr_ena_idle ? nice_req_rs1 : maddr_acc_r; // not reused
   wire [`E203_XLEN-1:0] maddr_acc_op2 = maddr_ena_idle ? `E203_XLEN'h4 : `E203_XLEN'h4; 

   wire [`E203_XLEN-1:0] maddr_acc_next = maddr_acc_op1 + maddr_acc_op2;
   wire  maddr_acc_ena = maddr_ena;

   sirv_gnrl_dfflr #(`E203_XLEN)   maddr_acc_dfflr (maddr_acc_ena, maddr_acc_next, maddr_acc_r, nice_clk, nice_rst_n);


  
   
////////////////////////////////////////////////////////////
   // Control cmd_req
   ////////////////////////////////////////////////////////////
   assign nice_req_hsked = nice_req_valid & nice_req_ready;
   assign nice_req_ready = state_is_idle & (custom_mem_op ? nice_icb_cmd_ready : 1'b1);

////////////////////////////////////////////////////////////
   // Control cmd_rsp
   ////////////////////////////////////////////////////////////
   assign nice_rsp_hsked = nice_rsp_valid & nice_rsp_ready; 
   assign nice_icb_rsp_hsked = nice_icb_rsp_valid & nice_icb_rsp_ready;
   assign nice_rsp_valid = nice_rsp_valid_jlsd;
   assign nice_rsp_rdat  = {`E203_XLEN{state_is_jlsd}} & picbuf_dat;

 
   
 //                           
 
   assign nice_rsp_err   =   (nice_icb_rsp_hsked & nice_icb_rsp_err);//



   assign nice_icb_rsp_ready = 1'b1; //时刻准备接收memory反馈
   assign nice_icb_cmd_valid =   (state_is_idle & nice_req_valid & custom_mem_op)
                              | nice_icb_cmd_valid_jlsd  ;
        //（状态idle且命令有效）为寄存器1，否则为maddr_acc_r
   assign nice_icb_cmd_addr  = (state_is_idle & custom_mem_op) ? nice_req_rs1 :
                              maddr_acc_r;       
   assign nice_icb_cmd_read  = (state_is_idle & custom_mem_op) ? custom3_jlsd : 
                              state_is_jlsd ? 1'b1 : 
                              1'b0; 
   assign nice_icb_cmd_wdata = 32'h0 ;
                 //assign nice_icb_cmd_wmask = {`sirv_XLEN_MW{custom3_sbuf}} & 4'b1111;
   assign nice_icb_cmd_size  = 2'b10;//2: 代表4字节32位数据
   assign nice_mem_holdup    =  state_is_jlsd; //独占内存信号

   ////////////////////////////////////////////////////////////
   // nice_active
   ////////////////////////////////////////////////////////////
   assign nice_active = state_is_idle ? nice_req_valid : 1'b1;//nice是否在工作                                                  
endmodule
`endif//}

