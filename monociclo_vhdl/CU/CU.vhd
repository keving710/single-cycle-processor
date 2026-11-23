-- ============================================================================
-- Archivo: CU/CU.vhd
-- Descripcion: Unidad de Control principal RV32I monociclo
-- ============================================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity CU is
    port (
        Opcode      : in  std_logic_vector(6 downto 0);
        Funct3      : in  std_logic_vector(2 downto 0);
        Funct7      : in  std_logic_vector(6 downto 0);
        RUWr        : out std_logic;
        ImmSrc      : out std_logic_vector(2 downto 0);
        ALUSrcA     : out std_logic_vector(1 downto 0);
        ALUSrcB     : out std_logic;
        ALUOp       : out std_logic_vector(3 downto 0);
        BrOp        : out std_logic_vector(4 downto 0);
        DMWr        : out std_logic;
        DMCtrl      : out std_logic_vector(2 downto 0);
        RUDataWrSrc : out std_logic_vector(1 downto 0)
    );
end entity CU;

architecture Behavioral of CU is
begin
    process(Opcode, Funct3, Funct7)
    begin
        RUWr        <= '0';
        ImmSrc      <= "000";
        ALUSrcA     <= "00";
        ALUSrcB     <= '0';
        ALUOp       <= "0000";
        BrOp        <= "00000";
        DMWr        <= '0';
        DMCtrl      <= "010";
        RUDataWrSrc <= "00";

        case Opcode is
            when "0110011" => -- Tipo R
                RUWr        <= '1';
                ALUSrcA     <= "00";
                ALUSrcB     <= '0';
                ALUOp       <= Funct7(5) & Funct3;
                BrOp        <= "00000";
                DMWr        <= '0';
                RUDataWrSrc <= "00";

            when "0010011" => -- Tipo I
                RUWr        <= '1';
                ImmSrc      <= "000";
                ALUSrcA     <= "00";
                ALUSrcB     <= '1';
                if Funct3 = "101" then
                    ALUOp <= Funct7(5) & Funct3;
                else
                    ALUOp <= '0' & Funct3;
                end if;
                BrOp        <= "00000";
                DMWr        <= '0';
                RUDataWrSrc <= "00";

            when "0000011" => -- Load
                RUWr        <= '1';
                ImmSrc      <= "000";
                ALUSrcA     <= "00";
                ALUSrcB     <= '1';
                ALUOp       <= "0000";
                BrOp        <= "00000";
                DMWr        <= '0';
                DMCtrl      <= Funct3;
                RUDataWrSrc <= "01";

            when "0100011" => -- Store
                RUWr        <= '0';
                ImmSrc      <= "001";
                ALUSrcA     <= "00";
                ALUSrcB     <= '1';
                ALUOp       <= "0000";
                BrOp        <= "00000";
                DMWr        <= '1';
                DMCtrl      <= Funct3;
                RUDataWrSrc <= "00";

            when "1100011" => -- Branch
                RUWr        <= '0';
                ImmSrc      <= "010";
                ALUSrcA     <= "01";
                ALUSrcB     <= '1';
                ALUOp       <= "0000";
                BrOp        <= "01" & Funct3;
                DMWr        <= '0';
                RUDataWrSrc <= "00";

            when "0110111" => -- LUI
                RUWr        <= '1';
                ImmSrc      <= "011";
                ALUSrcA     <= "10";
                ALUSrcB     <= '1';
                ALUOp       <= "0000";
                BrOp        <= "00000";
                DMWr        <= '0';
                RUDataWrSrc <= "00";

            when "1101111" => -- JAL
                RUWr        <= '1';
                ImmSrc      <= "100";
                ALUSrcA     <= "01";
                ALUSrcB     <= '1';
                ALUOp       <= "0000";
                BrOp        <= "11111";
                DMWr        <= '0';
                RUDataWrSrc <= "10";

            when others =>
                null;
        end case;
    end process;
end architecture Behavioral;
