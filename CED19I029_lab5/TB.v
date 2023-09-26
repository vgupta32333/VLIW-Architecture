// register file test bench....

`include "register.v"

module registerFile_tb ();

    reg [63:0] destination_register;
    reg [4:0] selectDestinationRegister, select_source1, select_source2;
    reg reset, WriteMode;
    
    wire [63:0] source_register1, source_register2;

    registerFileModule R1(source_register1, source_register2, destination_register, select_source1, select_source2, selectDestinationRegister, reset, WriteMode);

    initial begin
        reset=1; 
        #5;

        reset=0;select_source1=4; select_source2=2; WriteMode=1;
        #5;

        WriteMode=1; selectDestinationRegister=2; destination_register=10;
        #5;

        WriteMode=1; selectDestinationRegister=4; destination_register=20;
        #5;

        reset = 1; WriteMode=0;
        #5;

        $finish;
    end

    
    initial begin
        $monitor (  " source_register1 = %d\n source_register2 = %d\n destination_register = %d\n select_source1 = %d\n select_source2 = %d\n selectDestinationRegister = %d\n reset=%d\n WriteMode = %d\n",
                    source_register1, source_register2, destination_register, select_source1, select_source2, selectDestinationRegister, reset, WriteMode
                );
    end

endmodule


