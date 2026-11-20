-- =====================================================================
-- RU.vhd : Banco de 32 registros de 32 bits
--   * Escritura SINCRONA (flanco de subida) si ruWr='1' y rd /= x0
--   * Lectura ASINCRONA por dos puertos (rs1, rs2)
--   * x0 siempre vale 0; x2 (sp) arranca en 0xFFFFFFFF
-- =====================================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RU is
    port (
        clk    : in  std_logic;
        ruWr   : in  std_logic;
        rs1    : in  std_logic_vector(4 downto 0);
        rs2    : in  std_logic_vector(4 downto 0);
        rd     : in  std_logic_vector(4 downto 0);
        DataWr : in  std_logic_vector(31 downto 0);
        ruRs1  : out std_logic_vector(31 downto 0);
        ruRs2  : out std_logic_vector(31 downto 0)
    );
end entity RU;

architecture Behavioral of RU is
    type reg_array is array (0 to 31) of std_logic_vector(31 downto 0);

    -- Estado inicial: todo en 0, salvo x2 = 0xFFFFFFFF
    function estado_inicial return reg_array is
        variable r : reg_array := (others => (others => '0'));
    begin
        r(2) := x"FFFFFFFF";
        return r;
    end function;

    signal registers : reg_array := estado_inicial;
begin
    escritura : process (clk)
    begin
        if rising_edge(clk) then
            if ruWr = '1' and not Is_X(rd) and rd /= "00000" then
                registers(to_integer(unsigned(rd))) <= DataWr;
            end if;
        end if;
    end process escritura;

    ruRs1 <= (others => '0') when Is_X(rs1) or rs1 = "00000"
             else registers(to_integer(unsigned(rs1)));
    ruRs2 <= (others => '0') when Is_X(rs2) or rs2 = "00000"
             else registers(to_integer(unsigned(rs2)));
end architecture Behavioral;
