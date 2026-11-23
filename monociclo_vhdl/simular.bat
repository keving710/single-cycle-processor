@echo off
echo ============================================================================
echo Compilando y simulando Procesador RISC-V RV32I Monociclo con GHDL
echo ============================================================================

ghdl -a --std=08 tb_helpers_pkg.vhd
if errorlevel 1 goto :err

ghdl -a --std=08 PC/PC.vhd MuxPC/MuxPC.vhd IM/IM.vhd RU/RU.vhd IU/IU.vhd ALU/ALU.vhd BU/BU.vhd DM/DM.vhd CU/CU.vhd
if errorlevel 1 goto :err

ghdl -a --std=08 monociclo.vhd monociclo_tb.vhd
if errorlevel 1 goto :err

ghdl -e --std=08 monociclo_tb
if errorlevel 1 goto :err

ghdl -r --std=08 monociclo_tb --vcd=monociclo_tb.vcd --stop-time=500ns
if errorlevel 1 goto :err

echo.
echo ============================================================================
echo Simulacion exitosa! Archivo generado: monociclo_tb.vcd
echo Para visualizar ondas ejecute: gtkwave monociclo_tb.vcd
echo ============================================================================
goto :eof

:err
echo.
echo [ERROR] Fallo la compilacion o simulacion en GHDL.
exit /b 1
