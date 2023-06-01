module RegisterFile(clk, read_addr1, read_addr2, write_addr, write_enable, write_data, read_data1, read_data2);
  input  clk;
  input  [2:0] read_addr1; // Address of operand 1
  input  [2:0] read_addr2; // Address of operand 2
  input  [2:0] write_addr; // Used in load operation, (write_address = Op1)
  input  write_enable; // This will only be 1 in load operation else its zero
  input  [15:0] write_data; // Used in load operation, (write_data = &Op2 from RAM)
  output  [15:0] read_data1; // Op1
  output  [15:0] read_data2;// Op1
  input init;
  
  reg [15:0] registers [0:7]; // The eight registers comprising the register file
  
  integer i;
  
  initial begin
    
    for( i = 0; i < 8; i = i +1)
        registers[i] = i;
    end

  assign read_data1 = registers[read_addr1];
  assign read_data2 = registers[read_addr2];

  // Register write
  always @(negedge clk) begin //Negative Edge
    if (write_enable)
      registers[write_addr] <= write_data;
  end

endmodule
