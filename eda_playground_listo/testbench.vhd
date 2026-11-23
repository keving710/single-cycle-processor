-- ============================================================================
-- Archivo: tb_helpers_pkg.vhd
-- Descripcion: Funciones auxiliares de formateo hexadecimal para testbenches
-- Proyecto: Procesador RISC-V RV32I Monociclo
-- ============================================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package tb_helpers is
    function word32_to_hex(w : std_logic_vector(31 downto 0)) return string;
end package tb_helpers;

package body tb_helpers is
    function word32_to_hex(w : std_logic_vector(31 downto 0)) return string is
        constant HEX_CHARS : string(1 to 16) := "0123456789ABCDEF";
        variable res       : string(1 to 8);
        variable nibble    : std_logic_vector(3 downto 0);
        variable idx       : integer;
    begin
        for i in 0 to 7 loop
            nibble := w(31 - i*4 downto 28 - i*4);
            if is_x(nibble) then
                res(i + 1) := 'X';
            else
                idx := to_integer(unsigned(nibble));
                res(i + 1) := HEX_CHARS(idx + 1);
            end if;
        end loop;
        return res;
    end function word32_to_hex;
end package body tb_helpers;


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
