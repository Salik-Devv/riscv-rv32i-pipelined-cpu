-- forwarding_unit.vhd
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Forwarding_Unit is
    port (
        -- Inputs from pipeline regs
        EX_MEM_RegWrite : in  std_logic;
        MEM_WB_RegWrite : in  std_logic;
        EX_MEM_Rd       : in  std_logic_vector(4 downto 0);
        MEM_WB_Rd       : in  std_logic_vector(4 downto 0);
        ID_EX_Rs1       : in  std_logic_vector(4 downto 0);
        ID_EX_Rs2       : in  std_logic_vector(4 downto 0);
        -- Outputs (00 = no forward, 10 = forward from EX/MEM, 01 = forward from MEM/WB)
        ForwardA        : out std_logic_vector(1 downto 0);
        ForwardB        : out std_logic_vector(1 downto 0)
    );
end entity;

architecture Behavioral of Forwarding_Unit is
begin
    process(EX_MEM_RegWrite, MEM_WB_RegWrite, EX_MEM_Rd, MEM_WB_Rd, ID_EX_Rs1, ID_EX_Rs2)
    begin
        -- Defaults
        ForwardA <= "00";
        ForwardB <= "00";

        -- ForwardA priority: EX/MEM then MEM/WB
        if (EX_MEM_RegWrite = '1' and EX_MEM_Rd /= "00000" and EX_MEM_Rd = ID_EX_Rs1) then
            ForwardA <= "10";
        elsif (MEM_WB_RegWrite = '1' and MEM_WB_Rd /= "00000" and MEM_WB_Rd = ID_EX_Rs1) then
            ForwardA <= "01";
        else
            ForwardA <= "00";
        end if;

        -- ForwardB priority: EX/MEM then MEM/WB
        if (EX_MEM_RegWrite = '1' and EX_MEM_Rd /= "00000" and EX_MEM_Rd = ID_EX_Rs2) then
            ForwardB <= "10";
        elsif (MEM_WB_RegWrite = '1' and MEM_WB_Rd /= "00000" and MEM_WB_Rd = ID_EX_Rs2) then
            ForwardB <= "01";
        else
            ForwardB <= "00";
        end if;
    end process;
end architecture Behavioral;

