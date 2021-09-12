
   module imm_gen(i_instruction,i_sel,
                  o_dataout);
				  
	input [31:0]i_instruction;
	input [2:0] i_sel;
	output reg signed [31:0] o_dataout;
	
	
	/*---------   IMM_I  ---------------------/ 
	imm   = {instruction[31:20]}
	IMM_I =  SXT(imm[11:0]) ------------------*/
	
	wire [11:0] imm_i ;
	assign imm_i = i_instruction[31:20];
	wire signed [31:0] IMM_I;
	assign IMM_I = { {20{imm_i[11]}} , imm_i};
	
	/*---------- IMM B -------------------------
	imm   = {instruction[31,7,30-25,11-8]}
	IMM_B =  SXT(imm[11:0]) 
	imm[0] is never used in B type ------------*/
	
     wire [11:0] imm_b ;
	assign imm_b = {i_instruction[31],i_instruction[7],i_instruction[30:25],i_instruction[11:8]};
	wire signed [31:0] IMM_B;
     assign IMM_B = { {19{imm_b[11]}} , imm_b[11:0] , 1'b0};
	
	/*---------- IMM J --------------------------
	imm   =  {instruction[31,19-12,20,30-21]} 
	IMM_J =  {SXT(imm[20:1]),1'b0} ------------
	imm[0] is never used in J type ------------*/
	
     wire [19:0] imm_j ;
	assign imm_j  = {i_instruction[31],i_instruction[19:12],i_instruction[20],i_instruction[30:21]};
	wire signed [31:0] IMM_J;
     assign IMM_J  = {{11{imm_j[19]}} , imm_j[19:0] , 1'b0};
	
	/*---------- IMM U --------------------------
	imm   =  {instruction[31-12]} 
	IMM_U =  {SXT(imm[20:1]),12'b0} ------------
	imm[0] is never used in U type ------------*/
	
	wire [19:0] imm_u ;
	assign imm_u  = i_instruction[31:12];
	wire signed [31:0] IMM_U;
	assign IMM_U  = {imm_u , 12'b0};
  
    /*---------- IMM S --------------------------
	imm   =  {instruction[31-25,11-7]} 
	IMM_U =  {SXT(imm[11:10]) ------------*/
	
	wire [11:0] imm_s ;
	assign imm_s  = {i_instruction[31:25],i_instruction[11:7]};
	wire signed [31:0] IMM_S;
	assign IMM_S  = {{20{imm_s[11]}} , imm_s}; 
	
	
	always @(*) begin
        case (i_sel)
            1: o_dataout = IMM_I;
            2: o_dataout = IMM_U;
            3: o_dataout = IMM_S;
            4: o_dataout = IMM_B;
            5: o_dataout = IMM_J;
			default: o_dataout = IMM_I;
        endcase
    end
endmodule