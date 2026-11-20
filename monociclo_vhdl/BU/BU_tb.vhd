-- BU_tb.vhd : testbench de la BU (sin tb_helpers). 9 casos minimos +
-- contraejemplos de cada comparacion y el caso signed/unsigned opuesto.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity BU_tb is
end entity BU_tb;

architecture testbench of BU_tb is
    signal A         : std_logic_vector(31 downto 0) := (others => '0');
    signal B         : std_logic_vector(31 downto 0) := (others => '0');
    signal BrOp      : std_logic_vector(4 downto 0)  := (others => '0');
    signal NextPCSrc : std_logic;

    function v (n : integer) return std_logic_vector is
    begin
        return std_logic_vector(to_signed(n, 32));
    end function;
begin
    UUT : entity work.BU
        port map (A => A, B => B, BrOp => BrOp, NextPCSrc => NextPCSrc);

    estimulos : process
        procedure probar (
            nombre : in string;
            op     : in std_logic_vector(4 downto 0);
            va, vb : in std_logic_vector(31 downto 0);
            esp    : in std_logic) is
        begin
            BrOp <= op; A <= va; B <= vb;
            wait for 10 ns;
            assert NextPCSrc = esp report "ERROR " & nombre severity error;
        end procedure;
    begin
        -- Minimos
        probar("1 secuencial",         "00000", v(10),  v(10),  '0');
        probar("2 JAL",                "11111", v(0),   v(0),   '1');
        probar("3 BEQ verdadero",      "01000", v(42),  v(42),  '1');
        probar("4 BNE verdadero",      "01001", v(10),  v(20),  '1');
        probar("5 BLT -10<5",          "01100", v(-10), v(5),   '1');
        probar("6 BGE 5>=-10",         "01101", v(5),   v(-10), '1');
        probar("7 BLTU 5<100",         "01110", v(5),   v(100), '1');
        probar("8 BGEU 100>=5",        "01111", v(100), v(5),   '1');
        probar("9 BrOp invalido",      "10101", v(0),   v(0),   '0');
        -- Contraejemplos
        probar("10 BEQ falso",         "01000", v(42),  v(43),  '0');
        probar("11 BNE falso",         "01001", v(10),  v(10),  '0');
        probar("12 BLT falso",         "01100", v(5),   v(-10), '0');
        probar("13 BGE igualdad",      "01101", v(7),   v(7),   '1');
        probar("14 BLTU falso",        "01110", v(100), v(5),   '0');
        probar("15 BGEU igualdad",     "01111", v(50),  v(50),  '1');
        probar("16a BLT  FFFFFFFF<1",  "01100", x"FFFFFFFF", x"00000001", '1');
        probar("16b BLTU FFFFFFFF<1",  "01110", x"FFFFFFFF", x"00000001", '0');
        -- Extras
        probar("17 BGE falso",         "01101", v(-10), v(5),   '0');
        probar("18 BGEU 1>=FFFFFFFF",  "01111", x"00000001", x"FFFFFFFF", '0');
        probar("19 BLT igualdad",      "01100", v(3),   v(3),   '0');
        probar("20 BLTU igualdad",     "01110", v(3),   v(3),   '0');
        probar("21 secuencial ignora A/B distintos", "00000", v(1), v(2), '0');
        probar("22 JAL ignora A/B distintos",        "11111", v(1), v(2), '1');
        probar("23 BrOp 10000 (no existe)", "10000", v(1), v(1), '0');

        report "=== BU: pruebas terminadas ===" severity note;
        wait;
    end process estimulos;
end architecture testbench;
