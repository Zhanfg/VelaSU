#ifndef VELASU_CAPABILITY_H
#define VELASU_CAPABILITY_H

#include <stdint.h>

typedef enum {
    VELASU_CAP_NONE = 0,
    VELASU_CAP_FS_READ,
    VELASU_CAP_FS_WRITE_DATA,
    VELASU_CAP_FS_WRITE_SYSTEM,
    VELASU_CAP_PACKAGE_QUERY,
    VELASU_CAP_PACKAGE_MANAGE,
    VELASU_CAP_UI_INJECT,
    VELASU_CAP_APP_HOOK,
    VELASU_CAP_SERVICE_HOOK,
    VELASU_CAP_SENSOR_RAW,
    VELASU_CAP_BT_SCAN,
    VELASU_CAP_BT_GATT,
    VELASU_CAP_BT_CLASSIC,
    VELASU_CAP_BT_AUDIO,
    VELASU_CAP_MODULE_LOAD,
    VELASU_CAP_MODULE_CONTROL,
    VELASU_CAP_SYSTEM_CONTROL,
    VELASU_CAP_BOOT_MODIFY,
    VELASU_CAP_FIRMWARE_WRITE
} velasu_capability_t;

const char *velasu_capability_name(velasu_capability_t cap);
int velasu_capability_is_dangerous(velasu_capability_t cap);

#endif
