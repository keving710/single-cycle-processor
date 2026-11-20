# Procesador RISC-V RV32I monociclo en VHDL

Herramientas: GHDL (`--std=08`) y GTKWave.

## Estructura
`monociclo_vhdl/<MODULO>/<MODULO>.vhd` + `<MODULO>_tb.vhd` para PC, MuxPC, IM, RU, IU, ALU
(pendientes: BU, DM, CU y el top `monociclo.vhd`).

## Simular todos los modulos
Desde la carpeta `monociclo_vhdl/`:

    ./run_all.sh

## Simular un modulo (ejemplo ALU)
    ghdl -a --std=08 ALU/ALU.vhd ALU/ALU_tb.vhd
    ghdl -e --std=08 ALU_tb
    ghdl -r --std=08 ALU_tb --vcd=ALU_tb.vcd --stop-time=1us
    gtkwave ALU_tb.vcd

La IM lee `IM/instructions.txt` (un byte en binario por linea, 4 lineas por
instruccion, primer byte = MSB). Simular la IM desde `monociclo_vhdl/`.
El `instructions.txt` actual es solo un ejemplo para probar la IM.
