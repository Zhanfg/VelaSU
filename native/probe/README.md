# Native Probe

This is intentionally the smallest possible VelaSU native module.

It does not call Xiaomi APIs, does not write files, does not touch Bluetooth,
and does not persist across reboot. A successful `insmod` plus `lsmod`
presence is enough to prove that runtime native loading works.

Two ELF variants are produced:

- `velasu_probe_rel.elf`: ET_REL-style relocatable module used by current
  community MB10 Pro build tasks.
- `velasu_probe_dyn.elf`: ET_DYN fallback for firmware loader variants that
  require a shared-object ELF type.

The Lua bootstrap attempts both and records which one loaded.
