-- ============================================================================
-- Archivo: BU/BU_tb.vhd
-- Descripcion: Testbench completo de la Unidad de Salto (BU)
-- ============================================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity BU_tb is
end entity BU_tb;

architecture Behavioral of BU_tb is
    signal A         : std_logic_vector(31 downto 0) := (others => '0');
    signal B         : std_logic_vector(31 downto 0) := (others => '0');
    signal BrOp      : std_logic_vector(4 downto 0) := (others => '0');
    signal NextPCSrc : std_logic;
begin
    UUT : entity work.BU
        port map (A => A, B => B, BrOp => BrOp, NextPCSrc => NextPCSrc);

    stim : process
    begin
        A <= x"FFFFFFFF"; B <= x"00000001";
        BrOp <= "01100"; -- BLT (-1 < 1 => 1)
        wait for 10 ns;
        assert NextPCSrc = '1' report "ERROR BU: BLT fallo" severity error;

        BrOp <= "01110"; -- BLTU (4G < 1 => 0)
        wait for 10 ns;
        assert NextPCSrc = '0' report "ERROR BU: BLTU fallo" severity error;

        report "=== BU_tb completado exitosamente ===" severity note;
        wait;
    end process;
end architecture Behavioral;
