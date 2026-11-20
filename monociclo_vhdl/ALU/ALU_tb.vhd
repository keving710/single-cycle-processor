-- =====================================================================
-- ALU_tb.vhd : testbench de la ALU (10 operaciones + casos borde)
-- No usa tb_helpers. Ejecutar: ghdl -a --std=08 ALU.vhd ALU_tb.vhd
-- =====================================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALU_tb is
end entity ALU_tb;

architecture testbench of ALU_tb is
    signal A     : std_logic_vector(31 downto 0) := (others => '0');
    signal B     : std_logic_vector(31 downto 0) := (others => '0');
    signal ALUop : std_logic_vector(3 downto 0)  := (others => '0');
    signal ALUS  : std_logic_vector(31 downto 0);
    signal errores : natural := 0;
begin
    UUT : entity work.ALU
        port map (A => A, B => B, ALUop => ALUop, ALUS => ALUS);

    estimulos : process
        variable n_err : natural := 0;

        -- Aplica entradas, espera y compara con lo esperado
        procedure probar (
            nombre : in string;
            op     : in std_logic_vector(3 downto 0);
            va, vb : in std_logic_vector(31 downto 0);
            esp    : in std_logic_vector(31 downto 0)) is
        begin
            ALUop <= op; A <= va; B <= vb;
            wait for 10 ns;
            if ALUS /= esp then
                report "ERROR " & nombre severity error;
                n_err := n_err + 1;
            else
                report "OK " & nombre severity note;
            end if;
        end procedure;
    begin
        -- Operaciones de la clase 6
        probar("1 ADD 10+20",  "0000", x"0000000A", x"00000014", x"0000001E");
        probar("2 SUB 50-15",  "1000", x"00000032", x"0000000F", x"00000023");
        probar("3 AND",        "0111", x"FF00FF00", x"0F0F0F0F", x"0F000F00");
        probar("4 OR",         "0110", x"FF00FF00", x"0F0F0F0F", x"FF0FFF0F");
        probar("5 XOR",        "0100", x"FF00FF00", x"0F0F0F0F", x"F00FF00F");
        -- Operaciones de la clase 7
        probar("6 SLL 1<<4",   "0001", x"00000001", x"00000004", x"00000010");
        probar("7 SRL 256>>3", "0101", x"00000100", x"00000003", x"00000020");
        probar("8 SRA -128>>>2","1101", x"FFFFFF80", x"00000002", x"FFFFFFE0");
        probar("9 SLT -5<3",   "0010", x"FFFFFFFB", x"00000003", x"00000001");
        probar("10 SLTU 5<10", "0011", x"00000005", x"0000000A", x"00000001");
        -- Contraejemplos
        probar("11 SLT 3<-5 falso",  "0010", x"00000003", x"FFFFFFFB", x"00000000");
        probar("12 SLTU 10<5 falso", "0011", x"0000000A", x"00000005", x"00000000");
        -- Mismo patron de bits, SLT y SLTU opuestos
        probar("13 SLT  0xFFFFFFFF<1", "0010", x"FFFFFFFF", x"00000001", x"00000001");
        probar("14 SLTU 0xFFFFFFFF<1", "0011", x"FFFFFFFF", x"00000001", x"00000000");
        -- Bordes
        probar("15 SRL negativo",  "0101", x"80000000", x"00000001", x"40000000");
        probar("16 SRA negativo",  "1101", x"80000000", x"00000001", x"C0000000");
        probar("17 SLL por 31",    "0001", x"00000001", x"0000001F", x"80000000");
        probar("18 SLL shamt=0",   "0001", x"12345678", x"00000000", x"12345678");
        probar("19 shamt usa solo B[4:0]", "0001", x"00000001", x"00000024", x"00000010");
        probar("20 ADD overflow",  "0000", x"FFFFFFFF", x"00000001", x"00000000");
        probar("21 SUB negativo",  "1000", x"00000000", x"00000001", x"FFFFFFFF");
        probar("22 ALUop invalido","1111", x"FFFFFFFF", x"FFFFFFFF", x"00000000");

        if n_err = 0 then
            report "=== ALU: todas las pruebas pasaron ===" severity note;
        else
            report "=== ALU: hubo errores ===" severity failure;
        end if;
        wait;
    end process estimulos;
end architecture testbench;
