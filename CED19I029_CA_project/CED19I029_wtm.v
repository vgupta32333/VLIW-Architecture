//1 bit full adder
module fullAdder ( in1,in2,cin,sum,cout );

    input in1,in2,cin;
    output sum,cout;
    wire temp1,temp2,temp3;

    xor(sum,in1,in2,cin);
    and(temp1,in1,in2);
    and(temp2,in2,cin);
    and(temp3,cin,in1);
    or(cout,temp1,temp2,temp3);
endmodule

//128 bit carry save adder
module carrySaveAdder (
    in1,in2,in3,sum,cout
);
    input[128:0] in1,in2,in3;
    output[128:0] sum,cout;

    genvar i;
    // fullAdder fa1(in1[0],in2[0]);
    generate
        for(i=0;i<128;i=i+1)begin
            fullAdder fa(in1[i],in2[i],in3[i],sum[i],cout[i+1]);
        end
    endgenerate 
    assign sum[128]=1'b0;
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
    // genvar j;
    // fullAdder f1(in1[0],in2[0],1'b0,sum[0],temp[0]);//cin is 0 for 1st adder
    // generate
    //     for(j=1;j<129;j=j+1)begin
    //         fullAdder f(in1[j],in2[j],temp[j-1],sum[j],temp[j]);//temp[j] holds carry out from jth bit
    //     end
    // endgenerate
    // assign out={finalc,sum};//temp[127] holds final carry
    assign out[129]=finalc;
endmodule

module multiplier64bit (
    in1,in2,actualout
);
    input [63:0] in1,in2;
    wire [129:0] out;
    output [127:0]actualout;
    // wire [63:0]
    //partial product generation
    integer i;
    reg[128:0] pp[0:63];
    always @(*) begin
        for (i = 0; i<64; i++) begin
            if(in2[i]==1) begin
                pp[i] =in1 << i;
            end
            else begin
                pp[i] = 129'b0;
            end
        end
    end

wire [128:0] u1_1,v1_1,u1_2,v1_2,u1_3,v1_3,u1_4,v1_4,u1_5,v1_5,u1_6,v1_6,u1_7,v1_7,u1_8,v1_8,u1_9,v1_9,u1_10,v1_10,u1_11,v1_11,u1_12,v1_12,u1_13,v1_13,u1_14,v1_14,u1_15,v1_15,u1_16,v1_16,u1_17,v1_17,u1_18,v1_18,u1_19,v1_19,u1_20,v1_20,u1_21,v1_21;
//stage 1

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
carrySaveAdder csa1_18(pp[51],pp[52],pp[53],u1_18,v1_18);
carrySaveAdder csa1_19(pp[54],pp[55],pp[56],u1_19,v1_19);
carrySaveAdder csa1_20(pp[57],pp[58],pp[59],u1_20,v1_20);
carrySaveAdder csa1_21(pp[60],pp[61],pp[62],u1_21,v1_21);
// pp[63]
wire [128:0]u2_1,v2_1,u2_2,v2_2,u2_3,v2_3,u2_4,v2_4,u2_5,v2_5,u2_6,v2_6,u2_7,v2_7,u2_8,v2_8,u2_9,v2_9,u2_10,v2_10,u2_11,v2_11,u2_12,v2_12,u2_13,v2_13,u2_14,v2_14;
//stage 2
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
carrySaveAdder csa2_12(u1_18,v1_17,v1_18,u2_12,v2_12);
carrySaveAdder csa2_13(u1_19,v1_19,u1_20,u2_13,v2_13);
carrySaveAdder csa2_14(u1_21,v1_20,v1_21,u2_14,v2_14);
// pp[63]

wire [128:0] u3_1,v3_1,u3_2,v3_2,u3_3,v3_3,u3_4,v3_4,u3_5,v3_5,u3_6,v3_6,u3_7,v3_7,u3_8,v3_8,u3_9,v3_9;
//stage 3
carrySaveAdder csa3_1(u2_1,v2_1,u2_2,u3_1,v3_1);
carrySaveAdder csa3_2(u2_3,v2_2,v2_3,u3_2,v3_2);
carrySaveAdder csa3_3(u2_4,v2_4,u2_5,u3_3,v3_3);
carrySaveAdder csa3_4(u2_6,v2_5,v2_6,u3_4,v3_4);
carrySaveAdder csa3_5(u2_7,v2_7,u2_8,u3_5,v3_5);
carrySaveAdder csa3_6(u2_9,v2_8,v2_9,u3_6,v3_6);
carrySaveAdder csa3_7(u2_10,v2_10,u2_11,u3_7,v3_7);
carrySaveAdder csa3_8(u2_12,v2_11,v2_12,u3_8,v3_8);
carrySaveAdder csa3_9(u2_13,v2_13,u2_14,u3_9,v3_9);
// v2_14,pp[63]

wire [128:0] u4_1,v4_1,u4_2,v4_2,u4_3,v4_3,u4_4,v4_4,u4_5,v4_5,u4_6,v4_6;
// stage 4
carrySaveAdder csa4_1(u3_1,v3_1,u3_2,u4_1,v4_1);
carrySaveAdder csa4_2(u3_3,v3_2,v3_3,u4_2,v4_2);
carrySaveAdder csa4_3(u3_4,v3_4,u3_5,u4_3,v4_3);
carrySaveAdder csa4_4(u3_6,v3_5,v3_6,u4_4,v4_4);
carrySaveAdder csa4_5(u3_7,v3_7,u3_8,u4_5,v4_5);
carrySaveAdder csa4_6(u3_9,v3_8,v3_9,u4_6,v4_6);
// v2_14,pp[63]

wire [128:0] u5_1,v5_1,u5_2,v5_2,u5_3,v5_3,u5_4,v5_4;
// stage 5
carrySaveAdder csa5_1(u4_1,v4_1,u4_2,u5_1,v5_1);
carrySaveAdder csa5_2(u4_3,v4_2,v4_3,u5_2,v5_2);
carrySaveAdder csa5_3(u4_4,v4_4,u4_5,u5_3,v5_3);
carrySaveAdder csa5_4(u4_6,v4_5,v4_6,u5_4,v5_4);
// v2_14,pp[63]
wire [128:0] u6_1,v6_1,u6_2,v6_2,u6_3,v6_3;
// stage 6
carrySaveAdder csa6_1(u5_1,v5_1,u5_2,u6_1,v6_1);
carrySaveAdder csa6_2(u5_3,v5_2,v5_3,u6_2,v6_2);
carrySaveAdder csa6_3(u5_4,v5_4,pp[63],u6_3,v6_3);
// v2_14
wire [128:0] u7_1,v7_1,u7_2,v7_2;
//stage 7
carrySaveAdder csa7_1(u6_1,v6_1,u6_2,u7_1,v7_1);
carrySaveAdder csa7_2(u6_3,v6_2,v6_3,u7_2,v7_2);
// v2_14
wire [128:0] u8_1,v8_1;
// stage 8
carrySaveAdder csa8_1(u7_1,v7_1,u7_2,u8_1,v8_1);
// v2_14,v7_2
wire [128:0] u9_1,v9_1;
// stage 9
carrySaveAdder csa9_1(u8_1,v8_1,v2_14,u9_1,v9_1);
// v7_2
wire [128:0] u10_1,v10_1;
// stage 10
carrySaveAdder csa10_1(u9_1,v9_1,v7_2,u10_1,v10_1);

// assign v10_1={v10_1[127:1],1'b0};
addertest at(u10_1,v10_1,out);
assign actualout=out[127:0];
endmodule

