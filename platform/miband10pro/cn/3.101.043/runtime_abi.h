#ifndef VELASU_MB10P_CN_3101043_RUNTIME_ABI_H
#define VELASU_MB10P_CN_3101043_RUNTIME_ABI_H

#include <stdint.h>
#include <stddef.h>

/*
 * Exact-target runtime ABI for Xiaomi Smart Band 10 Pro CN firmware 3.101.043.
 *
 * Address provenance:
 *   AstralSightStudios/Canopus target xiaomi-band-10-pro-3.101.043
 *   firmware SHA-256:
 *   519307675665e4866d722a8119a98589c397b614ac3294cb87bfc86de45756ec
 *
 * These are factual firmware addresses, not a stable API. Never use this
 * profile when the runtime firmware version does not match exactly.
 */

#define VELASU_FW_3101043_OPEN            ((uintptr_t)0x0C1D0A29u)
#define VELASU_FW_3101043_CLOSE           ((uintptr_t)0x0C1B9D81u)
#define VELASU_FW_3101043_READ            ((uintptr_t)0x0C1D129Du)
#define VELASU_FW_3101043_WRITE           ((uintptr_t)0x0C1D2641u)
#define VELASU_FW_3101043_UNLINK          ((uintptr_t)0x0C1D2355u)
#define VELASU_FW_3101043_LV_TIMER_CREATE ((uintptr_t)0x0C587ED1u)
#define VELASU_FW_3101043_LV_TIMER_DEL    ((uintptr_t)0x0C588129u)

#define VELASU_NUTTX_O_RDONLY 1
#define VELASU_NUTTX_O_WRONLY 2
#define VELASU_NUTTX_O_CREAT  4

typedef int (*velasu_open_fn)(const char *path, int flags, ...);
typedef int (*velasu_close_fn)(int fd);
typedef int (*velasu_read_fn)(int fd, void *buffer, uint32_t count);
typedef int (*velasu_write_fn)(int fd, const void *buffer, uint32_t count);
typedef int (*velasu_unlink_fn)(const char *path);
typedef void (*velasu_timer_cb)(void *timer);
typedef void *(*velasu_timer_create_fn)(velasu_timer_cb callback, uint32_t period_ms, void *user_data);
typedef void (*velasu_timer_del_fn)(void *timer);

#define velasu_fw_open   ((velasu_open_fn)VELASU_FW_3101043_OPEN)
#define velasu_fw_close   ((velasu_close_fn)VELASU_FW_3101043_CLOSE)
#define velasu_fw_read   ((velasu_read_fn)VELASU_FW_3101043_READ)
#define velasu_fw_write   ((velasu_write_fn)VELASU_FW_3101043_WRITE)
#define velasu_fw_unlink   ((velasu_unlink_fn)VELASU_FW_3101043_UNLINK)
#define velasu_fw_timer_create   ((velasu_timer_create_fn)VELASU_FW_3101043_LV_TIMER_CREATE)
#define velasu_fw_timer_del   ((velasu_timer_del_fn)VELASU_FW_3101043_LV_TIMER_DEL)

#endif
