`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/29 17:33:51
// Design Name: 
// Module Name: fpu_sim
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module fpu_sim( );

    reg [31:0] frs1;
    reg [31:0] frs2;
    reg [31:0] frs3;
    
    reg [4:0] ftype;
    reg fcontrol;
    reg [2:0] roundingMode;
    reg [1:0] fmt;
    
    wire [31:0] farithematic_res;
    wire [4:0] exception_flags;
    wire  fflags_valid;

initial begin
    fmt = 2'b00;
    fcontrol = 1'b1;
    roundingMode = 3'b000;
    
    #200
    frs1 = 32'd1078355558;
    frs2 = 32'd1078355558;
    frs3 = 32'd1078355558;
    ftype = 5'd6;
    
    #2000
    ftype = 5'd9; 
    
    #2000
    ftype = 5'd7;
    
    #2000
    ftype = 5'd3;
end

fonecycle u_fonecycle (
	 .frs1(frs1),
	 .frs2(frs2),
	 .frs3(frs3),
	 .ftype(ftype),
	 .fcontrol(fcontrol),
	 .roundingMode(roundingMode),
	 .fmt(fmt),	
	 		
	 .farithematic_res(farithematic_res),
	 .exception_flags(exception_flags),	
	 .fflags_valid(fflags_valid)
);
endmodule
