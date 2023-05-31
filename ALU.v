module alu(Y, C, V, N, Z, A, B, Op);
   output [15:0] Y;  // Result.
   output 	 C;  // Carry.
   output 	 V;  // Overflow.
   output 	 Z;  // Zero.
   input [15:0]  A;  // Operand.
   input [15:0]  B;  // Operand.
   input [3:0] 	 Op; // Operation. 4 bits

   wire [15:0] 	 BitAnd, BitOr, BitXnor, Inc, Dec, Add, Sub,Abool,Bbool,LogAnd, LogOr;
   wire 	 Vas;
   wire 	 Cas;
   
   //temps
   nonzero ab(Abool, A); //if A != 0 then Abool = 1
   nonzero bb(Bbool, B); //if B != 0 then Bbool = 1
   
   // The operations
   ripple_carry_adder_subtractor incop(Inc, C, V, A, 1, 0);     	 // Op == 0000 Result = A + 1
   ripple_carry_adder_subtractor decop(Dec, C, V, A, 1, 1);     	 // Op == 0001 Result = A - 1
   ripple_carry_adder_subtractor subop(Sub, C, V, A, B, 1);     	 // Op == 0010 Result = A - B
   ripple_carry_adder_subtractor addop(Add, C, V, A, B, 0);     	 // Op == 0011 Result = A + B

									 // Op == 0100 TODO
									 // Op == 0101 TODO
									 // Op == 0110 TODO

   and logand(LogAnd, Abool, Bbool);                                 // Op == 0111 TODO
	or logor(LogOr, Abool, Bbool);							    	 // Op == 1000 TODO

   andop aluand(BitAnd, A, B);                                       // Op == 1001 Result = A . B
   orop aluor(BitOr, A, B);                                          // Op == 1010 Result = A + B
   xnorop aluxnor(BitXnor, A, B);                                    // Op == 1011 Result = A ~^ B
   			                                                 // Op == 1100 TODO
   			                                                 // Op == 1101 TODO

  multiplexer_16_1 mux(Y, Inc, Dec, Sub, Add, TODO, TODO, TODO, LogAnd, LogAnd, BitAnd, BitOr, BitXnor, TODO, TODO, A14, A15, Op);

 
   and(N, Y[15], s);       // Most significant bit is the sign bit in 2's complement.   
   zero z(Z, Y);           // All operations can set the Zero status bit.
endmodule // alu

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
endmodule 

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
endmodule 

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
endmodule


module zero(Z, A);
   output Z;        
   input [15:0]  A;
   wire [15:0] 	 Y; 
   
   xnor(Y[0], A[0], 0); // A XOR 0 = 1 iff A == 0
   xnor(Y[1], A[1], 0);
   xnor(Y[2], A[2], 0);
   xnor(Y[3], A[3], 0);
   xnor(Y[4], A[4], 0);
   xnor(Y[5], A[5], 0);
   xnor(Y[6], A[6], 0);
   xnor(Y[7], A[7], 0);
   xnor(Y[8], A[8], 0);
   xnor(Y[9], A[9], 0);
   xnor(Y[10], A[10], 0);
   xnor(Y[11], A[11], 0);
   xnor(Y[12], A[12], 0);
   xnor(Y[13], A[13], 0);
   xnor(Y[14], A[14], 0);
   xnor(Y[15], A[15], 0);
   and(Z, Y[0], Y[1], Y[2], Y[3], Y[4], Y[5], Y[6], Y[7], Y[8], Y[9], Y[10], Y[11], Y[12], Y[13], Y[14], Y[15]); // Z = 1 iff Y[i] == 1 for all i
endmodule

module nonzero(X, A);
    output X;
    input [15:0] A;
    wire temp;
    
    zero(temp, A);
    not(X,temp);
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
