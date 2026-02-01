library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.regfile_pkg.all;

entity cpu_top is
    port (
        clk          : in  std_logic;
        reset        : in  std_logic;
        -- Instruction Memory Interface
        imem_addr    : out std_logic_vector(31 downto 0);
        imem_data    : in  std_logic_vector(31 downto 0);
        -- Data Memory Interface
        dmem_addr    : out std_logic_vector(31 downto 0);
        dmem_wdata   : out std_logic_vector(31 downto 0);
        dmem_rdata   : in  std_logic_vector(31 downto 0);
        dmem_we      : out std_logic;
        dmem_re      : out std_logic;
        -- Debug outputs (optional)
        pc_out       : out std_logic_vector(31 downto 0);
        reg_dump     : out reg_array_public
    );
end entity cpu_top;

architecture Behavioral of cpu_top is

    -- Component Declarations
    
    component RegFile is
        port (
            clk           : in  std_logic;
            we            : in  std_logic;
            rs1_addr      : in  std_logic_vector(4 downto 0);
            rs2_addr      : in  std_logic_vector(4 downto 0);
            rd_addr       : in  std_logic_vector(4 downto 0);
            rd_data_in    : in  std_logic_vector(31 downto 0);
            rs1_data      : out std_logic_vector(31 downto 0);
            rs2_data      : out std_logic_vector(31 downto 0);
            dump_regs_out : out reg_array_public
        );
    end component;

    component Control_Unit is
        port (
            opcode   : in  std_logic_vector(6 downto 0);
            RegWrite : out std_logic;
            MemtoReg : out std_logic;
            MemRead  : out std_logic;
            MemWrite : out std_logic;
            ALUSrc   : out std_logic;
            Branch   : out std_logic;
            ALUOp    : out std_logic_vector(1 downto 0)
        );
    end component;

    component ALU_Control is
        port (
            ALUOp   : in  std_logic_vector(1 downto 0);
            funct3  : in  std_logic_vector(2 downto 0);
            funct7  : in  std_logic_vector(6 downto 0);
            ALUCtrl : out std_logic_vector(3 downto 0)
        );
    end component;

    component ALU is
        port (
            A       : in  std_logic_vector(31 downto 0);
            B       : in  std_logic_vector(31 downto 0);
            ALUCtrl : in  std_logic_vector(3 downto 0);
            Result  : out std_logic_vector(31 downto 0);
            Zero    : out std_logic
        );
    end component;

    component ImmGen is
        port (
            instr   : in  std_logic_vector(31 downto 0);
            imm_out : out std_logic_vector(31 downto 0)
        );
    end component;

    component Forwarding_Unit is
        port (
            EX_MEM_RegWrite : in  std_logic;
            MEM_WB_RegWrite : in  std_logic;
            EX_MEM_Rd       : in  std_logic_vector(4 downto 0);
            MEM_WB_Rd       : in  std_logic_vector(4 downto 0);
            ID_EX_Rs1       : in  std_logic_vector(4 downto 0);
            ID_EX_Rs2       : in  std_logic_vector(4 downto 0);
            ForwardA        : out std_logic_vector(1 downto 0);
            ForwardB        : out std_logic_vector(1 downto 0)
        );
    end component;

    component Hazard_Unit is
        port (
            ID_EX_MemRead  : in  std_logic;
            ID_EX_Rd       : in  std_logic_vector(4 downto 0);
            IF_ID_Rs1      : in  std_logic_vector(4 downto 0);
            IF_ID_Rs2      : in  std_logic_vector(4 downto 0);
            BranchTaken    : in  std_logic;
            JumpTaken      : in  std_logic;
            PCWrite        : out std_logic;
            IF_ID_Write    : out std_logic;
            ID_EX_Flush    : out std_logic
        );
    end component;

    -- Pipeline Stage Signals

    -- IF Stage
    signal PC_reg         : unsigned(31 downto 0) := (others => '0');
    signal PC_next        : unsigned(31 downto 0);
    signal PC_plus4       : unsigned(31 downto 0);
    signal PC_branch      : unsigned(31 downto 0);
    signal instruction    : std_logic_vector(31 downto 0);

    -- IF/ID Pipeline Register
    signal IFID_PC        : std_logic_vector(31 downto 0) := (others => '0');
    signal IFID_Instr     : std_logic_vector(31 downto 0) := (others => '0');

    -- ID Stage
    signal rs1_data       : std_logic_vector(31 downto 0);
    signal rs2_data       : std_logic_vector(31 downto 0);
    signal imm_extended   : std_logic_vector(31 downto 0);
    signal opcode         : std_logic_vector(6 downto 0);
    signal rs1_addr       : std_logic_vector(4 downto 0);
    signal rs2_addr       : std_logic_vector(4 downto 0);
    signal rd_addr        : std_logic_vector(4 downto 0);
    signal funct3         : std_logic_vector(2 downto 0);
    signal funct7         : std_logic_vector(6 downto 0);
    
    -- Control signals from ID
    signal ctrl_RegWrite  : std_logic;
    signal ctrl_MemtoReg  : std_logic;
    signal ctrl_MemRead   : std_logic;
    signal ctrl_MemWrite  : std_logic;
    signal ctrl_ALUSrc    : std_logic;
    signal ctrl_Branch    : std_logic;
    signal ctrl_ALUOp     : std_logic_vector(1 downto 0);
    signal ctrl_Jump      : std_logic;

    -- ID/EX Pipeline Register
    signal IDEX_PC        : std_logic_vector(31 downto 0) := (others => '0');
    signal IDEX_Rs1Data   : std_logic_vector(31 downto 0) := (others => '0');
    signal IDEX_Rs2Data   : std_logic_vector(31 downto 0) := (others => '0');
    signal IDEX_Imm       : std_logic_vector(31 downto 0) := (others => '0');
    signal IDEX_Rs1       : std_logic_vector(4 downto 0)  := (others => '0');
    signal IDEX_Rs2       : std_logic_vector(4 downto 0)  := (others => '0');
    signal IDEX_Rd        : std_logic_vector(4 downto 0)  := (others => '0');
    signal IDEX_Funct3    : std_logic_vector(2 downto 0)  := (others => '0');
    signal IDEX_Funct7    : std_logic_vector(6 downto 0)  := (others => '0');
    -- Control signals in ID/EX
    signal IDEX_RegWrite  : std_logic := '0';
    signal IDEX_MemtoReg  : std_logic := '0';
    signal IDEX_MemRead   : std_logic := '0';
    signal IDEX_MemWrite  : std_logic := '0';
    signal IDEX_ALUSrc    : std_logic := '0';
    signal IDEX_Branch    : std_logic := '0';
    signal IDEX_Jump      : std_logic := '0';
    signal IDEX_ALUOp     : std_logic_vector(1 downto 0) := (others => '0');

    -- EX Stage
    signal alu_input_a    : std_logic_vector(31 downto 0);
    signal alu_input_b    : std_logic_vector(31 downto 0);
    signal alu_result     : std_logic_vector(31 downto 0);
    signal alu_zero       : std_logic;
    signal alu_ctrl       : std_logic_vector(3 downto 0);
    signal forward_a      : std_logic_vector(1 downto 0);
    signal forward_b      : std_logic_vector(1 downto 0);
    signal forwarded_a    : std_logic_vector(31 downto 0);
    signal forwarded_b    : std_logic_vector(31 downto 0);

    -- EX/MEM Pipeline Register
    signal EXMEM_ALUResult : std_logic_vector(31 downto 0) := (others => '0');
    signal EXMEM_Rs2Data   : std_logic_vector(31 downto 0) := (others => '0');
    signal EXMEM_Rd        : std_logic_vector(4 downto 0)  := (others => '0');
    signal EXMEM_PC        : std_logic_vector(31 downto 0) := (others => '0');
    signal EXMEM_Imm       : std_logic_vector(31 downto 0) := (others => '0');  
    signal EXMEM_Zero      : std_logic := '0';
    -- Control signals in EX/MEM
    signal EXMEM_RegWrite  : std_logic := '0';
    signal EXMEM_MemtoReg  : std_logic := '0';
    signal EXMEM_MemRead   : std_logic := '0';
    signal EXMEM_MemWrite  : std_logic := '0';
    signal EXMEM_Branch    : std_logic := '0';
    signal EXMEM_Jump      : std_logic := '0';

    -- MEM Stage
    signal mem_read_data  : std_logic_vector(31 downto 0);

    -- MEM/WB Pipeline Register
    signal MEMWB_ALUResult : std_logic_vector(31 downto 0) := (others => '0');
    signal MEMWB_MemData   : std_logic_vector(31 downto 0) := (others => '0');
    signal MEMWB_Rd        : std_logic_vector(4 downto 0)  := (others => '0');
    -- Control signals in MEM/WB
    signal MEMWB_RegWrite  : std_logic := '0';
    signal MEMWB_MemtoReg  : std_logic := '0';

    -- WB Stage
    signal wb_data        : std_logic_vector(31 downto 0);

    -- Hazard Control Signals
    signal pc_write       : std_logic;
    signal ifid_write     : std_logic;
    signal idex_flush     : std_logic;
    signal ifid_flush     : std_logic;
    signal branch_taken   : std_logic;
    signal jump_taken     : std_logic;
    signal control_hazard : std_logic;

    -- Registered control signals for better timing
    signal pc_write_reg   : std_logic := '1';

