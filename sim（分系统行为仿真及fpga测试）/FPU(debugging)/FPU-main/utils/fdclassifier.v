/* `include "../../../../params.vh" */

module fdclassifier(
	input [63:0] frs,
	output [63:0] class_res
);

/* Get sign, exponent and fraction */
wire sign;
wire [10 : 0] exponent;
wire [51 : 0] fraction;

assign sign = frs[63];
assign exponent = frs[62 : 52];
assign fraction = frs[51 : 0];

/* class_res variables */
reg neg_infinity;
reg neg_normal_number;
reg neg_subnormal_number;
reg neg_zero;
reg pos_zero;
reg pos_subnormal_number;
reg pos_normal_number;
reg pos_infinity;
reg signaling_NaN;
reg quiet_NaN;

/* negative infinity */
always @ (*) begin
	if (sign == 1'b1 && exponent == 11'b1111_1111_111 && fraction == 0)
		neg_infinity = 1;
	else
		neg_infinity = 0;
end

/* negative normal number */
always @ (*) begin
	if (sign == 1'b1 && exponent != 0 && exponent != 11'b1111_1111_111)
		neg_normal_number = 1;
	else
		neg_normal_number = 0;
end

/* negative subnormal number */
always @ (*) begin
	if (sign == 1'b1 && exponent == 0 && fraction != 0)
		neg_subnormal_number = 1;
	else
		neg_subnormal_number = 0;
end

/* negative zero */
always @ (*) begin
	if (sign == 1'b1 && exponent == 0 && fraction == 0)
		neg_zero = 1;
	else
		neg_zero = 0;
end

/* positive zero */
always @ (*) begin
	if (sign == 1'b0 && exponent == 0 && fraction == 0) begin
		pos_zero = 1;
	end
	else begin
		pos_zero = 0;
	end
end

/* positive subnormal number */
always @ (*) begin
	if (sign == 1'b0 && exponent == 0 && fraction != 0)
		pos_subnormal_number = 1;
	else
		pos_subnormal_number = 0;
end

/* positive normal number */
always @ (*) begin
	if (sign == 1'b0 && exponent != 0 && exponent != 11'b1111_1111_111)
		pos_normal_number = 1;
	else
		pos_normal_number = 0;
end

/* positive infinity */
always @ (*) begin
	if (sign == 1'b0 && exponent == 11'b1111_1111_111 && fraction == 0)
		pos_infinity = 1;
	else
		pos_infinity = 0;
end

/* signaling_NaN and quiet_NaN */
always @ (*) begin
	if (exponent == 11'b1111_1111_111 && fraction != 0) begin
		if (fraction[51] == 1'b0) begin
			signaling_NaN = 1;
			quiet_NaN = 0;
		end
		else begin
			signaling_NaN = 0;
			quiet_NaN = 1;
		end
	end
	else begin
		signaling_NaN = 0;
		quiet_NaN = 0;
	end
end

assign class_res = {
	55'b0,
	quiet_NaN,
	signaling_NaN,
	pos_infinity,
	pos_normal_number,
	pos_subnormal_number,
	pos_zero,
	neg_zero,
	neg_subnormal_number,
	neg_normal_number,
	neg_infinity
};
endmodule
