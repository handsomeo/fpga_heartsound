/* `ifndef _FONECYCLE_V_ */
/* `define _FONECYCLE_V_ */
/* `include "../../../../params.vh" */

/* This module implement single/double float point arithematic */
module fonecycle(
	//浮点数运算的操作数
	input [63:0] frs1,
	input [63:0] frs2,
	input [63:0] frs3,
	//rd,to wbck
	input  [`E203_RFIDX_WIDTH-1:0] i_frdidx		,
	output [`E203_RFIDX_WIDTH-1:0] wbck_o_frdidx,
	// output fpu_o_need_wbck,

	input [4:0] ftype,			//具体浮点操作指令类型
	input fcontrol,				//1为detect tininess after rounding(较好？)，0为before rounding？
	input [2:0] roundingMode,	//舍入模式
	input [1:0] fmt,			//single(00)/double(11) float
	output reg [63:0] farithematic_res,	//浮点运算结果
	output reg [4:0] exception_flags,	//浮点数运算过程中出现的异常，异常的编码为{invalid, infinite, overflow, underflow, inexact}
	output reg fflags_valid		//输出有效信号
);

assign wbck_o_frdidx   = i_frdidx;
// assign fpu_o_need_wbck = (ftype != 5'd29);	//除fsw指令外，浮点指令均需写回rd


/* Store recoded operand for single */
wire [32:0] rec_frs1_single;
wire [32:0] rec_frs2_single;
wire [32:0] rec_frs3_single;

/* Store recoded operand for double */
wire [64:0] rec_frs1_double;
wire [64:0] rec_frs2_double;
wire [64:0] rec_frs3_double;

/* Store recoded result for single float operation */
wire [32:0] rec_fadds_res;
wire [32:0] rec_fsubs_res;
wire [32:0] rec_fmuls_res;
/* fmin.s do not need recoded result */
/* fmax.s do not need recoded result */
wire [32:0] rec_fmadds_res;
wire [32:0] rec_fnmadds_res;
wire [32:0] rec_fmsubs_res;
wire [32:0] rec_fnmsubs_res;
/* fcvt.w.s do not need recoded result */
/* fcvt.wu.s do not need recoded result */
/* fcvt.l.s do not need recoded result */
/* fcvt.lu.s do not need recoded result */
wire [32:0] rec_fcvtsw_res;
wire [32:0] rec_fcvtswu_res;
wire [32:0] rec_fcvtsl_res;
wire [32:0] rec_fcvtslu_res;
wire [32:0] rec_fsgnjs_res;
wire [32:0] rec_fsgnjns_res;
wire [32:0] rec_fsgnjxs_res;
/* feq.s do not need recoded result */
/* flt.s do not need recoded result */
/* fle.s do not need recoded result */
/* fclass.s do not need recoded result */
/* fmv.w.x do not need recoded result */
/* fmv.x.w do not need recoded result */

/* Store recoded result for double float operation */
wire [64:0] rec_faddd_res;
wire [64:0] rec_fsubd_res;
wire [64:0] rec_fmuld_res;
/* fmin.d do not need recoded result */
/* fmax.d do not need recoded result */
wire [64:0] rec_fmaddd_res;
wire [64:0] rec_fnmaddd_res;
wire [64:0] rec_fmsubd_res;
wire [64:0] rec_fnmsubd_res;
/* fcvt.w.d do not need recoded result */
/* fcvt.wu.d do not need recoded result */
/* fcvt.l.d do not need recoded result */
/* fcvt.lu.d do not need recoded result */
wire [64:0] rec_fcvtdw_res;
wire [64:0] rec_fcvtdwu_res;
wire [64:0] rec_fcvtdl_res;
wire [64:0] rec_fcvtdlu_res;
wire [64:0] rec_fsgnjd_res;
wire [64:0] rec_fsgnjnd_res;
wire [64:0] rec_fsgnjxd_res;
/* feq.d do not need recoded result */
/* flt.d do not need recoded result */
/* fle.d do not need recoded result */
/* fclass.d do not need recoded result */
/* fmv.d.x do not need recoded result */
/* fmv.d.w do not need recoded result */

/* Store final result for single */
wire [31:0] fadds_res;
wire [31:0] fsubs_res;
wire [31:0] fmuls_res;
reg  [31:0] fmins_res;
reg  [31:0] fmaxs_res;
wire [31:0] fmadds_res;
wire [31:0] fnmadds_res;
wire [31:0] fmsubs_res;
wire [31:0] fnmsubs_res;
wire [31:0] fcvtws_res;
wire [31:0] fcvtwus_res;
wire [63:0] fcvtls_res;
wire [63:0] fcvtlus_res;
wire [31:0] fcvtsw_res;
wire [31:0] fcvtswu_res;
wire [31:0] fcvtsl_res;
wire [31:0] fcvtslu_res;
wire [31:0] fsgnjs_res;
wire [31:0] fsgnjns_res;
wire [31:0] fsgnjxs_res;
wire feqs_res;
wire flts_res;
wire fles_res;
wire [31:0] fclasss_res;
wire [31:0] fmvwx_res;
wire [31:0] fmvxw_res;
wire [31:0] fcvtsd_res;


/* Store final result for double */
wire [63:0] faddd_res;
wire [63:0] fsubd_res;
wire [63:0] fmuld_res;
reg [63:0] fmind_res;
reg [63:0] fmaxd_res;
wire [63:0] fmaddd_res;
wire [63:0] fnmaddd_res;
wire [63:0] fmsubd_res;
wire [63:0] fnmsubd_res;
wire [31:0] fcvtwd_res;
wire [31:0] fcvtwud_res;
wire [63:0] fcvtld_res;
wire [63:0] fcvtlud_res;
wire [63:0] fcvtdw_res;
wire [63:0] fcvtdwu_res;
wire [63:0] fcvtdl_res;
wire [63:0] fcvtdlu_res;
wire [63:0] fsgnjd_res;
wire [63:0] fsgnjnd_res;
wire [63:0] fsgnjxd_res;
wire feqd_res;
wire fltd_res;
wire fled_res;
wire [63:0] fclassd_res;
wire [63:0] fmvdx_res;
wire [63:0] fmvxd_res;
wire [63:0] fcvtds_res;

