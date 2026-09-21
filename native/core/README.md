# VelaSU Native Core

The first live transport is deliberately target-specific.

## Supported live target

- Xiaomi Smart Band 10 Pro CN
- firmware **3.101.043 only**
- ET_REL NuttX modlib profile
- Cortex-M33 / Thumb2 / soft-float

Other firmware versions are not guessed. The Lua Bootstrap detects the exact
firmware string and refuses to load this Core when it does not match.

## VelaCall v0 transport

The module installs a low-frequency LVGL timer and handles one minimal command:

`PING <nonce>\n` -> `PONG <nonce> <heartbeat>\n`

The Manager uses this response to prove that the native module is still alive
after the Bootstrap watchface is no longer active.

The v0 core is resident-until-reboot. Do not `rmmod velasu_core`; reboot is
the supported teardown path until an owner-thread timer teardown is implemented.
