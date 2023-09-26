
// 64 bit recursive adder....
module adder_64bit (a, b, cin, sum, cout);

    input [63:0] a, b;
    input cin;
    output reg [63:0] sum;
    output reg cout;

    wire [63:0] partial_sum;
    wire [64:0] carry, carry_1, carry_2, carry_4, carry_8, carry_16, carry_32, carry_64;
    wire [64:0] p, p_1, p_2, p_4, p_8, p_16, p_32, p_64;

    assign carry[0] = cin;
    assign p[0] = 0;

    always @(*) begin    
        // checking condtions 
        if(a == 0) begin
            sum = b;
            cout = 0;
        end
        else if(b == 0) begin
            sum = a;
            cout = 0;
        end
        else if(~a == 0 || ~b == 0) begin  // overflow condition if all bits are 1
            sum = {64{1'b1}};
            cout = 1'b1;
        end
        else begin 
            sum = partial_sum[63:0] ^ carry_64[63:0];
            cout = carry_64[64];
        end

    end

    // kpg initialise....
    genvar i;
    generate
        for(i=0; i<64; i=i+1) begin
            kpg_init k1(a[i], b[i], p[i+1], carry[i+1]);
        end
    endgenerate

    assign p_1[0] = cin;
    assign carry_1[0] = cin;

    assign p_2[1:0] = p_1[1:0];
    assign carry_2[1:0] = carry_1[1:0];
    
    assign p_4[3:0] = p_2[3:0];
    assign carry_4[3:0] = carry_2[3:0];
    
    assign p_8[7:0] = p_4[7:0];
    assign carry_8[7:0] = carry_4[7:0];
    
    assign p_16[15:0] = p_8[15:0];
    assign carry_16[15:0] = carry_8[15:0];
    
    assign p_32[31:0] = p_16[31:0];
    assign carry_32[31:0] = carry_16[31:0]; 
    
    assign p_64[63:0] = p_32[63:0];
    assign carry_64[63:0] = carry_32[63:0];

    
    kpg iteration_1  [64:1]  (p[64:1],     carry[64:1],     p[63:0],    carry[63:0],    p_1[64:1],  carry_1[64:1]);
    kpg iteration_2  [64:2]  (p_1[64:2],   carry_1[64:2],   p_1[62:0],  carry_1[62:0],  p_2[64:2],  carry_2[64:2]);
    kpg iteration_4  [64:4]  (p_2[64:4],   carry_2[64:4],   p_2[60:0],  carry_2[60:0],  p_4[64:4],  carry_4[64:4]);
    kpg iteration_8  [64:8]  (p_4[64:8],   carry_4[64:8],   p_4[56:0],  carry_4[56:0],  p_8[64:8],  carry_8[64:8]);
    kpg iteration_16 [64:16] (p_8[64:16],  carry_8[64:16],  p_8[48:0],  carry_8[48:0],  p_16[64:16], carry_16[64:16]);
    kpg iteration_32 [64:32] (p_16[64:32], carry_16[64:32], p_16[32:0], carry_16[32:0], p_32[64:32], carry_32[64:32]);
    kpg iteration_64 [64:64] (p_32[64:64], carry_32[64:64], p_32[0:0],  carry_32[0:0],  p_64[64:64], carry_64[64:64]);

    assign partial_sum = a^b;


endmodule


module kpg_init ( input a, b, output p, carry );
	xor (p,a,b);
	and (carry,a,b);

endmodule


module kpg ( input current_p, current_carry, from_p, from_carry, output final_p, final_carry );
	wire x,y,not_current_p;

	and p(final_p, from_p, current_p);
	not current_p_invert(not_current_p, current_p);
	and c_prod1(x, not_current_p, current_carry);
	and c_prod2(y, current_p, from_carry);
	or c(final_carry, x, y);

endmodule



