module RAM(clk, addr, write_data, write_enable, read_data);
  input  clk; // Same Clock as Register File
  input  write_enable; // 1 if instruction is store, otherwise 0
  input  [9:0] addr; // Only take the 10 least significant bits for load/store
  input  [15:0] write_data; 
  output reg [15:0] read_data; // Change to reg type

  reg [15:0] Memory[0:1023];
  
  initial begin
    for (integer i = 0; i < 1024; i = i + 1)
      Memory[i] = i;
  end

  always @(negedge clk or addr or write_data) begin
    if (write_enable == 1)
      Memory[addr] <= write_data; // Used in store operation where addr = Op2 and write_data = Op1
      
    read_data <= Memory[addr]; // Move read_data assignment inside always block
  end
endmodule
