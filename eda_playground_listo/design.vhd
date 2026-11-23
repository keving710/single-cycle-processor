-- ============================================================================
-- Archivo: PC/PC.vhd
-- Descripcion: Contador de Programa (Program Counter) de 32 bits con reset
--              sincrono activo en alto.
-- ============================================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PC is
    port (
        clk    : in  std_logic;
        reset  : in  std_logic;
        PC_in  : in  std_logic_vector(31 downto 0);
        PC_out : out std_logic_vector(31 downto 0)
    );
end entity PC;

architecture Behavioral of PC is
    signal pc_reg : std_logic_vector(31 downto 0) := (others => '0');
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                pc_reg <= (others => '0');
            else
                pc_reg <= PC_in;
            end if;
        end if;
    end process;

    PC_out <= pc_reg;
end architecture Behavioral;


-- ============================================================================
-- Archivo: MuxPC/MuxPC.vhd
-- Descripcion: Multiplexor del Contador de Programa. Selecciona PC_4 + 4
--              cuando NextPCSrc = '0' o AluJump cuando NextPCSrc = '1'.
-- ============================================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MuxPC is
    port (
        PC_4      : in  std_logic_vector(31 downto 0);
        AluJump   : in  std_logic_vector(31 downto 0);
        NextPCSrc : in  std_logic;
        NextPC    : out std_logic_vector(31 downto 0)
    );
end entity MuxPC;

architecture Behavioral of MuxPC is
begin
    process(PC_4, AluJump, NextPCSrc)
    begin
        if NextPCSrc = '1' then
            NextPC <= AluJump;
        else
            NextPC <= std_logic_vector(unsigned(PC_4) + 4);
        end if;
    end process;
end architecture Behavioral;


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


-- ============================================================================
-- Archivo: RU/RU.vhd
-- Descripcion: Banco de 32 registros de 32 bits (x0..x31). x0 siempre vale 0.
-- ============================================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RU is
    port (
        clk    : in  std_logic;
        rs1    : in  std_logic_vector(4 downto 0);
        rs2    : in  std_logic_vector(4 downto 0);
        rd     : in  std_logic_vector(4 downto 0);
        DataWr : in  std_logic_vector(31 downto 0);
        RUWr   : in  std_logic;
        RU1    : out std_logic_vector(31 downto 0);
        RU2    : out std_logic_vector(31 downto 0)
    );
end entity RU;

architecture Behavioral of RU is
    type reg_array is array (0 to 31) of std_logic_vector(31 downto 0);
    signal regs : reg_array := (others => (others => '0'));
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if RUWr = '1' and rd /= "00000" then
                regs(to_integer(unsigned(rd))) <= DataWr;
            end if;
        end if;
    end process;

    RU1 <= (others => '0') when rs1 = "00000" else regs(to_integer(unsigned(rs1)));
    RU2 <= (others => '0') when rs2 = "00000" else regs(to_integer(unsigned(rs2)));
end architecture Behavioral;


-- ============================================================================
-- Archivo: IU/IU.vhd
-- Descripcion: Unidad de Inmediatos (extensor de signo para formatos I,S,B,U,J)
-- ============================================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity IU is
    port (
        Instruction : in  std_logic_vector(31 downto 0);
        ImmSrc      : in  std_logic_vector(2 downto 0);
        ImmExt      : out std_logic_vector(31 downto 0)
    );
end entity IU;

architecture Behavioral of IU is
begin
    process(Instruction, ImmSrc)
        variable sign_bit : std_logic;
    begin
        sign_bit := Instruction(31);
        case ImmSrc is
            when "000" => -- Formato I
                ImmExt <= (31 downto 12 => sign_bit) & Instruction(31 downto 20);
            when "001" => -- Formato S
                ImmExt <= (31 downto 12 => sign_bit) & Instruction(31 downto 25) & Instruction(11 downto 7);
            when "010" => -- Formato B
                ImmExt <= (31 downto 13 => sign_bit) & Instruction(31) & Instruction(7) &
                          Instruction(30 downto 25) & Instruction(11 downto 8) & '0';
            when "011" => -- Formato U
                ImmExt <= Instruction(31 downto 12) & x"000";
            when "100" => -- Formato J
                ImmExt <= (31 downto 21 => sign_bit) & Instruction(31) & Instruction(19 downto 12) &
                          Instruction(20) & Instruction(30 downto 21) & '0';
            when others =>
                ImmExt <= (others => '0');
        end case;
    end process;
end architecture Behavioral;


-- ============================================================================
-- Archivo: ALU/ALU.vhd
-- Descripcion: Unidad Aritmetico-Logica de 32 bits (10 operaciones RV32I)
-- ============================================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALU is
    port (
        A      : in  std_logic_vector(31 downto 0);
        B      : in  std_logic_vector(31 downto 0);
        ALUOp  : in  std_logic_vector(3 downto 0);
        ALURes : out std_logic_vector(31 downto 0)
    );
end entity ALU;

