-- ============================================================================
-- Archivo: DM/DM_tb.vhd
-- Descripcion: Testbench unitario para Memoria de Datos (DM)
-- ============================================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity DM_tb is
end entity DM_tb;

architecture Behavioral of DM_tb is
    signal clk      : std_logic := '0';
    signal Address  : std_logic_vector(31 downto 0) := (others => '0');
    signal DataWr   : std_logic_vector(31 downto 0) := (others => '0');
    signal DMWr     : std_logic := '0';
    signal DMCtrl   : std_logic_vector(2 downto 0) := "010";
    signal DataRd   : std_logic_vector(31 downto 0);
    signal sim_done : boolean := false;
begin
    UUT : entity work.DM
        port map (clk => clk, Address => Address, DataWr => DataWr, DMWr => DMWr, DMCtrl => DMCtrl, DataRd => DataRd);

    clk_gen : process
    begin
        while not sim_done loop
            clk <= '0'; wait for 10 ns; clk <= '1'; wait for 10 ns;
        end loop;
        wait;
    end process;

    stim : process
    begin
        Address <= x"00000004"; DataWr <= x"12345680"; DMWr <= '1'; DMCtrl <= "010";
        wait until rising_edge(clk);
        wait for 2 ns;
        DMWr <= '0';
        assert DataRd = x"12345680" report "ERROR DM: LW fallo" severity error;

        DMCtrl <= "000"; -- LB (0x80 con signo => 0xFFFFFF80)
        wait for 5 ns;
        assert DataRd = x"FFFFFF80" report "ERROR DM: LB signo fallo" severity error;

        report "=== DM_tb completado exitosamente ===" severity note;
        sim_done <= true;
        wait;
    end process;
end architecture Behavioral;
