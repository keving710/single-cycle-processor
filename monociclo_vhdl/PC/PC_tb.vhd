-- PC_tb.vhd : testbench del PC (6 pruebas + reloj de 20 ns)
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity PC_tb is
end entity PC_tb;

architecture testbench of PC_tb is
    signal clk    : std_logic := '0';
    signal reset  : std_logic := '0';
    signal PC_in  : std_logic_vector(31 downto 0) := (others => '0');
    signal PC_out : std_logic_vector(31 downto 0);
    constant T    : time := 20 ns;
    signal fin    : boolean := false;
begin
    UUT : entity work.PC
        port map (clk => clk, reset => reset, PC_in => PC_in, PC_out => PC_out);

    -- Generador de reloj: se detiene cuando fin = true
    reloj : process
    begin
        while not fin loop
            clk <= '0'; wait for T/2;
            clk <= '1'; wait for T/2;
        end loop;
        wait;
    end process reloj;

    estimulos : process
    begin
        -- Prueba 1: reset inicial
        reset <= '1'; PC_in <= x"00000010";
        wait for T;
        assert PC_out = x"00000000" report "ERROR P1: reset no pone PC en 0" severity error;

        -- Prueba 2: carga secuencial 4, 8
        reset <= '0';
        PC_in <= x"00000004"; wait for T;
        assert PC_out = x"00000004" report "ERROR P2a: PC deberia ser 4" severity error;
        PC_in <= x"00000008"; wait for T;
        assert PC_out = x"00000008" report "ERROR P2b: PC deberia ser 8" severity error;

        -- Prueba 3: salto adelante
        PC_in <= x"00000100"; wait for T;
        assert PC_out = x"00000100" report "ERROR P3: salto adelante" severity error;

        -- Prueba 4: salto hacia atras
        PC_in <= x"00000008"; wait for T;
        assert PC_out = x"00000008" report "ERROR P4: salto atras" severity error;

        -- Prueba 5: reset durante la operacion (tiene prioridad sobre PC_in)
        reset <= '1'; PC_in <= x"00000200"; wait for T;
        assert PC_out = x"00000000" report "ERROR P5: reset en operacion" severity error;

        -- Prueba 6: recuperacion tras el reset
        reset <= '0'; PC_in <= x"00000004"; wait for T;
        assert PC_out = x"00000004" report "ERROR P6: recuperacion tras reset" severity error;

        -- Extra: PC_in no se refleja sin flanco de reloj
        wait for T/4;
        PC_in <= x"000000AA"; wait for 1 ns;
        assert PC_out = x"00000004" report "ERROR extra: PC cambio sin flanco" severity error;

        report "=== PC: pruebas terminadas ===" severity note;
        fin <= true;
        wait;
    end process estimulos;
end architecture testbench;
