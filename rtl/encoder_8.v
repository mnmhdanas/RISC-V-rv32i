

   module encoder_8(i_datain,o_dataout);
   input [7:0]i_datain;
   output reg [2:0] o_dataout = 0;
   
   always@(*)
     begin
	     if(i_datain[7])
		    o_dataout <= 7;
		 else if(i_datain[6])
            o_dataout <= 6;
         else if(i_datain[5])
            o_dataout <= 5;
         else if(i_datain[4])
            o_dataout <= 4;
	     else if(i_datain[3])
            o_dataout <= 3;
         else if(i_datain[2])
            o_dataout <= 2;
         else if(i_datain[1])
            o_dataout <= 1;	
         else if(i_datain[0])
            o_dataout <= 0;			
         else
            o_dataout <= 0;		 
	 end
	 
	endmodule