begin

    -- IF Stage - Instruction Fetch

    -- PC calculation
    PC_plus4 <= PC_reg + 4;
    PC_branch <= unsigned(signed(EXMEM_PC) + signed(EXMEM_Imm));  

    -- Branch/Jump detection
    branch_taken <= EXMEM_Branch and EXMEM_Zero;
    jump_taken <= EXMEM_Jump;
    control_hazard <= branch_taken or jump_taken;

    -- PC mux: priority is branch/jump > normal increment
    PC_next <= PC_branch when control_hazard = '1' else PC_plus4;

    -- Flush IF/ID on control hazards
    ifid_flush <= control_hazard;

    -- PC update process
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                PC_reg <= (others => '0');
                pc_write_reg <= '1';
            else
                pc_write_reg <= pc_write;
                if pc_write_reg = '1' then
                    PC_reg <= PC_next;
                end if;
            end if;
        end if;
    end process;

    -- Instruction memory interface
    imem_addr <= std_logic_vector(PC_reg);
    instruction <= imem_data;

    -- IF/ID Pipeline Register

    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' or ifid_flush = '1' then
                IFID_PC <= (others => '0');
                IFID_Instr <= x"00000013"; -- NOP (ADDI x0, x0, 0)
            elsif ifid_write = '1' then
                IFID_PC <= std_logic_vector(PC_reg);
                IFID_Instr <= instruction;
            end if;
        end if;
    end process;

    -- ID Stage - Instruction Decode
    opcode   <= IFID_Instr(6 downto 0);
    rd_addr  <= IFID_Instr(11 downto 7);
    funct3   <= IFID_Instr(14 downto 12);
    rs1_addr <= IFID_Instr(19 downto 15);
    rs2_addr <= IFID_Instr(24 downto 20);
    funct7   <= IFID_Instr(31 downto 25);

    -- Detect Jump instructions
    ctrl_Jump <= '1' when (opcode = "1101111" or opcode = "1100111") else '0';

    -- Register File
    U_RegFile: RegFile
        port map (
            clk           => clk,
            we            => MEMWB_RegWrite,
            rs1_addr      => rs1_addr,
            rs2_addr      => rs2_addr,
            rd_addr       => MEMWB_Rd,
            rd_data_in    => wb_data,
            rs1_data      => rs1_data,
            rs2_data      => rs2_data,
            dump_regs_out => reg_dump
        );

    -- Control Unit
    U_Control: Control_Unit
        port map (
            opcode   => opcode,
            RegWrite => ctrl_RegWrite,
            MemtoReg => ctrl_MemtoReg,
            MemRead  => ctrl_MemRead,
            MemWrite => ctrl_MemWrite,
            ALUSrc   => ctrl_ALUSrc,
            Branch   => ctrl_Branch,
            ALUOp    => ctrl_ALUOp
        );

    -- Immediate Generator
    U_ImmGen: ImmGen
        port map (
            instr   => IFID_Instr,
            imm_out => imm_extended
        );

    -- ID/EX Pipeline Register

    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' or idex_flush = '1' then
                -- Clear all control signals
                IDEX_RegWrite <= '0';
                IDEX_MemtoReg <= '0';
                IDEX_MemRead  <= '0';
                IDEX_MemWrite <= '0';
                IDEX_ALUSrc   <= '0';
                IDEX_Branch   <= '0';
                IDEX_Jump     <= '0';
                IDEX_ALUOp    <= "00";
                -- Clear data signals
                IDEX_PC       <= (others => '0');
                IDEX_Rs1Data  <= (others => '0');
                IDEX_Rs2Data  <= (others => '0');
                IDEX_Imm      <= (others => '0');
                IDEX_Rs1      <= (others => '0');
                IDEX_Rs2      <= (others => '0');
                IDEX_Rd       <= (others => '0');
                IDEX_Funct3   <= (others => '0');
                IDEX_Funct7   <= (others => '0');
            else
                -- Propagate control signals
                IDEX_RegWrite <= ctrl_RegWrite;
                IDEX_MemtoReg <= ctrl_MemtoReg;
                IDEX_MemRead  <= ctrl_MemRead;
                IDEX_MemWrite <= ctrl_MemWrite;
                IDEX_ALUSrc   <= ctrl_ALUSrc;
                IDEX_Branch   <= ctrl_Branch;
                IDEX_Jump     <= ctrl_Jump;
                IDEX_ALUOp    <= ctrl_ALUOp;
                -- Propagate data signals
                IDEX_PC       <= IFID_PC;
                IDEX_Rs1Data  <= rs1_data;
                IDEX_Rs2Data  <= rs2_data;
                IDEX_Imm      <= imm_extended;
                IDEX_Rs1      <= rs1_addr;
                IDEX_Rs2      <= rs2_addr;
                IDEX_Rd       <= rd_addr;
                IDEX_Funct3   <= funct3;
                IDEX_Funct7   <= funct7;
            end if;
        end if;
    end process;

    -- EX Stage - Execute

    -- Forwarding Unit
    U_Forwarding: Forwarding_Unit
        port map (
            EX_MEM_RegWrite => EXMEM_RegWrite,
            MEM_WB_RegWrite => MEMWB_RegWrite,
            EX_MEM_Rd       => EXMEM_Rd,
            MEM_WB_Rd       => MEMWB_Rd,
            ID_EX_Rs1       => IDEX_Rs1,
            ID_EX_Rs2       => IDEX_Rs2,
            ForwardA        => forward_a,
            ForwardB        => forward_b
        );

    -- Forwarding Mux A
    with forward_a select
        forwarded_a <= IDEX_Rs1Data      when "00",
                       wb_data           when "01",
                       EXMEM_ALUResult   when "10",
                       IDEX_Rs1Data      when others;

    -- Forwarding Mux B
    with forward_b select
        forwarded_b <= IDEX_Rs2Data      when "00",
                       wb_data           when "01",
                       EXMEM_ALUResult   when "10",
                       IDEX_Rs2Data      when others;

    -- ALU Control
    U_ALU_Control: ALU_Control
        port map (
            ALUOp   => IDEX_ALUOp,
            funct3  => IDEX_Funct3,
            funct7  => IDEX_Funct7,
            ALUCtrl => alu_ctrl
        );

    -- ALU input muxes
    alu_input_a <= forwarded_a;
    alu_input_b <= IDEX_Imm when IDEX_ALUSrc = '1' else forwarded_b;

    -- ALU
    U_ALU: ALU
        port map (
            A       => alu_input_a,
            B       => alu_input_b,
            ALUCtrl => alu_ctrl,
            Result  => alu_result,
            Zero    => alu_zero
        );

    -- EX/MEM Pipeline Register

    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                EXMEM_RegWrite  <= '0';
                EXMEM_MemtoReg  <= '0';
                EXMEM_MemRead   <= '0';
                EXMEM_MemWrite  <= '0';
                EXMEM_Branch    <= '0';
                EXMEM_Jump      <= '0';
                EXMEM_ALUResult <= (others => '0');
                EXMEM_Rs2Data   <= (others => '0');
                EXMEM_Rd        <= (others => '0');
                EXMEM_PC        <= (others => '0');
                EXMEM_Imm       <= (others => '0');  
                EXMEM_Zero      <= '0';
            else
                EXMEM_RegWrite  <= IDEX_RegWrite;
                EXMEM_MemtoReg  <= IDEX_MemtoReg;
                EXMEM_MemRead   <= IDEX_MemRead;
                EXMEM_MemWrite  <= IDEX_MemWrite;
                EXMEM_Branch    <= IDEX_Branch;
                EXMEM_Jump      <= IDEX_Jump;
                EXMEM_ALUResult <= alu_result;
                EXMEM_Rs2Data   <= forwarded_b;
                EXMEM_Rd        <= IDEX_Rd;
                EXMEM_PC        <= IDEX_PC;
                EXMEM_Imm       <= IDEX_Imm;  
                EXMEM_Zero      <= alu_zero;
            end if;
        end if;
    end process;

    -- MEM Stage - Memory Access

    dmem_addr  <= EXMEM_ALUResult;
    dmem_wdata <= EXMEM_Rs2Data;
    dmem_we    <= EXMEM_MemWrite;
    dmem_re    <= EXMEM_MemRead;
    mem_read_data <= dmem_rdata;

    -- MEM/WB Pipeline Register

    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                MEMWB_RegWrite  <= '0';
                MEMWB_MemtoReg  <= '0';
                MEMWB_ALUResult <= (others => '0');
                MEMWB_MemData   <= (others => '0');
                MEMWB_Rd        <= (others => '0');
            else
                MEMWB_RegWrite  <= EXMEM_RegWrite;
                MEMWB_MemtoReg  <= EXMEM_MemtoReg;
                MEMWB_ALUResult <= EXMEM_ALUResult;
                MEMWB_MemData   <= mem_read_data;
                MEMWB_Rd        <= EXMEM_Rd;
            end if;
        end if;
    end process;

    -- WB Stage - Write Back

    wb_data <= MEMWB_MemData when MEMWB_MemtoReg = '1' else MEMWB_ALUResult;

    -- Hazard Detection Unit

    U_Hazard: Hazard_Unit
        port map (
            ID_EX_MemRead => IDEX_MemRead,
            ID_EX_Rd      => IDEX_Rd,
            IF_ID_Rs1     => rs1_addr,
            IF_ID_Rs2     => rs2_addr,
            BranchTaken   => branch_taken,
            JumpTaken     => jump_taken,
            PCWrite       => pc_write,
            IF_ID_Write   => ifid_write,
            ID_EX_Flush   => idex_flush
        );

    -- Debug Outputs

    pc_out <= std_logic_vector(PC_reg);

end architecture Behavioral;