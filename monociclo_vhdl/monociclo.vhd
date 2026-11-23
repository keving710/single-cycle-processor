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
