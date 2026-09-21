# Recovery and Zero-Brick Boundary

Until a Xiaomi Smart Band 10 Pro physical recovery path is independently verified, VelaSU treats loss of Bluetooth before the stock system finishes booting as an unacceptable failure mode.

## Forbidden in bootstrap-probe

- bootloader modification;
- early startup modification;
- firmware/system partition overwrite;
- OTA/recovery patching;
- Bluetooth initialization patching;
- automatic native module loading before stock UI/Bluetooth are healthy.

## Failure classes

- B0: plugin failure; disable plugin.
- B1: VelaSU core/UI failure; reboot clears runtime state.
- B2: NuttX/Bluetooth alive; recover through Manager/BLE rescue.
- B3: system fails before Bluetooth; requires a physical recovery path. Bootstrap-probe must never intentionally enter this class.

## Later persistent-loader requirements

A future persistent loader must implement:
- ABI validation;
- core signature/hash validation;
- staged activation;
- crash counter;
- one-failure temporary disable;
- repeated-failure safe mode;
- previous-known-good rollback;
- no third-party modules before health confirmation.
