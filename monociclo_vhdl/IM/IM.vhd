-- =====================================================================
-- IM.vhd : Memoria de instrucciones (ROM de 128 bytes = 32 instrucciones)
-- Se carga una vez al elaborar desde instructions.txt (textio):
--   un byte en binario por linea, 4 lineas por instruccion,
--   primera linea = byte MSB de la palabra (big-endian).
-- Lectura combinacional. La direccion se alinea a palabra (ignora los
-- 2 bits bajos) y solo usa los 7 bits bajos (128 bytes).
-- El archivo se busca en IM/instructions.txt (simulando desde la raiz
-- monociclo_vhdl/) y, si no esta, en instructions.txt (carpeta IM/).
-- =====================================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;

entity IM is
    port (
        address     : in  std_logic_vector(31 downto 0);
        instruction : out std_logic_vector(31 downto 0)
    );
end entity IM;

architecture Behavioral of IM is
    type mem_type is array (0 to 127) of std_logic_vector(7 downto 0);

    impure function cargar_memoria return mem_type is
        file     archivo : text;
        variable estado  : file_open_status;
        variable linea   : line;
        variable bits    : bit_vector(7 downto 0);
        variable mem     : mem_type := (others => (others => '0'));
        variable i       : integer := 0;
    begin
        file_open(estado, archivo, "IM/instructions.txt", read_mode);
        if estado /= open_ok then
            file_open(estado, archivo, "instructions.txt", read_mode);
        end if;
        if estado /= open_ok then
            report "IM: no se encontro instructions.txt, memoria en ceros"
                severity warning;
            return mem;
        end if;
        while not endfile(archivo) and i < 128 loop
            readline(archivo, linea);
            read(linea, bits);
            mem(i) := to_stdlogicvector(bits);
            i := i + 1;
        end loop;
        file_close(archivo);
        return mem;
    end function;

    signal rom : mem_type := cargar_memoria;
begin
    lectura : process (address, rom)
        variable a : integer;
    begin
        if Is_X(address) then
            instruction <= (others => '0');
        else
            a := to_integer(unsigned(address(6 downto 2))) * 4;
            instruction <= rom(a) & rom(a + 1) & rom(a + 2) & rom(a + 3);
        end if;
    end process lectura;
end architecture Behavioral;
