-- IU_tb.vhd : testbench de la IU. Usa palabras de instruccion reales
-- y pasa inst[31:7] a la IU.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity IU_tb is
end entity IU_tb;

architecture testbench of IU_tb is
    signal imm : std_logic_vector(24 downto 0) := (others => '0');
    signal src : std_logic_vector(2 downto 0)  := (others => '0');
    signal ext : std_logic_vector(31 downto 0);
begin
    UUT : entity work.IU port map (imm => imm, src => src, ext => ext);

    estimulos : process
        procedure probar (
            nombre : in string;
            inst   : in std_logic_vector(31 downto 0);
            s      : in std_logic_vector(2 downto 0);
            esp    : in std_logic_vector(31 downto 0)) is
        begin
            imm <= inst(31 downto 7); src <= s;
            wait for 10 ns;
            assert ext = esp report "ERROR " & nombre severity error;
        end procedure;
    begin
        probar("1 ADDI x1,x0,5",        x"00500093", "000", x"00000005");
        probar("2 ADDI x1,x0,-1",       x"FFF00093", "000", x"FFFFFFFF");
        probar("3 SLLI x5,x10,3",       x"00351293", "000", x"00000003");
        probar("4 SRAI x5,x10,5",       x"40555293", "000", x"00000005");
        probar("5 SW x5,16(x0)",        x"00502823", "001", x"00000010");
        probar("6 SW x5,-4(x0)",        x"FE502E23", "001", x"FFFFFFFC");
        probar("7 BEQ x0,x0,+8",        x"00000463", "101", x"00000008");
        probar("8 BEQ x0,x0,-8",        x"FE000CE3", "101", x"FFFFFFF8");
        probar("9 LUI x1,0xABCDE",      x"ABCDE0B7", "010", x"ABCDE000");
        probar("10 JAL x0,0",           x"0000006F", "110", x"00000000");
        probar("11 JAL x1,+2048",       x"001000EF", "110", x"00000800");
        probar("12 JAL x1,-4",          x"FFDFF0EF", "110", x"FFFFFFFC");
        probar("13 src invalido 011",   x"FFFFFFFF", "011", x"00000000");
        probar("14 SRLI shamt=31",      x"01F55293", "000", x"0000001F");

        report "=== IU: pruebas terminadas ===" severity note;
        wait;
    end process estimulos;
end architecture testbench;
