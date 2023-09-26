//  left and right shift module..

module left_shift(A, shift, out);
    input [53:0] A;
    input [5:0] shift;
    output reg [53:0] out;

    integer k;
    always @(shift) begin
        k = shift;
        out = A << k;
    end

endmodule

module right_shift(A, shift, out);
    input [52:0] A;
    input [5:0] shift;
    output reg [52:0] out;

    integer k;
    always @(shift) begin
        k = shift;
        out = A >> k;
    end

endmodule


//  addtion and subtraction module..

module add_sub(A, B, cin, sum);
    input [52:0] A, B;
    input cin;
    output reg [53:0] sum;

    always @(A, B, cin) begin
        if(!cin)
            sum = A + B;
        else
            sum = A - B;
    end

endmodule



module fp_adder(a, b, out);
	input [63:0] a, b;
	output reg [63:0] out;

    reg S1, S2, S3;				// signed bits
	reg [10:0] E1, E2, E3, D;	// exponents, D = E1-E2
	reg [52:0] M1, M2;			// i bit extra bcoz in form of 1.010101		
	reg [51:0] M3_final;
	reg [5:0] normalizer_shift, actual_shift;

	wire [53:0] M3, M3_normalised;
	wire [52:0] M2_shifted;

	integer q;
    right_shift rs(M2, D[5:0], M2_shifted);
	add_sub as(M1, M2_shifted, S1^S2, M3);
	left_shift ls(M3, normalizer_shift, M3_normalised);

    always @(*) begin

        // extract values
		S1 = a[63];
		S2 = b[63];
		E1 = a[62:52];
		E2 = b[62:52];
		M1 = {1'b1,a[51:0]};
		M2 = {1'b1,b[51:0]};


        // swap X1, X2 if |X2|>|X1|
		if(E2>E1 || (E1 == E2 && M2>M1)) begin
			S1 = b[63];
			S2 = a[63];
			E1 = b[62:52];
			E2 = a[62:52];
			M1 = {1'b1,b[51:0]};
			M2 = {1'b1,a[51:0]};

		end


		// Denormalize M2.. shift will happen in module
		S3 = S1;
		D = E1 - E2;
		if(D >= 52)		// if right-shift is more than 52 then its 0;
			D = 11'd52;


		// normalize result...   1.1010101
		normalizer_shift = 0;
		while (M3[53-normalizer_shift] == 1'b0 && normalizer_shift < 53) begin
			normalizer_shift = normalizer_shift + 1;
		end
		actual_shift = normalizer_shift - 1 ; 

		// if 53th bit is 1 then.
		if(M3[53] == 1'b1) begin
			M3_final = M3[52:1];
			E3 = E1 + 1'b1;
		end

		// if 52th bit is 1, then no need to normalize results, print the same.
		else if(M3[52] == 1'b1) begin
			M3_final = M3[51:0];
			E3 = E1;
		end

		else begin
			M3_final = M3_normalised[52:1];
			E3 = E1 - actual_shift;
		end

		// checking for infinity, 0, NaN
		// if exponent is 255 then its consider infinity..
		if(E1 == 11'hff || E2 == 11'hff)
			out = 64'b0111111111111111111111111111111111111111111111111111111111111111;
		// if a is 0
		else if(a[62:0] == 0) 
			out = b;
		// if b is 0
		else if(b[62:0] == 0)
			out = a;
		else if(M3_normalised == 0)
			out = 64'b0;
		else
			out = { S3, E3, M3_final};

    end

endmodule

