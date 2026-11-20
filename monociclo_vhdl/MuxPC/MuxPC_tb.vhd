-- MuxPC_tb.vhd : testbench del MuxPC (6 escenarios, combinacional)
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MuxPC_tb is
end entity MuxPC_tb;

architecture testbench of MuxPC_tb is
    signal PC_4      : std_logic_vector(31 downto 0) := (others => '0');
    signal AluJump   : std_logic_vector(31 downto 0) := (others => '0');
    signal NextPCSrc : std_logic := '0';
    signal NextPC    : std_logic_vector(31 downto 0);
    constant W : time := 10 ns;
begin
    UUT : entity work.MuxPC
        port map (PC_4 => PC_4, AluJump => AluJump,
                  NextPCSrc => NextPCSrc, NextPC => NextPC);

    estimulos : process
    begin
        -- 1: secuencial desde 0
        PC_4 <= x"00000000"; AluJump <= x"00000100"; NextPCSrc <= '0'; wait for W;
        assert NextPC = x"00000004" report "ERROR P1" severity error;
        -- 2: secuencial desde 8
        PC_4 <= x"00000008"; AluJump <= x"00002000"; wait for W;
        assert NextPC = x"0000000C" report "ERROR P2" severity error;
        -- 3: salto adelante
        PC_4 <= x"0000000C"; AluJump <= x"00000100"; NextPCSrc <= '1'; wait for W;
        assert NextPC = x"00000100" report "ERROR P3" severity error;
        -- 4: salto atras
        PC_4 <= x"00000100"; AluJump <= x"00000008"; wait for W;
        assert NextPC = x"00000008" report "ERROR P4" severity error;
        -- 5: cambio de selector con los mismos datos
        PC_4 <= x"00000020"; AluJump <= x"00000200"; NextPCSrc <= '1'; wait for W;
        assert NextPC = x"00000200" report "ERROR P5a" severity error;
        NextPCSrc <= '0'; wait for W;
        assert NextPC = x"00000024" report "ERROR P5b" severity error;
        -- 6: cambio del destino de salto
        PC_4 <= x"00000030"; AluJump <= x"00000300"; NextPCSrc <= '1'; wait for W;
        assert NextPC = x"00000300" report "ERROR P6a" severity error;
        AluJump <= x"00000400"; wait for W;
        assert NextPC = x"00000400" report "ERROR P6b" severity error;
        -- extra: PC cerca del limite de 32 bits (suma modular)
        PC_4 <= x"FFFFFFFC"; NextPCSrc <= '0'; wait for W;
        assert NextPC = x"00000000" report "ERROR extra: desbordamiento" severity error;

        report "=== MuxPC: pruebas terminadas ===" severity note;
        wait;
    end process estimulos;
end architecture testbench;
