-- ============================================================================
-- Archivo: monociclo_tb.vhd
-- Descripcion: Testbench completo del procesador RISC-V RV32I Monociclo.
--              Listo para GHDL (Windows/Linux) y EDA Playground (EPWave).
-- ============================================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;
library work;
use work.tb_helpers.all;

entity monociclo_tb is
end entity monociclo_tb;

architecture Behavioral of monociclo_tb is
    signal clk       : std_logic := '0';
    signal reset     : std_logic := '1';
    signal dbg_pc    : std_logic_vector(31 downto 0);
    signal dbg_instr : std_logic_vector(31 downto 0);
    signal sim_done  : boolean := false;

    constant CLK_PERIOD : time := 20 ns;
begin
    UUT : entity work.monociclo
        port map (
            clk       => clk,
            reset     => reset,
            dbg_pc    => dbg_pc,
            dbg_instr => dbg_instr
        );

    clk_process : process
    begin
        while not sim_done loop
            clk <= '0';
            wait for CLK_PERIOD / 2;
            clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
        wait;
    end process;

    stim_proc : process
    begin
        reset <= '1';
        wait for CLK_PERIOD * 2;
        reset <= '0';

        for ciclo in 1 to 14 loop
            wait until rising_edge(clk);
            wait for 1 ns;
            report "Ciclo " & integer'image(ciclo) &
                   " | PC = 0x" & word32_to_hex(dbg_pc) &
                   " | Instr = 0x" & word32_to_hex(dbg_instr)
                severity note;
        end loop;

        assert dbg_pc = x"00000030"
            report "ERROR: PC final esperado 0x00000030, obtenido 0x" & word32_to_hex(dbg_pc)
            severity error;

        report "=== SIMULACION COMPLETA EXITOSA: Monociclo RV32I verificado ==="
            severity note;
        sim_done <= true;
        wait;
    end process;
end architecture Behavioral;
