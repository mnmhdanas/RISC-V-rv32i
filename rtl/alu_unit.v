module alu_unit(i_A,i_B,i_op,
                   o_Y);
	input [31:0] i_A,i_B;
    input [3:0] i_op;
    output reg [31:0] o_Y;

    wire signed [31:0] A,B;
    assign A = i_A;
    assign B = i_B;

    
    always@(*)
         begin
		     case(i_op)
			   0 : o_Y <=  i_A + i_B;     // add
			   1 : o_Y <=  i_A - i_B;     // sub
			   2 : o_Y <=  i_A & i_B;     // and
			   3 : o_Y <=  i_A | i_B;     // or
			   4 : o_Y <=  i_A ^ i_B;     // xor
			   5 : o_Y <=  i_A << i_B;    // sll
			   6 : o_Y <=  i_A >> i_B;    // srl
			   7 : o_Y <=  A >>> i_B;     // sra
			   8 : o_Y <=  (A < B ) ? 1'b1 :1'b0 ;  // slt
			   9 : o_Y <=  (i_A < i_B ) ? 1'b1 : 1'b0; // sltu
			   default : o_Y <= i_A + i_B;
			  endcase 
         end		 
		 
	endmodule	 
