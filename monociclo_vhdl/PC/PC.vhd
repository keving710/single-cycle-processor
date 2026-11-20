-- =====================================================================
-- PC.vhd : Contador de Programa (registro de 32 bits, reset sincrono)
-- Guarda la direccion de la instruccion actual. Solo cambia en el
-- flanco de subida del reloj; si reset='1' vuelve a 0.
-- =====================================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity PC is
    port (
        clk    : in  std_logic;
        reset  : in  std_logic;                        -- reset sincrono
        PC_in  : in  std_logic_vector(31 downto 0);    -- siguiente PC (desde MuxPC)
        PC_out : out std_logic_vector(31 downto 0)     -- PC actual
    );
end entity PC;

architecture Behavioral of PC is
    signal pc_reg : std_logic_vector(31 downto 0) := (others => '0');
begin
    registro : process (clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                pc_reg <= (others => '0');
            else
                pc_reg <= PC_in;
            end if;
        end if;
    end process registro;

    PC_out <= pc_reg;
end architecture Behavioral;
