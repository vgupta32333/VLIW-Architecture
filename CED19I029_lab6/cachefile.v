
module cache ( read_addr, read_data, write_addr, write_data, readEnable, writeEnable, clk );

    input readEnable, writeEnable, clk;
    input [15:0] read_addr, write_addr;//2 bits tag,10 bits index,4 bits offset
    input [63:0] write_data;
    output reg [63:0] read_data;

    reg [1:0] tag_bit;
    reg [3:0] offset_bits;
    reg [9:0] index_bits;

    reg [1023:0] CacheMEM [1023:0];   // 1024 blocks, 16words each 64bit long -> 64*16 
    reg [1023:0] MainMEM [4095:0];
    reg [1:0] tag [1023:0];
    reg [1023:0] valid,dirty;

    integer i;
    initial begin
        for(i=0; i<1024; i=i+1) begin
            CacheMEM[i] = 1024'b0;
            tag[i] = 2'b0;
        end

        for(i=0; i<4096; i=i+1) begin
            MainMEM[i] = 1024'b0;
        end

        valid = 1024'b0;
        dirty = 1024'b0;
        $display(" Initialising all valid and dirty bit to 0.\n");
    end
    
    always @(posedge clk) begin

        tag_bit = read_addr[15:14];
        index_bits = read_addr[13:4];
        offset_bits = read_addr[3:0];

        if (readEnable) begin
            if ((tag_bit == tag[index_bits]) && valid[index_bits]) begin
                $display(" Time = %0t Read Hit.", $time);
                read_data = CacheMEM[index_bits][64*(offset_bits+1)-:64];
                $display(" Value at %b_%b_%b = %d\n", tag_bit, index_bits, offset_bits, read_data);
            end

            else begin
                $display(" Time = %0t Read Miss.", $time);

                if(valid[index_bits] && dirty[index_bits] ) begin
                    $display(" Dirty bit was set so, writing back block %b_%b from cache index %b", tag[index_bits], index_bits, index_bits);
                    MainMEM[{tag[index_bits],index_bits}] = CacheMEM[index_bits];
                end

                else begin
                    $display(" Dirty bit not set. No need to save block.");
                end

                $display(" Loading block %b_%b from main memory to cache index %b and setting valid bit to 1.",tag_bit,index_bits,index_bits);
                CacheMEM[index_bits] = MainMEM[{tag_bit,index_bits}];
                tag[index_bits] = tag_bit;
                valid[index_bits] = 1'b1;
                read_data = CacheMEM[index_bits][64*(offset_bits+1)-:64];

                $display(" Value at %b_%b_%b = %d \n",tag_bit, index_bits, offset_bits, read_data);
            end
        end

        if (writeEnable) begin
            if ((write_addr[15:14]==tag[index_bits]) && valid[index_bits]) begin
                $display(" Time = %0t Write Hit.",$time);
                CacheMEM[index_bits][64*(offset_bits+1)-:64] = write_data;
                dirty[index_bits] = 1'b1;
                $display(" Value at %b_%b_%b updated to %d. Also dirty bit set to 1.\n", write_addr[15:14], write_addr[13:4], write_addr[3:0], write_data);
            end

            else begin
                $display(" Time = %0t Write Miss.",$time);
                if(valid[index_bits] && (dirty[index_bits])begin
                    MainMEM[{tag[index_bits],index_bits}] = CacheMEM[index_bits];
                    $display(" Dirty bit was set. Saving block %b_%b from cache index %b.",tag[index_bits],index_bits,index_bits);
                end

                else begin
                    $display(" Dirty bit not set.No need to save block.");
                end
                
                $display(" Loading block %b_%b from main memory to cache index %b and setting valid bit to 1.",write_addr[15:14],index_bits,index_bits);
                CacheMEM[index_bits] = MainMEM[{tag_bit,index_bits}];
                CacheMEM[index_bits][64*(offset_bits+1)-:64] = write_data;
                tag[index_bits] = write_addr[15:14];
                dirty[index_bits] = 1'b1;
                $display(" Value at %b_%b_%b updated to %d . Dirty bit set to 1.\n", write_addr[15:14],write_addr[13:4],write_addr[3:0],write_data);
            
            end

        end
       
    end

endmodule


