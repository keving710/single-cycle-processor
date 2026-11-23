-- ============================================================================
-- Archivo: DM/DM.vhd
-- Descripcion: Memoria de datos byte-direccionable (1024 bytes, Little-Endian)
-- ============================================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity DM is
    port (
        clk     : in  std_logic;
        Address : in  std_logic_vector(31 downto 0);
        DataWr  : in  std_logic_vector(31 downto 0);
        DMWr    : in  std_logic;
        DMCtrl  : in  std_logic_vector(2 downto 0);
        DataRd  : out std_logic_vector(31 downto 0)
    );
end entity DM;

architecture Behavioral of DM is
    type ram_type is array (0 to 1023) of std_logic_vector(7 downto 0);
    signal mem : ram_type := (others => (others => '0'));
begin
    process(clk)
        variable addr : integer;
    begin
        if rising_edge(clk) then
            if DMWr = '1' then
                addr := to_integer(unsigned(Address(9 downto 0)));
                case DMCtrl is
                    when "000" =>
                        if addr <= 1023 then
                            mem(addr) <= DataWr(7 downto 0);
                        end if;
                    when "001" =>
                        if addr <= 1022 then
                            mem(addr)     <= DataWr(7 downto 0);
                            mem(addr + 1) <= DataWr(15 downto 8);
                        end if;
                    when "010" =>
                        if addr <= 1020 then
                            mem(addr)     <= DataWr(7 downto 0);
                            mem(addr + 1) <= DataWr(15 downto 8);
                            mem(addr + 2) <= DataWr(23 downto 16);
                            mem(addr + 3) <= DataWr(31 downto 24);
                        end if;
                    when others =>
                        null;
                end case;
            end if;
        end if;
    end process;

    process(mem, Address, DMCtrl)
        variable addr : integer;
    begin
        addr := to_integer(unsigned(Address(9 downto 0)));
        if addr <= 1020 then
            case DMCtrl is
                when "000" => DataRd <= (31 downto 8 => mem(addr)(7)) & mem(addr);
                when "001" => DataRd <= (31 downto 16 => mem(addr + 1)(7)) & mem(addr + 1) & mem(addr);
                when "010" => DataRd <= mem(addr + 3) & mem(addr + 2) & mem(addr + 1) & mem(addr);
                when "100" => DataRd <= (31 downto 8 => '0') & mem(addr);
                when "101" => DataRd <= (31 downto 16 => '0') & mem(addr + 1) & mem(addr);
                when others => DataRd <= (others => '0');
            end case;
        else
            DataRd <= (others => '0');
        end if;
    end process;
end architecture Behavioral;
