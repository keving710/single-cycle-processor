-- ============================================================================
-- Archivo: IM/IM_tb.vhd
-- Descripcion: Testbench unitario para la Memoria de Instrucciones (IM)
-- ============================================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity IM_tb is
end entity IM_tb;

architecture Behavioral of IM_tb is
    signal Address     : std_logic_vector(31 downto 0) := (others => '0');
    signal Instruction : std_logic_vector(31 downto 0);
begin
    UUT : entity work.IM
        port map (
            Address     => Address,
            Instruction => Instruction
        );

    stim : process
    begin
        Address <= x"00000000";
        wait for 10 ns;
        assert Instruction = x"000010B7" report "ERROR IM: Addr 0x00 fallo" severity error;

        Address <= x"00000004";
        wait for 10 ns;
        assert Instruction = x"00F00113" report "ERROR IM: Addr 0x04 fallo" severity error;

        report "=== IM_tb completado exitosamente ===" severity note;
        wait;
    end process;
end architecture Behavioral;
