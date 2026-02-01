library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.regfile_pkg.all;

entity RegFile is
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
end entity;

architecture Behavioral of RegFile is
    signal regs : reg_array_public := (others => (others => '0'));
begin

    process(clk)
    begin
        if rising_edge(clk) then
            if we = '1' and rd_addr /= "00000" then
                regs(to_integer(unsigned(rd_addr))) <= rd_data_in;
            end if;
        end if;
    end process;

    -- asynchronous reads with internal forwarding
    rs1_data <= rd_data_in when (we = '1' and rs1_addr = rd_addr and rd_addr /= "00000")
                else (others => '0') when rs1_addr = "00000"
                else regs(to_integer(unsigned(rs1_addr)));

    rs2_data <= rd_data_in when (we = '1' and rs2_addr = rd_addr and rd_addr /= "00000")
                else (others => '0') when rs2_addr = "00000"
                else regs(to_integer(unsigned(rs2_addr)));
    dump_regs_out <= regs;
end architecture;
