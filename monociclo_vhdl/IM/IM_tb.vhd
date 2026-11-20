-- IM_tb.vhd : testbench de la IM. Requiere IM/instructions.txt con:
--   0x00500093, 0x00A00113, 0x002081B3 (addi x1,x0,5 / addi x2,x0,10 / add x3,x1,x2)
-- Ejecutar desde la carpeta monociclo_vhdl/.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity IM_tb is
end entity IM_tb;

architecture testbench of IM_tb is
    signal address     : std_logic_vector(31 downto 0) := (others => '0');
    signal instruction : std_logic_vector(31 downto 0);
begin
    UUT : entity work.IM port map (address => address, instruction => instruction);

    estimulos : process
    begin
        address <= x"00000000"; wait for 10 ns;
        assert instruction = x"00500093" report "ERROR P1: instruccion 0" severity error;
        address <= x"00000004"; wait for 10 ns;
        assert instruction = x"00A00113" report "ERROR P2: instruccion 1" severity error;
        address <= x"00000008"; wait for 10 ns;
        assert instruction = x"002081B3" report "ERROR P3: instruccion 2" severity error;
        -- mas alla del programa: ceros
        address <= x"0000000C"; wait for 10 ns;
        assert instruction = x"00000000" report "ERROR P4: fuera del programa" severity error;
        -- ultima palabra de la ROM
        address <= x"0000007C"; wait for 10 ns;
        assert instruction = x"00000000" report "ERROR P5: ultima palabra" severity error;
        -- vuelve a la primera (lectura combinacional, sin reloj)
        address <= x"00000000"; wait for 10 ns;
        assert instruction = x"00500093" report "ERROR P6: relectura" severity error;
        -- direccion no alineada: se alinea a palabra
        address <= x"00000005"; wait for 10 ns;
        assert instruction = x"00A00113" report "ERROR P7: alineacion" severity error;

        report "=== IM: pruebas terminadas ===" severity note;
        wait;
    end process estimulos;
end architecture testbench;