/* used to store exception flags for single */
wire [4:0] fadds_exception_flags;
wire [4:0] fsubs_exception_flags;
wire [4:0] fmuls_exception_flags;
wire [4:0] fmins_exception_flags;
wire [4:0] fmaxs_exception_flags;
wire [4:0] fmadds_exception_flags;
wire [4:0] fnmadds_exception_flags;
wire [4:0] fmsubs_exception_flags;
wire [4:0] fnmsubs_exception_flags;
wire [4:0] fcvtws_exception_flags;
wire [4:0] fcvtwus_exception_flags;
wire [4:0] fcvtls_exception_flags;
wire [4:0] fcvtlus_exception_flags;
wire [4:0] fcvtsw_exception_flags;
wire [4:0] fcvtswu_exception_flags;
wire [4:0] fcvtsl_exception_flags;
wire [4:0] fcvtslu_exception_flags;
/* fsgnjs do not need exception flags */
/* fsgnjns do not need exception flags */
/* fsgnjxs do not need exception flags */
wire [4:0] feqs_exception_flags;
wire [4:0] flts_exception_flags;
wire [4:0] fles_exception_flags;
/* fclass.s do not need exception flags */
/* fmv.w.x do not need exception flags */
/* fmv.x.w do not need exception flags */
wire [4:0] fcvtsd_exception_flags;


/* used to store exception flags for double */
wire [4:0] faddd_exception_flags;
wire [4:0] fsubd_exception_flags;
wire [4:0] fmuld_exception_flags;
wire [4:0] fmind_exception_flags;
wire [4:0] fmaxd_exception_flags;
wire [4:0] fmaddd_exception_flags;
wire [4:0] fnmaddd_exception_flags;
wire [4:0] fmsubd_exception_flags;
wire [4:0] fnmsubd_exception_flags;
wire [4:0] fcvtwd_exception_flags;
wire [4:0] fcvtwud_exception_flags;
wire [4:0] fcvtld_exception_flags;
wire [4:0] fcvtlud_exception_flags;
wire [4:0] fcvtdw_exception_flags;
wire [4:0] fcvtdwu_exception_flags;
wire [4:0] fcvtdl_exception_flags;
wire [4:0] fcvtdlu_exception_flags;
/* fsgnjd do not need exception flags */
/* fsgnjnd do not need exception flags */
/* fsgnjxd do not need exception flags */
wire [4:0] feqd_exception_flags;
wire [4:0] fltd_exception_flags;
wire [4:0] fled_exception_flags;
/* fclass.d do not need exception flags */
/* fmv.d.x do not need exception flags */
/* fmv.x.d do not need exception flags */
wire [4:0] fcvtds_exception_flags;

fNToRecFN#(
	.expWidth(8),
	.sigWidth(24)
) fn2recfn_frs1_single(
	.in(frs1[31:0]),
	.out(rec_frs1_single)
);
fNToRecFN#(
	.expWidth(8),
	.sigWidth(24)
) fn2recfn_frs2_single(
	.in(frs2[31:0]),
	.out(rec_frs2_single)
);
fNToRecFN#(
	.expWidth(8),
	.sigWidth(24)
) fn2recfn_frs3_single(
	.in(frs3[31:0]),
	.out(rec_frs3_single)
);

fNToRecFN#(
	.expWidth(11),
	.sigWidth(53)
) fn2recfn_frs1(
	.in(frs1),
	.out(rec_frs1_double)
);
fNToRecFN#(
	.expWidth(11),
	.sigWidth(53)
) fn2recfn_frs2(
	.in(frs2),
	.out(rec_frs2_double)
);
fNToRecFN#(
	.expWidth(11),
	.sigWidth(53)
) fn2recfn_frs3(
	.in(frs3),
	.out(rec_frs3_double)
);


/* fadd.s */
addRecFN#(
	.expWidth(8),
	.sigWidth(24)
) fadds(
	.control(fcontrol),
	.subOp(1'b0),
	.a(rec_frs1_single),
	.b(rec_frs2_single),
	.roundingMode(roundingMode),
	.out(rec_fadds_res),
	.exceptionFlags(fadds_exception_flags)
);
/* fadd.d */
addRecFN#(
	.expWidth(11),
	.sigWidth(53)
) faddd(
	.control(fcontrol),
	.subOp(1'b0),
	.a(rec_frs1_double),
	.b(rec_frs2_double),
	.roundingMode(roundingMode),
	.out(rec_faddd_res),
	.exceptionFlags(faddd_exception_flags)
);
/* fsub.s */
addRecFN#(
	.expWidth(8),
	.sigWidth(24)
) fsubs(
	.control(fcontrol),
	.subOp(1'b1),
	.a(rec_frs1_single),
	.b(rec_frs2_single),
	.roundingMode(roundingMode),
	.out(rec_fsubs_res),
	.exceptionFlags(fsubs_exception_flags)
);
/* fsub.d */
addRecFN#(
	.expWidth(11),
	.sigWidth(53)
) fsubd(
	.control(fcontrol),
	.subOp(1'b1),
	.a(rec_frs1_double),
	.b(rec_frs2_double),
	.roundingMode(roundingMode),
	.out(rec_fsubd_res),
	.exceptionFlags(fsubd_exception_flags)
);
/* fmul.s */
mulRecFN#(
	.expWidth(8),
	.sigWidth(24)
) fmuls(
	.control(fcontrol),
	.a(rec_frs1_single),
	.b(rec_frs2_single),
	.roundingMode(roundingMode),
	.out(rec_fmuls_res),
	.exceptionFlags(fmuls_exception_flags)
);
/* fmul.d */
mulRecFN#(
	.expWidth(11),
	.sigWidth(53)
) fmuld(
	.control(fcontrol),
	.a(rec_frs1_double),
	.b(rec_frs2_double),
	.roundingMode(roundingMode),
	.out(rec_fmuld_res),
	.exceptionFlags(fmuld_exception_flags)
);

