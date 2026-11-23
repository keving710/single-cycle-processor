-- ============================================================================
-- Archivo: PC/PC_tb.vhd
-- Descripcion: Testbench unitario para el Contador de Programa (PC)
-- ============================================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PC_tb is
end entity PC_tb;

architecture Behavioral of PC_tb is
    signal clk      : std_logic := '0';
    signal reset    : std_logic := '1';
    signal PC_in    : std_logic_vector(31 downto 0) := (others => '0');
    signal PC_out   : std_logic_vector(31 downto 0);
    signal sim_done : boolean := false;
begin
    UUT : entity work.PC
        port map (
            clk    => clk,
            reset  => reset,
            PC_in  => PC_in,
            PC_out => PC_out
        );

    clk_gen : process
    begin
        while not sim_done loop
            clk <= '0';
            wait for 10 ns;
            clk <= '1';
            wait for 10 ns;
        end loop;
        wait;
    end process;

    stim : process
    begin
        reset <= '1';
        PC_in <= x"00000010";
        wait until rising_edge(clk);
        wait for 2 ns;
        assert PC_out = x"00000000" report "ERROR PC: reset fallo" severity error;

        reset <= '0';
        PC_in <= x"00000004";
        wait until rising_edge(clk);
        wait for 2 ns;
        assert PC_out = x"00000004" report "ERROR PC: carga 0x04 fallo" severity error;

        PC_in <= x"00000024";
        wait until rising_edge(clk);
        wait for 2 ns;
        assert PC_out = x"00000024" report "ERROR PC: salto 0x24 fallo" severity error;

        report "=== PC_tb completado exitosamente ===" severity note;
        sim_done <= true;
        wait;
    end process;
end architecture Behavioral;
