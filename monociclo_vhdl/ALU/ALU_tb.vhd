-- ============================================================================
-- Archivo: ALU/ALU_tb.vhd
-- Descripcion: Testbench unitario para la ALU
-- ============================================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALU_tb is
end entity ALU_tb;

architecture Behavioral of ALU_tb is
    signal A      : std_logic_vector(31 downto 0) := (others => '0');
    signal B      : std_logic_vector(31 downto 0) := (others => '0');
    signal ALUOp  : std_logic_vector(3 downto 0) := "0000";
    signal ALURes : std_logic_vector(31 downto 0);
begin
    UUT : entity work.ALU
        port map (A => A, B => B, ALUOp => ALUOp, ALURes => ALURes);

    stim : process
    begin
        A <= x"0000000F"; B <= x"0000000A"; ALUOp <= "0000"; -- ADD
        wait for 10 ns;
        assert ALURes = x"00000019" report "ERROR ALU: ADD fallo" severity error;

        ALUOp <= "1000"; -- SUB
        wait for 10 ns;
        assert ALURes = x"00000005" report "ERROR ALU: SUB fallo" severity error;

        report "=== ALU_tb completado exitosamente ===" severity note;
        wait;
    end process;
end architecture Behavioral;
