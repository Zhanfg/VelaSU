# Module ABI v0 Draft

Two module classes are planned.

## VM: Vela Module

High-level module. Describes requested capabilities, UI/data hooks, overlays, and optional Quick App resources. It should not depend on raw firmware addresses.

## VNM: Vela Native Module

Native ELF module for providers, hardware backends, and advanced hooks. Loading a VNM requires `module.load`.

## Lifecycle

```c
int velasu_module_probe(const struct velasu_host_api *host);
int velasu_module_init(const struct velasu_host_api *host);
int velasu_module_control(uint32_t cmd, const void *in, void *out);
void velasu_module_exit(void);
```

## Compatibility

Modules request named ABI features, not hard-coded addresses. A platform resolver maps names to firmware-specific implementations. Missing required symbols cause a hard load refusal.
