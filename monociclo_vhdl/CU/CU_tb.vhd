-- ============================================================================
-- Archivo: CU/CU_tb.vhd
-- Descripcion: Testbench unitario para la Unidad de Control (CU)
-- ============================================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity CU_tb is
end entity CU_tb;

architecture Behavioral of CU_tb is
    signal Opcode      : std_logic_vector(6 downto 0) := (others => '0');
    signal Funct3      : std_logic_vector(2 downto 0) := (others => '0');
    signal Funct7      : std_logic_vector(6 downto 0) := (others => '0');
    signal RUWr        : std_logic;
    signal ImmSrc      : std_logic_vector(2 downto 0);
    signal ALUSrcA     : std_logic_vector(1 downto 0);
    signal ALUSrcB     : std_logic;
    signal ALUOp       : std_logic_vector(3 downto 0);
    signal BrOp        : std_logic_vector(4 downto 0);
    signal DMWr        : std_logic;
    signal DMCtrl      : std_logic_vector(2 downto 0);
    signal RUDataWrSrc : std_logic_vector(1 downto 0);
begin
    UUT : entity work.CU
        port map (
            Opcode => Opcode, Funct3 => Funct3, Funct7 => Funct7,
            RUWr => RUWr, ImmSrc => ImmSrc, ALUSrcA => ALUSrcA,
            ALUSrcB => ALUSrcB, ALUOp => ALUOp, BrOp => BrOp,
            DMWr => DMWr, DMCtrl => DMCtrl, RUDataWrSrc => RUDataWrSrc
        );

    stim : process
    begin
        Opcode <= "0110011"; Funct3 <= "000"; Funct7 <= "0100000"; -- SUB
        wait for 10 ns;
        assert ALUOp = "1000" and RUWr = '1' report "ERROR CU: SUB fallo" severity error;

        Opcode <= "1101111"; -- JAL
        wait for 10 ns;
        assert BrOp = "11111" and RUDataWrSrc = "10" report "ERROR CU: JAL fallo" severity error;

        report "=== CU_tb completado exitosamente ===" severity note;
        wait;
    end process;
end architecture Behavioral;
