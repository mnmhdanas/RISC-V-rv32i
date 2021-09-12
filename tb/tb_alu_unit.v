
    module tb_alu_unit();
	reg [31:0] i_A,i_B;
	reg [3:0] i_op;
	wire [31:0] o_Y;
	wire o_equal;
	
	
    alu_unit DUT(i_A,i_B,i_op,
                   o_Y,o_equal);
				   
	task input_t();
         begin
		     i_A = 16;
			 i_B = 2;
			 i_op = {$random}%16;
         end
	endtask	 
	
	initial
	    begin
		    $dumpfile("tb_reg_file.vcd");
            $dumpvars(); 
		end
		
	initial
        $monitor("A:%d  B:%d  op:%d  Y:%d  eq:%b ",i_A,i_B,i_op,o_Y,o_equal);	
		
	initial
         begin
		     repeat(10)
			   begin
			      input_t;
				  #10;
			   end
			 $finish;  
         end		 
		 
	endmodule	 
