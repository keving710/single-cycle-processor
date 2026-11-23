# Procesador RISC-V (RV32I) Monociclo en VHDL

## Estructura del Proyecto
- `monociclo_vhdl/`: Estructura oficial por carpetas requerida por la rubrica (`PC/`, `MuxPC/`, `IM/`, `RU/`, `IU/`, `ALU/`, `BU/`, `DM/`, `CU/`, `monociclo.vhd`, `monociclo_tb.vhd`, `tb_helpers_pkg.vhd`, `simular.bat`, `simular_modulos.bat`).
- `eda_playground_listo/`: Archivos planos listos para subir o copiar/pegar directamente en **EDA Playground** (`design.vhd`, `testbench.vhd`, `instructions.txt` y los `.vhd` individuales).

## Ejecucion en Windows (GHDL + GTKWave)
1. Abra PowerShell o CMD dentro de `monociclo_vhdl/`.
2. Ejecute `simular.bat` para compilar, simular y generar `monociclo_tb.vcd`.
3. Ejecute `simular_modulos.bat` para validar los 9 testbenches individuales.
4. Abra las ondas con `gtkwave monociclo_tb.vcd`.

## Ejecucion en EDA Playground
1. Seleccione **Testbench + Design**: `VHDL`.
2. Seleccione **Tools & Simulators**: `GHDL 0.37` (o `Aldec Riviera Pro`).
3. En **Compile Options**, escriba: `--std=08`.
4. En **Run Options**, escriba: `--vcd=dump.vcd --stop-time=500ns` y marque **Open EPWave after run**.
5. Suba o pegue los archivos de `eda_playground_listo/` y presione **Run**.
