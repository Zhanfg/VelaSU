#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SRC="$ROOT/native/probe/src/probe_module.c"
LD="$ROOT/native/probe/mb10pro.ld"
OUT="$ROOT/build/native-probe"

mkdir -p "$OUT"

COMMON=(
  -mcpu=cortex-m33
  -mthumb
  -mfloat-abi=soft
  -ffreestanding
  -fno-common
  -fno-builtin
  -nostdlib
  -fno-jump-tables
  -fno-stack-protector
  -fno-unwind-tables
  -fno-asynchronous-unwind-tables
  -fdata-sections
  -fno-function-sections
  -Os
  -Wall
  -Wextra
  -Werror
)

arm-none-eabi-gcc "${COMMON[@]}" -c "$SRC" -o "$OUT/probe.o"

# Variant A: compact relocatable module, matching the current MB10 Pro
# community build tasks.
arm-none-eabi-gcc   -mcpu=cortex-m33 -mthumb -mfloat-abi=soft   -r -T "$LD"   -o "$OUT/velasu_probe_rel.elf" "$OUT/probe.o"

# Variant B: ET_DYN, matching reverse-engineering reports for firmware
# builds whose modlib_load rejects ET_REL.
arm-none-eabi-gcc "${COMMON[@]}"   -shared -fPIC -nostartfiles   -Wl,--entry=module_initialize   -o "$OUT/velasu_probe_dyn.elf" "$SRC"

for elf in "$OUT"/velasu_probe_*.elf; do
  echo "== $elf =="
  arm-none-eabi-readelf -h "$elf" | grep -E 'Type:|Machine:|Entry point'
  if arm-none-eabi-nm -u "$elf" | grep -q .; then
    echo "ERROR: undefined imports found in $elf" >&2
    arm-none-eabi-nm -u "$elf" >&2
    exit 1
  fi
done
