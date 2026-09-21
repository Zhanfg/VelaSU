# VelaSU

Experimental privilege, module, recovery, and system-extension framework for Xiaomi Vela / NuttX wearables.

> **Safety status:** early research. The current development phase is intentionally runtime-only and must not modify the bootloader, firmware partitions, early boot path, OTA/recovery path, or Bluetooth initialization path.

Initial hardware target: **Xiaomi Smart Band 10 Pro (CN)**.

Development starts on `dev/bootstrap-probe`. `main` is kept minimal until the runtime bootstrap/probe chain is validated on-device.
