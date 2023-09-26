`include "logic.v"

// logic unit test bench...
module logicunittb ();
    reg [63:0] A, B;
    reg [2:0] select;
    wire [63:0] out;

    logicUnit l1 (A, B, select, out);
    
    initial begin
        $monitor(" Select: %b\n A:   %b\n B:   %b\n out: %b\n", select, A, B, out);
    end
    
    initial begin
        select=0;
        A=64'b0000000000000000000000000000111111111100000000000000000001110000;
        B=64'b0111000110000110100110000110000111011110110111100111001110111011;
        #10;

        select=1; #10;

        select=2; #10;

        select=3; #10;

        select=4; #10;

        select=5; #10;

        select=6; #10;

        select=7; #10;
        $finish;
    end

endmodule