#!/usr/bin/env bash
# Compila y simula cada modulo. Ejecutar desde monociclo_vhdl/ :  ./run_all.sh
set -u
mkdir -p build
fallos=0
for m in PC MuxPC IM RU IU ALU; do
    out=$( { ghdl -a --std=08 --workdir=build $m/$m.vhd $m/${m}_tb.vhd \
          && ghdl -e --std=08 --workdir=build ${m}_tb \
          && ghdl -r --std=08 --workdir=build ${m}_tb --vcd=build/${m}_tb.vcd --stop-time=2us; } 2>&1 )
    if echo "$out" | grep -qiE "error|failure|:error:"; then
        echo "[FALLO] $m"; echo "$out" | grep -iE "error|failure" | head -5; fallos=1
    else
        echo "[ OK  ] $m"
    fi
done
exit $fallos