/* basic structure for float compare instruction */
wire single_signal_lt, single_signal_eq, single_signal_gt;
wire [4:0] single_signal_exception_flags;
wire single_signal_unorder;
wire single_not_signal_lt, single_not_signal_eq, single_not_signal_gt;
wire [4:0] single_not_signal_exception_flags;
wire single_not_signal_unorder;


wire double_signal_lt, double_signal_eq, double_signal_gt;
wire [4:0] double_signal_exception_flags;
wire double_signal_unorder;
wire double_not_signal_lt, double_not_signal_eq, double_not_signal_gt;
wire [4:0] double_not_signal_exception_flags;
wire double_not_signal_unorder;

compareRecFN#(
	.expWidth(8),
	.sigWidth(24)
) single_not_signal(
	.a(rec_frs1_single),
	.b(rec_frs2_single),
	.signaling(1'b0),
	.lt(single_not_signal_lt),
	.eq(single_not_signal_eq),
	.gt(single_not_signal_gt),
	.unordered(single_not_signal_unorder),
	.exceptionFlags(single_not_signal_exception_flags)
);
compareRecFN#(
	.expWidth(8),
	.sigWidth(24)
) single_signal(
	.a(rec_frs1_single),
	.b(rec_frs2_single),
	.signaling(1'b1),
	.lt(single_signal_lt),
	.eq(single_signal_eq),
	.gt(single_signal_gt),
	.unordered(single_signal_unorder),
	.exceptionFlags(single_signal_exception_flags)
);
compareRecFN#(
	.expWidth(11),
	.sigWidth(53)
) double_not_signal(
	.a(rec_frs1_double),
	.b(rec_frs2_double),
	.signaling(1'b0),
	.lt(double_not_signal_lt),
	.eq(double_not_signal_eq),
	.gt(double_not_signal_gt),
	.unordered(double_not_signal_unorder),
	.exceptionFlags(double_not_signal_exception_flags)
);
compareRecFN#(
	.expWidth(11),
	.sigWidth(53)
) double_signal(
	.a(rec_frs1_double),
	.b(rec_frs2_double),
	.signaling(1'b1),
	.lt(double_signal_lt),
	.eq(double_signal_eq),
	.gt(double_signal_gt),
	.unordered(double_signal_unorder),
	.exceptionFlags(double_signal_exception_flags)
);

/* fmin.s result */
assign fmins_exception_flags = single_not_signal_exception_flags;
always @ (*) begin
	/* -0.0 < +0.0 */
	if ((frs1[31:0] == 32'h80000000 && frs2[31:0] == 32'h00000000) || (frs1[31:0] == 32'h00000000 && frs2[31:0] == 32'h80000000)) begin
		fmins_res = 32'h80000000;	
	end
	else begin
		fmins_res = (single_not_signal_lt) ? frs1[31:0] : frs2[31:0];
	end
end

/* fmin.d result */
assign fmind_exception_flags = double_not_signal_exception_flags;
always @ (*) begin
	/* -0.0 < +0.0 */
	if ((frs1 == 64'h80000000_00000000 && frs2 == 64'h00000000_00000000) || (frs1 == 64'h00000000_00000000 && frs2 == 64'h80000000_00000000)) begin
		fmind_res = 64'h80000000_00000000;	
	end
	else begin
		fmind_res = (double_not_signal_lt) ? frs1 : frs2;
	end
end

/* fmax.s result */
assign fmaxs_exception_flags = single_not_signal_exception_flags;
always @ (*) begin
	/* -0.0 < +0.0 */
	if ((frs1[31:0] == 32'h80000000 && frs2[31:0] == 32'h00000000) || (frs1[31:0] == 32'h00000000 && frs2[31:0] == 32'h80000000)) begin
		fmaxs_res = 32'h00000000;	
	end
	else if (frs1[31:0] == 32'h7FFFFFFF && frs2[31:0] == 32'h7FFFFFFF) begin
		fmaxs_res = 32'h7FC00000;
	end
	else begin
		fmaxs_res = (single_not_signal_gt) ? frs1[31:0] : frs2[31:0];
	end
end

/* fmax.d result */
assign fmaxd_exception_flags = double_not_signal_exception_flags;
always @ (*) begin
	/* -0.0 < +0.0 */
	if ((frs1 == 64'h80000000_00000000 && frs2 == 64'h00000000_00000000) || (frs1 == 64'h00000000_00000000 && frs2 == 64'h80000000_00000000)) begin
		fmaxd_res = 64'h00000000_00000000;	
	end
	else if (frs1 == 64'h7FFFFFFF_FFFFFFFF && frs2 == 64'h7FFFFFFF_FFFFFFFF) begin
		fmaxd_res = 64'h7FF80000_00000000;
	end
	else begin
		fmaxd_res = (double_not_signal_gt) ? frs1 : frs2;
	end
end

/* fmadd.s */
mulAddRecFN#(
	.expWidth(8),
	.sigWidth(24)
) fmadds(
	.control(fcontrol),
	.op(2'b00),
	.a(rec_frs1_single),
	.b(rec_frs2_single),
	.c(rec_frs3_single),
	.roundingMode(roundingMode),
	.out(rec_fmadds_res),
	.exceptionFlags(fmadds_exception_flags)
);
/* fmadd.d */
mulAddRecFN#(
	.expWidth(11),
	.sigWidth(53)
) fmaddd(
	.control(fcontrol),
	.op(2'b00),
	.a(rec_frs1_double),
	.b(rec_frs2_double),
	.c(rec_frs3_double),
	.roundingMode(roundingMode),
	.out(rec_fmaddd_res),
	.exceptionFlags(fmaddd_exception_flags)
);

/* fnmadd.s */
mulAddRecFN#(
	.expWidth(8),
	.sigWidth(24)
) fnmadds(
	.control(fcontrol),
	.op(2'b11),
	.a(rec_frs1_single),
	.b(rec_frs2_single),
	.c(rec_frs3_single),
	.roundingMode(roundingMode),
	.out(rec_fnmadds_res),
	.exceptionFlags(fnmadds_exception_flags)
);
/* fnmadd.d */
mulAddRecFN#(
	.expWidth(11),
	.sigWidth(53)
) fnmaddd(
	.control(fcontrol),
	.op(2'b11),
	.a(rec_frs1_double),
	.b(rec_frs2_double),
	.c(rec_frs3_double),
	.roundingMode(roundingMode),
	.out(rec_fnmaddd_res),
	.exceptionFlags(fnmaddd_exception_flags)
);

/* fmsub.s */
mulAddRecFN#(
	.expWidth(8),
	.sigWidth(24)
) fmsubs(
	.control(fcontrol),
	.op(2'b01),
	.a(rec_frs1_single),
	.b(rec_frs2_single),
	.c(rec_frs3_single),
	.roundingMode(roundingMode),
	.out(rec_fmsubs_res),
	.exceptionFlags(fmsubs_exception_flags)
);
/* fmsub.d */
mulAddRecFN#(
	.expWidth(11),
	.sigWidth(53)
) fmsubd(
	.control(fcontrol),
	.op(2'b01),
	.a(rec_frs1_double),
	.b(rec_frs2_double),
	.c(rec_frs3_single),
	.roundingMode(roundingMode),
	.out(rec_fmsubd_res),
	.exceptionFlags(fmsubd_exception_flags)
);
/* fnmsub.s */
mulAddRecFN#(
	.expWidth(8),
	.sigWidth(24)
) fnmsubs(
	.control(fcontrol),
	.op(2'b10),
	.a(rec_frs1_single),
	.b(rec_frs2_single),
	.c(rec_frs3_single),
	.roundingMode(roundingMode),
	.out(rec_fnmsubs_res),
	.exceptionFlags(fnmsubs_exception_flags)
);
/* fnmsub.d */
mulAddRecFN#(
	.expWidth(11),
	.sigWidth(53)
) fnmsubd(
	.control(fcontrol),
	.op(2'b10),
	.a(rec_frs1_double),
	.b(rec_frs2_double),
	.c(rec_frs3_double),
	.roundingMode(roundingMode),
	.out(rec_fnmsubd_res),
	.exceptionFlags(fnmsubd_exception_flags)
);
/* fcvt.w.s */
wire [2:0] fcvtws_tmp_exception_flags;
recFNToIN#(
	.expWidth(8),
	.sigWidth(24),
	.intWidth(32)
) fcvtws(
	.control(fcontrol),
	.in(rec_frs1_single),
	.roundingMode(roundingMode),
	.signedOut(1'b1),
	.out(fcvtws_res),
	.intExceptionFlags(fcvtws_tmp_exception_flags)
);
assign fcvtws_exception_flags = {fcvtws_tmp_exception_flags[2] | fcvtws_tmp_exception_flags[1], 1'b0, 1'b0, 1'b0, fcvtws_tmp_exception_flags[0]};

/* fcvt.w.d */
wire [2:0] fcvtwd_tmp_exception_flags;
recFNToIN#(
	.expWidth(11),
	.sigWidth(53),
	.intWidth(32)
) fcvtwd(
	.control(fcontrol),
	.in(rec_frs1_double),
	.roundingMode(roundingMode),
	.signedOut(1'b1),
	.out(fcvtwd_res),
	.intExceptionFlags(fcvtwd_tmp_exception_flags)
);
assign fcvtwd_exception_flags = {fcvtwd_tmp_exception_flags[2] | fcvtwd_tmp_exception_flags[1], 1'b0, 1'b0, 1'b0, fcvtwd_tmp_exception_flags[0]};

/* fcvt.wu.s */
wire [2:0] fcvtwus_tmp_exception_flags;
recFNToIN#(
	.expWidth(8),
	.sigWidth(24),
	.intWidth(32)
) fcvtwus(
	.control(fcontrol),
	.in(rec_frs1_single),
	.roundingMode(roundingMode),
	.signedOut(1'b0),
	.out(fcvtwus_res),
	.intExceptionFlags(fcvtwus_tmp_exception_flags)
);
assign fcvtwus_exception_flags = {fcvtwus_tmp_exception_flags[2] | fcvtwus_tmp_exception_flags[1], 1'b0, 1'b0, 1'b0, fcvtwus_tmp_exception_flags[0]};

/* fcvt.wu.d */
wire [2:0] fcvtwud_tmp_exception_flags;
recFNToIN#(
	.expWidth(11),
	.sigWidth(53),
	.intWidth(32)
) fcvtwud(
	.control(fcontrol),
	.in(rec_frs1_double),
	.roundingMode(roundingMode),
	.signedOut(1'b0),
	.out(fcvtwud_res),
	.intExceptionFlags(fcvtwud_tmp_exception_flags)
);
assign fcvtwud_exception_flags = {fcvtwud_tmp_exception_flags[2] | fcvtwud_tmp_exception_flags[1], 1'b0, 1'b0, 1'b0, fcvtwud_tmp_exception_flags[0]};

/* fcvt.l.s */
wire [2:0] fcvtls_tmp_exception_flags;
recFNToIN#(
	.expWidth(8),
	.sigWidth(24),
	.intWidth(64)
) fcvtls(
	.control(fcontrol),
	.in(rec_frs1_single),
	.roundingMode(roundingMode),
	.signedOut(1'b1),
	.out(fcvtls_res),
	.intExceptionFlags(fcvtls_tmp_exception_flags)
);
assign fcvtls_exception_flags = {fcvtls_tmp_exception_flags[2] | fcvtls_tmp_exception_flags[1], 1'b0, 1'b0, 1'b0, fcvtls_tmp_exception_flags[0]};

/* fcvt.l.d */
wire [2:0] fcvtld_tmp_exception_flags;
recFNToIN#(
	.expWidth(11),
	.sigWidth(53),
	.intWidth(64)
) fcvtld(
	.control(fcontrol),
	.in(rec_frs1_double),
	.roundingMode(roundingMode),
	.signedOut(1'b1),
	.out(fcvtld_res),
	.intExceptionFlags(fcvtld_tmp_exception_flags)
);
assign fcvtld_exception_flags = {fcvtld_tmp_exception_flags[2] | fcvtld_tmp_exception_flags[1], 1'b0, 1'b0, 1'b0, fcvtld_tmp_exception_flags[0]};

/* fcvt.lu.s */
wire [2:0] fcvtlus_tmp_exception_flags;
recFNToIN#(
	.expWidth(8),
	.sigWidth(24),
	.intWidth(64)
) fcvtlus(
	.control(fcontrol),
	.in(rec_frs1_single),
	.roundingMode(roundingMode),
	.signedOut(1'b0),
	.out(fcvtlus_res),
	.intExceptionFlags(fcvtlus_tmp_exception_flags)
);
assign fcvtlus_exception_flags = {fcvtlus_tmp_exception_flags[2] | fcvtlus_tmp_exception_flags[1], 1'b0, 1'b0, 1'b0, fcvtlus_tmp_exception_flags[0]};

/* fcvt.lu.d */
wire [2:0] fcvtlud_tmp_exception_flags;
recFNToIN#(
	.expWidth(11),
	.sigWidth(53),
	.intWidth(64)
) fcvtlud(
	.control(fcontrol),
	.in(rec_frs1_double),
	.roundingMode(roundingMode),
	.signedOut(1'b0),
	.out(fcvtlud_res),
	.intExceptionFlags(fcvtlud_tmp_exception_flags)
);
assign fcvtlud_exception_flags = {fcvtlud_tmp_exception_flags[2] | fcvtlud_tmp_exception_flags[1], 1'b0, 1'b0, 1'b0, fcvtlud_tmp_exception_flags[0]};

/* fcvt.s.w */
iNToRecFN#(
	.intWidth(32),
	.expWidth(8),
	.sigWidth(24)
) fcvtsw(
	.control(fcontrol),
	.signedIn(1'b1),
	.in(frs1[31:0]),
	.roundingMode(roundingMode),
	.out(rec_fcvtsw_res),
	.exceptionFlags(fcvtsw_exception_flags)
);
/* fcvt.d.w */
iNToRecFN#(
	.intWidth(32),
	.expWidth(11),
	.sigWidth(53)
) fcvtdw(
	.control(fcontrol),
	.signedIn(1'b1),
	.in(frs1[31:0]),
	.roundingMode(roundingMode),
	.out(rec_fcvtdw_res),
	.exceptionFlags(fcvtdw_exception_flags)
);

/* fcvt.s.wu */
iNToRecFN#(
	.intWidth(32),
	.expWidth(8),
	.sigWidth(24)
) fcvtswu(
	.control(fcontrol),
	.signedIn(1'b0),
	.in(frs1[31:0]),
	.roundingMode(roundingMode),
	.out(rec_fcvtswu_res),
	.exceptionFlags(fcvtswu_exception_flags)
);

/* fcvt.d.wu */
iNToRecFN#(
	.intWidth(32),
	.expWidth(11),
	.sigWidth(53)
) fcvtdwu(
	.control(fcontrol),
	.signedIn(1'b0),
	.in(frs1[31:0]),
	.roundingMode(roundingMode),
	.out(rec_fcvtdwu_res),
	.exceptionFlags(fcvtdwu_exception_flags)
);
/* fcvt.s.l */
iNToRecFN#(
	.intWidth(64),
	.expWidth(8),
	.sigWidth(24)
) fcvtsl(
	.control(fcontrol),
	.signedIn(1'b1),
	.in(frs1),
	.roundingMode(roundingMode),
	.out(rec_fcvtsl_res),
	.exceptionFlags(fcvtsl_exception_flags)
);
/* fcvt.d.l */
iNToRecFN#(
	.intWidth(64),
	.expWidth(11),
	.sigWidth(53)
) fcvtdl(
	.control(fcontrol),
	.signedIn(1'b1),
	.in(frs1),
	.roundingMode(roundingMode),
	.out(rec_fcvtdl_res),
	.exceptionFlags(fcvtdl_exception_flags)
);
/* fcvt.s.lu */
iNToRecFN#(
	.intWidth(64),
	.expWidth(8),
	.sigWidth(24)
) fcvtslu(
	.control(fcontrol),
	.signedIn(1'b0),
	.in(frs1),
	.roundingMode(roundingMode),
	.out(rec_fcvtslu_res),
	.exceptionFlags(fcvtslu_exception_flags)
);
/* fcvt.d.lu */
iNToRecFN#(
	.intWidth(64),
	.expWidth(11),
	.sigWidth(53)
) fcvtdlu(
	.control(fcontrol),
	.signedIn(1'b0),
	.in(frs1),
	.roundingMode(roundingMode),
	.out(rec_fcvtdlu_res),
	.exceptionFlags(fcvtdlu_exception_flags)
);

/* fsgnj.s */
assign fsgnjs_res = { frs2[31], frs1[30:0] };
/* fsgnj.d */
assign fsgnjd_res = { frs2[63], frs1[62:0] };
/* fsgnjn.s */
assign fsgnjns_res = { ~frs2[31], frs1[30:0] };
/* fsgnjn.d */
assign fsgnjnd_res = { ~frs2[63], frs1[62:0] };
/* fsgnjx.s */
assign fsgnjxs_res = { frs1[31] ^ frs2[31], frs1[30:0] };
/* fsgnjx.d */
assign fsgnjxd_res = { frs1[63] ^ frs2[63], frs1[62:0] };
/* feq.s */
assign feqs_res = single_not_signal_eq;
assign feqs_exception_flags = single_not_signal_exception_flags;
/* feq.d */
assign feqd_res = double_not_signal_eq;
assign feqd_exception_flags = double_not_signal_exception_flags;
/* flt.s */
assign flts_res = single_signal_lt;
assign flts_exception_flags = single_signal_exception_flags;
/* flt.d */
assign fltd_res = double_signal_lt;
assign fltd_exception_flags = double_signal_exception_flags;
/* fle.s */
assign fles_res = single_signal_lt | single_signal_eq;
assign fles_exception_flags = single_signal_exception_flags;
/* fle.d */
assign fled_res = double_signal_lt | double_signal_eq;
assign fled_exception_flags = double_signal_exception_flags;

/* fclass.s */
fclassifier fclasss(
	.frs(frs1[31:0]),
	.class_res(fclasss_res)
);
/* fclass.d */
fdclassifier fclassd(
	.frs(frs1),
	.class_res(fclassd_res)
);
/* fmv.w.x */
assign fmvwx_res = frs1[31:0];
/* fmv.d.x */
assign fmvdx_res = frs1;
/* fmv.x.w */
assign fmvxw_res = frs1[31:0];
/* fmv.x.d */
assign fmvxd_res = frs1;

/* fcvt.s.d */
wire [32:0] fcvtsd_single_tmp;
recFNToRecFN #(
	.inExpWidth(11),
	.inSigWidth(53),
	.outExpWidth(8),
	.outSigWidth(24)
) fcvtsd(
	.control(fcontrol),
	.in(rec_frs1_double),
	.roundingMode(roundingMode),
	.out(fcvtsd_single_tmp),
	.exceptionFlags(fcvtsd_exception_flags)
);
recFNToFN#(
	.expWidth(8),
	.sigWidth(24)
) fcvtsd_single_converter(
	.in(fcvtsd_single_tmp),
	.out(fcvtsd_res)
);


/* fcvt.d.s */
wire [64:0] fcvtds_double_tmp;
recFNToRecFN #(
	.inExpWidth(8),
	.inSigWidth(24),
	.outExpWidth(11),
	.outSigWidth(53)
) fcvtds(
	.control(fcontrol),
	.in(rec_frs1_single),
	.roundingMode(roundingMode),
	.out(fcvtds_double_tmp),
	.exceptionFlags(fcvtds_exception_flags)
);
recFNToFN#(
	.expWidth(11),
	.sigWidth(53)
) fcvtds_double_converter(
	.in(fcvtds_double_tmp),
	.out(fcvtds_res)
);

/* convert recoded result to normal result */
recFNToFN#(
	.expWidth(8),
	.sigWidth(24)
) rec2fn_fadds(
	.in(rec_fadds_res),
	.out(fadds_res)
);
recFNToFN#(
	.expWidth(11),
	.sigWidth(53)
) rec2fn_faddd(
	.in(rec_faddd_res),
	.out(faddd_res)
);
recFNToFN#(
	.expWidth(8),
	.sigWidth(24)
) rec2fn_fsubs(
	.in(rec_fsubs_res),
	.out(fsubs_res)
);
recFNToFN#(
	.expWidth(11),
	.sigWidth(53)
) rec2fn_fsubd(
	.in(rec_fsubd_res),
	.out(fsubd_res)
);
recFNToFN#(
	.expWidth(8),
	.sigWidth(24)
) rec2fn_fmuls(
	.in(rec_fmuls_res),
	.out(fmuls_res)
);
recFNToFN#(
	.expWidth(11),
	.sigWidth(53)
) rec2fn_fmuld(
	.in(rec_fmuld_res),
	.out(fmuld_res)
);
recFNToFN#(
	.expWidth(8),
	.sigWidth(24)
) rec2fn_fmadds(
	.in(rec_fmadds_res),
	.out(fmadds_res)
);
recFNToFN#(
	.expWidth(11),
	.sigWidth(53)
) rec2fn_fmaddd(
	.in(rec_fmaddd_res),
	.out(fmaddd_res)
);
recFNToFN#(
	.expWidth(8),
	.sigWidth(24)
) rec2fn_fnmadds(
	.in(rec_fnmadds_res),
	.out(fnmadds_res)
);
recFNToFN#(
	.expWidth(11),
	.sigWidth(53)
) rec2fn_fnmaddd(
	.in(rec_fnmaddd_res),
	.out(fnmaddd_res)
);
recFNToFN#(
	.expWidth(8),
	.sigWidth(24)
) rec2fn_fmsubs(
	.in(rec_fmsubs_res),
	.out(fmsubs_res)
);
recFNToFN#(
	.expWidth(11),
	.sigWidth(53)
) rec2fn_fmsubd(
	.in(rec_fmsubd_res),
	.out(fmsubd_res)
);
recFNToFN#(
	.expWidth(8),
	.sigWidth(24)
) rec2fn_fnmsubs(
	.in(rec_fnmsubs_res),
	.out(fnmsubs_res)
);
recFNToFN#(
	.expWidth(11),
	.sigWidth(53)
) rec2fn_fnmsubd(
	.in(rec_fnmsubd_res),
	.out(fnmsubd_res)
);
recFNToFN#(
	.expWidth(8),
	.sigWidth(24)
) rec2fn_fcvtsw(
	.in(rec_fcvtsw_res),
	.out(fcvtsw_res)
);
recFNToFN#(
	.expWidth(11),
	.sigWidth(53)
) rec2fn_fcvtdw(
	.in(rec_fcvtdw_res),
	.out(fcvtdw_res)
);
recFNToFN#(
	.expWidth(8),
	.sigWidth(24)
) rec2fn_fcvtswu(
	.in(rec_fcvtswu_res),
	.out(fcvtswu_res)
);
recFNToFN#(
	.expWidth(11),
	.sigWidth(53)
) rec2fn_fcvtdwu(
	.in(rec_fcvtdwu_res),
	.out(fcvtdwu_res)
);


