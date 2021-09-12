      
	  module tb_imm_gen();
	  reg [31:0] i_instruction;
	  reg [2:0] i_sel;
	  wire [31:0] o_dataout;
	  
      imm_gen DUT(i_instruction,i_sel,
                  o_dataout);
				  
	   task input_t();
         begin
		    i_instruction = 32'h12353112; //0001_0010_0011_0101_0011_0001_0001_0010
			i_sel         = {$random}%8;
         end
       endtask		 
	   
	   initial
	      begin
		      repeat(10)
			    begin
				   input_t;
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
          $monitor("instruction:%b /n i_sel:%d /n o_dataout:%h",
                    i_instruction,i_sel,o_dataout);

        endmodule

