// `include "CED19I026_rdcla.v"
`include "CED19I028_RDCLA.v"
module select (
    sel,out1,out2,out3,out4,out5,out6,out7,out8,out
);
    input [2:0] sel;
    input out1,out2,out3,out4,out5,out6,out7,out8;
    output out;
    wire [2:0]selnot;

    genvar i;
    generate
        for (i=0;i<3;i=i+1) begin
            not(selnot[i],sel[i]);
        end
    endgenerate
// 001
// 110
// y=a'b'cI1+a'b'cI2+.......
    and(temp1,selnot[0],selnot[1],selnot[2],out1);// 0-and
    and(temp2,selnot[2],selnot[1],sel[0],out2);// 1-or
    and(temp3,selnot[2],sel[1],selnot[0],out3);// 2-nor
    and(temp4,selnot[2],sel[1],sel[0],out4);//3-not
    and(temp5,sel[2],selnot[1],selnot[0],out5);//4-xor
    and(temp6,sel[2],selnot[1],sel[0],out6);//5-nand
    and(temp7,sel[2],sel[1],selnot[0],out7);//6-xnor
    and(temp8,sel[2],sel[1],sel[0],out8);//7-2's comp

    or(temp9,temp1,temp2,temp3,temp4);
    or(temp10,temp5,temp6,temp7,temp8);
    or(out,temp9,temp10);

endmodule

module logicunit (
    in1,in2,sel,out
);
    input [63:0] in1,in2;
    input[2:0] sel;
    output [63:0] out;

    wire [63:0] AND_OUT,OR_OUT,NOR_OUT,NOT_OUT,XOR_OUT,NAND_OUT,XNOR_OUT,COMP_OUT;
    wire cout;
    wire[1:0] temp;
    genvar i,j;
    generate
        for (i=0;i<64;i=i+1) begin
            and(AND_OUT[i],in1[i],in2[i]);
            or(OR_OUT[i],in1[i],in2[i]);
            nor(NOR_OUT[i],in1[i],in2[i]);
            not(NOT_OUT[i],in1[i]);
            xor(XOR_OUT[i],in1[i],in2[i]);
            nand(NAND_OUT[i],in1[i],in2[i]);
            xnor(XNOR_OUT[i],in1[i],in2[i]);
        end
    endgenerate
    // cla64bit cla(NOT_OUT,64'd1,1'b0,COMP_OUT,cout,temp);
    RDCLA r1(NOT_OUT,64'd1,1'b0,COMP_OUT,cout);
    generate
        for(i=0;i<64;i=i+1) begin
            select s(sel,AND_OUT[i],OR_OUT[i],NOR_OUT[i],NOT_OUT[i],XOR_OUT[i],NAND_OUT[i],XNOR_OUT[i],COMP_OUT[i],out[i]);
        end
    endgenerate
    // assign out=AND_OUT;
endmodule
