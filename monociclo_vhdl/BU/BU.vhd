-- =====================================================================
-- BU.vhd : Unidad de salto (Branch Unit), combinacional
-- Lee rs1 (A) y rs2 (B) directamente de la RU y, segun BrOp (que arma
-- la CU), decide si el PC salta (NextPCSrc='1') o sigue secuencial ('0').
--
--   BrOp    Operacion          Salta si
--   00000   secuencial         nunca
--   11111   JAL                siempre
--   01000   BEQ                A = B
--   01001   BNE                A /= B
--   01100   BLT  (con signo)   A <  B
--   01101   BGE  (con signo)   A >= B
--   01110   BLTU (sin signo)   A <  B
--   01111   BGEU (sin signo)   A >= B
--   otro    -                  nunca (valor seguro)
-- Para las ramas BrOp = "01" & funct3 de la instruccion.
-- =====================================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity BU is
    port (
        A         : in  std_logic_vector(31 downto 0);  -- rs1
        B         : in  std_logic_vector(31 downto 0);  -- rs2
        BrOp      : in  std_logic_vector(4 downto 0);   -- tipo de salto (desde CU)
        NextPCSrc : out std_logic                       -- hacia MuxPC
    );
end entity BU;

architecture Behavioral of BU is
begin
    decision : process (A, B, BrOp)
        variable salta : boolean;
    begin
        salta := false;                        -- por defecto no salta
        case BrOp is
            when "00000" => salta := false;
            when "11111" => salta := true;
            when "01000" => salta := (A = B);
            when "01001" => salta := (A /= B);
            when "01100" => salta := (signed(A)   <  signed(B));
            when "01101" => salta := (signed(A)   >= signed(B));
            when "01110" => salta := (unsigned(A) <  unsigned(B));
            when "01111" => salta := (unsigned(A) >= unsigned(B));
            when others  => salta := false;
        end case;

        if salta then
            NextPCSrc <= '1';
        else
            NextPCSrc <= '0';
        end if;
    end process decision;
end architecture Behavioral;
