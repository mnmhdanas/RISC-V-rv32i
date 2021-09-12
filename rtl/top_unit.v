   module top_unit(i_clk);
   input i_clk;

   
   wire [9:0] Datamem_Addr;
   wire [31:0] Datamem_wrdata,Datamem_rddata;
   wire Datamem_wren;
   
   
   wire [9:0] Instmem_Addr;
   wire [31:0] Instruction;
   
    cpu_unit Cpuu(.i_DataMemory_ReadData(Datamem_rddata),
			.i_instruction(Instruction),
			.i_clk(i_clk),
			.o_DataMemory_Address(Datamem_Addr),
            .o_DataMemory_WriteData(Datamem_wrdata),
			.o_MWR(Datamem_wren),
			.o_InstructionMemory_Address(Instmem_Addr)); 
			
	/*cpu_unit Cpuu(.RAM_READ_DATA(Datamem_rddata),
                 .INSTRUCTION(Instruction),
				 .CLK(i_clk),
				 .RAM_ADDR(Datamem_Addr),          // 10-bit Size RAM
				 .RAM_WRITE_DATA(Datamem_wrdata),
				 .RAM_WRITE_ENABLE(Datamem_wren),
				 .INSTRUCTION_ADDR(Instmem_Addr),   // 10-bit Size ROM
				 .GPIO(o_GPIO));		*/
			
			
	Datamemory RAM_unit(.i_Address(Datamem_Addr),
						.i_Datawrite(Datamem_wrdata),
						.i_wrenb(Datamem_wren),
						.i_clk(i_clk),
                        .o_Dataread(Datamem_rddata));		
			   
			   
	
	Instructionmemory ROM_unit(.i_Address(Instmem_Addr),
							   .o_Dataout(Instruction));
							   
	endmodule