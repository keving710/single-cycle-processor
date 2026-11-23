-- ============================================================================
-- Archivo: tb_helpers_pkg.vhd
-- Descripcion: Funciones auxiliares de formateo hexadecimal para testbenches
-- Proyecto: Procesador RISC-V RV32I Monociclo
-- ============================================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package tb_helpers is
    function word32_to_hex(w : std_logic_vector(31 downto 0)) return string;
end package tb_helpers;

package body tb_helpers is
    function word32_to_hex(w : std_logic_vector(31 downto 0)) return string is
        constant HEX_CHARS : string(1 to 16) := "0123456789ABCDEF";
        variable res       : string(1 to 8);
        variable nibble    : std_logic_vector(3 downto 0);
        variable idx       : integer;
    begin
        for i in 0 to 7 loop
            nibble := w(31 - i*4 downto 28 - i*4);
            if is_x(nibble) then
                res(i + 1) := 'X';
            else
                idx := to_integer(unsigned(nibble));
                res(i + 1) := HEX_CHARS(idx + 1);
            end if;
        end loop;
        return res;
    end function word32_to_hex;
end package body tb_helpers;
