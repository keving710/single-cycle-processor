-- ============================================================================
-- Archivo: IM/IM.vhd
-- Descripcion: Memoria ROM de instrucciones byte-direccionable (Big-Endian).
--              Compatible tanto con ejecucion local ("IM/instructions.txt")
--              como con EDA Playground ("instructions.txt").
-- ============================================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;

entity IM is
    port (
        Address     : in  std_logic_vector(31 downto 0);
        Instruction : out std_logic_vector(31 downto 0)
    );
end entity IM;

architecture Behavioral of IM is
    type rom_type is array (0 to 1023) of std_logic_vector(7 downto 0);

    function str_to_slv8(s : string) return std_logic_vector is
        variable res : std_logic_vector(7 downto 0) := (others => '0');
    begin
        for i in 1 to 8 loop
            if i <= s'length then
                if s(i) = '1' then
                    res(8 - i) := '1';
                else
                    res(8 - i) := '0';
                end if;
            end if;
        end loop;
        return res;
    end function str_to_slv8;

    impure function init_rom return rom_type is
        file f          : text;
        variable status : file_open_status;
        variable l      : line;
        variable s      : string(1 to 8);
        variable mem    : rom_type := (others => (others => '0'));
        variable idx    : integer := 0;
    begin
        -- Precargar toda la ROM con NOP (0x00000013 = addi x0, x0, 0)
        for k in 0 to 255 loop
            mem(k*4)     := x"00";
            mem(k*4 + 1) := x"00";
            mem(k*4 + 2) := x"00";
            mem(k*4 + 3) := x"13";
        end loop;

        -- Intentar primero ruta relativa de proyecto ("IM/instructions.txt")
        file_open(status, f, "IM/instructions.txt", READ_MODE);
        if status /= OPEN_OK then
            -- Fallback para directorio plano (EDA Playground o ejecucion dentro de IM/)
            file_open(status, f, "instructions.txt", READ_MODE);
        end if;

        if status = OPEN_OK then
            while not endfile(f) and idx < 1024 loop
                readline(f, l);
                if l'length >= 8 then
                    read(l, s);
                    mem(idx) := str_to_slv8(s);
                    idx := idx + 1;
                end if;
            end loop;
            file_close(f);
        else
            report "ADVERTENCIA IM: No se encontro instructions.txt. Se cargaron NOPs."
                severity warning;
        end if;
        return mem;
    end function init_rom;

    signal rom : rom_type := init_rom;
begin
    process(Address, rom)
        variable addr : integer;
    begin
        addr := to_integer(unsigned(Address(9 downto 0)));
        if addr <= 1020 then
            Instruction <= rom(addr) & rom(addr + 1) & rom(addr + 2) & rom(addr + 3);
        else
            Instruction <= x"00000013";
        end if;
    end process;
end architecture Behavioral;
