module RegisterFile(clk, read_addr1, read_addr2, write_addr, write_enable, write_data, read_data1, read_data2);
  input  clk;
  input  [2:0] read_addr1; // Address of operand 1
  input  [2:0] read_addr2; // Address of operand 2
  input  [2:0] write_addr; // Used in load operation, (write_address = Op1)
  input  write_enable; // This will only be 1 in load operation else its zero
  input  [15:0] write_data; // Used in load operation, (write_data = &Op2 from RAM)
  output  [15:0] read_data1; // Op1
  output  [15:0] read_data2;// Op1
  
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

module RegisterFile_tb;

  reg clk;
  reg [2:0] read_addr1;
  reg [2:0] read_addr2;
  reg [2:0] write_addr;
  reg write_enable;
  reg [15:0] write_data;
  wire [15:0] read_data1;
  wire [15:0] read_data2;
  reg [15:0] registers [0:7];

  // Instantiate the RegisterFile module
  RegisterFile dut (
    .clk(clk),
    .read_addr1(read_addr1),
    .read_addr2(read_addr2),
    .write_addr(write_addr),
    .write_enable(write_enable),
    .write_data(write_data),
    .read_data1(read_data1),
    .read_data2(read_data2)
  );

  // Clock generation
  always begin
    #5 clk = ~clk;
  end

  // Test inputs
  initial begin
    clk = 0;
    read_addr1 = 3'b001;    // Read address 1
    read_addr2 = 3'b010;    // Read address 2
    write_addr = 3'b011;    // Write address
    write_enable = 1;       // Enable write
    write_data = 75;  // Write data
    #10;
    $display("register[1]: %d", read_data1);
    $display("register[2]: %d", read_data2);
    $display("write_data: %d, write_addr: = %d, write_enable = %d", write_data, write_addr, write_enable);
    

    #10;
    write_enable = 1;       // Enable write
    write_data = 175;  // New write data
    write_addr = 3'b100;    // Write address
    read_addr1 = 3'b100;    // Read address 1
    read_addr2 = 3'b011;    // Read address 2
    #10;
    $display("register[4]: %d", read_data1);
    $display("register[3]: %d", read_data2);
    $display("write_data: %d, write_addr: = %d, write_enable = %d", write_data, write_addr, write_enable);
    
    
    #10;
    write_enable = 0;       // Enable write
    write_data = 175;  // New write data
    write_addr = 3'b100;    // Write address
    read_addr1 = 3'b100;    // Read address 1
    read_addr2 = 3'b011;    // Read address 2
    #10;
    $display("register[4]: %d", read_data1);
    $display("register[3]: %d", read_data2);
    $display("write_data: %d, write_addr: = %d, write_enable = %d", write_data, write_addr, write_enable);

    // End simulation
    $finish;
  end

endmodule

