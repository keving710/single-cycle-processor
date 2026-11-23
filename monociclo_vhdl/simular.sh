#!/usr/bin/env bash
set -e
ghdl -a --std=08 tb_helpers_pkg.vhd
ghdl -a --std=08 PC/PC.vhd MuxPC/MuxPC.vhd IM/IM.vhd RU/RU.vhd IU/IU.vhd ALU/ALU.vhd BU/BU.vhd DM/DM.vhd CU/CU.vhd
ghdl -a --std=08 monociclo.vhd monociclo_tb.vhd
ghdl -e --std=08 monociclo_tb
ghdl -r --std=08 monociclo_tb --vcd=monociclo_tb.vcd --stop-time=500ns
echo "Simulacion completada. Abra monociclo_tb.vcd con: gtkwave monociclo_tb.vcd"
