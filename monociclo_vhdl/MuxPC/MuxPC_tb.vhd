-- ============================================================================
-- Archivo: MuxPC/MuxPC_tb.vhd
-- Descripcion: Testbench unitario para MuxPC
-- ============================================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MuxPC_tb is
end entity MuxPC_tb;

architecture Behavioral of MuxPC_tb is
    signal PC_4      : std_logic_vector(31 downto 0) := (others => '0');
    signal AluJump   : std_logic_vector(31 downto 0) := (others => '0');
    signal NextPCSrc : std_logic := '0';
    signal NextPC    : std_logic_vector(31 downto 0);
begin
    UUT : entity work.MuxPC
        port map (
            PC_4      => PC_4,
            AluJump   => AluJump,
            NextPCSrc => NextPCSrc,
            NextPC    => NextPC
        );

    stim : process
    begin
        PC_4 <= x"00000000"; AluJump <= x"00000100"; NextPCSrc <= '0';
        wait for 10 ns;
        assert NextPC = x"00000004" report "ERROR MuxPC: secuencial fallo" severity error;

        NextPCSrc <= '1';
        wait for 10 ns;
        assert NextPC = x"00000100" report "ERROR MuxPC: salto fallo" severity error;

        report "=== MuxPC_tb completado exitosamente ===" severity note;
        wait;
    end process;
end architecture Behavioral;
