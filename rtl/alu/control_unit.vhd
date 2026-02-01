library ieee;
use ieee.std_logic_1164.all;

entity Control_Unit is
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
end entity;

architecture Behavioral of Control_Unit is
begin
    process(opcode)
    begin
        -- Default (NOP)
        RegWrite <= '0';
        MemtoReg <= '0';
        MemRead  <= '0';
        MemWrite <= '0';
        ALUSrc   <= '0';
        Branch   <= '0';
        ALUOp    <= "00";

        case opcode is

            -- R-type (ADD, SUB, AND, OR, XOR)
            when "0110011" =>      
                RegWrite <= '1';
                ALUSrc   <= '0';
                ALUOp    <= "10";

            -- I-type arithmetic (ADDI, ORI, ANDI, etc.)
            when "0010011" =>      
                RegWrite <= '1';
                ALUSrc   <= '1';
                ALUOp    <= "00";

            -- Load (LW)
            when "0000011" =>     
                RegWrite <= '1';
                MemtoReg <= '1';
                MemRead  <= '1';
                ALUSrc   <= '1';
                ALUOp    <= "00";

            -- Store (SW)
            when "0100011" =>      
                MemWrite <= '1';
                ALUSrc   <= '1';
                ALUOp    <= "00";

            -- Branch (BEQ)
            when "1100011" =>      
                Branch   <= '1';
                ALUOp    <= "01";

            -- JAL / JALR (optional)
            when "1101111" | "1100111" =>
                RegWrite <= '1';
                ALUSrc   <= '1';
                ALUOp    <= "00";

            -- Default (NOP)
            when others =>
                RegWrite <= '0';
                MemtoReg <= '0';
                MemRead  <= '0';
                MemWrite <= '0';
                ALUSrc   <= '0';
                Branch   <= '0';
                ALUOp    <= "00";
        end case;
    end process;
end architecture;

