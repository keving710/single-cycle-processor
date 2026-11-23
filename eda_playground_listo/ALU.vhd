-- ============================================================================
-- Archivo: ALU/ALU.vhd
-- Descripcion: Unidad Aritmetico-Logica de 32 bits (10 operaciones RV32I)
-- ============================================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALU is
    port (
        A      : in  std_logic_vector(31 downto 0);
        B      : in  std_logic_vector(31 downto 0);
        ALUOp  : in  std_logic_vector(3 downto 0);
        ALURes : out std_logic_vector(31 downto 0)
    );
end entity ALU;

architecture Behavioral of ALU is
begin
    process(A, B, ALUOp)
        variable shamt : natural range 0 to 31;
    begin
        shamt := to_integer(unsigned(B(4 downto 0)));
        case ALUOp is
            when "0000" => ALURes <= std_logic_vector(signed(A) + signed(B));
            when "1000" => ALURes <= std_logic_vector(signed(A) - signed(B));
            when "0001" => ALURes <= std_logic_vector(shift_left(unsigned(A), shamt));
            when "0010" =>
                if signed(A) < signed(B) then ALURes <= x"00000001"; else ALURes <= x"00000000"; end if;
            when "0011" =>
                if unsigned(A) < unsigned(B) then ALURes <= x"00000001"; else ALURes <= x"00000000"; end if;
            when "0100" => ALURes <= A xor B;
            when "0101" => ALURes <= std_logic_vector(shift_right(unsigned(A), shamt));
            when "1101" => ALURes <= std_logic_vector(shift_right(signed(A), shamt));
            when "0110" => ALURes <= A or B;
            when "0111" => ALURes <= A and B;
            when others => ALURes <= (others => '0');
        end case;
    end process;
end architecture Behavioral;
