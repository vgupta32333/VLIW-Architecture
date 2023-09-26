`include "CED19I028_RDCLA.v"
module top;
reg [63:0] in1, in2;
reg cin;
wire [63:0] sum;
wire cout;
RDCLA r1 (in1, in2, cin, sum, cout);
initial
begin
in1 = 64'b0000000000000000000000000000000000000000000100000000000000001011; in2 = 64'b0000000000000000000000000000000000000000000000000000000000000001; cin = 1'b0;
end
initial
$monitor ("%b",sum);
endmodule