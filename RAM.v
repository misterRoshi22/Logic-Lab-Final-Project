module RAM(clk, addr, write_data, write_enable, read_data); //if write = 1 then write else read
    input  clk; //Same Clock as Register File
    input  write_enable; //1 if instruction is store else it's equal zero
    input  [9:0] addr; //Only take the 10 least significant bits when load/store
    input  [15:0] write_data; 
    output [15:0] read_data;

    
    reg [15:0] read_data;
    
    reg[15:0] Memory[0:1023];
    
    integer i;
    initial begin
    
    for( i = 0; i < 1024; i = i + 1)
        Memory[i] = i;
    end

    always@(negedge clk or addr or write_enable)
    begin
        if(write_enable == 1) begin
        Memory[addr] = write_data; //Used in store operation where addr = Op2 and write_data = Op1
        end
        
        else if (write_enable == 0) begin
        read_data = Memory[addr];
        end
    end
endmodule