architecture Behavioral of ALU is
begin
    process(A, B, ALUOp)
        variable shamt : natural range 0 to 31;
    begin
        shamt := to_integer(unsigned(B(4 downto 0)));
        case ALUOp is
            when "0000" => ALURes <= std_logic_vector(signed(A) + signed(B));
            when "1000" => ALURes <= std_logic_vector(signed(A) - signed(B));
            when "0001" => ALURes <= std_logic_vector(shift_left(unsigned(A), shamt));
            when "0010" =>
                if signed(A) < signed(B) then ALURes <= x"00000001"; else ALURes <= x"00000000"; end if;
            when "0011" =>
                if unsigned(A) < unsigned(B) then ALURes <= x"00000001"; else ALURes <= x"00000000"; end if;
            when "0100" => ALURes <= A xor B;
            when "0101" => ALURes <= std_logic_vector(shift_right(unsigned(A), shamt));
            when "1101" => ALURes <= std_logic_vector(shift_right(signed(A), shamt));
            when "0110" => ALURes <= A or B;
            when "0111" => ALURes <= A and B;
            when others => ALURes <= (others => '0');
        end case;
    end process;
end architecture Behavioral;


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


-- ============================================================================
-- Archivo: monociclo.vhd
-- Descripcion: Top-Level del Procesador RISC-V RV32I Monociclo
-- ============================================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity monociclo is
    port (
        clk       : in  std_logic;
        reset     : in  std_logic;
        dbg_pc    : out std_logic_vector(31 downto 0);
        dbg_instr : out std_logic_vector(31 downto 0)
    );
end entity monociclo;

architecture Structural of monociclo is
    signal pc_current   : std_logic_vector(31 downto 0);
    signal pc_next      : std_logic_vector(31 downto 0);
    signal pc_plus_4    : std_logic_vector(31 downto 0);
    signal instruction  : std_logic_vector(31 downto 0);
    signal ru_data1     : std_logic_vector(31 downto 0);
    signal ru_data2     : std_logic_vector(31 downto 0);
    signal imm_ext      : std_logic_vector(31 downto 0);
    signal alu_in_a     : std_logic_vector(31 downto 0);
    signal alu_in_b     : std_logic_vector(31 downto 0);
    signal alu_res      : std_logic_vector(31 downto 0);
    signal dm_data_rd   : std_logic_vector(31 downto 0);
    signal ru_data_wr   : std_logic_vector(31 downto 0);

    signal ru_wr        : std_logic;
    signal imm_src      : std_logic_vector(2 downto 0);
    signal alu_src_a    : std_logic_vector(1 downto 0);
    signal alu_src_b    : std_logic;
    signal alu_op       : std_logic_vector(3 downto 0);
    signal br_op        : std_logic_vector(4 downto 0);
    signal next_pc_src  : std_logic;
    signal dm_wr        : std_logic;
    signal dm_ctrl      : std_logic_vector(2 downto 0);
    signal ru_data_src  : std_logic_vector(1 downto 0);
begin
    dbg_pc    <= pc_current;
    dbg_instr <= instruction;
    pc_plus_4 <= std_logic_vector(unsigned(pc_current) + 4);

    U_PC : entity work.PC
        port map (clk => clk, reset => reset, PC_in => pc_next, PC_out => pc_current);

    U_MuxPC : entity work.MuxPC
        port map (PC_4 => pc_current, AluJump => alu_res, NextPCSrc => next_pc_src, NextPC => pc_next);

    U_IM : entity work.IM
        port map (Address => pc_current, Instruction => instruction);

    U_CU : entity work.CU
        port map (
            Opcode      => instruction(6 downto 0),
            Funct3      => instruction(14 downto 12),
            Funct7      => instruction(31 downto 25),
            RUWr        => ru_wr,
            ImmSrc      => imm_src,
            ALUSrcA     => alu_src_a,
            ALUSrcB     => alu_src_b,
            ALUOp       => alu_op,
            BrOp        => br_op,
            DMWr        => dm_wr,
            DMCtrl      => dm_ctrl,
            RUDataWrSrc => ru_data_src
        );

    U_RU : entity work.RU
        port map (
            clk    => clk,
            rs1    => instruction(19 downto 15),
            rs2    => instruction(24 downto 20),
            rd     => instruction(11 downto 7),
            DataWr => ru_data_wr,
            RUWr   => ru_wr,
            RU1    => ru_data1,
            RU2    => ru_data2
        );

    U_IU : entity work.IU
        port map (Instruction => instruction, ImmSrc => imm_src, ImmExt => imm_ext);

    with alu_src_a select
        alu_in_a <= ru_data1        when "00",
                    pc_current      when "01",
                    (others => '0') when "10",
                    ru_data1        when others;

    alu_in_b <= imm_ext when alu_src_b = '1' else ru_data2;

    U_ALU : entity work.ALU
        port map (A => alu_in_a, B => alu_in_b, ALUOp => alu_op, ALURes => alu_res);

    U_BU : entity work.BU
        port map (A => ru_data1, B => ru_data2, BrOp => br_op, NextPCSrc => next_pc_src);

    U_DM : entity work.DM
        port map (
            clk     => clk,
            Address => alu_res,
            DataWr  => ru_data2,
            DMWr    => dm_wr,
            DMCtrl  => dm_ctrl,
            DataRd  => dm_data_rd
        );

    with ru_data_src select
        ru_data_wr <= alu_res    when "00",
                      dm_data_rd when "01",
                      pc_plus_4  when "10",
                      alu_res    when others;
end architecture Structural;
