

   module encoder_4(i_datain,o_dataout);
   input [3:0]i_datain;
   output reg [1:0] o_dataout = 0;
   
   always@(*)
     begin
	     if(i_datain[3])
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
	