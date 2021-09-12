

   module encoder_16(i_datain,o_dataout);
   input [15:0]i_datain;
   output reg [3:0] o_dataout = 0;
   
   always@(*)
     begin
	     if(i_datain[15])
		    o_dataout <= 15;
		 else if(i_datain[14])
            o_dataout <= 14;
         else if(i_datain[13])
            o_dataout <= 13;
         else if(i_datain[12])
            o_dataout <= 12;
	     else if(i_datain[11])
            o_dataout <= 11;
         else if(i_datain[10])
            o_dataout <= 10;
         else if(i_datain[9])
            o_dataout <= 9;	
         else if(i_datain[8])
            o_dataout <= 8;
		 else if(i_datain[7])
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