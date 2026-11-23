-- ============================================================================
-- Archivo: MuxPC/MuxPC.vhd
-- Descripcion: Multiplexor del Contador de Programa. Selecciona PC_4 + 4
--              cuando NextPCSrc = '0' o AluJump cuando NextPCSrc = '1'.
-- ============================================================================
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
    process(PC_4, AluJump, NextPCSrc)
    begin
        if NextPCSrc = '1' then
            NextPC <= AluJump;
        else
            NextPC <= std_logic_vector(unsigned(PC_4) + 4);
        end if;
    end process;
end architecture Behavioral;
