library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ImmGen is
    port (
        instr   : in  std_logic_vector(31 downto 0); -- full instruction
        imm_out : out std_logic_vector(31 downto 0)  -- sign-extended immediate
    );
end entity;

architecture Behavioral of ImmGen is
    signal imm_s : signed(31 downto 0);
begin
    process(instr)
        variable tmp : signed(31 downto 0);
        variable opcode : std_logic_vector(6 downto 0);
    begin
        opcode := instr(6 downto 0);
        -- Default
        tmp := (others => '0');

        -- I-type (ADDI, LD, loads): imm[11:0] = instr[31:20]
        if opcode = "0010011" or opcode = "0000011" or opcode = "1100111" then
            tmp := resize(signed(instr(31 downto 20)), 32);

        -- S-type (stores): imm[11:0] = instr[31:25] & instr[11:7]
        elsif opcode = "0100011" then
            tmp := resize(signed(instr(31 downto 25) & instr(11 downto 7)), 32);

        -- B-type (branches): imm[12|10:5|4:1|11] << 1 (branch offsets)
        elsif opcode = "1100011" then
            tmp := resize(
                       signed(instr(31) & instr(7) & instr(30 downto 25) & instr(11 downto 8) & '0'),
                       32);

        -- U-type (LUI/AUIPC): imm[31:12] << 12
        elsif opcode = "0110111" or opcode = "0010111" then
            tmp := resize(signed(instr(31 downto 12) & (12 => '0')), 32);

        -- J-type (JAL): imm[20|10:1|11|19:12] << 1
        elsif opcode = "1101111" then
            tmp := resize(
                       signed(instr(31) & instr(19 downto 12) & instr(20) & instr(30 downto 21) & '0'),
                       32);

        else
            tmp := (others => '0');
        end if;

        imm_s <= tmp;
    end process;

    imm_out <= std_logic_vector(imm_s);
end architecture Behavioral;

