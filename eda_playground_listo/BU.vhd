-- ============================================================================
-- Archivo: BU/BU.vhd
-- Descripcion: Unidad de Bifurcacion (Branch Unit) para RV32I
-- ============================================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity BU is
    port (
        A         : in  std_logic_vector(31 downto 0);
        B         : in  std_logic_vector(31 downto 0);
        BrOp      : in  std_logic_vector(4 downto 0);
        NextPCSrc : out std_logic
    );
end entity BU;

architecture Behavioral of BU is
begin
    process(A, B, BrOp)
    begin
        case BrOp is
            when "00000" => NextPCSrc <= '0';
            when "11111" => NextPCSrc <= '1';
            when "01000" => if A = B then NextPCSrc <= '1'; else NextPCSrc <= '0'; end if;
            when "01001" => if A /= B then NextPCSrc <= '1'; else NextPCSrc <= '0'; end if;
            when "01100" => if signed(A) < signed(B) then NextPCSrc <= '1'; else NextPCSrc <= '0'; end if;
            when "01101" => if signed(A) >= signed(B) then NextPCSrc <= '1'; else NextPCSrc <= '0'; end if;
            when "01110" => if unsigned(A) < unsigned(B) then NextPCSrc <= '1'; else NextPCSrc <= '0'; end if;
            when "01111" => if unsigned(A) >= unsigned(B) then NextPCSrc <= '1'; else NextPCSrc <= '0'; end if;
            when others  => NextPCSrc <= '0';
        end case;
    end process;
end architecture Behavioral;
