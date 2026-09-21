#include "velasu/probe.h"

size_t velasu_probe_static_matrix(velasu_probe_result_t *out, size_t capacity) {
    static const char *items[] = {
        "nuttx.build_mode", "memory.protection", "quickapp.isolation",
        "elf.module_loader", "elf.cross_module_symbols", "fs.mount",
        "fs.unionfs", "fs.tmpfs", "fs.data_persistence",
        "xiaomi.package_api", "xiaomi.lvgl_api", "quickjs.native_bridge",
        "sensor.uorb", "bt.ble_raw", "bt.classic", "bt.gatt",
        "bt.l2cap", "boot.late_hook"
    };

    size_t count = sizeof(items) / sizeof(items[0]);
    if (!out || capacity == 0) {
        return count;
    }

    size_t n = capacity < count ? capacity : count;
    for (size_t i = 0; i < n; ++i) {
        out[i].name = items[i];
        out[i].state = VELASU_PROBE_UNKNOWN;
        out[i].detail = 0;
    }
    return count;
}
