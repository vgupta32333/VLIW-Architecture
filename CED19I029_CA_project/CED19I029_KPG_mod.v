module KPGS (out1, out0, in1, in2);
	input in1,in2;
	output reg out1, out0;

    wire [1:0] temp;
    assign temp = {in1, in2};

	always@(*)

        case (temp)

            2'b00: begin
                out0 = 1'b0;
                out1 = 1'b0;
            end
            2'b11: begin
                out0 = 1'b1;
                out1 = 1'b1;
            end
            default: begin 
                out0 = 1'b0;
                out1 = 1'b1;
            end

        endcase
endmodule


module KPG (cur_bit_1, cur_bit_0, prev_bit_1, prev_bit_0, out_bit_1, out_bit_0);

	input cur_bit_1, cur_bit_0, prev_bit_1, prev_bit_0;
	output reg out_bit_1, out_bit_0;

    wire [1:0] temp;
    assign temp = {cur_bit_1,cur_bit_0};
    
	always@(*)
        
        
        case(temp)

            2'b00: begin 
                out_bit_1 = 1'b0;
                out_bit_0 = 1'b0;
            end
            2'b11: begin 
                out_bit_1 = 1'b1;
                out_bit_0 = 2'b1;
            end            
            2'b10: begin 
                out_bit_1 = prev_bit_1;
                out_bit_0 = prev_bit_0;
            end 
            
        endcase

endmodule
