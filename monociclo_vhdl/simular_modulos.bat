@echo off
echo ============================================================================
echo Ejecutando los 9 Testbenches Individuales (Criterio 1 de la Rubrica)
echo ============================================================================

ghdl -a --std=08 PC/PC.vhd PC/PC_tb.vhd && ghdl -e --std=08 PC_tb && ghdl -r --std=08 PC_tb
ghdl -a --std=08 MuxPC/MuxPC.vhd MuxPC/MuxPC_tb.vhd && ghdl -e --std=08 MuxPC_tb && ghdl -r --std=08 MuxPC_tb
ghdl -a --std=08 IM/IM.vhd IM/IM_tb.vhd && ghdl -e --std=08 IM_tb && ghdl -r --std=08 IM_tb
ghdl -a --std=08 RU/RU.vhd RU/RU_tb.vhd && ghdl -e --std=08 RU_tb && ghdl -r --std=08 RU_tb
ghdl -a --std=08 IU/IU.vhd IU/IU_tb.vhd && ghdl -e --std=08 IU_tb && ghdl -r --std=08 IU_tb
ghdl -a --std=08 ALU/ALU.vhd ALU/ALU_tb.vhd && ghdl -e --std=08 ALU_tb && ghdl -r --std=08 ALU_tb
ghdl -a --std=08 BU/BU.vhd BU/BU_tb.vhd && ghdl -e --std=08 BU_tb && ghdl -r --std=08 BU_tb
ghdl -a --std=08 DM/DM.vhd DM/DM_tb.vhd && ghdl -e --std=08 DM_tb && ghdl -r --std=08 DM_tb
ghdl -a --std=08 CU/CU.vhd CU/CU_tb.vhd && ghdl -e --std=08 CU_tb && ghdl -r --std=08 CU_tb

echo.
echo Todos los testbenches individuales finalizaron!
