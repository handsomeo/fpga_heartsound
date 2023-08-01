//=====================================================================
//
// Designer   : ZMM
//
// Description:
//  The fpu_decode module to decode the Float instruction details
//
// ====================================================================
`include "e203_defines.v"

module e203_fpu_dec(
    input [`E203_INSTR_SIZE-1:0] fp_instr,

    inout dec_fp_en,
    input [`E203_DECINFO_FPU_WIDTH-1:0] dec_fp_info,

    //寄存器使能/索引
	output dec_frs1en ,
	output dec_frs2en ,
	output dec_frs3en ,
	output dec_frdwen ,
	output [`E203_RFIDX_WIDTH-1:0] dec_frs1idx,
	output [`E203_RFIDX_WIDTH-1:0] dec_frs2idx,
	output [`E203_RFIDX_WIDTH-1:0] dec_frs3idx,
	output [`E203_RFIDX_WIDTH-1:0] dec_frdidx ,
    //源寄存器或目的寄存器为浮点寄存器还是整数寄存器，为1表示浮点寄存器，为0表示整数寄存器
    output i_fpu_rs1fpu,          
    output i_fpu_rs2fpu,
    output i_fpu_rs3fpu,
    output i_fpu_rdfpu ,

	output [2:0] roundingMode,	//舍入模式
    output [4:0] ftype			//具体浮点操作指令类型
 );

    //舍入模式   
    wire [2:0] dec_rm = fp_instr [14:12];
    assign roundingMode = dec_rm;
    ////////////////////////////////////////
	// rne = 3'b000     向最近的偶数舍入
	// rtz = 3'b001     向零舍入
	// rdn = 3'b010     向下(-∞)舍入
	// rup = 3'b011     向上(+∞)舍入
	// rmm = 3'b100     向最近的最大值舍入
	// res = dec_rm[2] & !rm_rmm   保留
    ////////////////////////////////////////

	wire [4:0]  _rd     = fp_instr[11:7];
	wire [2:0]  _func3  = fp_instr[14:12];
	wire [4:0]  _rs1    = fp_instr[19:15];
	wire [4:0]  _rs2    = fp_instr[24:20];
	wire [6:0]  _func7  = fp_instr[31:25];
	wire [4:0]  _rs3    = fp_instr[31:27];
    reg  [4:0]  ftype_r;
    always @(*) begin
        case(dec_fp_info)
            30'h0000_0001: begin
                ftype_r = 5'd0;
            end
            30'h0000_0002: begin
                ftype_r = 5'd1;
            end
            30'h0000_0004: begin
                ftype_r = 5'd2;
            end
            30'h0000_0008: begin
                ftype_r = 5'd3;
            end
            30'h0000_0010: begin
                ftype_r = 5'd4;
            end
            30'h0000_0020: begin
                ftype_r = 5'd5;
            end
            30'h0000_0040: begin
                ftype_r = 5'd6;
            end
            30'h0000_0080: begin
                ftype_r = 5'd7;
            end
            30'h0000_0100: begin
                ftype_r = 5'd8;
            end
            30'h0000_0200: begin
                ftype_r = 5'd9;
            end
            30'h0000_0400: begin
                ftype_r = 5'd10;
            end
            30'h0000_0800: begin
                ftype_r = 5'd11;
            end
            30'h0000_1000: begin
                ftype_r = 5'd12;
            end
            30'h0000_2000: begin
                ftype_r = 5'd13;
            end
            30'h0000_4000: begin
                ftype_r = 5'd14;
            end
            30'h0000_8000: begin
                ftype_r = 5'd15;
            end
            30'h0001_0000: begin
                ftype_r = 5'd16;
            end
            30'h0002_0000: begin
                ftype_r = 5'd17;
            end
            30'h0004_0000: begin
                ftype_r = 5'd18;
            end
            30'h0008_0000: begin
                ftype_r = 5'd19;
            end
            30'h0010_0000: begin
                ftype_r = 5'd20;
            end
            30'h0020_0000: begin
                ftype_r = 5'd21;
            end
            30'h0040_0000: begin
                ftype_r = 5'd22;
            end
            30'h0080_0000: begin
                ftype_r = 5'd23;
            end
            30'h0100_0000: begin
                ftype_r = 5'd24;
            end
            30'h0200_0000: begin
                ftype_r = 5'd25;
            end
            30'h0400_0000: begin
                ftype_r = 5'd26;
            end
            30'h0800_0000: begin
                ftype_r = 5'd27;
            end
            30'h1000_0000: begin
                ftype_r = 5'd28;
            end
            30'h2000_0000: begin
                ftype_r = 5'd29;
            end
            default:       begin
                ftype_r = 5'd31;
            end
        endcase
    end
    assign ftype = ftype_r;
    //reg
    wire fp_need_rs1 = dec_fp_en;
    wire fp_need_rs2 = (dec_fp_info != `E203_DECINFO_FPU_FLW      )
                     & (dec_fp_info != `E203_DECINFO_FPU_FSQRT    )
                     & (dec_fp_info != `E203_DECINFO_FPU_FCVT_W_S )
                     & (dec_fp_info != `E203_DECINFO_FPU_FCVT_WU_S)
                     & (dec_fp_info != `E203_DECINFO_FPU_FMV_X_W  )
                     & (dec_fp_info != `E203_DECINFO_FPU_FCLASS   )
                     & (dec_fp_info != `E203_DECINFO_FPU_FCVT_S_W )
                     & (dec_fp_info != `E203_DECINFO_FPU_FCVT_S_WU)
                     & (dec_fp_info != `E203_DECINFO_FPU_FMV_W_X  );
    wire fp_need_rs3 = (dec_fp_info == `E203_DECINFO_FPU_FMADD    )
                     | (dec_fp_info == `E203_DECINFO_FPU_FMSUB    )
                     | (dec_fp_info == `E203_DECINFO_FPU_FNMSUB   )
                     | (dec_fp_info == `E203_DECINFO_FPU_FNMADD   );
    wire fp_need_rd  = (dec_fp_info != `E203_DECINFO_FPU_FSW      );

    assign dec_frs1en = fp_need_rs1;
    assign dec_frs2en = fp_need_rs2;
    assign dec_frs3en = fp_need_rs3;
    assign dec_frdwen = fp_need_rd ;

    assign i_fpu_rs1fpu = (dec_fp_info != `E203_DECINFO_FPU_FLW      )
                        & (dec_fp_info != `E203_DECINFO_FPU_FSW      )
                        & (dec_fp_info != `E203_DECINFO_FPU_FCVT_S_W )
                        & (dec_fp_info != `E203_DECINFO_FPU_FCVT_S_WU)
                        & (dec_fp_info != `E203_DECINFO_FPU_FMV_W_X  );
    assign i_fpu_rs2fpu = fp_need_rs2;
    assign i_fpu_rs3fpu = fp_need_rs3;  
    assign i_fpu_rdfpu  = (dec_fp_info != `E203_DECINFO_FPU_FCVT_W_S )
                        & (dec_fp_info != `E203_DECINFO_FPU_FCVT_WU_S)
                        & (dec_fp_info != `E203_DECINFO_FPU_FMV_X_W  )
                        & (dec_fp_info != `E203_DECINFO_FPU_FEQ      )
                        & (dec_fp_info != `E203_DECINFO_FPU_FLT      )
                        & (dec_fp_info != `E203_DECINFO_FPU_FLE      )
                        & (dec_fp_info != `E203_DECINFO_FPU_FCLASS   );
    assign dec_frs1idx = _rs1;
    assign dec_frs2idx = _rs2;
    assign dec_frs3idx = _rs3;
    assign dec_frdidx  = _rd ;
 endmodule