library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.regfile_pkg.all;

entity cpu_top_synth is
    port (
        clk          : in  std_logic;
        reset        : in  std_logic;

        -- Instruction memory interface
        instr_addr   : out std_logic_vector(31 downto 0);
        instr_data   : in  std_logic_vector(31 downto 0);

        -- Data memory interface
        data_addr    : out std_logic_vector(31 downto 0);
        data_wdata   : out std_logic_vector(31 downto 0);
        data_rdata   : in  std_logic_vector(31 downto 0);
        data_we      : out std_logic
    );
end entity;

architecture Structural of cpu_top_synth is

    -- IF/ID Pipeline Signals
    signal IF_ID_instr, IF_ID_pc : std_logic_vector(31 downto 0);

    -- ID/EX Pipeline Signals 
    signal ID_EX_ReadData1, ID_EX_ReadData2, ID_EX_Imm : std_logic_vector(31 downto 0);
    signal ID_EX_Rs1, ID_EX_Rs2, ID_EX_Rd : std_logic_vector(4 downto 0);
    signal ID_EX_RegWrite, ID_EX_MemRead, ID_EX_MemWrite, ID_EX_MemToReg, ID_EX_ALUSrc, ID_EX_Branch : std_logic;
    signal ID_EX_pc : std_logic_vector(31 downto 0);
    
    signal ID_EX_ALUCtrl : std_logic_vector(3 downto 0);
    
    signal ID_EX_ForwardedA : std_logic_vector(31 downto 0);
    signal ID_EX_ForwardedB : std_logic_vector(31 downto 0);

    -- EX/MEM Pipeline Signals
    signal EX_MEM_ALUResult, EX_MEM_WriteData : std_logic_vector(31 downto 0);
    signal EX_MEM_Rd : std_logic_vector(4 downto 0);
    signal EX_MEM_RegWrite, EX_MEM_MemRead, EX_MEM_MemWrite, EX_MEM_MemToReg : std_logic;
    signal EX_MEM_pc : std_logic_vector(31 downto 0);
    
    signal EX_MEM_BranchTaken : std_logic;
    signal EX_MEM_BranchTarget : std_logic_vector(31 downto 0);

    -- MEM/WB Pipeline Signals
    signal MEM_WB_ReadData, MEM_WB_ALUResult : std_logic_vector(31 downto 0);
    signal MEM_WB_Rd : std_logic_vector(4 downto 0);
    signal MEM_WB_RegWrite, MEM_WB_MemToReg : std_logic;

    -- Program Counter
    signal PC, next_PC : std_logic_vector(31 downto 0);
    signal PCWrite, IF_ID_Write, ID_EX_Flush : std_logic;

    -- Control/ALU Signals
    signal RegWrite, MemRead, MemWrite, MemToReg, ALUSrc, Branch : std_logic;
    signal ALUOp : std_logic_vector(1 downto 0);
    
    signal ALUCtrl_computed : std_logic_vector(3 downto 0);
    
    signal ALU_A, ALU_B : std_logic_vector(31 downto 0);
    signal ALU_Result_w : std_logic_vector(31 downto 0);
    signal ALU_Zero : std_logic;
    signal WB_WriteData : std_logic_vector(31 downto 0);

    -- Forwarding signals (combinational in ID stage)
    signal ForwardA_comb, ForwardB_comb : std_logic_vector(1 downto 0);
    signal forwarded_rs1_comb, forwarded_rs2_comb : std_logic_vector(31 downto 0);

    -- Branch computation (combinational in EX)
    signal BranchTaken_comb : std_logic;
    signal BranchTarget_comb : std_logic_vector(31 downto 0);

    -- Internal Regfile
    signal RegFile_dump_int : reg_array_public;
    signal rs1_data_raw, rs2_data_raw : std_logic_vector(31 downto 0);
    
    signal imm_extended : std_logic_vector(31 downto 0);

    -- Load-use hazard detection
    signal load_use_stall : std_logic;

