module usage_BH1750(sys_clk, _rst, SCL, SDA);
input sys_clk, _rst;
inout SDA, SCL;	
//---------------------------------------------------//		
wire busy;//refresh the data as negedge
wire [15:0]Rxdata;//get data from BH1750 per 1'S
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
//---------------------------------------------------//
endmodule 
