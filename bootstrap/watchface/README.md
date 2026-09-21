# VelaSU Lua Bootstrap Watchface

The bootstrap is the temporary runtime activation surface.

Current behavior:
- locates the VelaSU Manager sandbox by a marker created by the Manager;
- copies a minimal native probe ELF into `/data`;
- tries ET_DYN first and ET_REL as a fallback;
- verifies the module with `lsmod`;
- runs read-only capability checks;
- returns a compact JSON result to the Manager sandbox.

It does **not** modify firmware, bootloader, OTA/recovery, or Bluetooth
initialization, and the loaded module disappears after reboot.
