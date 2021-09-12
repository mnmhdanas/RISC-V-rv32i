
module tb_top_unit();
  
  reg i_clk;
  integer i;
  
  top_unit DUT(i_clk);
  
  
	 
   initial
     begin
	    i_clk = 1'b0;
		forever #5 i_clk = ~i_clk;
     end	 

    initial 
     	begin
        	$dumpfile("tb_top_unit.vcd");
        	$dumpvars;
			#1000 $finish;
    	end
    
	
   /*  initial
    $monitor("$time=%t Rs1_exe=%b Rs2_Exe=%b Rd_mem=%b ",
             $time,DUT.Cpuu.Rs1_PIPELINE[1],DUT.Cpuu.Rs2_PIPELINE[1],
             DUT.Cpuu.Rd_PIPELINE[2]);  */
			 
        initial
             $monitor("time:%t R10=%d  R7=%d  R8=%d R20=%d R9=%d   R4=%d  R3=%d  R5=%d ",$time,
			          DUT.Cpuu.regFile.xREG[10],
					  DUT.Cpuu.regFile.xREG[7],
					  DUT.Cpuu.regFile.xREG[8],
					  DUT.Cpuu.regFile.xREG[20],
					  DUT.Cpuu.regFile.xREG[9],
					  DUT.Cpuu.regFile.xREG[4],
					  DUT.Cpuu.regFile.xREG[3],
					  DUT.Cpuu.regFile.xREG[5]);		
    
endmodule