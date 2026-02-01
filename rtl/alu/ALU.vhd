library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU is
    generic (
        XLEN : integer := 32
    );
    port (
        A       : in  std_logic_vector(XLEN-1 downto 0);
        B       : in  std_logic_vector(XLEN-1 downto 0);
        ALUCtrl : in  std_logic_vector(3 downto 0);
        Result  : out std_logic_vector(XLEN-1 downto 0);
        Zero    : out std_logic
    );
end entity ALU;

architecture Behavioral of ALU is
    -- Intermediate signals
    signal a_s, b_s : signed(XLEN-1 downto 0);
    signal r_s      : signed(XLEN-1 downto 0);
    
    -- Pre-computed operations (all in parallel)
    signal add_result : signed(XLEN-1 downto 0);
    signal sub_result : signed(XLEN-1 downto 0);
    signal and_result : signed(XLEN-1 downto 0);
    signal or_result  : signed(XLEN-1 downto 0);
    signal xor_result : signed(XLEN-1 downto 0);
    signal sll_result : signed(XLEN-1 downto 0);
    signal srl_result : signed(XLEN-1 downto 0);
    signal sra_result : signed(XLEN-1 downto 0);
    signal slt_result : signed(XLEN-1 downto 0);
    signal sltu_result: signed(XLEN-1 downto 0);
    
    -- Shift amount
    signal shamt : natural range 0 to 31;
    
    -- Attributes for synthesis optimization
    attribute use_dsp : string;
    attribute use_dsp of add_result : signal is "no";
    attribute use_dsp of sub_result : signal is "no";
    
begin

    -- Type conversions
    a_s <= signed(A);
    b_s <= signed(B);
    shamt <= to_integer(unsigned(B(4 downto 0)));
    
    -- Arithmetic operations
    add_result <= a_s + b_s;
    sub_result <= a_s - b_s;
    
    -- Logical operations
    and_result <= a_s and b_s;
    or_result  <= a_s or b_s;
    xor_result <= a_s xor b_s;
    
    -- Shift operations
    sll_result <= shift_left(a_s, shamt);
    srl_result <= signed(shift_right(unsigned(a_s), shamt));
    sra_result <= shift_right(a_s, shamt);
    
    -- Set less than
    slt_result <= (0 => '1', others => '0') when a_s < b_s else (others => '0');
    sltu_result <= (0 => '1', others => '0') when unsigned(a_s) < unsigned(b_s) else (others => '0');

    -- Final result selection 
    
    process(ALUCtrl, add_result, sub_result, and_result, or_result, 
            xor_result, sll_result, srl_result, sra_result, slt_result, sltu_result)
    begin
        case ALUCtrl is
            when "0010" => r_s <= add_result;   -- ADD
            when "0110" => r_s <= sub_result;   -- SUB
            when "0000" => r_s <= and_result;   -- AND
            when "0001" => r_s <= or_result;    -- OR
            when "0011" => r_s <= xor_result;   -- XOR
            when "0100" => r_s <= sll_result;   -- SLL (Shift Left Logical)
            when "0101" => r_s <= srl_result;   -- SRL (Shift Right Logical)
            when "0111" => r_s <= sra_result;   -- SRA (Shift Right Arithmetic)
            when "1000" => r_s <= slt_result;   -- SLT (Set Less Than)
            when "1001" => r_s <= sltu_result;  -- SLTU (Set Less Than Unsigned)
            when others => r_s <= (others => '0');
        end case;
    end process;

    -- Output assignment
    Result <= std_logic_vector(r_s);
    
    -- Zero flag computation 
    Zero <= '1' when r_s = 0 else '0';

end architecture Behavioral;
