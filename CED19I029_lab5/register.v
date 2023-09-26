// register file module...

module registerFileModule (source_register1, source_register2, destination_register, select_source1, select_source2, selectDestinationRegister, reset, WriteMode);

    input [63:0] destination_register;
    input [4:0] selectDestinationRegister, select_source1, select_source2;
    input reset, WriteMode;
    
    output [63:0] source_register1, source_register2;

    reg [63:0] RegisterFile [0:31];         // 32 registers each 64bit size...
    integer i;

    always @(*) begin
        if(reset == 1) begin
            for(i=0; i<32; i=i+1) 
                RegisterFile[i] = {64{1'b0}};
        end

        else if(WriteMode == 1) 
            RegisterFile[selectDestinationRegister] = destination_register;
    
    end

        // storing result to output registers...
        assign source_register1 = RegisterFile[select_source1];
        assign source_register2 = RegisterFile[select_source2];

endmodule


