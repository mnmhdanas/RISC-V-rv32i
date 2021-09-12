module Instructionmemory(i_Address,o_Dataout);
	input [9:0] i_Address;
	output [31:0] o_Dataout;
	
	reg [31:0] ROM [1023:0];
	
	assign o_Dataout = ROM[i_Address];
	
/*	initial
	   begin
			// Example program:

        ROM[0] = 32'h00000013; // nop (add x0 x0 0)
        
        // start:
        ROM[1] = 32'h00100093; // addi x1 x0 1
        ROM[2] = 32'h00100313; // addi x6 x0 1
        ROM[3] = 32'h00400613; // addi x12 x0 4
        ROM[4] = 32'h00602023; // sw x6 0(x0)        x6 R2 Dep (WB)

        // loop:
        ROM[5] = 32'h00002303; // lw x6 0(x0)        
        ROM[6] = 32'h00130313; // addi x6 x6 1       LoadStall and x6 R1 Dep (WB)
        ROM[7] = 32'h00602023; // sw x6 0(x0)        x6 R2 Dep
        ROM[8] = 32'hFEC34AE3; // blt x6 x12 -12     x6 R1 Dep (WB)

        // finish:
        ROM[9] = 32'h00000013; // nop (add x0 x0 0)
	   end  */
	   
	   
	//multiplication eg

   initial
     begin
      ROM[0]  = 32'h00000013; // nop (add x0 x0 0)	
	  ROM[1]  = 32'h01000513;
	  ROM[2]  = 32'h00100393;
	  ROM[3]  = 32'h00000433;
	  ROM[4]  = 32'h02400a6f;
	  ROM[5]  = 32'h007274b3;
	  ROM[6]  = 32'h00748863;
	  ROM[7]  = 32'h00140413;
	  ROM[8]  = 32'h00139393;
	  ROM[9]  = 32'h00000863;
	  ROM[10] = 32'h008195b3;
	  ROM[11] = 32'h00b282b3;
	  ROM[12] = 32'hfe0006e3;
	  ROM[13] = 32'hfea440e3;
	  ROM[14] = 32'h06502da3;
	  end
	   
	 endmodule  