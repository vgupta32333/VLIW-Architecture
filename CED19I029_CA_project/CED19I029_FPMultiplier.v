module fullAdder (
    in1,in2,cin,sum,cout
);
    input in1,in2,cin;
    output sum,cout;
    wire temp1,temp2,temp3;

    xor(sum,in1,in2,cin);
    and(temp1,in1,in2);
    and(temp2,in2,cin);
    and(temp3,cin,in1);
    or(cout,temp1,temp2,temp3);
endmodule

//106 bit carry save adder
module carrySaveAdder (
    in1,in2,in3,sum,cout
);
    input[106:0] in1,in2,in3;
    output[106:0] sum,cout;

    genvar i;
    // fullAdder fa1(in1[0],in2[0]);
    generate
        for(i=0;i<106;i=i+1)begin
            fullAdder fa(in1[i],in2[i],in3[i],sum[i],cout[i+1]);
        end
    endgenerate 
    assign sum[106]=1'b0;
    assign cout[0]=1'b0;
endmodule

module cla64bit(in1,in2,cin,sum,cout);
    input [63:0] in1,in2;
    input cin;
    output [63:0] sum;
    // output reg [1:0] temp;
    output cout;
    wire [127:0] kpg,kpg1,kpg2,kpg3,kpg4,kpg5,kpg6;
    wire [63:0] xor_sum,carry;

    genvar i,j,k;
    generate
        for (i=0 ;i<64;i=i+1 ) begin
            assign kpg[2*i]=in1[i];
            assign kpg[(2*i)+1]=in2[i];
        end
    endgenerate

    assign xor_sum=in1^in2;
    reg [1:0] temp;
    always @(*) begin
        if (kpg[1:0]==2'b01 | kpg[1:0]==2'b10) begin
            if(cin==1'b1) begin
                temp=2'b11;
            end
            else begin 
                temp=kpg[1:0];
            end
        end
        else begin
            temp=kpg[1:0];
        end
        // temp=2'b00;
    end
// stage 1
    assign kpg1[1:0]=temp;
    generate
        for(i=0;i<125;i=i+2)begin
            parallelprefix pp(kpg[(i+3):(i+2)],kpg[(i+1):i],kpg1[(i+3):(i+2)]);
        end
    endgenerate

// stage 2
    assign kpg2[3:2]=kpg1[3:2];
    assign kpg2[1:0]=kpg1[1:0];
    generate
        for(i=0;i<123;i=i+2)begin
            parallelprefix pp(kpg1[(i+5):(i+4)],kpg1[(i+1):i],kpg2[(i+5):(i+4)]);
        end
    endgenerate

// stage 3
    assign kpg3[7:6]=kpg2[7:6];
    assign kpg3[5:4]=kpg2[5:4];
    assign kpg3[3:2]=kpg2[3:2];
    assign kpg3[1:0]=kpg2[1:0];

    generate
        for(i=0;i<119;i=i+2)begin
            parallelprefix pp(kpg2[(i+9):(i+8)],kpg2[(i+1):i],kpg3[(i+9):(i+8)]);
        end
    endgenerate

// stage 4
    generate
        for (i=0;i<15;i=i+2) begin
            assign kpg4[i+1:i]=kpg3[i+1:i];
        end
    endgenerate
    generate
        for(i=0;i<111;i=i+2)begin
            parallelprefix pp(kpg3[(i+17):(i+16)],kpg3[(i+1):i],kpg4[(i+17):(i+16)]);
        end
    endgenerate

// stage 5
    generate
        for (i=0;i<31;i=i+2) begin
            assign kpg5[i+1:i]=kpg4[i+1:i];
        end
    endgenerate
    generate
        for(i=0;i<95;i=i+2)begin
            parallelprefix pp(kpg4[(i+33):(i+32)],kpg4[(i+1):i],kpg5[(i+33):(i+32)]);
        end
    endgenerate

// stage 6
    generate
        for (i=0;i<63;i=i+2) begin
            assign kpg6[i+1:i]=kpg5[i+1:i];
        end
    endgenerate
    generate
        for(i=0;i<63;i=i+2)begin
            parallelprefix pp(kpg5[(i+65):(i+64)],kpg5[(i+1):i],kpg6[(i+65):(i+64)]);
        end
    endgenerate

    generate
        for (i=0 ;i<64;i=i+1 ) begin
            assign carry[i]=kpg6[(2*i)+1];
        end
    endgenerate

    assign sum[0] = xor_sum[0]^cin;
    assign sum[63:1]=xor_sum[63:1]^carry[62:0];
    assign cout = carry[63];
    // assign temp=kgp[1:0];
endmodule

module parallelprefix(in1,in2,out);
    input [1:0] in1, in2;
    // input cin;
    output reg [1:0] out;

    always@(*) begin
        if (in1 == 2'b00 || in1 == 2'b11)//if prev state is K or G next also K or G
            assign out = in1;
        else//next state is whatever is prev state
            assign out = in2;
    end
endmodule

// add last 2 numbers
module addertest (
    in1,in2,out
);
    input [128:0] in1,in2;
    output [129:0] out;
    wire [128:0] sum,temp;
    wire cout1,cout2,finalc;
    cla64bit c1(in1[63:0],in2[63:0],1'b0,out[63:0],cout1);
    cla64bit c2(in1[127:64],in2[127:64],cout1,out[127:64],cout2);
    fullAdder fa1(in1[128],in2[128],cout2,out[128],finalc);

    assign out[129]=finalc;
endmodule

module multiplier53bit (
    in1,in2,actualout
);
    input [52:0] in1,in2;
    wire [129:0] out;
    output [105:0] actualout;

    //partial product generation
    integer i;
    reg[106:0] pp[0:52];
    always @(*) begin
        for (i = 0; i<53; i++) begin
            if(in2[i]==1) begin
                pp[i] =in1 << i;
            end
            else begin
                pp[i] = 106'b0;
            end
        end
    end


wire [106:0] u1_1,v1_1,u1_2,v1_2,u1_3,v1_3,u1_4,v1_4,u1_5,v1_5,u1_6,v1_6,u1_7,v1_7,u1_8,v1_8,u1_9,v1_9,u1_10,v1_10,u1_11,v1_11,u1_12,v1_12,u1_13,v1_13,u1_14,v1_14,u1_15,v1_15,u1_16,v1_16,u1_17,v1_17;
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

// stage 2
wire [106:0] u2_1,v2_1,u2_2,v2_2,u2_3,v2_3,u2_4,v2_4,u2_5,v2_5,u2_6,v2_6,u2_7,v2_7,u2_8,v2_8,u2_9,v2_9,u2_10,v2_10,u2_11,v2_11,u2_12,v2_12;
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

// stage 3
wire [106:0] u3_1,v3_1,u3_2,v3_2,u3_3,v3_3,u3_4,v3_4,u3_5,v3_5,u3_6,v3_6,u3_7,v3_7,u3_8,v3_8;
carrySaveAdder csa3_1(u2_1,v2_1,u2_2,u3_1,v3_1);
carrySaveAdder csa3_2(u2_3,v2_2,v2_3,u3_2,v3_2);
carrySaveAdder csa3_3(u2_4,v2_4,u2_5,u3_3,v3_3);
carrySaveAdder csa3_4(u2_6,v2_5,v2_6,u3_4,v3_4);
carrySaveAdder csa3_5(u2_7,v2_7,u2_8,u3_5,v3_5);
carrySaveAdder csa3_6(u2_9,v2_8,v2_9,u3_6,v3_6);
carrySaveAdder csa3_7(u2_10,v2_10,u2_11,u3_7,v3_7);
carrySaveAdder csa3_8(u2_12,v2_11,v2_12,u3_8,v3_8);

// stage 4
wire [106:0] u4_1,v4_1,u4_2,v4_2,u4_3,v4_3,u4_4,v4_4,u4_5,v4_5;
carrySaveAdder csa4_1(u3_1,v3_1,u3_2,u4_1,v4_1);
carrySaveAdder csa4_2(u3_3,v3_2,v3_3,u4_2,v4_2);
carrySaveAdder csa4_3(u3_4,v3_4,u3_5,u4_3,v4_3);
carrySaveAdder csa4_4(u3_6,v3_5,v3_6,u4_4,v4_4);
carrySaveAdder csa4_5(u3_7,v3_7,u3_8,u4_5,v4_5);
// v3_8

// stage 5
wire [106:0] u5_1,v5_1,u5_2,v5_2,u5_3,v5_3;
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

addertest at({22'b0,u9_1},{22'b0,v9_1},out);

assign actualout=out[105:0];
endmodule


module leftshift (
    in,mag,out
);
    input [53:0] in;
    input [5:0] mag;
    output reg [53:0] out;
    integer i;
    always @(*) begin
        i=mag;
        out=in << i;
    end
endmodule

module rightshift (
    in,mag,out
);
    input [52:0] in;
    input [5:0] mag;
    output reg [52:0] out;
    integer i;
    always @(*) begin
        i=mag;
        out=in >> i;
    end
endmodule


module fpm (
    in1,in2,out
);
    input [63:0] in1,in2;
    output reg [63:0] out;

    reg s1,s2;
    reg [10:0] e1,e2;
    reg [52:0] m1,m2;

    wire [105:0] prodWithCarry;
    wire [104:0] prod;
    wire [52:0] prodTruncated;
    wire prodCarry;

    wire [51:0] zeros52;
    assign zeros52=52'b0000000000000000000000000000000000000000000000000000;
    wire [51:0] ones52;
    assign ones52=52'b1111111111111111111111111111111111111111111111111111;
    wire [10:0] zeros11;
    assign zeros11=11'b00000000000;
    wire [10:0] ones11;
    assign ones11=11'b11111111111;

    reg s3;
    reg [10:0] e3;
    reg [51:0] m3;

    multiplier53bit m53_1(m1,m2,prodWithCarry);
    assign prod=prodWithCarry[104:0];
    assign prodTruncated=prod[104:52];
    assign prodCarry=prodWithCarry[105];
    // reg [1:0] condcheck;

    // normalization
    reg[52:0] temp;
    always @(*) begin

        s1=in1[63];
        s2=in2[63];

        e1=in1[62:52];
        e2=in2[62:52];

        m1={1'b1,in1[51:0]};
        m2={1'b1,in2[51:0]};
        // if ((e1==11'b1)||(e2==11'b1)) begin
        //     condcheck=2'b00;
        // end
        // else begin
        //     condcheck=2'b11;
        // end
        s3=s1^s2;
        e3=e1+e2-1023;
        if(prodCarry==1)begin
            m3=prodTruncated[52:1];
            // temp[52]=carry;
            e3=e3+1;
            // m3=temp[51:0]
        end
        else begin
            if (prodTruncated[52]==1'b1) begin
                m3=prodTruncated[51:0];
            end
            else begin
                temp=prodTruncated;
                while (temp[52]!=1'b1) begin
                    temp[52:1]=temp[51:0];
                    e3=e3-1;
                end
                m3=temp[51:0];
            end
        end
        if (in1[62:0]==0 || in2[62:0]==0) begin
            out=0;
        end
        else if((in1[62:52]==ones11 && in1[51:0]==ones52)||(in2[62:52]==ones11 && in2[51:0]==ones52))//nan case
        begin
            out=64'b1111111111111111111111111111111111111111111111111111111111111111;
        end
        else if((in1[62:52]==ones11 && in1[51:0]==zeros52)||(in2[62:52]==ones11 && in2[51:0]==zeros52)) begin//inf case
            out=64'b0_11111111111_0000000000000000000000000000000000000000000000000000;
        end
        else begin
            out={s3,e3,m3};
        end
    end

endmodule
