
module SET ( clk , rst, en, central, radius, mode, busy, valid, candidate );

input clk, rst;
input en;
input [23:0] central;
input [11:0] radius;
input [1:0] mode;
output busy;
output valid;
output [7:0] candidate;

//////////////
// reg wire //
//////////////

reg [3:0]  cur_st, nex_st;
reg [2:0]  X,Y;
reg [1:0]  mode_reg;
reg [23:0] central_reg;
reg [11:0] radius_reg;
reg [1:0]  judge;
reg [7:0]  count;

wire [3:0] central_ax,
           central_ay,
           central_bx,
           central_by,
           central_cx,
           central_cy;
		   
wire [3:0] radius_a,
           radius_b,
		   radius_c;
		   

///////////////
// parameter //
///////////////

/* parameter IDLE     = 4'b0000,
		  mode1a   = 4'b0001,		 
		  mode2a   = 4'b0011,
		  mode3a   = 4'b0101,
		  mode4a   = 4'b0111,
		  mode2b   = 4'b0010,
		  mode3b   = 4'b0110,
		  mode4b   = 4'b1010,		  
		  mode4c   = 4'b0100,
		  cclate   = 4'b1100,
		  out      = 4'b1000; */
parameter 	IDLE 	= 3'd0,
		mode_a	= 3'd1,
		mode_b	= 3'd2,
		mode_c	= 3'd3,
		cclate	= 3'd4,
		out	= 3'd5;

////////////
// design //
////////////
assign central_ax = central_reg[23:20];
assign central_ay = central_reg[19:16];
assign central_bx = central_reg[15:12];
assign central_by = central_reg[11:8];
assign central_cx = central_reg[7:4];
assign central_cy = central_reg[3:0];

assign radius_a = radius_reg[11:8];
assign radius_b = radius_reg[7:4];
assign radius_c = radius_reg[3:0];
/* 
assign Xa_up = ((central_ax + radius_a)<=8) ? central_ax + radius_a - 1 : 3'h7 ;
assign Xb_up = ((central_bx + radius_b)<=8) ? central_bx + radius_b - 1 : 3'h7 ;
assign Xc_up = ((central_cx + radius_c)<=8) ? central_cx + radius_c - 1 : 3'h7 ;
assign Ya_up = ((central_ay + radius_a)<=8) ? central_ay + radius_a - 1 : 3'h7 ;
assign Yb_up = ((central_by + radius_b)<=8) ? central_by + radius_b - 1 : 3'h7 ;
assign Yc_up = ((central_cy + radius_c)<=8) ? central_cy + radius_c - 1 : 3'h7 ;
assign Xa_down = ((central_ax - radius_a)<=0) ? central_ax - radius_a - 1 : 3'h0 ;
assign Xb_down = ((central_bx - radius_a)<=0) ? central_bx - radius_a - 1 : 3'h0 ;
assign Xc_down = ((central_cx - radius_a)<=0) ? central_cx - radius_a - 1 : 3'h0 ;
assign Ya_down = ((central_ay - radius_a)<=0) ? central_ay - radius_a - 1 : 3'h0 ;
assign Yb_down = ((central_by - radius_a)<=0) ? central_by - radius_a - 1 : 3'h0 ;
assign Yc_down = ((central_cy - radius_a)<=0) ? central_cy - radius_a - 1 : 3'h0 ;
 */
always@(posedge clk or posedge rst)
if(rst)
	begin
		mode_reg    <= 2'd0;
		central_reg <= 24'd0;
		radius_reg  <= 12'd0;
	end
else if(en)
	begin
		mode_reg    <= mode;
		central_reg <= central;
		radius_reg  <= radius;
	end

always@(posedge clk or posedge rst)
	if(rst)
		cur_st <= 4'h0;
	else
		cur_st <= nex_st;

always@(*)
	case(cur_st)
		IDLE     :  nex_st = (en) ? mode_a : IDLE;
		mode_a	 :  nex_st = (mode_reg == 2'b00) ? cclate : mode_b;
		mode_b	 :	nex_st = (mode_reg == 2'b11) ? mode_c : cclate;
		mode_c	 :  nex_st = cclate;
		cclate	 :	nex_st = (X==3'd7 && Y==3'd7) ? out : mode_a;
		out		 :  nex_st = IDLE;
		default  :  nex_st = IDLE;
	endcase
/* always@(*)
	case(cur_st)
		IDLE     : 
					if(en)
						case(mode)
							2'b00 : nex_st = mode1a;
							2'b01 : nex_st = mode2a;
							2'b10 : nex_st = mode3a;
							2'b11 : nex_st = mode4a;
						endcase
					else
				   nex_st = IDLE;
		mode1a   : nex_st = cclate;
        mode2a   : nex_st = mode2b;
        mode2b   : nex_st = cclate;
		mode3a   : nex_st = mode3b;
		mode3b   : nex_st = cclate;
		mode4a   : nex_st = mode4b;
		mode4b   : nex_st = mode4c;
		mode4c   : nex_st = cclate;
		cclate   : 
					if(X==3'd7 && Y==3'd7)
						nex_st = out;
					else
						case(mode_reg)
							2'b00 : nex_st = mode1a;
							2'b01 : nex_st = mode2a;
							2'b10 : nex_st = mode3a;
							2'b11 : nex_st = mode4a;
						endcas
		out      : nex_st = IDLE;
		default  : nex_st = IDLE;
	endcase */

always@(posedge clk or posedge rst)
	if(rst)
		Y <= 3'd0;
	else if(cur_st==cclate)
		Y <= Y+1'b1; 

always@(posedge clk or posedge rst)
	if(rst)
		X <= 3'd0;
	else if(cur_st==cclate && Y==3'b111)
		X <= X+1'b1;

assign busy = (cur_st!=IDLE);
assign valid = (cur_st==out);
assign candidate = (cur_st==out) ? count : 8'd0;

always@(posedge clk or posedge rst)
	if(rst)
		judge <= 2'd0 ;
	else if (cur_st == mode_a)//a
		judge <= judge + point_in(X ,Y , radius_a , central_ax ,central_ay);
	else if(cur_st == mode_b)//b
		judge <= judge + point_in(X ,Y , radius_b , central_bx ,central_by);
	else if(cur_st == mode_c)//c
		judge <= judge + point_in(X ,Y , radius_c , central_cx ,central_cy);
	else
		judge <= 2'd0 ;
		
always@(posedge clk or posedge rst)
	if(rst)
		count <= 8'd0 ;
	else if ((cur_st==cclate)&&((mode_reg[0]==0 && judge==2'd1) || (mode_reg[0]==1 && judge==2'd2)))
		count <= count + 1'b1 ;
	else if (cur_st==out)
		count <= 8'd0 ;
					
					
					

function point_in;
input [2:0] X, Y, radius;
input [3:0] central_x, central_y;

reg signed [4:0] X_dis, Y_dis;
reg signed [9:0] X_sqr, Y_sqr;
reg [5:0] radius_sqr;
reg [10:0] dis_sum;
begin
	X_dis = X - (central_x - 1'b1);
	Y_dis = Y - (central_y - 1'b1);  
	X_sqr = X_dis * X_dis;
	Y_sqr = Y_dis * Y_dis;
	radius_sqr = radius * radius;	
	dis_sum = X_sqr + Y_sqr;
	point_in = (dis_sum <= radius_sqr);
end
endfunction	 
	
endmodule


