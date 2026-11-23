-- ============================================================================
-- Archivo: IU/IU.vhd
-- Descripcion: Unidad de Inmediatos (extensor de signo para formatos I,S,B,U,J)
-- ============================================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity IU is
    port (
        Instruction : in  std_logic_vector(31 downto 0);
        ImmSrc      : in  std_logic_vector(2 downto 0);
        ImmExt      : out std_logic_vector(31 downto 0)
    );
end entity IU;

architecture Behavioral of IU is
begin
    process(Instruction, ImmSrc)
        variable sign_bit : std_logic;
    begin
        sign_bit := Instruction(31);
        case ImmSrc is
            when "000" => -- Formato I
                ImmExt <= (31 downto 12 => sign_bit) & Instruction(31 downto 20);
            when "001" => -- Formato S
                ImmExt <= (31 downto 12 => sign_bit) & Instruction(31 downto 25) & Instruction(11 downto 7);
            when "010" => -- Formato B
                ImmExt <= (31 downto 13 => sign_bit) & Instruction(31) & Instruction(7) &
                          Instruction(30 downto 25) & Instruction(11 downto 8) & '0';
            when "011" => -- Formato U
                ImmExt <= Instruction(31 downto 12) & x"000";
            when "100" => -- Formato J
                ImmExt <= (31 downto 21 => sign_bit) & Instruction(31) & Instruction(19 downto 12) &
                          Instruction(20) & Instruction(30 downto 21) & '0';
            when others =>
                ImmExt <= (others => '0');
        end case;
    end process;
end architecture Behavioral;