recFNToFN#(
	.expWidth(8),
	.sigWidth(24)
) rec2fn_fcvtsl(
	.in(rec_fcvtsl_res),
	.out(fcvtsl_res)
);
recFNToFN#(
	.expWidth(11),
	.sigWidth(53)
) rec2fn_fcvtdl(
	.in(rec_fcvtdl_res),
	.out(fcvtdl_res)
);
recFNToFN#(
	.expWidth(8),
	.sigWidth(24)
) rec2fn_fcvtslu(
	.in(rec_fcvtslu_res),
	.out(fcvtslu_res)
);
recFNToFN#(
	.expWidth(11),
	.sigWidth(53)
) rec2fn_fcvtdlu(
	.in(rec_fcvtdlu_res),
	.out(fcvtdlu_res)
);

/* Output */
always @ (*) begin
	if (fmt == 2'b00) begin
		case (ftype)
			5'd0:begin
				farithematic_res = { 32'b0, fadds_res };
				fflags_valid = 1;
				exception_flags = fadds_exception_flags;
			end
			5'd1:begin
				farithematic_res = { 32'b0, fsubs_res };
				fflags_valid = 1;
				exception_flags = fsubs_exception_flags;
			end
			5'd2:begin
				farithematic_res = { 32'b0, fmuls_res };
				fflags_valid = 1;
				exception_flags = fmuls_exception_flags;
			end
			5'd3:begin
				farithematic_res = { 32'b0, fmins_res };
				fflags_valid = 1;
				exception_flags = fmins_exception_flags;
			end
			5'd4:begin
				farithematic_res = { 32'b0, fmaxs_res };
				fflags_valid = 1;
				exception_flags = fmaxs_exception_flags;
			end
			5'd5:begin
				farithematic_res = { 32'b0, fmadds_res };
				fflags_valid = 1;
				exception_flags = fmadds_exception_flags;
			end
			5'd6:begin
				farithematic_res = { 32'b0, fnmadds_res };
				fflags_valid = 1;
				exception_flags = fnmaddd_exception_flags;
			end
			5'd7:begin
				farithematic_res = { 32'b0, fmsubs_res };
				fflags_valid = 1;
				exception_flags = fmsubs_exception_flags;
			end
			5'd8:begin
				farithematic_res = { 32'b0, fnmsubs_res };
				fflags_valid = 1;
				exception_flags = fnmsubs_exception_flags;
			end
			5'd9:begin
				farithematic_res = { {32{fcvtws_res[31]}}, fcvtws_res };
				fflags_valid = 1;
				exception_flags = fcvtws_exception_flags;
			end
			5'd10:begin
				farithematic_res = { {32{fcvtwus_res[31]}}, fcvtwus_res };
				fflags_valid = 1;
				exception_flags = fcvtwus_exception_flags;
			end
			5'd11:begin
				farithematic_res = fcvtls_res;
				fflags_valid = 1;
				exception_flags = fcvtls_exception_flags;
			end
			5'd12:begin
				farithematic_res = fcvtlus_res;
				fflags_valid = 1;
				exception_flags = fcvtlus_exception_flags;
			end
			5'd13:begin
				farithematic_res = { 32'b0, fcvtsw_res };
				fflags_valid = 1;
				exception_flags = fcvtsw_exception_flags;
			end
			5'd14:begin
				farithematic_res = { 32'b0, fcvtswu_res };
				fflags_valid = 1;
				exception_flags = fcvtswu_exception_flags;
			end
			5'd15:begin
				farithematic_res = { 32'b0, fcvtsl_res };
				fflags_valid = 1;
				exception_flags = fcvtsl_exception_flags;
			end
			5'd16:begin
				farithematic_res = { 32'b0, fcvtslu_res };
				fflags_valid = 1;
				exception_flags = fcvtslu_exception_flags;
			end
			5'd17:begin
				farithematic_res = { 32'b0, fsgnjs_res };
				fflags_valid = 0;
				exception_flags = 0;
			end
			5'd18:begin
				farithematic_res = { 32'b0, fsgnjns_res };
				fflags_valid = 0;
				exception_flags = 0;
			end
			5'd19:begin
				farithematic_res = { 32'b0, fsgnjxs_res };
				fflags_valid = 0;
				exception_flags = 0;
			end
			5'd20:begin
				farithematic_res = { 63'b0, feqs_res };
				fflags_valid = 0;
				exception_flags = 0;
			end
			5'd21:begin
				farithematic_res = { 63'b0, flts_res };
				fflags_valid = 0;
				exception_flags = 0;
			end
			5'd22:begin
				farithematic_res = { 63'b0, fles_res };
				fflags_valid = 0;
				exception_flags = 0;
			end
			5'd23:begin
				farithematic_res = { 32'b0, fclasss_res };
				fflags_valid = 0;
				exception_flags = 0;
			end
			5'd24:begin
				farithematic_res = { 32'b0, fmvwx_res };
				fflags_valid = 0;
				exception_flags = 0;
			end
			5'd25:begin
				farithematic_res = { {32{fmvxw_res[31]}}, fmvxw_res };
				fflags_valid = 0;
				exception_flags = 0;
			end
			5'd30:begin
				farithematic_res = { 32'b0, fcvtsd_res };
				fflags_valid = 1;
				exception_flags = fcvtsd_exception_flags;
			end
			default:begin
				farithematic_res = 0;
				fflags_valid = 0;
				exception_flags = 0;
			end
		endcase
	end
	else if (fmt == 2'b11) begin
		case(ftype)
			5'd0:begin
				farithematic_res = faddd_res;
				fflags_valid = 1;
				exception_flags = faddd_exception_flags;
			end
			5'd1:begin
				farithematic_res = fsubd_res;
				fflags_valid = 1;
				exception_flags = fsubd_exception_flags;
			end
			5'd2:begin
				farithematic_res = fmuld_res;
				fflags_valid = 1;
				exception_flags = fmuld_exception_flags;
			end
			5'd3:begin
				farithematic_res = fmind_res;
				fflags_valid = 1;
				exception_flags = fmind_exception_flags;
			end
			5'd4:begin
				farithematic_res = fmaxd_res;
				fflags_valid = 1;
				exception_flags = fmaxd_exception_flags;
			end
			5'd5:begin
				farithematic_res = fmaddd_res;
				fflags_valid = 1;
				exception_flags = fmaddd_exception_flags;
			end
			5'd6:begin
				farithematic_res = fnmaddd_res;
				fflags_valid = 1;
				exception_flags = fnmaddd_exception_flags;
			end
			5'd7:begin
				farithematic_res = fmsubd_res;
				fflags_valid = 1;
				exception_flags = fnmsubd_exception_flags;
			end
			5'd8:begin
				farithematic_res = fnmsubd_res;
				fflags_valid = 1;
				exception_flags = fnmsubd_exception_flags;
			end
			5'd9:begin
				farithematic_res = { {32{fcvtwd_res[31]}}, fcvtwd_res[30:0] };
				fflags_valid = 1;
				exception_flags = fcvtwd_exception_flags;
			end
			5'd10:begin
				farithematic_res = { {32{fcvtwud_res[31]}}, fcvtwd_res[30:0] };
				fflags_valid = 1;
				exception_flags = fcvtwud_exception_flags;
			end
			5'd11:begin
				farithematic_res = fcvtld_res;
				fflags_valid = 1;
				exception_flags = fcvtld_exception_flags;
			end
			5'd12:begin
				farithematic_res = fcvtlud_res;
				fflags_valid = 1;
				exception_flags = fcvtlud_exception_flags;
			end
			5'd13:begin
				farithematic_res = fcvtdw_res;
				fflags_valid = 1;
				exception_flags = fcvtdw_exception_flags;
			end
			5'd14:begin
				farithematic_res = fcvtdwu_res;
				fflags_valid = 1;
				exception_flags = fcvtdwu_exception_flags;
			end
			5'd15:begin
				farithematic_res = fcvtdl_res;
				fflags_valid = 1;
				exception_flags = fcvtdl_exception_flags;
			end
			5'd16:begin
				farithematic_res = fcvtdlu_res;
				fflags_valid = 1;
				exception_flags = fcvtdlu_exception_flags;
			end
			5'd17:begin
				farithematic_res = fsgnjd_res;
				fflags_valid = 0;
				exception_flags = 0;
			end
			5'd18:begin
				farithematic_res = fsgnjnd_res;
				fflags_valid = 0;
				exception_flags = 0;
			end
			5'd19:begin
				farithematic_res = fsgnjxd_res;
				fflags_valid = 0;
				exception_flags = 0;
			end
			5'd20:begin
				farithematic_res = { 63'b0, feqd_res };
				fflags_valid = 1;
				exception_flags = feqd_exception_flags;
			end
			5'd21:begin
				farithematic_res = { 63'b0, fltd_res };
				fflags_valid = 1;
				exception_flags = fltd_exception_flags;
			end
			5'd22:begin
				farithematic_res = { 63'b0, fled_res };
				fflags_valid = 1;
				exception_flags = fled_exception_flags;
			end
			5'd23:begin
				farithematic_res = fclassd_res;
				fflags_valid = 0;
				exception_flags = 0;
			end
			5'd24:begin
				farithematic_res = fmvdx_res;
				fflags_valid = 0;
				exception_flags = 0;
			end
			5'd25:begin
				farithematic_res = fmvxd_res;
				fflags_valid = 0;
				exception_flags = 0;
			end
			5'd31:begin
				farithematic_res = fcvtds_res;
				fflags_valid = 1;
				exception_flags = fcvtds_exception_flags;
			end
			default:begin
				farithematic_res = 0;
				fflags_valid = 0;
				exception_flags = 0;
			end
		endcase
	end
	else begin
		farithematic_res = 0;
		exception_flags = 0;
		fflags_valid = 0;
	end
end

endmodule

/* `endif // _FONECYCLE_V_ */
