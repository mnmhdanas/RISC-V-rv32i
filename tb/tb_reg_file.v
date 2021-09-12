
     module tb_reg_file();
	 
	 reg [4:0] i_RA1,i_RA2,i_WA;
	 reg [31:0] i_WD;
	 reg i_WE;
	 wire [31:0] o_RD1,o_RD2;
	 integer i,j,k;
	 
	 /*********** DUT instaniation *************/
	 
	 reg_file DUT(i_RA1,i_RA2,i_WA,i_WD,i_WE,
                  o_RD1,o_RD2);
	
     task write_t(input [4:0]addr,input [31:0]data);
        begin
            i_WE = 1'b1;
            i_WA = addr;	
            i_WD = data;			
        end	
     endtask

     task read_t(input [4:0]addr1,addr2);
        begin
		   i_WE = 1'b0;
		   i_RA1 = addr1;
		   i_RA2 = addr2;
        end	
     endtask

    	 
	 initial
         begin
		    for(i=0;i<32;i=i+1)
			  begin
                write_t(i,{$random}%100);
				  #10;
			  end
			#100;
            repeat(30)
			      begin
                    read_t({$random}%32,{$random}%32);
				  #10;
				  end

            $finish;				  
         end		 
		 
	   initial
            begin
			    $dumpfile("tb_reg_file.vcd");
                $dumpvars();
            end
        initial
          $monitor("WA:%d  WD:%d   xREG[%d]:%d",i_WA,i_WD,i_WA,DUT.xREG[i_WA]);
		   
		initial 
          $monitor("RA1:%h  RA2:%h   RD1:%h  RD2:%h  ",i_RA1,i_RA2,DUT.xREG[i_RA1],DUT.xREG[i_RA2]);
       
    endmodule			