-- ============================================================================
-- Archivo: IU/IU_tb.vhd
-- Descripcion: Testbench unitario para la Unidad de Inmediatos (IU)
-- ============================================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity IU_tb is
end entity IU_tb;

architecture Behavioral of IU_tb is
    signal Instruction : std_logic_vector(31 downto 0) := (others => '0');
    signal ImmSrc      : std_logic_vector(2 downto 0) := "000";
    signal ImmExt      : std_logic_vector(31 downto 0);
begin
    UUT : entity work.IU
        port map (
            Instruction => Instruction,
            ImmSrc      => ImmSrc,
            ImmExt      => ImmExt
        );

    stim : process
    begin
        -- Tipo I: addi x1, x0, -5 (0xFFB00093)
        Instruction <= x"FFB00093"; ImmSrc <= "000";
        wait for 10 ns;
        assert ImmExt = x"FFFFFFFB" report "ERROR IU: Tipo I negativo fallo" severity error;

        -- Tipo U: lui x1, 0x12345 (0x123450B7)
        Instruction <= x"123450B7"; ImmSrc <= "011";
        wait for 10 ns;
        assert ImmExt = x"12345000" report "ERROR IU: Tipo U fallo" severity error;

        report "=== IU_tb completado exitosamente ===" severity note;
        wait;
    end process;
end architecture Behavioral;
