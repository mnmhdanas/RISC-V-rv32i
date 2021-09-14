

        module reg_file(i_clk,i_RA1,i_RA2,i_WA,i_WD,i_WE,
                  o_RD1,o_RD2);
				  
		/********************************************
		i_RA1 -> address of Rs1
		i_RA2 -> address of Rs2
		i_WA  -> address of Rd
		i_WD  -> data of Rd
		i_WE  -> write enable for Rd
		o_RD1 -> data of Rs1
		o_RD2 -> data of Rs2
        *********************************************/
        input i_clk;
        input [4:0]i_RA1,i_RA2,i_WA;
        input [31:0]i_WD;
        input i_WE;
        output [31:0] o_RD1,o_RD2;

        /*----- 32 REGISTERS of 32 bits width creation ----*/
      
        reg [31:0] xREG [31:0];	  
		
		integer i = 0;
	/*	initial
		   begin
		       for(i=0;i<32;i=i+1)
		          xREG[i] <= 32'b0;
            end */
			
			
		/* for multiplication x4 - mp , x3 - mc */

		initial
		   begin
		       xREG[0] <= 0;
			   xREG[1] <= 0;
			   xREG[2] <= 0;
			   xREG[3] <= 0;
		           xREG[4] <= 0;
			   xREG[5] <= 0;
			   xREG[6] <= 0;
			   xREG[7] <= 0;
			   xREG[8] <= 0;
			   xREG[9] <= 0;
			   xREG[10] <= 0;
			   xREG[11] <= 0;
			   xREG[12] <= 0;
			   xREG[13] <= 0;
			   xREG[14] <= 0;
			   xREG[15] <= 0;
			   xREG[16] <= 0;
			   xREG[17] <= 0;
			   xREG[18] <= 0;
			   xREG[19] <= 0;
			   xREG[20] <= 0;
			   xREG[21] <= 0;
			   xREG[22] <= 0;
			   xREG[20] <= 0;
			   xREG[23] <= 0;
			   xREG[24] <= 0;
			   xREG[25] <= 0;
			   xREG[26] <= 0;
			   xREG[27] <= 0;
			   xREG[28] <= 0;
			   xREG[29] <= 0;
			   xREG[30] <= 0;
			   xREG[31] <= 0;
			   
		   end
        /*----- choosing a register between 32 registers ---*/
        assign o_RD1 = xREG[i_RA1];
        assign o_RD2 = xREG[i_RA2];
		
		/*----- writing back into register --------------------
		ensure not writing into x0 as it is hardwired to zero */
		
		always@(*)
		     begin
			     if( i_WE && (i_WA != 0))
				     xREG[i_WA] <= i_WD;
			 end
			 
		endmodule
		
		
