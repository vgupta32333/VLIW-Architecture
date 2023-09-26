// 64 bit wallace tree multiplier..
module wallace_64bit ( A, B, correct_out );

    input [63:0] A ,B;
    wire [129:0] out;
    output reg [127:0] correct_out;

    reg[128:0] pp[0:63];
    integer i;
    always @(*) begin
        // generating partial products using loop...
        for (i = 0; i<64; i++) begin
            if(B[i] == 1) begin
                pp[i] = (A << i);
            end
            else begin
                pp[i] = 129'b0;
            end
        end
        
        // checking condtions 
        if(A == 0 || B == 0) 
            correct_out = 128'b0;
        else if(~A == 0 && ~B == 0)   // overflow condition if all bits are 1
            correct_out = {128{1'b1}};
        else 
            correct_out = out[127:0];

    end

    // u means sum, v means carry..
    wire [128:0] u1_1, u1_2, u1_3, u1_4, u1_5, u1_6, u1_7, u1_8, u1_9, u1_10, u1_11, u1_12, u1_13, u1_14, u1_15, u1_16, u1_17, u1_18, u1_19, u1_20, u1_21;
    wire [128:0] v1_1, v1_2, v1_3, v1_4, v1_5, v1_6, v1_7, v1_8, v1_9, v1_10, v1_11, v1_12, v1_13, v1_14, v1_15, v1_16, v1_17, v1_18, v1_19, v1_20, v1_21;
    
    // stage 1
    carrySaveAdder csa1_1(pp[0], pp[1] ,pp[2], u1_1, v1_1);
    carrySaveAdder csa1_2(pp[3], pp[4], pp[5], u1_2, v1_2);
    carrySaveAdder csa1_3(pp[6], pp[7], pp[8], u1_3, v1_3);
    carrySaveAdder csa1_4(pp[9], pp[10], pp[11], u1_4, v1_4);
    carrySaveAdder csa1_5(pp[12], pp[13], pp[14], u1_5, v1_5);
    carrySaveAdder csa1_6(pp[15], pp[16], pp[17], u1_6, v1_6);
    carrySaveAdder csa1_7(pp[18], pp[19], pp[20], u1_7, v1_7);
    carrySaveAdder csa1_8(pp[21], pp[22], pp[23], u1_8, v1_8);
    carrySaveAdder csa1_9(pp[24], pp[25], pp[26], u1_9, v1_9);
    carrySaveAdder csa1_10(pp[27], pp[28], pp[29], u1_10, v1_10);
    carrySaveAdder csa1_11(pp[30], pp[31], pp[32], u1_11, v1_11);
    carrySaveAdder csa1_12(pp[33], pp[34], pp[35], u1_12, v1_12);
    carrySaveAdder csa1_13(pp[36], pp[37], pp[38], u1_13, v1_13);
    carrySaveAdder csa1_14(pp[39], pp[40], pp[41], u1_14, v1_14);
    carrySaveAdder csa1_15(pp[42], pp[43], pp[44], u1_15, v1_15);
    carrySaveAdder csa1_16(pp[45], pp[46], pp[47], u1_16, v1_16);
    carrySaveAdder csa1_17(pp[48], pp[49], pp[50], u1_17, v1_17);
    carrySaveAdder csa1_18(pp[51], pp[52], pp[53], u1_18, v1_18);
    carrySaveAdder csa1_19(pp[54], pp[55], pp[56], u1_19, v1_19);
    carrySaveAdder csa1_20(pp[57], pp[58], pp[59], u1_20, v1_20);
    carrySaveAdder csa1_21(pp[60], pp[61], pp[62], u1_21, v1_21);
    // pp[63] is left bcoz cant make pair of 3..

    // u means sum, v means carry..
    wire [128:0] u2_1, u2_2, u2_3, u2_4, u2_5, u2_6, u2_7, u2_8, u2_9, u2_10, u2_11, u2_12, u2_13, u2_14;
    wire [128:0] v2_1, v2_2, v2_3, v2_4, v2_5, v2_6, v2_7, v2_8, v2_9, v2_10, v2_11, v2_12, v2_13, v2_14;
    
    // stage 2
    carrySaveAdder csa2_1(u1_1, v1_1, u1_2, u2_1, v2_1);
    carrySaveAdder csa2_2(u1_3, v1_2, v1_3, u2_2, v2_2);
    carrySaveAdder csa2_3(u1_4, v1_4, u1_5, u2_3, v2_3);
    carrySaveAdder csa2_4(u1_6, v1_5, v1_6, u2_4, v2_4);
    carrySaveAdder csa2_5(u1_7, v1_7, u1_8, u2_5, v2_5);
    carrySaveAdder csa2_6(u1_9, v1_8, v1_9, u2_6, v2_6);
    carrySaveAdder csa2_7(u1_10, v1_10, u1_11, u2_7, v2_7);
    carrySaveAdder csa2_8(u1_12, v1_11, v1_12, u2_8, v2_8);
    carrySaveAdder csa2_9(u1_13, v1_13, u1_14, u2_9, v2_9);
    carrySaveAdder csa2_10(u1_15, v1_14, v1_15, u2_10, v2_10);
    carrySaveAdder csa2_11(u1_16, v1_16, u1_17, u2_11, v2_11);
    carrySaveAdder csa2_12(u1_18, v1_17, v1_18, u2_12, v2_12);
    carrySaveAdder csa2_13(u1_19, v1_19, u1_20, u2_13, v2_13);
    carrySaveAdder csa2_14(u1_21, v1_20, v1_21, u2_14, v2_14);
    // pp[63] is left bcoz cant make pair of 3.. from stage 1

    // u means sum, v means carry..
    wire [128:0] u3_1, u3_2, u3_3, u3_4, u3_5, u3_6, u3_7, u3_8, u3_9;
    wire [128:0] v3_1, v3_2, v3_3, v3_4, v3_5, v3_6, v3_7, v3_8, v3_9;
    
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
    // v2_14, pp[63] still left..

    // u means sum, v means carry..
    wire [128:0] u4_1, u4_2, u4_3, u4_4, u4_5, u4_6;
    wire [128:0] v4_1, v4_2, v4_3, v4_4, v4_5, v4_6;
    // stage 4
    carrySaveAdder csa4_1(u3_1,v3_1,u3_2,u4_1,v4_1);
    carrySaveAdder csa4_2(u3_3,v3_2,v3_3,u4_2,v4_2);
    carrySaveAdder csa4_3(u3_4,v3_4,u3_5,u4_3,v4_3);
    carrySaveAdder csa4_4(u3_6,v3_5,v3_6,u4_4,v4_4);
    carrySaveAdder csa4_5(u3_7,v3_7,u3_8,u4_5,v4_5);
    carrySaveAdder csa4_6(u3_9,v3_8,v3_9,u4_6,v4_6);
    // v2_14, pp[63] still left..

    // u means sum, v means carry..
    wire [128:0] u5_1, u5_2, u5_3, u5_4;
    wire [128:0] v5_1, v5_2, v5_3, v5_4;
    // stage 5
    carrySaveAdder csa5_1(u4_1,v4_1,u4_2,u5_1,v5_1);
    carrySaveAdder csa5_2(u4_3,v4_2,v4_3,u5_2,v5_2);
    carrySaveAdder csa5_3(u4_4,v4_4,u4_5,u5_3,v5_3);
    carrySaveAdder csa5_4(u4_6,v4_5,v4_6,u5_4,v5_4);
    // v2_14,pp[63] still left..

    // u means sum, v means carry..
    wire [128:0] u6_1, u6_2, u6_3;
    wire [128:0] v6_1, v6_2, v6_3;
    // stage 6
    carrySaveAdder csa6_1(u5_1,v5_1,u5_2,u6_1,v6_1);
    carrySaveAdder csa6_2(u5_3,v5_2,v5_3,u6_2,v6_2);
    carrySaveAdder csa6_3(u5_4,v5_4,pp[63],u6_3,v6_3);
    // v2_14 left..

    // u means sum, v means carry..
    wire [128:0] u7_1, u7_2;
    wire [128:0] v7_1, v7_2;
    //stage 7
    carrySaveAdder csa7_1(u6_1,v6_1,u6_2,u7_1,v7_1);
    carrySaveAdder csa7_2(u6_3,v6_2,v6_3,u7_2,v7_2);
    // v2_14

    // u means sum, v means carry..
    wire [128:0] u8_1;
    wire [128:0] v8_1;
    // stage 8
    carrySaveAdder csa8_1(u7_1,v7_1,u7_2,u8_1,v8_1);
    // v2_14,v7_2

    // u means sum, v means carry..
    wire [128:0] u9_1,v9_1;
    // stage 9
    carrySaveAdder csa9_1(u8_1,v8_1,v2_14,u9_1,v9_1);
    // v7_2

    // u means sum, v means carry..
    wire [128:0] u10_1,v10_1;
    // stage 10
    carrySaveAdder csa10_1(u9_1,v9_1,v7_2,u10_1,v10_1);     // final addition..

    adder ad (u10_1,v10_1,out);
    // assign correct_out = out[127:0];

endmodule



// full adder
module full_adder(a, b, cin, sum, cout);
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



// 128_bit Carry Save Adder
module carrySaveAdder ( a, b, c, sum, cout );

    input [128:0] a, b, c;
    output [128:0] sum, cout;

    genvar i;
    generate
        for(i=0; i<128; i=i+1)begin
            full_adder fa(a[i], b[i], c[i], sum[i], cout[i+1]);
        end
    endgenerate 

    assign sum[128]=1'b0;
    assign cout[0]=1'b0;

endmodule


// add final results..
module adder ( a, b, out );

    input [128:0] a, b;
    output [129:0] out;
    wire [128:0] sum, temp;

    // doing addition for LSB 
    full_adder f1(a[0], b[0], 1'b0, sum[0], temp[0]);
    genvar j;
    generate
        for(j=1; j<129; j=j+1) begin
            // temp[j] holds carry out from jth bit
            full_adder f(a[j], b[j], temp[j-1], sum[j], temp[j]);
        end
    endgenerate

    //temp[128] holds final carry value
    assign out={temp[128], sum};

endmodule


