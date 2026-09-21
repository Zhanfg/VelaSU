# Privilege Model

VelaSU uses capability-based authorization.

## Initial capability namespaces

- `fs.read`
- `fs.write.data`
- `fs.write.system`
- `package.query`
- `package.manage`
- `ui.inject`
- `app.hook`
- `service.hook`
- `sensor.raw`
- `bt.scan`
- `bt.gatt`
- `bt.classic`
- `bt.audio`
- `module.load`
- `module.control`
- `system.control`
- `boot.modify`
- `firmware.write`

Default policy is deny.

The Manager does not automatically receive `boot.modify` or `firmware.write`.

## Identity

A privileged request is evaluated against:
1. package/application identity;
2. expected package hash/signature when available;
3. an ephemeral session token;
4. the requested capability and scope;
5. current policy.

A universal long-lived SuperKey is intentionally not exposed to Quick Apps.
