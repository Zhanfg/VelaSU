#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SRC="$ROOT/native/core/src/core_3101043.c"
LD="$ROOT/native/probe/mb10pro.ld"
ABI="$ROOT/platform/miband10pro/cn/3.101.043"
OUT="$ROOT/build/native-core"

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
  -I"$ABI"
)

arm-none-eabi-gcc "${COMMON[@]}" -c "$SRC" -o "$OUT/core_3101043.o"
arm-none-eabi-gcc   -mcpu=cortex-m33 -mthumb -mfloat-abi=soft   -r -T "$LD"   -o "$OUT/velasu_core_3.101.043.elf" "$OUT/core_3101043.o"

ELF="$OUT/velasu_core_3.101.043.elf"
arm-none-eabi-readelf -h "$ELF" | grep -E 'Type:|Machine:|Entry point'
if arm-none-eabi-nm -u "$ELF" | grep -q .; then
  echo "ERROR: undefined imports found in $ELF" >&2
  arm-none-eabi-nm -u "$ELF" >&2
  exit 1
fi
arm-none-eabi-nm "$ELF" | grep ' module_initialize$'
