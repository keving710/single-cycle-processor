-- =====================================================================
-- MuxPC.vhd : selecciona el siguiente PC (combinacional)
--   NextPCSrc = '0' -> NextPC = PC_4 + 4   (secuencial)
--   NextPCSrc = '1' -> NextPC = AluJump    (salto)
-- Nota: PC_4 recibe el PC ACTUAL; la suma de 4 se hace aqui dentro.
-- =====================================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MuxPC is
    port (
        PC_4      : in  std_logic_vector(31 downto 0);
        AluJump   : in  std_logic_vector(31 downto 0);
        NextPCSrc : in  std_logic;
        NextPC    : out std_logic_vector(31 downto 0)
    );
end entity MuxPC;

architecture Behavioral of MuxPC is
begin
    seleccion : process (PC_4, AluJump, NextPCSrc)
    begin
        if NextPCSrc = '1' then
            NextPC <= AluJump;
        else
            NextPC <= std_logic_vector(unsigned(PC_4) + 4);
        end if;
    end process seleccion;
end architecture Behavioral;
