-- RU_tb.vhd : testbench del banco de registros (reloj de 20 ns)
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity RU_tb is
end entity RU_tb;

architecture testbench of RU_tb is
    signal clk    : std_logic := '0';
    signal ruWr   : std_logic := '0';
    signal rs1, rs2, rd : std_logic_vector(4 downto 0) := (others => '0');
    signal DataWr, ruRs1, ruRs2 : std_logic_vector(31 downto 0) := (others => '0');
    constant T : time := 20 ns;
    signal fin : boolean := false;
begin
    UUT : entity work.RU
        port map (clk => clk, ruWr => ruWr, rs1 => rs1, rs2 => rs2, rd => rd,
                  DataWr => DataWr, ruRs1 => ruRs1, ruRs2 => ruRs2);

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
        wait for T;
        -- 1: x0 es cero por ambos puertos
        rs1 <= "00000"; rs2 <= "00000"; wait for 1 ns;
        assert ruRs1 = x"00000000" and ruRs2 = x"00000000" report "ERROR P1: x0" severity error;
        -- 2: valor inicial de x2
        rs1 <= "00010"; wait for 1 ns;
        assert ruRs1 = x"FFFFFFFF" report "ERROR P2: x2 inicial" severity error;
        -- 3: escribir x5 y leerlo por los dos puertos
        ruWr <= '1'; rd <= "00101"; DataWr <= x"12345678"; wait for T;
        ruWr <= '0'; rs1 <= "00101"; rs2 <= "00101"; wait for 1 ns;
        assert ruRs1 = x"12345678" and ruRs2 = x"12345678" report "ERROR P3: x5" severity error;
        -- 4: escritura a x0 ignorada
        ruWr <= '1'; rd <= "00000"; DataWr <= x"DEADBEEF"; wait for T;
        ruWr <= '0'; rs1 <= "00000"; wait for 1 ns;
        assert ruRs1 = x"00000000" report "ERROR P4: x0 modificado" severity error;
        -- 5: lecturas simultaneas de dos registros distintos
        ruWr <= '1'; rd <= "01010"; DataWr <= x"AABBCCDD"; wait for T;
        ruWr <= '0'; rs1 <= "00101"; rs2 <= "01010"; wait for 1 ns;
        assert ruRs1 = x"12345678" and ruRs2 = x"AABBCCDD" report "ERROR P5: lecturas dobles" severity error;
        -- 6: x2 no cambio
        rs1 <= "00010"; wait for 1 ns;
        assert ruRs1 = x"FFFFFFFF" report "ERROR P6: x2 cambio" severity error;
        -- 7: sobreescribir x5
        ruWr <= '1'; rd <= "00101"; DataWr <= x"CAFEBABE"; wait for T;
        ruWr <= '0'; rs1 <= "00101"; wait for 1 ns;
        assert ruRs1 = x"CAFEBABE" report "ERROR P7: sobreescritura" severity error;
        -- 8 (extra): ruWr=0 no escribe
        ruWr <= '0'; rd <= "00101"; DataWr <= x"11111111"; wait for T;
        assert ruRs1 = x"CAFEBABE" report "ERROR P8: escribio con ruWr=0" severity error;
        -- 9 (extra): ultimo registro x31
        ruWr <= '1'; rd <= "11111"; DataWr <= x"0000001F"; wait for T;
        ruWr <= '0'; rs2 <= "11111"; wait for 1 ns;
        assert ruRs2 = x"0000001F" report "ERROR P9: x31" severity error;

        report "=== RU: pruebas terminadas ===" severity note;
        fin <= true;
        wait;
    end process estimulos;
end architecture testbench;
