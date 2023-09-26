// logic unit using 8x1 mux...

module logicUnit ( a, b, sel, out );

    input [63:0] a, b;
    input[2:0] sel;
    output [63:0] out;

    wire [63:0] AND_OUT, XOR_OUT, NAND_OUT, OR_OUT, NOT_OUT, NOR_OUT, COMP_OUT, XNOR_OUT;

    and And [63:0] (AND_OUT, a, b);
	xor Xor [63:0] (XOR_OUT, a, b);
	nand Nand [63:0] (NAND_OUT, a, b);
	or Or [63:0] (OR_OUT, a, b);
	not Not [63:0] (NOT_OUT, a);
	nor Nor [63:0] (NOR_OUT, a, b);
	two_complement two (a, COMP_OUT);
	xnor Xnor [63:0] (XNOR_OUT, a, b);

    MUX8to1 m [63:0] (AND_OUT, OR_OUT, NOR_OUT, NOT_OUT, XOR_OUT, NAND_OUT, XNOR_OUT, COMP_OUT, sel, out);

endmodule


module MUX8to1 (in1, in2, in3, in4, in5, in6, in7, in8, sel, out );
    input [2:0] sel;
    input in1, in2, in3, in4, in5, in6, in7, in8;
    output out;

    wire [2:0] not_sel;

    genvar i;
    generate
        for (i=0;i<3;i=i+1) begin
            not(not_sel[i], sel[i]);
        end
    endgenerate

    and (temp1, not_sel[0], not_sel[1], not_sel[2], in1);  // 000: and
    and (temp2, not_sel[2], not_sel[1], sel[0], in2);      // 001: or
    and (temp3, not_sel[2], sel[1], not_sel[0], in3);      // 010: nor
    and (temp4, not_sel[2], sel[1], sel[0], in4);          // 011: not
    and (temp5, sel[2], not_sel[1], not_sel[0], in5);      // 100: xor
    and (temp6, sel[2], not_sel[1], sel[0], in6);          // 101: nand
    and (temp7, sel[2], sel[1], not_sel[0], in7);          // 110: xnor
    and (temp8, sel[2], sel[1], sel[0], in8);              // 111: 2's complement

    or(temp9, temp1, temp2, temp3, temp4);
    or(temp10, temp5, temp6, temp7, temp8);
    or(out, temp9, temp10);

endmodule


module two_complement ( input [63:0] a, output [63:0] out );

	wire [63:0] l, complement;

	not Not [63:0] (complement, a);
	half_adder HA [63:0] (complement, {l[62:0], 1'b1}, out[63:0], l[63:0]);
    
endmodule


module half_adder ( input a, input b, output sum, output carry );

	xor (sum, a, b);
	and (carry, a, b);

endmodule



