library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PipelineReg is
    generic (
        WIDTH : integer := 32  -- number of bits in the pipeline register
    );
    port (
        clk          : in  std_logic;
        reset        : in  std_logic;          -- synchronous active-high reset
        Write_Enable : in  std_logic;          -- when '1' capture D_in
        Flush        : in  std_logic;          -- when '1' clear register (insert bubble)
        D_in         : in  std_logic_vector(WIDTH-1 downto 0);
        Q_out        : out std_logic_vector(WIDTH-1 downto 0)
    );
end entity PipelineReg;

architecture Behavioral of PipelineReg is
    signal reg_data : std_logic_vector(WIDTH-1 downto 0) := (others => '0');
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                reg_data <= (others => '0');
            else
                if Flush = '1' then
                    reg_data <= (others => '0');   -- bubble
                elsif Write_Enable = '1' then
                    reg_data <= D_in;
                end if;
            end if;
        end if;
    end process;

    Q_out <= reg_data;
end architecture Behavioral;
