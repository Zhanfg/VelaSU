# Bootstrap Probe: first on-device test

Target: Xiaomi Smart Band 10 Pro CN.

This test validates the runtime bootstrap chain. It does not enable boot persistence and does not modify firmware partitions.

## Safety boundary

The current Bootstrap:
- copies tiny ELF payloads to `/data`;
- attempts `insmod`;
- verifies presence with `lsmod`;
- reads a small set of existing capability indicators;
- writes the probe result to the Manager sandbox;
- on **exact firmware 3.101.043 only**, loads the first VelaCall Core.

The 3.101.043 Core installs a low-frequency LVGL timer and handles only:

`PING <nonce>` -> `PONG <nonce> <heartbeat>`

It does **not** modify the bootloader, OTA/recovery, early boot, Bluetooth initialization, or firmware partitions.

The Core is resident-until-reboot in this phase. Do **not** run `rmmod velasu_core`; reboot is the supported teardown path.

## Test sequence

1. Install the VelaSU Manager RPK.
2. Open VelaSU Manager once.
3. Install and activate the VelaSU Bootstrap Lua watchface.
4. Tap **ACTIVATE** once.
5. Return to Manager.
6. Record the displayed firmware and loader format.
7. If firmware is exactly `3.101.043`, wait for:
   - `VELACALL = ONLINE`
   - an increasing heartbeat value.
8. Switch to an unrelated ordinary watchface.
9. Open Manager again.
10. Confirm the heartbeat continues increasing.
11. Delete the Bootstrap watchface if your installer supports doing so safely.
12. Open Manager again and confirm the heartbeat still increases.
13. Reboot the band.
14. Confirm stock boot and Bluetooth pairing remain normal.
15. Open Manager. The old probe report may remain, but live PING/PONG must become OFFLINE because the runtime Core was cleared.

## Pass criteria

- P0: Manager and Bootstrap install/open.
- P1: Bootstrap finds Manager sandbox and returns probe JSON.
- P2: at least one safe loader probe ELF is accepted.
- P3: capability report renders in Manager.
- P4: on supported firmware, live PING/PONG reaches ONLINE.
- P5: PING/PONG remains live after switching/deleting Bootstrap.
- P6: reboot clears VelaSU runtime and restores stock-only operation.

## Stop conditions

Reboot immediately if:
- the UI repeatedly restarts;
- touch becomes persistently unresponsive;
- Bluetooth disconnects together with repeated system restarts;
- ACTIVATE causes a reproducible reboot.

Do not repeat the failing activation until its firmware/profile result is reviewed.
