
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



