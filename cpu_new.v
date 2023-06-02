//Mahmoud Abu-Qtiesh 20210383	sec:Sunday 
//Selen Qarajeh      20210622   sec:Thursday
//Nazeeh Hanbali     20210144	sec:Sunday

module cpu(Y, C, V, Z, Op1, Op2, Op, clk);

   output [15:0]	 Y;   // Result
   output 	     	 C;   // Carry
   output 	    	 V;   // Overflow
   output 	    	 Z;   // Zero
   input [2:0]   	Op1;  // A address
   input [2:0]   	Op2;  // B address
   input [3:0]   	Op;   // Operation Code
   input         	clk;  // Clock
  
   wire [15:0]   BitAnd, BitOr, BitXnor, Inc, Dec, Add, Sub, LogAnd, LogOr, CircLeft, CircRight, Comp;  // MUX Inputs
   wire          comLT;                                                                                 // Comparasion Result
   wire 	 Vas0, Vas1, Vas2, Vas3;                                                                // Overflow's from the 4 Arithmetic Operations
   wire 	 Cas0, Cas1, Cas2, Cas3;                                                                // Carry's from the 4 Arithmetic Operations
   wire [15:0]   A;                                                                                     // Operand
   wire [15:0]   B;                                                                                     // Operand
   wire [15:0]   write_data;                                                                            // Data used in store and load operations
   wire          is_store;
   wire          is_load;
   
  
   RegisterFile regFile(clk, Op1, Op2, Op1, is_load, write_data, A, B);                 // Op == 0101 Store
   RAM ram(clk, B[9:0], A, is_store, write_data);                                       // Op == 0110 Load
   
   // Minterm Checker for Store Operation and Load Operations
   store_op STORE(is_store, Op);
   load_op  LOAD(is_load, Op);
   
   // Arithmetic Operations
   ripple_carry_adder_subtractor incop(Inc, Cas0, Vas0, A, 16'b1, 1'b0);     	        // Op == 0000 Result = A + 1
   ripple_carry_adder_subtractor decop(Dec, Cas1, Vas1, A, 16'b1, 1'b1);     	        // Op == 0001 Result = A - 1
   ripple_carry_adder_subtractor subop(Sub, Cas2, Vas2, A, B, 1'b1);     	        // Op == 0010 Result = A - B
   ripple_carry_adder_subtractor addop(Add, Cas3, Vas3, A, B, 1'b0);     	        // Op == 0011 Result = A + B

   // Logical Operations
   comparator compop(comLT,A,B);							// Op == 0100 A = A <= B ? 1 : 0
   extension compop2(Comp, comLT);

   logical_and logandop(LogAnd, A, B);                                                  // Op == 0111 Result = A && B
   logical_or logorop(LogOr, A, B);                                                     // Op == 1000 Result = A || B

   and_16 andop(BitAnd, A, B);                                                          // Op == 1001 Result = A & B
   or_16 orop(BitOr, A, B);                                                             // Op == 1010 Result = A | B
   xnor_16 xnorop(BitXnor, A, B);                                                       // Op == 1011 Result = A ~^ B
   			                                                            
   circular_shift_right rightop(CircRight, A);                                          // Op == 1100 Result = A >> 1 + A[0]
   circular_shift_left leftop(CircLeft, A);                                             // Op == 1101 Result = A << 1 + A[15]


   // Result and Status MUXs
   multiplexer_16_1_1 muxC(C, Cas0, Cas1, Cas2, Cas3, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, Op);
   multiplexer_16_1_1 muxv(V, Vas0, Vas1, Vas2, Vas3, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, Op);
   multiplexer_16_1 muxY(Y, Inc, Dec, Sub, Add, Comp, 16'b1, 16'b1, LogAnd, LogOr, BitAnd, BitOr, BitXnor, CircRight, CircLeft, 16'b0, 16'b0, Op);

   // Zero Flag set to 1 iff Result == 1
   zero z(Z, Y);           
   
endmodule // cpu


module logical_and(R, A, B);
  input [15:0] A;
  input [15:0] B;
  output [15:0] R;
  wire temp_a, temp_b;
  wire final;

  or(temp_a, A[0], A[1], A[2], A[3], A[4], A[5], A[6], A[7], A[8], A[9], A[10], A[11], A[12], A[13], A[14], A[15]);
  or(temp_b, B[0], B[1], B[2], B[3], B[4], B[5], B[6], B[7], B[8], B[9], B[10], B[11], B[12], B[13], B[14], B[15]);

  and(final, temp_a, temp_b);
  extension e1(R, final);
endmodule // logical_and

module logical_or(R, A, B);
  input [15:0] A;
  input [15:0] B;
  output [15:0] R;
  wire temp_a, temp_b;
  wire final;

  or(temp_a, A[0], A[1], A[2], A[3], A[4], A[5], A[6], A[7], A[8], A[9], A[10], A[11], A[12], A[13], A[14], A[15]);
  or(temp_b, B[0], B[1], B[2], B[3], B[4], B[5], B[6], B[7], B[8], B[9], B[10], B[11], B[12], B[13], B[14], B[15]);

  or(final, temp_a, temp_b);
  extension e1(R, final);
endmodule // logical_or


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

endmodule // RegisterFile


module RAM(clk, addr, write_data, write_enable, read_data);
  input  clk; // Same Clock as Register File
  input  write_enable; // 1 if instruction is store, otherwise 0
  input  [9:0] addr; // Only take the 10 least significant bits for load/store
  input  [15:0] write_data; 
  output reg [15:0] read_data; 

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
endmodule // RAM




module comparator(comLT,A,B);
  input [15:0] A;
  input [15:0] B;
  output comLT;
  
  wire [15:0] LT,equal,bitLT; 
  
  xnor(equal[15],A[15],B[15]);
  xnor(equal[14],A[14],B[14]);
  xnor(equal[13],A[13],B[13]);
  xnor(equal[12],A[12],B[12]);
  xnor(equal[11],A[11],B[11]);
  xnor(equal[10],A[10],B[10]);
  xnor(equal[9],A[9],B[9]);
  xnor(equal[8],A[8],B[8]);
  xnor(equal[7],A[7],B[7]);
  xnor(equal[6],A[6],B[6]);
  xnor(equal[5],A[5],B[5]);
  xnor(equal[4],A[4],B[4]);
  xnor(equal[3],A[3],B[3]);
  xnor(equal[2],A[2],B[2]);
  xnor(equal[1],A[1],B[1]);
  xnor(equal[0],A[0],B[0]);

  and(bitLT[15],~A[15],B[15]);
  and(bitLT[14],~A[14],B[14]);
  and(bitLT[13],~A[13],B[13]);
  and(bitLT[12],~A[12],B[12]);
  and(bitLT[11],~A[11],B[11]);
  and(bitLT[10],~A[10],B[10]);
  and(bitLT[9],~A[9],B[9]);
  and(bitLT[8],~A[8],B[8]);
  and(bitLT[7],~A[7],B[7]);
  and(bitLT[6],~A[6],B[6]);
  and(bitLT[5],~A[5],B[5]);
  and(bitLT[4],~A[4],B[4]);
  and(bitLT[3],~A[3],B[3]);
  and(bitLT[2],~A[2],B[2]);
  and(bitLT[1],~A[1],B[1]);
  and(bitLT[0],~A[0],B[0]);

  and(LT[15],bitLT[15],1);
  and(LT[14],bitLT[14],equal[15]);
  and(LT[13],bitLT[13],equal[15],equal[14]);
  and(LT[12],bitLT[12],equal[15],equal[14],equal[13]);
  and(LT[11],bitLT[11],equal[15],equal[14],equal[13],equal[12]);
  and(LT[10],bitLT[10],equal[15],equal[14],equal[13],equal[12],equal[11]);
  and(LT[9],bitLT[9],equal[15],equal[14],equal[13],equal[12],equal[11],equal[10]);
  and(LT[8],bitLT[8],equal[15],equal[14],equal[13],equal[12],equal[11],equal[10],equal[9]);
  and(LT[7],bitLT[7],equal[15],equal[14],equal[13],equal[12],equal[11],equal[10],equal[9],equal[8]);
  and(LT[6],bitLT[6],equal[15],equal[14],equal[13],equal[12],equal[11],equal[10],equal[9],equal[8],equal[7]);
  and(LT[5],bitLT[5],equal[15],equal[14],equal[13],equal[12],equal[11],equal[10],equal[9],equal[8],equal[7],equal[6]);
  and(LT[4],bitLT[4],equal[15],equal[14],equal[13],equal[12],equal[11],equal[10],equal[9],equal[8],equal[7],equal[6],equal[5]);
  and(LT[3],bitLT[3],equal[15],equal[14],equal[13],equal[12],equal[11],equal[10],equal[9],equal[8],equal[7],equal[6],equal[5],equal[4]);
  and(LT[2],bitLT[2],equal[15],equal[14],equal[13],equal[12],equal[11],equal[10],equal[9],equal[8],equal[7],equal[6],equal[5],equal[4],equal[3]);
  and(LT[1],bitLT[1],equal[15],equal[14],equal[13],equal[12],equal[11],equal[10],equal[9],equal[8],equal[7],equal[6],equal[5],equal[4],equal[3],equal[2]);
  and(LT[0],bitLT[0],equal[15],equal[14],equal[13],equal[12],equal[11],equal[10],equal[9],equal[8],equal[7],equal[6],equal[5],equal[4],equal[3],equal[2],equal[1]);

  
or(comLT,LT[15],LT[14],LT[13],LT[12],LT[11],LT[10],LT[9],LT[8],LT[7],LT[6],LT[5],LT[4],LT[3],LT[2],LT[1],LT[0]);

endmodule // comparator


module multiplexer_16_1(X, A0, A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12, A13, A14, A15, S);
   output [15:0] X;        // The output line

   input [15:0] A15;       // Input line with id 4'b1111
   input [15:0] A14;       // Input line with id 4'b1110
   input [15:0] A13;       // Input line with id 4'b1101
   input [15:0] A12;       // Input line with id 4'b1100
   input [15:0] A11;       // Input line with id 4'b1011
   input [15:0] A10;       // Input line with id 4'b1010
   input [15:0] A9;        // Input line with id 4'b1001
   input [15:0] A8;        // Input line with id 4'b1000
   input [15:0] A7;        // Input line with id 4'b0111
   input [15:0] A6;        // Input line with id 4'b0110
   input [15:0] A5;        // Input line with id 4'b0101
   input [15:0] A4;        // Input line with id 4'b0100
   input [15:0] A3;        // Input line with id 4'b0011
   input [15:0] A2;        // Input line with id 4'b0010
   input [15:0] A1;        // Input line with id 4'b0001
   input [15:0] A0;        // Input line with id 4'b0000
   input [3:0] S;          // Selection lines

   assign X = (S[3] == 0 
               ? (S[2] == 0 
                  ? (S[1] == 0 
                     ? (S[0] == 0 ? A0 : A1)
                     : (S[0] == 0 ? A2 : A3))
                  : (S[1] == 0 
                     ? (S[0] == 0 ? A4 : A5)
                     : (S[0] == 0 ? A6 : A7)))
               : (S[2] == 0 
                  ? (S[1] == 0 
                     ? (S[0] == 0 ? A8 : A9)
                     : (S[0] == 0 ? A10 : A11))
                  : (S[1] == 0 
                     ? (S[0] == 0 ? A12 : A13)
                     : (S[0] == 0 ? A14 : A15))));
endmodule // multiplexer_16_1

module multiplexer_16_1_1(X, A0, A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12, A13, A14, A15, S);
  output X;              // The output line

  input A15;             // Input line with id 4'b1111
  input A14;             // Input line with id 4'b1110
  input A13;             // Input line with id 4'b1101
  input A12;             // Input line with id 4'b1100
  input A11;             // Input line with id 4'b1011
  input A10;             // Input line with id 4'b1010
  input A9;              // Input line with id 4'b1001
  input A8;              // Input line with id 4'b1000
  input A7;              // Input line with id 4'b0111
  input A6;              // Input line with id 4'b0110
  input A5;              // Input line with id 4'b0101
  input A4;              // Input line with id 4'b0100
  input A3;              // Input line with id 4'b0011
  input A2;              // Input line with id 4'b0010
  input A1;              // Input line with id 4'b0001
  input A0;              // Input line with id 4'b0000
  input [3:0] S;         // Selection lines

  assign X = (S[3] == 0 
              ? (S[2] == 0 
                  ? (S[1] == 0 
                     ? (S[0] == 0 ? A0 : A1)
                     : (S[0] == 0 ? A2 : A3))
                  : (S[1] == 0 
                     ? (S[0] == 0 ? A4 : A5)
                     : (S[0] == 0 ? A6 : A7)))
              : (S[2] == 0 
                  ? (S[1] == 0 
                     ? (S[0] == 0 ? A8 : A9)
                     : (S[0] == 0 ? A10 : A11))
                  : (S[1] == 0 
                     ? (S[0] == 0 ? A12 : A13)
                     : (S[0] == 0 ? A14 : A15))));
endmodule // multiplexer_16_1_1


module circular_shift_right(Y, A);
  input [15:0] A;
  output [15:0] Y;
  wire d;

  or (d, A[0], 0);

  or (Y[0], A[1], 0);
  or (Y[1], A[2], 0);
  or (Y[2], A[3], 0);
  or (Y[3], A[4], 0);
  or (Y[4], A[5], 0);

  or (Y[5], A[6], 0);
  or (Y[6], A[7], 0);
  or (Y[7], A[8], 0);
  or (Y[8], A[9], 0);
  or (Y[9], A[10], 0);

  or (Y[10], A[11], 0);
  or (Y[11], A[12], 0);
  or (Y[12], A[13], 0);
  or (Y[13], A[14], 0);
  or (Y[14], A[15], 0);

  or (Y[15], d, 0);
endmodule //circular_shift_right


module circular_shift_left(Y, A);
  input [15:0] A;
  output [15:0] Y;
  wire d;

  or (d, A[15], 0);
  or (Y[0], d, 0);

  or (Y[1], A[0], 0);
  or (Y[2], A[1], 0);
  or (Y[3], A[2], 0);
  or (Y[4], A[3], 0);
  or (Y[5], A[4], 0);
  or (Y[6], A[5], 0);

  or (Y[7], A[6], 0);
  or (Y[8], A[7], 0);
  or (Y[9], A[8], 0);
  or (Y[10], A[9], 0);
  or (Y[11], A[10], 0);

  or (Y[12], A[11], 0);
  or (Y[13], A[12], 0);
  or (Y[14], A[13], 0);
  or (Y[15], A[14], 0);
endmodule // circular_shift_left


module and_16(Y, A, B);
   output [15:0] Y;  
   input [15:0]  A;  
   input [15:0]  B;  

   and(Y[0], A[0], B[0]);
   and(Y[1], A[1], B[1]);
   and(Y[2], A[2], B[2]);
   and(Y[3], A[3], B[3]);
   and(Y[4], A[4], B[4]);
   and(Y[5], A[5], B[5]);
   and(Y[6], A[6], B[6]);
   and(Y[7], A[7], B[7]);
   and(Y[8], A[8], B[8]);
   and(Y[9], A[9], B[9]);
   and(Y[10], A[10], B[10]);
   and(Y[11], A[11], B[11]);
   and(Y[12], A[12], B[12]);
   and(Y[13], A[13], B[13]);
   and(Y[14], A[14], B[14]);
   and(Y[15], A[15], B[15]);
endmodule // and_16

module or_16(Y, A, B);
   output [15:0] Y; 
   input [15:0]  A; 
   input [15:0]  B; 

   or(Y[0], A[0], B[0]);
   or(Y[1], A[1], B[1]);
   or(Y[2], A[2], B[2]);
   or(Y[3], A[3], B[3]);
   or(Y[4], A[4], B[4]);
   or(Y[5], A[5], B[5]);
   or(Y[6], A[6], B[6]);
   or(Y[7], A[7], B[7]);
   or(Y[8], A[8], B[8]);
   or(Y[9], A[9], B[9]);
   or(Y[10], A[10], B[10]);
   or(Y[11], A[11], B[11]);
   or(Y[12], A[12], B[12]);
   or(Y[13], A[13], B[13]);
   or(Y[14], A[14], B[14]);
   or(Y[15], A[15], B[15]);
endmodule // or_16

module extension(o, A);
    input A;
    output [15:0] o;
    and(o[0], A,A);
    and(o[1], 0,0);
    and(o[2], 0,0);
    and(o[3], 0,0);
    and(o[4], 0,0);
    and(o[5], 0,0);
    and(o[6], 0,0);
    and(o[7], 0,0);
    and(o[8], 0,0);
    and(o[9], 0,0);
    and(o[10], 0,0);
    and(o[11], 0,0);
    and(o[12], 0,0);
    and(o[13], 0,0);
    and(o[14], 0,0);
    and(o[15], 0,0);
endmodule // extension
    
    

module xnor_16(Y, A, B);
   output [15:0] Y; 
   input [15:0]  A; 
   input [15:0]  B; 

   xnor(Y[0], A[0], B[0]);
   xnor(Y[1], A[1], B[1]);
   xnor(Y[2], A[2], B[2]);
   xnor(Y[3], A[3], B[3]);
   xnor(Y[4], A[4], B[4]);
   xnor(Y[5], A[5], B[5]);
   xnor(Y[6], A[6], B[6]);
   xnor(Y[7], A[7], B[7]);
   xnor(Y[8], A[8], B[8]);
   xnor(Y[9], A[9], B[9]);
   xnor(Y[10], A[10], B[10]);
   xnor(Y[11], A[11], B[11]);
   xnor(Y[12], A[12], B[12]);
   xnor(Y[13], A[13], B[13]);
   xnor(Y[14], A[14], B[14]);
   xnor(Y[15], A[15], B[15]);
endmodule // xnor_16


module zero(Z, A);
    output Z;
    input [15:0] A;
    wire temp;

    or(temp, A[0], A[1], A[2], A[3], A[4], A[5], A[6], A[7], A[8], A[9], A[10], A[11], A[12], A[13], A[14], A[15]);
    not(Z, temp);
endmodule // zero

module nonzero(X, A);
    output X;
    input [15:0] A;
    or(X, A[0], A[1], A[2], A[3], A[4], A[5], A[6], A[7], A[8], A[9], A[10], A[11], A[12], A[13], A[14], A[15]);
endmodule
      
module full_adder(S, Cout, A, B, Cin);
   output S;
   output Cout;
   input  A;
   input  B;
   input  Cin;
   
   wire   w1;
   wire   w2;
   wire   w3;
   wire   w4;
   
   xor(w1, A, B);
   xor(S, Cin, w1);
   and(w2, A, B);   
   and(w3, A, Cin);
   and(w4, B, Cin);   
   or(Cout, w2, w3, w4);
endmodule // full_adder


module ripple_carry_adder_subtractor(S, C, V, A, B, Op);
   output [15:0] S;   // The 16-bit sum/difference.
   output 	C;   // The 1-bit carry/borrow status.
   output 	V;   // The 1-bit overflow status.
   input [15:0] 	A;   // The 16-bit augend/minuend.
   input [15:0] 	B;   // The 16-bit addend/subtrahend.
   input 	Op;  // The operation: 0 => Add, 1=>Subtract.
   
   wire 	C0; // The carry out bit of fa0, the carry in bit of fa1.
   wire 	C1; // The carry out bit of fa1, the carry in bit of fa2.
   wire 	C2; // The carry out bit of fa2, the carry in bit of fa3.
   wire 	C3; // The carry out bit of fa2, the carr in bit for fa4
   wire 	C4;
   wire 	C5;
   wire 	C6;
   wire 	C7;
   wire 	C8;
   wire 	C9;
   wire 	C10;
   wire 	C11;
   wire 	C12;
   wire 	C13;
   wire 	C14;
   wire 	C15;
   
   wire 	B0; // The xor'd result of B[0] and Op
   wire 	B1; // The xor'd result of B[1] and Op
   wire 	B2; // The xor'd result of B[2] and Op
   wire 	B3; // The xor'd result of B[3] and Op
   wire 	B4;
   wire 	B5;
   wire 	B6;
   wire 	B7;
   wire 	B8;
   wire 	B9; 
   wire 	B10;
   wire 	B11;
   wire 	B12;
   wire 	B13;
   wire 	B14;
   wire 	B15;

   xor(B0, B[0], Op);
   xor(B1, B[1], Op);
   xor(B2, B[2], Op);
   xor(B3, B[3], Op);
   xor(B4, B[4], Op);
   xor(B5, B[5], Op);
   xor(B6, B[6], Op);
   xor(B7, B[7], Op);
   xor(B8, B[8], Op);
   xor(B9, B[9], Op);
   xor(B10, B[10], Op);
   xor(B11, B[11], Op);
   xor(B12, B[12], Op);
   xor(B13, B[13], Op);
   xor(B14, B[14], Op);
   xor(B15, B[15], Op);

   xor(C, C15, Op);      // Carry = C15 for addition, Carry = not(C15) for subtraction.
   xor(V, C15, C14);     // If the two most significant carry output bits differ, then we have an overflow.
   
   full_adder fa0(S[0], C0, A[0], B0, Op);    // Least significant bit.
   full_adder fa1(S[1], C1, A[1], B1, C0);
   full_adder fa2(S[2], C2, A[2], B2, C1);
   full_adder fa3(S[3], C3, A[3], B3, C2);  
   full_adder fa4(S[4], C4, A[4], B4, C3);
   full_adder fa5(S[5], C5, A[5], B5, C4);
   full_adder fa6(S[6], C6, A[6], B6, C5);
   full_adder fa7(S[7], C7, A[7], B7, C6);
   full_adder fa8(S[8], C8, A[8], B8, C7);
   full_adder fa9(S[9], C9, A[9], B9, C8);
   full_adder fa10(S[10], C10, A[10], B10, C9);
   full_adder fa11(S[11], C11, A[11], B11, C10);
   full_adder fa12(S[12], C12, A[12], B12, C11);
   full_adder fa13(S[13], C13, A[13], B13, C12);
   full_adder fa14(S[14], C14, A[14], B14, C13);
   full_adder fa15(S[15], C15, A[15], B15, C14);    // Most significant bit.

endmodule // ripple_carry_adder_subtractor


module arth_op(B, M); //00xx
    input [3:0] M;
    output B;
    
    wire inv3;
    wire inv2;
    
    not n1(inv3, M[3]);
    not n2(inv2, M[2]);
    
    and a1(bB, inv3, inv2);
endmodule //arth_op

module store_op(B, M); //0101
    input [3:0] M;
    output B;
    
    wire inv3;
    wire inv1;
    
    not n1(inv3, M[3]);
    not n2(inv1, M[1]);
    
    and a1(B,inv3, M[2], inv1, M[0]);
    
endmodule // store_ op


module load_op(B, M); //0110
    input [3:0] M;
    output B;
    
    wire inv3;
    wire inv0;
    
    not n1(inv3, M[3]);
    not n2(inv0, M[0]);
    
    and a1(B, inv3, M[2], M[1], inv0);
endmodule // load_op


module cpu_tb;

  reg [2:0] Op1_tb, Op2_tb;
  reg [3:0] Op_tb;
  reg clk_tb;
  wire [15:0] Y_tb;
  wire C_tb, V_tb, Z_tb;
  
  cpu cpu_inst(Y_tb, C_tb, V_tb, Z_tb, Op1_tb, Op2_tb, Op_tb, clk_tb);
  
  initial begin
    clk_tb = 0;
    Op1_tb = 0;
    Op2_tb = 0;
    Op_tb = 0;
    
    #10// Wait for initialization 
    $display("The Ram and register file are initialized to have the same value as the address   i.e register[101]=5,ram[101]=5..");
    
    // Perform operation 0000 (Op1 = Op1 + 1)
    Op1_tb = 1;
    Op2_tb = 2;
    Op_tb = 4'b0000;
    #10;
    $display("Operation 0000: Op1=%d               register[%b]+1 = %d,         	                C = %b, V = %b, Z = %b",Op1_tb,Op1_tb, Y_tb, C_tb, V_tb, Z_tb); // 2   
    
    // Perform operation 0001 (Op1 = Op1 - 1)
    Op1_tb = 5;
    Op_tb = 4'b0001;
    #10;
    $display("Operation 0001: Op1=%d               register[%b]-1 = %d,         	                C = %b, V = %b, Z = %b",Op1_tb,Op1_tb, Y_tb, C_tb, V_tb, Z_tb); // 4   
    
    // Perform operation 0010 (Op1 - Op2) 
    Op_tb = 4'b0010;
    Op1_tb = 7;
    Op2_tb = 1;
    #10;
    $display("Operation 0010: Op1=%d    Op2=%d      Op1-Op2 = %d,                                    C = %b, V = %b, Z = %b",Op1_tb,Op2_tb, Y_tb, C_tb, V_tb, Z_tb);// 6
    
    // Perform operation 0011 (Op1 + Op2) 
    Op_tb = 4'b0011;
    Op1_tb = 5;
    Op2_tb = 5;
    #10;
    $display("Operation 0011: Op1=%d    Op2=%d      Op1+Op2 = %d,                                    C = %b, V = %b, Z = %b",Op1_tb,Op2_tb, Y_tb, C_tb, V_tb, Z_tb);// 10
    
    // Perform operation 0100 (Op1 < Op2)
    Op_tb = 4'b0100;
    Op1_tb = 6;
    Op2_tb = 1;
    #10;
    $display("Operation 0100: Op1=%d    Op2=%d      Op1<Op2 = %d,                                                  Z = %b",Op1_tb,Op2_tb, Y_tb, Z_tb);// 0
    //#10 $display("Now Op2=%d    ",Op2_tb);
    
    // Perform Operation 0101 (memory[Op2] = register[Op1])
    Op_tb = 4'b0101;
    Op1_tb = 2;
    Op2_tb = 7;
    #10;
    $display("Operation 0101: Op1=%d    Op2=%d      memory[%b] = register[%b]=%d,                                    Z = %b",Op1_tb,Op2_tb,Op2_tb,Op1_tb,Op1_tb,Z_tb);//1
    
    // Perform Operation 0110 (register[Op1] = memory[Op2])
    Op_tb = 4'b0110;
    Op1_tb = 4;
    Op2_tb = 7;
    #10;
    $display("Operation 0110: Op1=%d    Op2=%d      register[%b] = memory[%b]=2,                                    Z = %b",Op1_tb,Op2_tb,Op1_tb,Op2_tb,Z_tb);//1
    
    // Perform operation 0000 (Op1 = Op1 + 1)
    Op1_tb = 4;
    Op2_tb = 2;
    Op_tb = 4'b0000;
    #10;
    $display("Operation 0000: Op1=%d               register[%b]+1 = %d,         	                C = %b, V = %b, Z = %b",Op1_tb,Op1_tb, Y_tb, C_tb, V_tb, Z_tb); // 3    
    
    // Perform Operation 0111 (Op1 && Op2)
    Op_tb = 4'b0111;
    Op1_tb = 0;
    Op2_tb = 3;
    #10;
    $display("Operation 0111: Op1=%d    Op2=%d      register[%b]!=0 && register[%b]!=0   =%d,                    Z = %b",Op1_tb,Op2_tb,Op1_tb,Op2_tb,Y_tb,Z_tb);//0
    
    // Perform Operation 0111 (Op1 && Op2)
    Op_tb = 4'b0111;
    Op1_tb = 6;
    Op2_tb = 5;
    #10;
    $display("Operation 0111: Op1=%d    Op2=%d      register[%b]!=0 && register[%b]!=0   =%d,                    Z = %b",Op1_tb,Op2_tb,Op1_tb,Op2_tb,Y_tb,Z_tb);//1
    
    // Perform Operation 1000 (Op1 || Op2) 
    Op_tb = 4'b1000;
    Op1_tb = 0;
    Op2_tb = 2;
    #10;
    $display("Operation 1000: Op1=%d    Op2=%d      register[%b]!=0 || register[%b]!=0   =%d,                    Z = %b",Op1_tb,Op2_tb,Op1_tb,Op2_tb,Y_tb,Z_tb);//1
    
    // Perform Operation 1001 (Op1 & Op2)
    Op_tb = 4'b1001;
    Op1_tb = 7;
    Op2_tb = 3;
    #10;
    $display("Operation 1001: Op1=%d    Op2=%d      register[%b] & register[%b] =%b,                  Z = %b",Op1_tb,Op2_tb,Op1_tb,Op2_tb,Y_tb,Z_tb);//3
    
    // Perform Operation 1010 (Op1 | Op2)
    Op_tb = 4'b1010;
    Op1_tb = 7;
    Op2_tb = 3;
    #10;
    $display("Operation 1010: Op1=%d    Op2=%d      register[%b] | register[%b] =%b,                  Z = %b",Op1_tb,Op2_tb,Op1_tb,Op2_tb,Y_tb,Z_tb);//7
    
    // Perform Operation 1011 (Op1 ~^ Op2)
    Op_tb = 4'b1011;
    Op1_tb = 7;
    Op2_tb = 3;
    #10;
    $display("Operation 1011: Op1=%d    Op2=%d      register[%b] ~^ register[%b] =%b,                 Z = %b",Op1_tb,Op2_tb,Op1_tb,Op2_tb,Y_tb,Z_tb);//ra8am kbeer
    
    // Perform Operation 1100  shift right
    Op_tb = 4'b1100;
    Op1_tb = 1;
    Op2_tb = 2;
    #10;
    $display("Operation 1100: Op1=%d               register[%b] shifted to the right =%b,             Z = %b",Op1_tb,Op1_tb,Y_tb,Z_tb);//7
    
    // Perform Operation 1101  shift left
    Op_tb = 4'b1101;
    Op1_tb = 6;
    Op2_tb = 2;
    #10;
    $display("Operation 1101: Op1=%d               register[%b] shifted to the left  =%b,             Z = %b",Op1_tb,Op1_tb,Y_tb,Z_tb);//12
    
    
    // End simulation
    #10;
    $finish;
  end
  
  always begin
    #5;
    clk_tb = ~clk_tb;
  end
  
endmodule
