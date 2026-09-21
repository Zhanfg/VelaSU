# Xiaomi Smart Band 10 Pro CN platform profile

Status: research / unverified ABI profile.

Known device context from the current project work:
- target family: Xiaomi Smart Band 10 Pro;
- region: CN;
- watchface canvas: 336x480;
- runtime/native ABI must be fingerprinted per firmware before loading hooks.

No raw function addresses belong in shared module code. Firmware-specific addresses/signatures, once verified, live in versioned symbol profiles under this directory.
