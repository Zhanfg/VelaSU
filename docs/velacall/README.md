# VelaCall v0

VelaCall is the broker interface between Quick Apps/Manager and VelaSU Core.

Initial operations:

- HELLO
- GET_VERSION
- GET_CAPABILITIES
- AUTH
- REQUEST_CAPABILITY
- PROBE_RUN
- PROBE_RESULT
- MODULE_LIST
- MODULE_CONTROL

Privileged filesystem, package, hook, and Bluetooth operations are added only after the bootstrap/identity chain is verified.

Every request carries a protocol version, caller identity handle, session token, operation, scope, and request id.
