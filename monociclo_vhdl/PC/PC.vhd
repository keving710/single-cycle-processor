-- ============================================================================
-- Archivo: PC/PC.vhd
-- Descripcion: Contador de Programa (Program Counter) de 32 bits con reset
--              sincrono activo en alto.
-- ============================================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PC is
    port (
        clk    : in  std_logic;
        reset  : in  std_logic;
        PC_in  : in  std_logic_vector(31 downto 0);
        PC_out : out std_logic_vector(31 downto 0)
    );
end entity PC;

architecture Behavioral of PC is
    signal pc_reg : std_logic_vector(31 downto 0) := (others => '0');
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                pc_reg <= (others => '0');
            else
                pc_reg <= PC_in;
            end if;
        end if;
    end process;

    PC_out <= pc_reg;
end architecture Behavioral;
