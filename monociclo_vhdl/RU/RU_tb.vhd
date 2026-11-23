-- ============================================================================
-- Archivo: RU/RU_tb.vhd
-- Descripcion: Testbench unitario para el Banco de Registros (RU)
-- ============================================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RU_tb is
end entity RU_tb;

architecture Behavioral of RU_tb is
    signal clk      : std_logic := '0';
    signal rs1      : std_logic_vector(4 downto 0) := (others => '0');
    signal rs2      : std_logic_vector(4 downto 0) := (others => '0');
    signal rd       : std_logic_vector(4 downto 0) := (others => '0');
    signal DataWr   : std_logic_vector(31 downto 0) := (others => '0');
    signal RUWr     : std_logic := '0';
    signal RU1      : std_logic_vector(31 downto 0);
    signal RU2      : std_logic_vector(31 downto 0);
    signal sim_done : boolean := false;
begin
    UUT : entity work.RU
        port map (
            clk    => clk,
            rs1    => rs1,
            rs2    => rs2,
            rd     => rd,
            DataWr => DataWr,
            RUWr   => RUWr,
            RU1    => RU1,
            RU2    => RU2
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
        -- Intentar escribir en x0 (debe ignorarse)
        rd <= "00000"; DataWr <= x"DEADBEEF"; RUWr <= '1';
        wait until rising_edge(clk);
        wait for 2 ns;
        rs1 <= "00000";
        wait for 2 ns;
        assert RU1 = x"00000000" report "ERROR RU: x0 fue modificado" severity error;

        -- Escribir 42 en x5
        rd <= "00101"; DataWr <= x"0000002A"; RUWr <= '1';
        wait until rising_edge(clk);
        wait for 2 ns;
        rs2 <= "00101";
        wait for 2 ns;
        assert RU2 = x"0000002A" report "ERROR RU: lectura de x5 fallo" severity error;

        report "=== RU_tb completado exitosamente ===" severity note;
        sim_done <= true;
        wait;
    end process;
end architecture Behavioral;
