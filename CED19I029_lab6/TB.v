
`include "cachefile.v"

module cachetb();

    reg[15:0] read_addr, write_addr;
    reg[63:0] write_data;
    reg clk, read_enable, write_enable;
    wire[63:0] read_data;

    cache c1(read_addr,read_data,write_addr,write_data,read_enable,write_enable,clk);

    initial begin
        clk = 0;
            forever begin
            clk = ~clk;
            #5;
        end
    end
    
    initial begin
        //Read Miss
        #10;
        read_enable = 1'b1;
        read_addr = 16'b10_1110000000_0100;
        #10;
        read_enable = 1'b0;
        #10;
        $display(" Time = %0t read_addr = %b read_data = %d", $time, read_addr, read_data);
        //Write Hit
        #10;
        write_enable = 1'b1;
        write_addr = 16'b10_1110000000_0100;
        x
        #10;
        write_enable = 1'b0;
        //Read Hit
        #10;
        read_enable = 1'b1;
        read_addr = 16'b10_1110000000_0100;
        #10;
        read_enable = 1'b0;
        #10;
        $display(" Time = %0t read_addr = %b read_data = %d", $time, read_addr, read_data);
        //Read Miss
        #10;
        read_enable = 1'b1;
        read_addr = 16'b11_1110000000_0100;
        #10;
        read_enable = 1'b0;
        #10;
        $display(" Time = %0t read_addr = %b read_data = %d", $time, read_addr, read_data);
        //Read Miss
        #10;
        read_enable = 1'b1;
        read_addr = 16'b10_1110000000_0100;
        #10;
        read_enable = 1'b0;
        #10;
        $display(" Time = %0t read_addr = %b read_data = %d", $time, read_addr, read_data);
        //Write Miss
        #10;
        write_enable = 1'b1;
        write_addr = 16'b11_1110000000_0100;
        write_data = 64'd98;
        #10;
        write_enable = 1'b0;
        //Read Miss
        #10;
        read_enable = 1'b1;
        read_addr = 16'b10_1110000000_0100;
        #10;
        read_enable = 1'b0;
        #10;
        $display(" Time = %0t read_addr = %b read_data = %d", $time, read_addr, read_data);
        //Read Miss
        #10;
        read_enable = 1'b1;
        read_addr = 16'b11_1110000000_0100;
        #10;
        read_enable = 1'b0;
        #10;
        $display(" Time = %0t read_addr = %b read_data = %d", $time, read_addr, read_data);
        #10;
        $finish;

    end

endmodule