begin
    load_use_stall <= '1' when (
        ID_EX_MemRead = '1' and ID_EX_Rd /= "00000" and (
            ID_EX_Rd = IF_ID_instr(19 downto 15) or 
            ID_EX_Rd = IF_ID_instr(24 downto 20)
        )
    ) else '0';

    PCWrite <= not load_use_stall;
    IF_ID_Write <= not load_use_stall;
    ID_EX_Flush <= load_use_stall or EX_MEM_BranchTaken;

    -- PC Update 
    process(clk, reset)
    begin
        if reset = '1' then
            PC <= (others => '0');
        elsif rising_edge(clk) then
            if PCWrite = '1' then
                PC <= next_PC;
            end if;
        end if;
    end process;

    next_PC <= EX_MEM_BranchTarget when EX_MEM_BranchTaken = '1' 
               else std_logic_vector(unsigned(PC) + 4);
    
    instr_addr <= PC;

    -- Register File
    RF: entity work.RegFile
        port map (
            clk => clk,
            we => MEM_WB_RegWrite,
            rs1_addr => IF_ID_instr(19 downto 15),
            rs2_addr => IF_ID_instr(24 downto 20),
            rd_addr => MEM_WB_Rd,
            rd_data_in => WB_WriteData,
            rs1_data => rs1_data_raw,
            rs2_data => rs2_data_raw,
            dump_regs_out => RegFile_dump_int
        );

    -- IF/ID Pipeline Register
    process(clk, reset)
    begin
        if reset = '1' then
            IF_ID_instr <= (others => '0');
            IF_ID_pc <= (others => '0');
        elsif rising_edge(clk) then
            if ID_EX_Flush = '1' then
                IF_ID_instr <= x"00000013";  -- NOP
                IF_ID_pc <= (others => '0');
            elsif IF_ID_Write = '1' then
                IF_ID_instr <= instr_data;
                IF_ID_pc <= PC;
            end if;
        end if;
    end process;

    -- Control Unit (ID Stage)
    CU: entity work.Control_Unit
        port map (
            opcode => IF_ID_instr(6 downto 0),
            RegWrite => RegWrite,
            MemToReg => MemToReg,
            MemRead  => MemRead,
            MemWrite => MemWrite,
            ALUSrc   => ALUSrc,
            Branch   => Branch,
            ALUOp    => ALUOp
        );

    -- OPTIMIZATION 1: Immediate Generator 
    IMM: entity work.ImmGen
        port map (
            instr => IF_ID_instr,
            imm_out => imm_extended  
        );

    -- OPTIMIZATION 2: ALU Control (ID Stage - precomputed)
    ALU_CTRL_UNIT: entity work.ALU_Control
        port map (
            ALUOp   => ALUOp,
            funct3  => IF_ID_instr(14 downto 12),
            funct7  => IF_ID_instr(31 downto 25),
            ALUCtrl => ALUCtrl_computed  
        );

    -- Computes forwarding for NEXT cycle
    FWD: entity work.Forwarding_Unit
        port map (
            EX_MEM_RegWrite => EX_MEM_RegWrite,
            MEM_WB_RegWrite => MEM_WB_RegWrite,
            EX_MEM_Rd => EX_MEM_Rd,
            MEM_WB_Rd => MEM_WB_Rd,
            ID_EX_Rs1 => IF_ID_instr(19 downto 15), 
            ID_EX_Rs2 => IF_ID_instr(24 downto 20),  
            ForwardA => ForwardA_comb,
            ForwardB => ForwardB_comb
        );

    -- Forward RS1
    with ForwardA_comb select
        forwarded_rs1_comb <= EX_MEM_ALUResult when "10",
                              WB_WriteData when "01",
                              rs1_data_raw when others;

    -- Forward RS2
    with ForwardB_comb select
        forwarded_rs2_comb <= EX_MEM_ALUResult when "10",
                              WB_WriteData when "01",
                              rs2_data_raw when others;

    -- ID/EX Pipeline Register
    process(clk, reset)
    begin
        if reset = '1' then
            ID_EX_pc <= (others => '0');
            ID_EX_ReadData1 <= (others => '0');
            ID_EX_ReadData2 <= (others => '0');
            ID_EX_Imm <= (others => '0');
            ID_EX_Rs1 <= (others => '0');
            ID_EX_Rs2 <= (others => '0');
            ID_EX_Rd <= (others => '0');
            ID_EX_RegWrite <= '0';
            ID_EX_MemRead <= '0';
            ID_EX_MemWrite <= '0';
            ID_EX_MemToReg <= '0';
            ID_EX_ALUSrc <= '0';
            ID_EX_Branch <= '0';
            ID_EX_ALUCtrl <= (others => '0');
            ID_EX_ForwardedA <= (others => '0');
            ID_EX_ForwardedB <= (others => '0');
        elsif rising_edge(clk) then
            if ID_EX_Flush = '1' then
                ID_EX_RegWrite <= '0';
                ID_EX_MemRead <= '0';
                ID_EX_MemWrite <= '0';
                ID_EX_MemToReg <= '0';
                ID_EX_ALUSrc <= '0';
                ID_EX_Branch <= '0';
            else
                ID_EX_pc <= IF_ID_pc;
                ID_EX_ReadData1 <= rs1_data_raw;
                ID_EX_ReadData2 <= rs2_data_raw;
                ID_EX_Rs1 <= IF_ID_instr(19 downto 15);
                ID_EX_Rs2 <= IF_ID_instr(24 downto 20);
                ID_EX_Rd <= IF_ID_instr(11 downto 7);
                ID_EX_RegWrite <= RegWrite;
                ID_EX_MemRead <= MemRead;
                ID_EX_MemWrite <= MemWrite;
                ID_EX_MemToReg <= MemToReg;
                ID_EX_ALUSrc <= ALUSrc;
                ID_EX_Branch <= Branch;
                
                ID_EX_Imm <= imm_extended;
                
                ID_EX_ALUCtrl <= ALUCtrl_computed;
                
                ID_EX_ForwardedA <= forwarded_rs1_comb;
                ID_EX_ForwardedB <= forwarded_rs2_comb;
            end if;
        end if;
    end process;

    -- EX Stage 
    -- ALU inputs are already forwarded and registered!
    
    ALU_A <= ID_EX_ForwardedA;
    
    ALU_B <= ID_EX_Imm when ID_EX_ALUSrc = '1' else ID_EX_ForwardedB;

    -- ALU (EX Stage)
    ALU1: entity work.ALU
        port map (
            A       => ALU_A,
            B       => ALU_B,
            ALUCtrl => ID_EX_ALUCtrl,  
            Result  => ALU_Result_w,
            Zero    => ALU_Zero
        );

    -- Branch Logic (EX Stage - combinational, will be registered)
    BranchTaken_comb <= ID_EX_Branch and ALU_Zero;
    BranchTarget_comb <= std_logic_vector(unsigned(ID_EX_pc) + unsigned(ID_EX_Imm));

    -- EX/MEM Pipeline Register
    process(clk, reset)
    begin
        if reset = '1' then
            EX_MEM_pc <= (others => '0');
            EX_MEM_ALUResult <= (others => '0');
            EX_MEM_WriteData <= (others => '0');
            EX_MEM_Rd <= (others => '0');
            EX_MEM_RegWrite <= '0';
            EX_MEM_MemRead <= '0';
            EX_MEM_MemWrite <= '0';
            EX_MEM_MemToReg <= '0';
            EX_MEM_BranchTaken <= '0';
            EX_MEM_BranchTarget <= (others => '0');
        elsif rising_edge(clk) then
            EX_MEM_pc <= ID_EX_pc;
            EX_MEM_ALUResult <= ALU_Result_w;
            EX_MEM_WriteData <= ID_EX_ForwardedB;  -- Use pre-forwarded value
            EX_MEM_Rd <= ID_EX_Rd;
            EX_MEM_RegWrite <= ID_EX_RegWrite;
            EX_MEM_MemRead <= ID_EX_MemRead;
            EX_MEM_MemWrite <= ID_EX_MemWrite;
            EX_MEM_MemToReg <= ID_EX_MemToReg;
            
            EX_MEM_BranchTaken <= BranchTaken_comb;
            EX_MEM_BranchTarget <= BranchTarget_comb;
        end if;
    end process;

    -- Data Memory Interface
    data_addr <= EX_MEM_ALUResult;
    data_wdata <= EX_MEM_WriteData;
    data_we <= EX_MEM_MemWrite;

    -- MEM/WB Pipeline Register
    process(clk, reset)
    begin
        if reset = '1' then
            MEM_WB_ReadData <= (others => '0');
            MEM_WB_ALUResult <= (others => '0');
            MEM_WB_Rd <= (others => '0');
            MEM_WB_RegWrite <= '0';
            MEM_WB_MemToReg <= '0';
        elsif rising_edge(clk) then
            MEM_WB_ReadData <= data_rdata;
            MEM_WB_ALUResult <= EX_MEM_ALUResult;
            MEM_WB_Rd <= EX_MEM_Rd;
            MEM_WB_RegWrite <= EX_MEM_RegWrite;
            MEM_WB_MemToReg <= EX_MEM_MemToReg;
        end if;
    end process;

    -- Write Back Logic
    WB_WriteData <= MEM_WB_ReadData when MEM_WB_MemToReg = '1' else MEM_WB_ALUResult;

end architecture Structural;