`include "CED19I028_KPG_mod.v"


module RDCLA (in1, in2, cin, sum, cout);

	input [63:0] in1, in2;
	input cin;
	output [63:0] sum;
	output cout;

	wire [64:0] carr1, carr1_1, carr1_2, carr1_4, carr1_8, carr1_16, carr1_32;
	wire [64:0] carr0, carr0_1, carr0_2, carr0_4, carr0_8, carr0_16, carr0_32;

	assign carr0[0] = cin;
	assign carr1[0] = cin;

	assign carr1_1[0] = cin;
	assign carr0_1[0] = cin;
	assign carr1_2[1:0] = carr1_1[1:0];
	assign carr0_2[1:0] = carr0_1[1:0];
	assign carr1_4[3:0] = carr1_2[3:0];
	assign carr0_4[3:0] = carr0_2[3:0];
	assign carr1_8[7:0] = carr1_4[7:0];
	assign carr0_8[7:0] = carr0_4[7:0];
	assign carr1_16[15:0] = carr1_8[15:0];
	assign carr0_16[15:0] = carr0_8[15:0];
	assign carr1_32[31:0] = carr1_16[31:0];
	assign carr0_32[31:0] = carr0_16[31:0];

	KPGS start [64:1] (carr1[64:1], carr0[64:1], in1[63:0], in2[63:0]);

	// stage 1
	KPG kpg1 [64:1] (carr1[64:1], carr0[64:1], carr1[63:0], carr0[63:0], carr1_1[64:1], carr0_1[64:1]);
	// stage 2
	KPG kpg2 [64:2] (carr1_1[64:2], carr0_1[64:2], carr1_1[62:0], carr0_1[62:0], carr1_2[64:2], carr0_2[64:2]);
	// stage 3
	KPG kpg4 [64:4] (carr1_2[64:4], carr0_2[64:4], carr1_2[60:0], carr0_2[60:0], carr1_4[64:4], carr0_4[64:4]);
	// stage 4
	KPG kpg8 [64:8] (carr1_4[64:8], carr0_4[64:8], carr1_4[56:0], carr0_4[56:0], carr1_8[64:8], carr0_8[64:8]);
	// stage 5
	KPG kpg16 [64:16] (carr1_8[64:16], carr0_8[64:16], carr1_8[48:0], carr0_8[48:0], carr1_16[64:16], carr0_16[64:16]);
	// stage 6
	KPG kpg32 [64:32] (carr1_16[64:32], carr0_16[64:32], carr1_16[32:0], carr0_16[32:0], carr1_32[64:32], carr0_32[64:32]);


	wire [63:0] temp1;
	generate 
			assign temp1 = in1^in2;
			assign sum = temp1[63:0]^carr0_16[63:0];
			assign cout = carr0_16[64];	
	endgenerate


endmodule
