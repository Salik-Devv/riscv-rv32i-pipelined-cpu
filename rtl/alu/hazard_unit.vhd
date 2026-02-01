library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Hazard_Unit is
    port (
        -- Inputs
        ID_EX_MemRead  : in  std_logic;                     -- 1 if ID/EX instruction is a load
        ID_EX_Rd       : in  std_logic_vector(4 downto 0);  -- destination reg in ID/EX
        IF_ID_Rs1      : in  std_logic_vector(4 downto 0);  -- source regs in IF/ID
        IF_ID_Rs2      : in  std_logic_vector(4 downto 0);
        BranchTaken    : in  std_logic;                     -- set by branch comparator/EX stage
        JumpTaken      : in  std_logic;                     -- jal/jalr detection (EX/MEM or ID stage)
        -- Outputs
        PCWrite        : out std_logic;  -- when '0' freeze PC (stall)
        IF_ID_Write    : out std_logic;  -- when '0' don't update IF/ID (stall)
        ID_EX_Flush    : out std_logic   -- when '1' zero ID/EX (insert bubble)
    );
end entity;

architecture Behavioral of Hazard_Unit is
begin
    process(ID_EX_MemRead, ID_EX_Rd, IF_ID_Rs1, IF_ID_Rs2, BranchTaken, JumpTaken)
    begin
        -- Defaults: no stall, no flush
        PCWrite     <= '1';
        IF_ID_Write <= '1';
        ID_EX_Flush <= '0';

        -- Load-use hazard: if previous instruction is load and
        if (ID_EX_MemRead = '1' and
            ( (ID_EX_Rd = IF_ID_Rs1 and ID_EX_Rd /= "00000") or
              (ID_EX_Rd = IF_ID_Rs2 and ID_EX_Rd /= "00000") ) ) then
            PCWrite     <= '0';  -- stop PC (stall)
            IF_ID_Write <= '0';  -- freeze IF/ID
            ID_EX_Flush <= '1';  -- inject bubble into EX stage
        end if;

        -- Control hazard (branch/jump): flush the pipeline (override stall)
        if (BranchTaken = '1' or JumpTaken = '1') then
            PCWrite     <= '1';  -- allow PC to update to branch target
            IF_ID_Write <= '1';  -- fetch new instruction
            ID_EX_Flush <= '1';  -- flush the wrong-path instruction in EX
        end if;
    end process;
end architecture Behavioral;

