module cpu_unit (
    input [31:0] i_DataMemory_ReadData,
    input [31:0] i_instruction,
    input i_clk,

    output [9:0] o_DataMemory_Address,          // 10-bit Size RAM
    output reg [31:0] o_DataMemory_WriteData,
    output o_MWR,
    output [9:0] o_InstructionMemory_Address   // 10-bit Size ROM
    
);
 
   //o_MWR - Memory write read
   
   reg [9:0] PC = 0;
   assign o_InstructionMemory_Address = PC >> 2;
   reg [9:0] PC_DECODE_2 = 0;
   reg [31:0] INSTRUCTION_DECODE_2 = 0;
   reg [9:0] PC_EXECUTE_3 = 0;
   reg [31:0] INSTRUCTION_EXECUTE_3 = 0;
   reg [9:0] PC_MEMORY_4 = 0;
   reg [31:0] INSTRUCTION_MEMORY_4 = 0;
   reg [31:0] ALU_OUT_MEMORY_4 = 0;
   reg [31:0] INSTRUCTION_WRITEBACK_5 = 0;
   reg [31:0] REG_WRITE_DATA_WRITEBACK_5 = 0;
   reg [31:0] DataMEM_READ_DATA_WRITEBACK_5 = 0;
	
	wire signed [31:0] Rs1_DATA,Rs2_DATA;
	wire DATADEP_MEM_HAZARD_Rs1,DATADEP_MEM_HAZARD_Rs2,DATADEP_WB_HAZARD_Rs1,DATADEP_WB_HAZARD_Rs2;
	
	wire signed[31:0] Rs1_DATA_EXECUTE_3;
    wire signed [31:0] Rs2_DATA_EXECUTE_3;
	wire [1:0] REG_WRITEBACK_SELECTION;
	 
	//-----  to keep track of resource(register) need at diff stages of pipeline	   
	reg [4:0] Rs1_PIPELINE[3:0];        
    reg [4:0] Rs2_PIPELINE[3:0];        
    reg [4:0] Rd_PIPELINE[3:0];        
    reg [2:0] Inst_type_PIPELINE[3:0];     //-- keeps track of current instruction being processed in pipeline
	

     
    /*----------------------------- OPCODE constants ----------------------------------*/
	
    parameter OP_R_TYPE           = 7'b0110011;
    parameter OP_I_TYPE_LOAD      = 7'b0000011;
    parameter OP_I_TYPE_OTHER     = 7'b0010011;
    parameter OP_I_TYPE_JUMP      = 7'b1100111;
    parameter OP_S_TYPE           = 7'b0100011;
    parameter OP_B_TYPE           = 7'b1100011;
    parameter OP_U_TYPE_LOAD      = 7'b0110111;
    parameter OP_U_TYPE_JUMP      = 7'b1101111;
    parameter OP_U_TYPE_AUIPC     = 7'b0010111;
    // -- PIPELINE HAZARD i_instruction TYPE DEFINES:
    parameter TYPE_REGISTER       = 0;
    parameter TYPE_LOAD           = 1;
    parameter TYPE_STORE          = 2;
    parameter TYPE_IMMEDIATE      = 3;
    parameter TYPE_UPPERIMMEDIATE = 4;
    parameter TYPE_BRANCH         = 5;
    // -- PIPELINE STAGES
    parameter DECODE      = 0;
    parameter EXECUTE     = 1;
    parameter MEMORY      = 2;
    parameter WRITEBACK   = 3;


    // ISA definition:
    wire [6:0] OPCODE   = INSTRUCTION_EXECUTE_3[6:0];
    wire [4:0] Rd       = INSTRUCTION_WRITEBACK_5[11:7];
    wire [2:0] FUNCT3   = INSTRUCTION_EXECUTE_3[14:12];
    wire [4:0] Rs1      = INSTRUCTION_EXECUTE_3[19:15];
    wire [4:0] Rs2      = INSTRUCTION_EXECUTE_3[24:20];
    wire [6:0] FUNCT7   = INSTRUCTION_EXECUTE_3[31:25];

    /*-------- flag to indicate type of instruction ------*/
	
    wire R_TYPE         = OPCODE == OP_R_TYPE;
    wire I_TYPE_LOAD    = OPCODE == OP_I_TYPE_LOAD;
    wire I_TYPE_OTHER   = OPCODE == OP_I_TYPE_OTHER;
    wire I_TYPE_JUMP    = OPCODE == OP_I_TYPE_JUMP;
    wire I_TYPE         = I_TYPE_JUMP || I_TYPE_LOAD || I_TYPE_OTHER;
    wire S_TYPE         = OPCODE == OP_S_TYPE;
    wire B_TYPE         = OPCODE == OP_B_TYPE;
    wire U_TYPE_LOAD    = OPCODE == OP_U_TYPE_LOAD;
    wire U_TYPE_JUMP    = OPCODE == OP_U_TYPE_JUMP;
    wire U_TYPE_AUIPC   = OPCODE == OP_U_TYPE_AUIPC;
    wire U_TYPE         = U_TYPE_JUMP || U_TYPE_LOAD || U_TYPE_AUIPC;

    /*--------------------------R-Type -----------------------------------*/
	
    wire R_add      = R_TYPE && FUNCT3 == 3'b000 && FUNCT7 == 7'h00;
    wire R_sub      = R_TYPE && FUNCT3 == 3'b000 && FUNCT7 == 7'h20;
    wire R_sll      = R_TYPE && FUNCT3 == 3'b001 && FUNCT7 == 7'h00;
    wire R_slt      = R_TYPE && FUNCT3 == 3'b010 && FUNCT7 == 7'h00;
    wire R_sltu     = R_TYPE && FUNCT3 == 3'b011 && FUNCT7 == 7'h00;
    wire R_xor      = R_TYPE && FUNCT3 == 3'b100 && FUNCT7 == 7'h00;
    wire R_srl      = R_TYPE && FUNCT3 == 3'b101 && FUNCT7 == 7'h00;
    wire R_sra      = R_TYPE && FUNCT3 == 3'b101 && FUNCT7 == 7'h20;
    wire R_or       = R_TYPE && FUNCT3 == 3'b110 && FUNCT7 == 7'h00;
    wire R_and      = R_TYPE && FUNCT3 == 3'b111 && FUNCT7 == 7'h00;
    

    /*-------------------------I-Type ----------------------------------------*/
	
    wire I_addi     = I_TYPE_OTHER && FUNCT3 == 3'b000;
    wire I_slli     = I_TYPE_OTHER && FUNCT3 == 3'b001 && FUNCT7 == 7'h00;
    wire I_slti     = I_TYPE_OTHER && FUNCT3 == 3'b010;
    wire I_sltiu    = I_TYPE_OTHER && FUNCT3 == 3'b011;
    wire I_xori     = I_TYPE_OTHER && FUNCT3 == 3'b100;
    wire I_srli     = I_TYPE_OTHER && FUNCT3 == 3'b101 && FUNCT7 == 7'h00;
    wire I_srai     = I_TYPE_OTHER && FUNCT3 == 3'b101 && FUNCT7 == 7'h20;
    wire I_ori      = I_TYPE_OTHER && FUNCT3 == 3'b110;
    wire I_andi     = I_TYPE_OTHER && FUNCT3 == 3'b111;
    /*---------------------- Load (I-type)-----------------------------------*/
    wire I_lb       = INSTRUCTION_MEMORY_4[6:0] == OP_I_TYPE_LOAD && INSTRUCTION_MEMORY_4[14:12] == 3'b000;
    wire I_lh       = INSTRUCTION_MEMORY_4[6:0] == OP_I_TYPE_LOAD && INSTRUCTION_MEMORY_4[14:12] == 3'b001;
    wire I_lw       = INSTRUCTION_MEMORY_4[6:0] == OP_I_TYPE_LOAD && INSTRUCTION_MEMORY_4[14:12] == 3'b010;
	
    /*--------------------- JALR (I-Type) ------------------------------------*/
    wire I_jalr     = I_TYPE_JUMP;


    /*--------------------- U-Type -------------------------------------------*/
    wire U_lui      = U_TYPE_LOAD;
    wire U_auipc    = U_TYPE_AUIPC;
    wire U_jal      = U_TYPE_JUMP;


    /*---------------------- S-type -----------------------------------------*/
    wire S_sb       = INSTRUCTION_MEMORY_4[6:0] == OP_S_TYPE && INSTRUCTION_MEMORY_4[14:12] == 3'b000;
    wire S_sh       = INSTRUCTION_MEMORY_4[6:0] == OP_S_TYPE && INSTRUCTION_MEMORY_4[14:12] == 3'b001;
    wire S_sw       = INSTRUCTION_MEMORY_4[6:0] == OP_S_TYPE && INSTRUCTION_MEMORY_4[14:12] == 3'b010;


    /*---------------------- B-type ------------------------------------------*/
    wire B_beq      = B_TYPE && FUNCT3 == 3'b000;
    wire B_bne      = B_TYPE && FUNCT3 == 3'b001;
    wire B_blt      = B_TYPE && FUNCT3 == 3'b100;
    wire B_bge      = B_TYPE && FUNCT3 == 3'b101;
    wire B_bltu     = B_TYPE && FUNCT3 == 3'b110;
    wire B_bgeu     = B_TYPE && FUNCT3 == 3'b111;

    
	/*----------------IMMEDIATE GENERATOR BLOCK instantiation------------------------------*/
	
    wire [31:0] IMM_OUTPUT;
    wire [2:0] IMM_SEL;
    wire [7:0] IMM_ENC_INP;

    assign IMM_ENC_INP[0] = 0;
    assign IMM_ENC_INP[1] = I_TYPE;
    assign IMM_ENC_INP[2] = U_TYPE_LOAD || U_TYPE_AUIPC;
    assign IMM_ENC_INP[3] = S_TYPE;
    assign IMM_ENC_INP[4] = B_TYPE;
    assign IMM_ENC_INP[5] = U_TYPE_JUMP;
    assign IMM_ENC_INP[6] = 0;
    assign IMM_ENC_INP[7] = 0;
    encoder_8 immediateSelectionEncoder(IMM_ENC_INP, IMM_SEL);
    
    imm_gen immediateExtractor(INSTRUCTION_EXECUTE_3, IMM_SEL, IMM_OUTPUT);
	
	/*---------------ALU block instantiation--------------------------------------------------*/
	
    wire [15:0] ALU_ENC_INP;
    wire [3:0] ALU_OP;
    
    assign ALU_ENC_INP[0] = R_add || I_addi;
    assign ALU_ENC_INP[1] = R_sub;
    assign ALU_ENC_INP[2] = R_and || I_andi;
    assign ALU_ENC_INP[3] = R_or || I_ori;
    assign ALU_ENC_INP[4] = R_xor || I_xori;
    assign ALU_ENC_INP[5] = R_sll || I_slli;
    assign ALU_ENC_INP[6] = R_srl || I_srli;
    assign ALU_ENC_INP[7] = R_sra || I_srai;
    assign ALU_ENC_INP[8] = R_slt || I_slti;
    assign ALU_ENC_INP[9] = R_sltu || I_sltiu;
    assign ALU_ENC_INP[10] = 0;
    assign ALU_ENC_INP[11] = 0;
    assign ALU_ENC_INP[12] = 0;
    assign ALU_ENC_INP[13] = 0;
    assign ALU_ENC_INP[14] = 0;
    assign ALU_ENC_INP[15] = 0;
    encoder_16 aluOpEncoder(ALU_ENC_INP, ALU_OP);

    // -- ALU Input Encoders
    wire [3:0] aluA_ENC_INP;
    wire [3:0] aluB_ENC_INP;
    wire [1:0] ALU_A_SEL;
    wire [1:0] ALU_B_SEL;
    
    assign aluA_ENC_INP[0] = 1;
    assign aluA_ENC_INP[1] = B_TYPE || U_TYPE_JUMP || U_TYPE_AUIPC || I_TYPE_JUMP;
    assign aluA_ENC_INP[2] = U_TYPE_LOAD;
    assign aluA_ENC_INP[3] = 0;

    assign aluB_ENC_INP[0] = 1;
    assign aluB_ENC_INP[1] = S_TYPE || I_TYPE || B_TYPE || U_TYPE;    
    assign aluB_ENC_INP[2] = 0;
    assign aluB_ENC_INP[3] = 0;
    encoder_4 aluX1SelectionEncoder(aluA_ENC_INP, ALU_A_SEL);
    encoder_4 aluX2SelectionEncoder(aluB_ENC_INP, ALU_B_SEL);

    // -- ALU
    reg [31:0] ALU_A;
    reg [31:0] ALU_B;
    wire [31:0] ALU_OUT;
    alu_unit alu(ALU_A, ALU_B, ALU_OP, ALU_OUT);

    always @(*) 
	begin
        case(ALU_A_SEL)
            0: ALU_A <= Rs1_DATA;
            1: ALU_A <= PC_EXECUTE_3;
            default: ALU_A <= 0;
        endcase
    end
	always @(*) 
	  begin
        case(ALU_B_SEL)
            0: ALU_B <= Rs2_DATA;
            1: ALU_B <= IMM_OUTPUT;
            default: ALU_B <= 0;
        endcase
      end




    /*------------ Register file Write back selection input --------------------*/
    
	// Decoding OPCODE for 5th stage of pipeline.
    wire [6:0] OPCODE_WRITEBACK_5 = INSTRUCTION_WRITEBACK_5[6:0];
    wire WB_R_TYPE         = OPCODE_WRITEBACK_5 == OP_R_TYPE;
    wire WB_I_TYPE_LOAD    = OPCODE_WRITEBACK_5 == OP_I_TYPE_LOAD;
    wire WB_I_TYPE_OTHER   = OPCODE_WRITEBACK_5 == OP_I_TYPE_OTHER;
    wire WB_I_TYPE_JUMP    = OPCODE_WRITEBACK_5 == OP_I_TYPE_JUMP;
    wire WB_I_TYPE         = WB_I_TYPE_JUMP || WB_I_TYPE_LOAD || WB_I_TYPE_OTHER;
    wire WB_U_TYPE_LOAD    = OPCODE_WRITEBACK_5 == OP_U_TYPE_LOAD;
    wire WB_U_TYPE_JUMP    = OPCODE_WRITEBACK_5 == OP_U_TYPE_JUMP;
    wire WB_U_TYPE_AUIPC   = OPCODE_WRITEBACK_5 == OP_U_TYPE_AUIPC;
    wire WB_U_TYPE         = WB_U_TYPE_JUMP || WB_U_TYPE_LOAD || WB_U_TYPE_AUIPC;

    wire WERF = WB_R_TYPE || WB_I_TYPE || WB_U_TYPE; //Write enable for register file

    // -- Register Write Back Selection Encoder
    wire [3:0] regWritebackSelectionInputs;
   

    assign regWritebackSelectionInputs[0] = 0;
    assign regWritebackSelectionInputs[1] = WB_R_TYPE || WB_U_TYPE_LOAD || WB_I_TYPE_OTHER;
    assign regWritebackSelectionInputs[2] = WB_U_TYPE_JUMP || WB_I_TYPE_JUMP;
    assign regWritebackSelectionInputs[3] = WB_I_TYPE_LOAD;
    
    encoder_4 writeBackSelectionEncoder(regWritebackSelectionInputs, REG_WRITEBACK_SELECTION);    


    

    wire [31:0] REG_WRITE_DATA = REG_WRITEBACK_SELECTION == 3 ? DataMEM_READ_DATA_WRITEBACK_5 : REG_WRITE_DATA_WRITEBACK_5;

    reg_file regFile(i_clk,Rs1, Rs2, Rd, REG_WRITE_DATA, WERF, Rs1_DATA_EXECUTE_3, Rs2_DATA_EXECUTE_3);
	
	
	
	
	/*---------------- Rs1,Rs2,Rd data  -----------------*/
	

    assign Rs1_DATA =    DATADEP_MEM_HAZARD_Rs1 ? ALU_OUT_MEMORY_4 :
                                    DATADEP_WB_HAZARD_Rs1 ?
                                        (REG_WRITEBACK_SELECTION == 3 ? DataMEM_READ_DATA_WRITEBACK_5 : REG_WRITE_DATA_WRITEBACK_5)
                                        : Rs1_DATA_EXECUTE_3;
    assign Rs2_DATA =    DATADEP_MEM_HAZARD_Rs2 ? ALU_OUT_MEMORY_4 :
                                    DATADEP_WB_HAZARD_Rs2 ?
                                        (REG_WRITEBACK_SELECTION == 3 ? DataMEM_READ_DATA_WRITEBACK_5 : REG_WRITE_DATA_WRITEBACK_5)
                                        : Rs2_DATA_EXECUTE_3;
    
    wire [31:0] Rs1_U_DATA = Rs1_DATA;
    wire [31:0] Rs2_U_DATA = Rs2_DATA;

    wire PC_ALU_SEL =   (B_beq && Rs1_DATA == Rs2_DATA)
                        || (B_bne && Rs1_DATA != Rs2_DATA)
                        || (B_blt && Rs1_DATA <  Rs2_DATA)
                        || (B_bge && Rs1_DATA >= Rs2_DATA)
                        || (B_bltu && Rs1_U_DATA <  Rs2_U_DATA)
                        || (B_bgeu && Rs1_U_DATA >= Rs2_U_DATA)
                        || I_jalr
                        || U_jal;
    
    // -- Data memory Read address  & Write Enable Pins
    assign o_MWR     = INSTRUCTION_MEMORY_4[6:0] == OP_S_TYPE;
    assign o_DataMemory_Address      = ALU_OUT_MEMORY_4[9:0];


    /*------- HAZARDS IN PIPELINING
	 i) Data dependacy hazard :
	     i)  memory : if(Rs[Execution phase ] == Rd[Memory phase])
		      For rs1, during execution ,ensure its address not equal to zero nor of upper immediate instruction
			  For rs2,  during execution ,ensure its address not equal to zero nor of upper immediate instruction,immediate instruction
		  
		 ii) write back : if(Rs[Execution phase ] == Rd[WB phase])
	          For rs1, during execution ,ensure its address not equal to zero nor of upper immediate instruction
			  For rs2,  during execution ,ensure its address not equal to zero nor of upper immediate instruction,immediate instruction */
    

    // If Rs1 depends on the previous Rd (or Rs2 if STORE)
    assign DATADEP_MEM_HAZARD_Rs1 =
                        Rs1_PIPELINE[EXECUTE] != 0
                    &&  Inst_type_PIPELINE[EXECUTE] != TYPE_UPPERIMMEDIATE
                    &&  Rs1_PIPELINE[EXECUTE] == Rd_PIPELINE[MEMORY];
    // If Rs2 depends on the previous Rd (or Rs2 if STORE)
    assign DATADEP_MEM_HAZARD_Rs2 =
                        Rs2_PIPELINE[EXECUTE] != 0
                    &&  Inst_type_PIPELINE[EXECUTE] != TYPE_UPPERIMMEDIATE
                    &&  Inst_type_PIPELINE[EXECUTE] != TYPE_IMMEDIATE
                    &&  Rs2_PIPELINE[EXECUTE] == Rd_PIPELINE[MEMORY];
    
    // If Rs1 depends on the 5th stage Rd
    assign DATADEP_WB_HAZARD_Rs1 =
                        Rs1_PIPELINE[EXECUTE] != 0
                    &&  Inst_type_PIPELINE[EXECUTE] != TYPE_UPPERIMMEDIATE
                    &&  Rs1_PIPELINE[EXECUTE] == Rd_PIPELINE[WRITEBACK];
    // If Rs2 depends on the 5th stage Rd
    assign DATADEP_WB_HAZARD_Rs2 =
                        Rs2_PIPELINE[EXECUTE] != 0
                    &&  Inst_type_PIPELINE[EXECUTE] != TYPE_UPPERIMMEDIATE
                    &&  Inst_type_PIPELINE[EXECUTE] != TYPE_IMMEDIATE
                    &&  Rs2_PIPELINE[EXECUTE] == Rd_PIPELINE[WRITEBACK];
    

    // If the next instruction depends on a Load instruction before, stall one clock.
    wire LOAD_STALL =
                        Inst_type_PIPELINE[EXECUTE] == TYPE_LOAD
                    &&  (
                            (
                                Inst_type_PIPELINE[DECODE] != TYPE_UPPERIMMEDIATE
                            &&  Inst_type_PIPELINE[DECODE] != TYPE_IMMEDIATE
                            &&  (
                                    (Rs1_PIPELINE[DECODE] != 0 && Rs1_PIPELINE[DECODE] == Rd_PIPELINE[EXECUTE])
                                ||  (Rs2_PIPELINE[DECODE] != 0 && Rs2_PIPELINE[DECODE] == Rd_PIPELINE[EXECUTE])
                                )
                            )
                        ||  (   
                                Inst_type_PIPELINE[DECODE] == TYPE_IMMEDIATE
                            &&  Rs1_PIPELINE[DECODE] != 0
                            &&  Rs1_PIPELINE[DECODE] == Rd_PIPELINE[EXECUTE]
                            )
                        );
    
    // If there is a branch instruction, stall for 2 clocks.
    wire CONTROL_HAZARD_STALL = INSTRUCTION_DECODE_2[6:0] == OP_B_TYPE || INSTRUCTION_EXECUTE_3[6:0] == OP_B_TYPE;
    



    








    // == PIPELINING ==================================================    
    // -- 1. Stage: Fetch
    

    always @(posedge i_clk) begin
        if (PC_ALU_SEL == 1) begin
            PC <= ALU_OUT[9:0];
        end
        else begin
            if (LOAD_STALL == 1 || CONTROL_HAZARD_STALL == 1)
                PC <= PC; 
            else
                PC <= PC + 4;
        end        

        // PIPELINE HAZARD DATA REGISTERS
        if (CONTROL_HAZARD_STALL == 1) begin
            Rs1_PIPELINE[DECODE]      <= 0;
            Rs2_PIPELINE[DECODE]      <= 0;
            Rd_PIPELINE[DECODE]      <= 0;
            Inst_type_PIPELINE[DECODE]    <= TYPE_IMMEDIATE;
        end
        else begin
            Rs1_PIPELINE[DECODE] <= i_instruction[19:15];
            Rs2_PIPELINE[DECODE] <= i_instruction[24:20];
            Rd_PIPELINE[DECODE] <= i_instruction[11:7];

            if (i_instruction[6:0] == OP_R_TYPE) // R-Type
                Inst_type_PIPELINE[DECODE] <= TYPE_REGISTER;
                
            else if (i_instruction[6:0] == OP_I_TYPE_LOAD) // Load
                Inst_type_PIPELINE[DECODE] <= TYPE_LOAD;

            else if (i_instruction[6:0] == OP_S_TYPE) // Store
                Inst_type_PIPELINE[DECODE] <= TYPE_STORE;

            else if (i_instruction[6:0] == OP_I_TYPE_OTHER || i_instruction[6:0] == OP_I_TYPE_JUMP) // Immediate
                Inst_type_PIPELINE[DECODE] <= TYPE_IMMEDIATE;

            else if (i_instruction[6:0] == OP_B_TYPE[6:0]) // Branch
                Inst_type_PIPELINE[DECODE] <= TYPE_BRANCH;
        end
    end


    // -- 2. Stage: Decode
   

    always @(posedge i_clk) begin
        if (LOAD_STALL == 1) begin
            INSTRUCTION_DECODE_2 <= INSTRUCTION_DECODE_2;
            PC_DECODE_2 <= PC_DECODE_2;
        end
        else if (CONTROL_HAZARD_STALL == 1) begin
            INSTRUCTION_DECODE_2 <= 32'h00000013;
            PC_DECODE_2 <= PC_DECODE_2;
        end
        else begin
            INSTRUCTION_DECODE_2 <= i_instruction;
            PC_DECODE_2 <= PC;
        end
        
        
        // Pipeline Type
        if (INSTRUCTION_DECODE_2[6:0] == OP_R_TYPE) // R-Type
            Inst_type_PIPELINE[EXECUTE] <= TYPE_REGISTER;
            
        else if (INSTRUCTION_DECODE_2[6:0] == OP_I_TYPE_LOAD) // Load
            Inst_type_PIPELINE[EXECUTE] <= TYPE_LOAD;

        else if (INSTRUCTION_DECODE_2[6:0] == OP_S_TYPE) // Store
            Inst_type_PIPELINE[EXECUTE] <= TYPE_STORE;

        else if (INSTRUCTION_DECODE_2[6:0] == OP_I_TYPE_OTHER || INSTRUCTION_DECODE_2[6:0] == OP_I_TYPE_JUMP) // Immediate
            Inst_type_PIPELINE[EXECUTE] <= TYPE_IMMEDIATE;

        else if (INSTRUCTION_DECODE_2[6:0] == OP_B_TYPE[6:0]) // Branch
            Inst_type_PIPELINE[EXECUTE] <= TYPE_BRANCH;
        
        Rs1_PIPELINE[EXECUTE] <= INSTRUCTION_DECODE_2[19:15];
        Rs2_PIPELINE[EXECUTE] <= INSTRUCTION_DECODE_2[24:20];
        Rd_PIPELINE[EXECUTE] <= INSTRUCTION_DECODE_2[11:7];

        
        if (LOAD_STALL == 1) begin
            Rs1_PIPELINE[EXECUTE]      <= 0;
            Rs2_PIPELINE[EXECUTE]      <= 0;
            Rd_PIPELINE[EXECUTE]      <= 0;
            Inst_type_PIPELINE[EXECUTE]    <= TYPE_IMMEDIATE;
        end
    end


    // -- 3. Stage: Execute


    always @(posedge i_clk) begin
        if (LOAD_STALL == 1 ) begin
            INSTRUCTION_EXECUTE_3 <= 32'h00000013; // NOP for Stall
            PC_EXECUTE_3 <= PC_EXECUTE_3;
        end
        else begin
            PC_EXECUTE_3 <= PC_DECODE_2;
            INSTRUCTION_EXECUTE_3 <= INSTRUCTION_DECODE_2;
        end

        

        if (INSTRUCTION_EXECUTE_3[6:0] == OP_R_TYPE) // R-Type
            Inst_type_PIPELINE[MEMORY] <= TYPE_REGISTER;
            
        else if (INSTRUCTION_EXECUTE_3[6:0] == OP_I_TYPE_LOAD) // Load
            Inst_type_PIPELINE[MEMORY] <= TYPE_LOAD;

        else if (INSTRUCTION_EXECUTE_3[6:0] == OP_S_TYPE) // Store
            Inst_type_PIPELINE[MEMORY] <= TYPE_STORE;

        else if (INSTRUCTION_EXECUTE_3[6:0] == OP_I_TYPE_OTHER || INSTRUCTION_EXECUTE_3[6:0] == OP_I_TYPE_JUMP) // Immediate
            Inst_type_PIPELINE[MEMORY] <= TYPE_IMMEDIATE;

        else if (INSTRUCTION_EXECUTE_3[6:0] == OP_B_TYPE[6:0]) // Branch
            Inst_type_PIPELINE[MEMORY] <= TYPE_BRANCH;
        
        Rs1_PIPELINE[MEMORY] <= INSTRUCTION_EXECUTE_3[19:15];
        Rs2_PIPELINE[MEMORY] <= INSTRUCTION_EXECUTE_3[24:20];
        Rd_PIPELINE[MEMORY] <= INSTRUCTION_EXECUTE_3[11:7];
    end    


    // -- 4. Stage: Memory


    always @(posedge i_clk) begin
        INSTRUCTION_MEMORY_4 <= INSTRUCTION_EXECUTE_3;
        PC_MEMORY_4 <= PC_EXECUTE_3;

        ALU_OUT_MEMORY_4 <= ALU_OUT;
        o_DataMemory_WriteData <= Rs2_DATA;
        

        if (INSTRUCTION_MEMORY_4[6:0] == OP_R_TYPE) // R-Type
            Inst_type_PIPELINE[WRITEBACK] <= TYPE_REGISTER;
            
        else if (INSTRUCTION_MEMORY_4[6:0] == OP_I_TYPE_LOAD) // Load
            Inst_type_PIPELINE[WRITEBACK] <= TYPE_LOAD;

        else if (INSTRUCTION_MEMORY_4[6:0] == OP_S_TYPE) // Store
            Inst_type_PIPELINE[WRITEBACK] <= TYPE_STORE;

        else if (INSTRUCTION_MEMORY_4[6:0] == OP_I_TYPE_OTHER|| INSTRUCTION_MEMORY_4[6:0] == OP_I_TYPE_JUMP) // Immediate
            Inst_type_PIPELINE[WRITEBACK] <= TYPE_IMMEDIATE;

        else if (INSTRUCTION_MEMORY_4[6:0] == OP_B_TYPE[6:0]) // Branch
            Inst_type_PIPELINE[WRITEBACK] <= TYPE_BRANCH;
        
        Rs1_PIPELINE[WRITEBACK] <= INSTRUCTION_MEMORY_4[19:15];
        Rs2_PIPELINE[WRITEBACK] <= INSTRUCTION_MEMORY_4[24:20];
        Rd_PIPELINE[WRITEBACK] <= INSTRUCTION_MEMORY_4[11:7];
    end


    // -- 5. Stage: WriteBack

    
    always @(posedge i_clk) begin
        INSTRUCTION_WRITEBACK_5 <= INSTRUCTION_MEMORY_4;
        DataMEM_READ_DATA_WRITEBACK_5 <= i_DataMemory_ReadData;

        case (REG_WRITEBACK_SELECTION)
            1: REG_WRITE_DATA_WRITEBACK_5 <= ALU_OUT_MEMORY_4;
            2: REG_WRITE_DATA_WRITEBACK_5 <= PC_MEMORY_4 + 4;
        endcase
    end
endmodule
