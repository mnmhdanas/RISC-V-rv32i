
  module Datamemory(i_Address,i_Datawrite,i_wrenb,i_clk,
                    o_Dataread);
					
	input i_wrenb,i_clk;
    input [9:0]i_Address;
    input [31:0] i_Datawrite;

	output [31:0] o_Dataread;
	
	reg [31:0] RAM [1023:0];
	
	assign o_Dataread = RAM[i_Address];
	
	always@(posedge i_clk)
	   begin
			if(i_wrenb)
			    RAM[i_Address] <= i_Datawrite; 
	   end
  
  endmodule