-- =====================================================================
-- IU.vhd : Extensor de inmediatos (combinacional)
-- Entrada imm = instruccion[31:7] (25 bits). Indices: imm(k) = inst(k+7)
-- Selector src (codificacion de ESTE proyecto):
--   000 = I   001 = S   101 = B   010 = U   110 = J   otro = 0
-- =====================================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity IU is
    port (
        imm : in  std_logic_vector(24 downto 0);
        src : in  std_logic_vector(2 downto 0);
        ext : out std_logic_vector(31 downto 0)
    );
end entity IU;

architecture Behavioral of IU is
begin
    extender : process (imm, src)
        variable v : std_logic_vector(31 downto 0);
    begin
        v := (others => '0');
        case src is
            when "000" =>                       -- Tipo I
                if imm(7 downto 5) = "001" or imm(7 downto 5) = "101" then
                    -- SLLI/SRLI/SRAI: solo shamt (inst[24:20]), sin signo
                    v(4 downto 0) := imm(17 downto 13);
                else
                    v(11 downto 0)  := imm(24 downto 13);
                    v(31 downto 12) := (others => imm(24));
                end if;
            when "001" =>                       -- Tipo S: inst[31:25] & inst[11:7]
                v(11 downto 5)  := imm(24 downto 18);
                v(4 downto 0)   := imm(4 downto 0);
                v(31 downto 12) := (others => imm(24));
            when "101" =>                       -- Tipo B
                v(0)            := '0';
                v(4 downto 1)   := imm(4 downto 1);
                v(10 downto 5)  := imm(23 downto 18);
                v(11)           := imm(0);
                v(12)           := imm(24);
                v(31 downto 13) := (others => imm(24));
            when "010" =>                       -- Tipo U: 20 bits altos
                v(31 downto 12) := imm(24 downto 5);
            when "110" =>                       -- Tipo J
                v(0)            := '0';
                v(10 downto 1)  := imm(23 downto 14);
                v(11)           := imm(13);
                v(19 downto 12) := imm(12 downto 5);
                v(20)           := imm(24);
                v(31 downto 21) := (others => imm(24));
            when others =>
                v := (others => '0');
        end case;
        ext <= v;
    end process extender;
end architecture Behavioral;
