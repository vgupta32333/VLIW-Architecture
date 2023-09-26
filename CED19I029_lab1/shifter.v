
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






