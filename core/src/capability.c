#include "velasu/capability.h"

const char *velasu_capability_name(velasu_capability_t cap) {
    static const char *names[] = {
        "none", "fs.read", "fs.write.data", "fs.write.system",
        "package.query", "package.manage", "ui.inject", "app.hook",
        "service.hook", "sensor.raw", "bt.scan", "bt.gatt",
        "bt.classic", "bt.audio", "module.load", "module.control",
        "system.control", "boot.modify", "firmware.write"
    };

    unsigned int i = (unsigned int)cap;
    if (i >= (sizeof(names) / sizeof(names[0]))) {
        return "unknown";
    }
    return names[i];
}

int velasu_capability_is_dangerous(velasu_capability_t cap) {
    switch (cap) {
        case VELASU_CAP_FS_WRITE_SYSTEM:
        case VELASU_CAP_APP_HOOK:
        case VELASU_CAP_SERVICE_HOOK:
        case VELASU_CAP_MODULE_LOAD:
        case VELASU_CAP_SYSTEM_CONTROL:
        case VELASU_CAP_BOOT_MODIFY:
        case VELASU_CAP_FIRMWARE_WRITE:
            return 1;
        default:
            return 0;
    }
}
