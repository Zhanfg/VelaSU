# VelaSU Architecture v0.1

VelaSU is a privilege-broker and module framework for Xiaomi Vela/NuttX wearables. The first target is Xiaomi Smart Band 10 Pro CN.

## Design goals

1. Runtime privilege without requiring permanent boot modification.
2. Quick Apps remain unprivileged clients; privileged operations are brokered by a native core.
3. Capabilities are granted individually, not as a single global root bit.
4. Native modules and runtime hooks are isolated behind explicit provider APIs.
5. A normal software bug must not turn into an unrecoverable pre-Bluetooth boot failure.
6. Firmware ABI differences are first-class platform data.

## Layers

```text
Quick App / Manager
        |
     VelaCall
        |
+----------------------+
|      VelaSU Core     |
| auth | policy | audit|
+----------------------+
        |
   Provider Registry
  /       |        \
MetaFS  VelaHook  Radio/BT
  \       |        /
     Module Runtime
        |
 Xiaomi Vela / NuttX
```

## Privilege classes

- L0: Stock Quick App.
- L1: Brokered app. Can request named VelaSU capabilities.
- L2: Privileged native provider/core.
- L3: Runtime hook provider.
- L4: Native/system module.
- L5: Boot/firmware modification. **Out of scope until physical unbrick is verified.**

## Current phase

The bootstrap-probe phase is runtime-only:
- no bootloader changes;
- no firmware partition writes;
- no OTA/recovery changes;
- no early-boot autoload;
- no Bluetooth-init changes.

Success criterion: bootstrap -> native core/probe -> manager/bridge -> switch/delete installer watchface -> bridge still works -> reboot returns to stock state.
