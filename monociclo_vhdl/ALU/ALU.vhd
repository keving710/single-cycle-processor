-- =====================================================================
-- ALU.vhd : Unidad Aritmetico-Logica del RISC-V RV32I monociclo
-- Combinacional pura (sin reloj). 10 operaciones.
--
--   ALUop  Operacion   Resultado
--   0000   ADD         A + B
--   1000   SUB         A - B
--   0111   AND         A and B
--   0110   OR          A or B
--   0100   XOR         A xor B
--   0001   SLL         A << B[4:0]
--   0101   SRL         A >> B[4:0]  (rellena con ceros)
--   1101   SRA         A >> B[4:0]  (rellena con el bit de signo)
--   0010   SLT         (A < B) con signo   -> 1 o 0
--   0011   SLTU        (A < B) sin signo   -> 1 o 0
--   otro   -           0 (valor seguro, evita latches)
-- =====================================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALU is
    port (
        A     : in  std_logic_vector(31 downto 0);  -- operando A (rs1 o PC)
        B     : in  std_logic_vector(31 downto 0);  -- operando B (rs2 o inmediato)
        ALUop : in  std_logic_vector(3 downto 0);   -- selector de operacion
        ALUS  : out std_logic_vector(31 downto 0)   -- resultado
    );
end entity ALU;

architecture Behavioral of ALU is
    -- Cantidad de desplazamiento: los 5 bits bajos de B (0..31)
    signal shamt : natural range 0 to 31 := 0;
begin

    -- Proceso 1: extrae shamt de B. Si B trae 'U'/'X' (inicio de la
    -- simulacion), usa 0 para que to_integer no falle.
    shamt_calc : process (B)
    begin
        if Is_X(B(4 downto 0)) then
            shamt <= 0;
        else
            shamt <= to_integer(unsigned(B(4 downto 0)));
        end if;
    end process shamt_calc;

    -- Proceso 2: seleccion de la operacion segun ALUop
    alu_proc : process (A, B, ALUop, shamt)
    begin
        case ALUop is
            when "0000" =>  -- ADD
                ALUS <= std_logic_vector(unsigned(A) + unsigned(B));
            when "1000" =>  -- SUB
                ALUS <= std_logic_vector(unsigned(A) - unsigned(B));
            when "0111" =>  -- AND
                ALUS <= A and B;
            when "0110" =>  -- OR
                ALUS <= A or B;
            when "0100" =>  -- XOR
                ALUS <= A xor B;
            when "0001" =>  -- SLL (logico a la izquierda)
                ALUS <= std_logic_vector(shift_left(unsigned(A), shamt));
            when "0101" =>  -- SRL (logico a la derecha: unsigned)
                ALUS <= std_logic_vector(shift_right(unsigned(A), shamt));
            when "1101" =>  -- SRA (aritmetico: signed conserva el signo)
                ALUS <= std_logic_vector(shift_right(signed(A), shamt));
            when "0010" =>  -- SLT (comparacion con signo)
                if signed(A) < signed(B) then
                    ALUS <= (0 => '1', others => '0');
                else
                    ALUS <= (others => '0');
                end if;
            when "0011" =>  -- SLTU (comparacion sin signo)
                if unsigned(A) < unsigned(B) then
                    ALUS <= (0 => '1', others => '0');
                else
                    ALUS <= (others => '0');
                end if;
            when others =>
                ALUS <= (others => '0');
        end case;
    end process alu_proc;

end architecture Behavioral;
