library ieee;
use ieee.std_logic_1164.all;

entity ALU_Control is
    port (
        ALUOp   : in  std_logic_vector(1 downto 0);
        funct3  : in  std_logic_vector(2 downto 0);
        funct7  : in  std_logic_vector(6 downto 0);
        ALUCtrl : out std_logic_vector(3 downto 0)
    );
end entity;

architecture Behavioral of ALU_Control is
begin
    process(ALUOp, funct3, funct7)
    begin
        case ALUOp is
            when "00" => ALUCtrl <= "0010"; -- ADD (lw/sw/addi)
            when "01" => ALUCtrl <= "0110"; -- SUB (beq)
            when "10" =>
                case funct3 is
                    when "000" =>
                        if funct7 = "0100000" then
                            ALUCtrl <= "0110"; -- SUB
                        else
                            ALUCtrl <= "0010"; -- ADD
                        end if;
                    when "111" => ALUCtrl <= "0000"; -- AND
                    when "110" => ALUCtrl <= "0001"; -- OR
                    when "100" => ALUCtrl <= "0011"; -- XOR
                    when others => ALUCtrl <= "1111"; -- Undefined
                end case;
            when others =>
                ALUCtrl <= "1111";
        end case;
    end process;
end architecture;
