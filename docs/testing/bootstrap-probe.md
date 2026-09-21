# Bootstrap Probe: first on-device test

Target: Xiaomi Smart Band 10 Pro CN.

This test validates only the runtime bootstrap chain. It does not enable boot persistence and does not modify firmware partitions.

## Safety boundary

The current probe:
- copies two tiny ELF candidates to `/data`;
- attempts `insmod`;
- verifies presence with `lsmod`;
- reads a small set of existing system capability indicators;
- writes a JSON report to the VelaSU Manager Quick App sandbox.

It does **not** modify the bootloader, OTA/recovery, early boot, Bluetooth initialization, or system firmware.

If the runtime module misbehaves, rebooting the band is expected to clear it.

## Artifacts

Use artifacts generated from the same commit:
- `VelaSU-Manager-RPK-<sha>`
- `VelaSU-Lua-Watchface-<sha>`

The watchface artifact also contains the two ELF candidates for inspection.

## Test sequence

1. Install the VelaSU Manager RPK.
2. Open VelaSU Manager once.
   - Expected: `Bridge = READY`.
   - The app creates `internal://files/velasu_manager.marker`.
3. Install and activate the VelaSU Bootstrap Lua watchface.
4. Tap **ACTIVATE** once.
5. Wait for one of these results:
   - `Native probe ONLINE / ET_DYN`
   - `Native probe ONLINE / ET_REL`
   - `Native load failed`
6. Return to VelaSU Manager.
7. Record:
   - firmware string;
   - Native Core state;
   - ELF format selected;
   - Bridge state;
   - UnionFS result;
   - uORB result;
   - any error text.
8. Switch to an unrelated ordinary watchface.
9. Open VelaSU Manager again.
   - This version only proves that the previously produced report remains accessible.
   - It does **not yet** prove a live Manager-to-native bridge after the Bootstrap watchface exits.
10. Reboot the band.
11. Confirm stock boot and Bluetooth pairing still work normally.

## Pass criteria

### P0: packaging
Manager RPK and Bootstrap watchface install and open normally.

### P1: sandbox bridge
Bootstrap locates the Manager marker and writes `velasu_probe.json`.

### P2: native loader
At least one ELF variant loads and is visible in `lsmod`.

### P3: read-only capability probe
Manager receives and renders the JSON capability report.

### P4: reboot recovery
After reboot, the band returns to normal stock behavior without requiring VelaSU.

## Stop conditions

Stop testing and reboot immediately if:
- UI repeatedly restarts;
- touch input becomes persistently unresponsive;
- Bluetooth disconnects together with repeated system restarts;
- the bootstrap loops its activation without user input.

Do not attempt repeated `insmod` after a reproducible reboot until the failure is diagnosed.

## Next milestone

After P0-P4 pass, the next implementation is a live native VelaCall transport. That transport must demonstrate:
- Manager request -> native module response;
- continued responses after switching away from/deleting the Bootstrap watchface;
- clean disappearance after reboot.

Only after that milestone should module policy, Bluetooth providers, or runtime hooks be enabled.
