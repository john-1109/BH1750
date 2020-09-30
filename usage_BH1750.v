module usage_BH1750(sys_clk, _rst, SCL, SDA, Tx, CS, CLK, Din);
input sys_clk, _rst;
inout SDA, SCL;	
output Tx, CS, CLK, Din;
//---------------------------------------------------//		
reg [7:0]display[7:0];
reg [3:0]IRreg = 4'b0000;
reg [7:0]data = 8'h00;
wire busy, display_busy;
wire [15:0]Rxdata;	
//---------------------------------------------------//	
	BH1750 #(.Freq_MegaHZ(50))
		U0(
			.sys_clk(sys_clk),
			._rst(_rst),
			.str(1'b1),
			.SCL(SCL),
			.SDA(SDA),
			.data(Rxdata),
			.busy(busy)
	);
			
	UART_transmits U1(
		.clk(sys_clk),
		.TxD_start(~(busy)),
		.TxD_data(Rxdata[15:8]),
		.TxD(Tx),
		.TxD_busy()
	);
	
	MAX7219#(.Freq_MegaHZ(50))
		U2(
			.sys_clk(sys_clk),
			._rst(_rst),
			.str(1'b1),
			.busy(display_busy),
			.IRreg({4'b0000,IRreg}),
			.data(data),
			.CS(CS),
			.CLK(CLK),
			.Din(Din)
	);
//---------------------------------------------------//
	always@(*)begin
		display[0] = 8'b11111111;
		display[1] = 8'b00111100;
		display[2] = 8'b00111100;
		display[3] = 8'b11100111;
		display[4] = 8'b11100111;
		display[5] = 8'b00111100;
		display[6] = 8'b00111100;
		display[7] = 8'b11111111;
	end
//---------------------------------------------------//	
	always@(negedge display_busy, negedge _rst)begin
		if(!_rst)
			IRreg <= 4'd0;
		else
			IRreg <= IRreg + 1;
	end
//---------------------------------------------------//
	reg [3:0]light_value = 4'h0;
	always@(IRreg)begin
		if((Rxdata>>9)>15)
			light_value = 4'hF;
		else
			light_value = Rxdata/512;
		case(IRreg)
			4'h0:data  = 8'h00;
			4'h1:data  = display[0];
			4'h2:data  = display[1];
			4'h3:data  = display[2];
			4'h4:data  = display[3];
			4'h5:data  = display[4];
			4'h6:data  = display[5];
			4'h7:data  = display[6];
			4'h8:data  = display[7];
			4'h9:data  = 8'h00;//decode mode
			4'hA:data  = light_value;//light(0~15)
			4'hB:data  = 8'h07;//scanline(0~7)
			4'hC:data  = {7'b0000000,1'b1};//shutdown
			4'hF:data  = 8'h00;//test
			default:data  = 8'h00;
		endcase
	end
//---------------------------------------------------//
endmodule 