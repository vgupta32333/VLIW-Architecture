
// double precision floating point number...
module double_multiplier ( a, b, out );
    input [63:0] a, b;
    output reg [63:0] out;

    output [52:0] out1, out2;
    output [104:0] out3;
    output out4, out5, out6;
    output [10:0] out7;
    output [51:0] out8;

    wire s1,s2;		// sign bits
    wire [10:0] e1, e2;
    wire [52:0] m1, m2;

    wire [105:0] prodWithCarry;
    wire [104:0] prod;
    wire [52:0] prodTruncated;
    wire prodCarry;

    wire tempS1;
    wire [10:0] tempE3;
    wire [51:0] tempM3;


    reg s3;
    reg [10:0] e3;
    reg [51:0] m3;

    assign s1 = a[63];
    assign s2 = b[63];

    assign e1 = a[62:52];
    assign e2 = b[62:52];

    assign m1 = {1'b1,a[51:0]};
    assign m2 = {1'b1,b[51:0]};

    multiplier_53bits m53_1(m1 ,m2, prodWithCarry);
    assign prod = prodWithCarry[104:0];
    assign prodTruncated = prod[104:52];
    assign prodCarry = prodWithCarry[105];


    // normalise the result
    reg[52:0] temp;
    always @(*) begin
        s3 = s1^s2;				// sign bits of result...
        e3 = e1 + e2 - 1023;    // exponent1 + exponent2 + bias 
        
		if(prodCarry == 1)begin
            m3=prodTruncated[52:1];
            e3 = e3 + 1;
        end
        else begin
            if (prodTruncated[52]) begin
                m3 = prodTruncated[51:0];
            end
            else begin
                temp = prodTruncated;
                while(temp[52]!=1'b1) begin
                    temp[52:1] = temp[51:0];
                    e3 = e3 - 1;
                end
                m3 = temp[51:0];
            end
        end

		// if infinity...
		if(e1 == 2047 || e2 == 2047) 
			out = {64{1'b1}};
		else if ((e1 == 0 && m1[51:0] == 0) || (e2 == 0 && m2[51:0] == 0))	// if any of them is zero
			out = 0;
		else 
        	out = {s3, e3, m3};
    end

endmodule



module multiplier_53bits ( a, b, actual_output );

    input [52:0] a, b;
    wire [107:0] out;
    output [105:0] actual_output;

    //partial product generation
    integer i;
    reg[106:0] pp[0:52];
    always @(*) begin
        for (i = 0; i<53; i++) begin
            if(b[i] == 1) begin
                pp[i] = (a << i);
            end
            else begin
                pp[i] = 106'b0;
            end
        end
    end

	// u means sum, v means carry..
	wire [106:0] u1_1, u1_2, u1_3, u1_4, u1_5, u1_6, u1_7, u1_8, u1_9, u1_10, u1_11, u1_12, u1_13, u1_14, u1_15, u1_16, u1_17;
	wire [106:0] v1_1, v1_2, v1_3, v1_4, v1_5, v1_6, v1_7, v1_8, v1_9, v1_10, v1_11, v1_12, v1_13, v1_14, v1_15, v1_16, v1_17;

	// stage 1
	carrySaveAdder csa1_1(pp[0],pp[1],pp[2],u1_1,v1_1);
	carrySaveAdder csa1_2(pp[3],pp[4],pp[5],u1_2,v1_2);   
	carrySaveAdder csa1_3(pp[6],pp[7],pp[8],u1_3,v1_3);   
	carrySaveAdder csa1_4(pp[9],pp[10],pp[11],u1_4,v1_4); 
	carrySaveAdder csa1_5(pp[12],pp[13],pp[14],u1_5,v1_5);
	carrySaveAdder csa1_6(pp[15],pp[16],pp[17],u1_6,v1_6);
	carrySaveAdder csa1_7(pp[18],pp[19],pp[20],u1_7,v1_7);
	carrySaveAdder csa1_8(pp[21],pp[22],pp[23],u1_8,v1_8);
	carrySaveAdder csa1_9(pp[24],pp[25],pp[26],u1_9,v1_9);
	carrySaveAdder csa1_10(pp[27],pp[28],pp[29],u1_10,v1_10);
	carrySaveAdder csa1_11(pp[30],pp[31],pp[32],u1_11,v1_11);
	carrySaveAdder csa1_12(pp[33],pp[34],pp[35],u1_12,v1_12);
	carrySaveAdder csa1_13(pp[36],pp[37],pp[38],u1_13,v1_13);
	carrySaveAdder csa1_14(pp[39],pp[40],pp[41],u1_14,v1_14);
	carrySaveAdder csa1_15(pp[42],pp[43],pp[44],u1_15,v1_15);
	carrySaveAdder csa1_16(pp[45],pp[46],pp[47],u1_16,v1_16);
	carrySaveAdder csa1_17(pp[48],pp[49],pp[50],u1_17,v1_17);
	//pp[51],pp[52]


	// u means sum, v means carry..
	wire [106:0] u2_1, u2_2, u2_3, u2_4, u2_5, u2_6, u2_7, u2_8, u2_9, u2_10, u2_11, u2_12;
	wire [106:0] v2_1, v2_2, v2_3, v2_4, v2_5, v2_6, v2_7, v2_8, v2_9, v2_10, v2_11, v2_12;

	// stage 2
	carrySaveAdder csa2_1(u1_1,v1_1,u1_2,u2_1,v2_1);
	carrySaveAdder csa2_2(u1_3,v1_2,v1_3,u2_2,v2_2);
	carrySaveAdder csa2_3(u1_4,v1_4,u1_5,u2_3,v2_3);
	carrySaveAdder csa2_4(u1_6,v1_5,v1_6,u2_4,v2_4);
	carrySaveAdder csa2_5(u1_7,v1_7,u1_8,u2_5,v2_5);
	carrySaveAdder csa2_6(u1_9,v1_8,v1_9,u2_6,v2_6);
	carrySaveAdder csa2_7(u1_10,v1_10,u1_11,u2_7,v2_7);
	carrySaveAdder csa2_8(u1_12,v1_11,v1_12,u2_8,v2_8);
	carrySaveAdder csa2_9(u1_13,v1_13,u1_14,u2_9,v2_9);
	carrySaveAdder csa2_10(u1_15,v1_14,v1_15,u2_10,v2_10);
	carrySaveAdder csa2_11(u1_16,v1_16,u1_17,u2_11,v2_11);
	carrySaveAdder csa2_12(pp[51],v1_17,pp[52],u2_12,v2_12);


	// u means sum, v means carry..
	wire [106:0] u3_1, u3_2, u3_3, u3_4, u3_5, u3_6, u3_7, u3_8;
	wire [106:0] v3_1, v3_2, v3_3, v3_4, v3_5, v3_6, v3_7, v3_8;
	// stage 3
	carrySaveAdder csa3_1(u2_1,v2_1,u2_2,u3_1,v3_1);
	carrySaveAdder csa3_2(u2_3,v2_2,v2_3,u3_2,v3_2);
	carrySaveAdder csa3_3(u2_4,v2_4,u2_5,u3_3,v3_3);
	carrySaveAdder csa3_4(u2_6,v2_5,v2_6,u3_4,v3_4);
	carrySaveAdder csa3_5(u2_7,v2_7,u2_8,u3_5,v3_5);
	carrySaveAdder csa3_6(u2_9,v2_8,v2_9,u3_6,v3_6);
	carrySaveAdder csa3_7(u2_10,v2_10,u2_11,u3_7,v3_7);
	carrySaveAdder csa3_8(u2_12,v2_11,v2_12,u3_8,v3_8);

	// u means sum, v means carry..
	wire [106:0] u4_1, u4_2, u4_3, u4_4, u4_5;
	wire [106:0] v4_1, v4_2, v4_3, v4_4, v4_5;
	// stage 4
	carrySaveAdder csa4_1(u3_1,v3_1,u3_2,u4_1,v4_1);
	carrySaveAdder csa4_2(u3_3,v3_2,v3_3,u4_2,v4_2);
	carrySaveAdder csa4_3(u3_4,v3_4,u3_5,u4_3,v4_3);
	carrySaveAdder csa4_4(u3_6,v3_5,v3_6,u4_4,v4_4);
	carrySaveAdder csa4_5(u3_7,v3_7,u3_8,u4_5,v4_5);
	// v3_8

	// u means sum, v means carry..
	wire [106:0] u5_1, u5_2, u5_3;
	wire [106:0] v5_1, v5_2, v5_3;
	// stage 5
	carrySaveAdder csa5_1(u4_1,v4_1,u4_2,u5_1,v5_1);
	carrySaveAdder csa5_2(u4_3,v4_2,v4_3,u5_2,v5_2);
	carrySaveAdder csa5_3(u4_4,v4_4,u4_5,u5_3,v5_3);
	// v3_8,v4_5

	// stage 6
	wire [106:0] u6_1,v6_1,u6_2,v6_2;
	carrySaveAdder csa6_1(u5_1,v5_1,u5_2,u6_1,v6_1);
	carrySaveAdder csa6_2(u5_3,v5_2,v5_3,u6_2,v6_2);
	// v3_8,v4_5

	// stage 7
	wire [106:0] u7_1,v7_1,u7_2,v7_2;
	carrySaveAdder csa7_1(u6_1,v6_1,u6_2,u7_1,v7_1);
	carrySaveAdder csa7_2(v3_8,v6_2,v4_5,u7_2,v7_2);

	// stage 8
	wire [106:0] u8_1,v8_1;
	carrySaveAdder csa8_1(u7_1,v7_1,u7_2,u8_1,v8_1);
	// v7_2

	// stage 9
	wire [106:0] u9_1,v9_1;
	carrySaveAdder csa9_1(u8_1,v8_1,v7_2,u9_1,v9_1);

	adder at(u9_1,v9_1,out);

	assign actual_output = out[105:0];

endmodule


//106 bit carry save adder
module carrySaveAdder ( a, b, c, sum, cout );

    input[106:0] a, b, c;
    output[106:0] sum, cout;

    genvar i;
    generate
        for(i=0; i<106; i=i+1)begin
            fullAdder fa(a[i], b[i], c[i], sum[i], cout[i+1]);
        end
    endgenerate 

    assign sum[106] = 1'b0;
    assign cout[0] = 1'b0;

endmodule


// add final results..
module adder ( A, B, out );

    input [106:0] A,B;
    output [107:0] out;
    wire [106:0] sum,temp;

    genvar j;
    fullAdder f1(A[0],B[0],1'b0,sum[0],temp[0]);//cin is 0 for 1st adder
    generate
        for(j=1; j<107; j=j+1)begin
            fullAdder f(A[j], B[j], temp[j-1], sum[j], temp[j]);   //temp[j] holds carry out from jth bit
        end
    endgenerate
    assign out = {temp[106], sum};  //temp[127] holds final carry

endmodule


// full adder
module fullAdder(a, b, cin, sum, cout);
    input a, b, cin;
    output sum, cout;
    wire w1, w2, w3, w4, w5;

    xor (w1, a, b);
    xor (sum, w1, cin);
    and (w2, a, b);
    and (w3, a, cin);
    and (w4, b, cin);
    or (w5, w2, w3);
    or (cout, w4, w5);

endmodule


// doing left shift operations
module leftshift ( A, shift, out );

    input [53:0] A;
    input [5:0] shift;
    output reg [53:0] out;
    integer i;
    always @(*) begin
        i = shift;
        out = A << i;
    end

endmodule

// doing right shift operations 
module rightshift ( A, shift, out );
  
    input [52:0] A;
    input [5:0] shift;
    output reg [52:0] out;
    integer i;
    always @(*) begin
        i = shift;
        out = A >> i;
    end

endmodule


