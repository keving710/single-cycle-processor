-- ============================================================================
-- Archivo: RU/RU.vhd
-- Descripcion: Banco de 32 registros de 32 bits (x0..x31). x0 siempre vale 0.
-- ============================================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RU is
    port (
        clk    : in  std_logic;
        rs1    : in  std_logic_vector(4 downto 0);
        rs2    : in  std_logic_vector(4 downto 0);
        rd     : in  std_logic_vector(4 downto 0);
        DataWr : in  std_logic_vector(31 downto 0);
        RUWr   : in  std_logic;
        RU1    : out std_logic_vector(31 downto 0);
        RU2    : out std_logic_vector(31 downto 0)
    );
end entity RU;

architecture Behavioral of RU is
    type reg_array is array (0 to 31) of std_logic_vector(31 downto 0);
    signal regs : reg_array := (others => (others => '0'));
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if RUWr = '1' and rd /= "00000" then
                regs(to_integer(unsigned(rd))) <= DataWr;
            end if;
        end if;
    end process;

    RU1 <= (others => '0') when rs1 = "00000" else regs(to_integer(unsigned(rs1)));
    RU2 <= (others => '0') when rs2 = "00000" else regs(to_integer(unsigned(rs2)));
end architecture Behavioral;
