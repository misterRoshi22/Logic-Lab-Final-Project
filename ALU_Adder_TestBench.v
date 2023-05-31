module alu_tb;
   reg [15:0] A, B;
   reg [3:0] Op;
   wire [15:0] Y;
   wire C, V, Z;
   
   alu uut(
      .Y(Y),
      .C(C),
      .V(V),
      .Z(Z),
      .A(A),
      .B(B),
      .Op(Op)
   );
   
   // Clock generation
   reg clk;
   always #5 clk = ~clk;
   
   initial begin
      // Initialize inputs
      A = 8'h05;
      B = 8'h02;
      Op = 4'b0000;
      
      // Apply inputs and display outputs
      #10;
      display("A = %h, B = %h, Op = %b", A, B, Op);
      display("Y = %h, C = %b, V = %b, Z = %b", Y, C, V, Z);
      
      // Perform operation 0000 (A + 1)
      #10;
      Op = 4'b0000;
      display("Performing operation 0000 (A + 1)");
      display("A = %h, B = %h, Op = %b", A, B, Op);
      #10;
      display("Y = %h, C = %b, V = %b, Z = %b", Y, C, V, Z);
      
      // Perform operation 0001 (A - 1)
      #10;
      Op = 4'b0001;
      display("Performing operation 0001 (A - 1)");
      display("A = %h, B = %h, Op = %b", A, B, Op);
      #10;
      display("Y = %h, C = %b, V = %b, Z = %b", Y, C, V, Z);
      
      // Perform operation 0010 (A - B)
      #10;
      Op = 4'b0010;
      display("Performing operation 0010 (A - B)");
      display("A = %h, B = %h, Op = %b", A, B, Op);
      #10;
      display("Y = %h, C = %b, V = %b, Z = %b", Y, C, V, Z);
      
      // Perform operation 0011 (A + B)
      #10;
      Op = 4'b0011;
      display("Performing operation 0011 (A + B)");
      display("A = %h, B = %h, Op = %b", A, B, Op);
      #10;
      display("Y = %h, C = %b, V = %b, Z = %b", Y, C, V, Z);
      
      // End simulation
      #10;
      $finish;
   end
endmodule
