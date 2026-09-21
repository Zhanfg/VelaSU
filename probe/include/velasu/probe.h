#ifndef VELASU_PROBE_H
#define VELASU_PROBE_H

#include <stddef.h>
#include <stdint.h>

typedef enum {
    VELASU_PROBE_UNKNOWN = 0,
    VELASU_PROBE_UNAVAILABLE,
    VELASU_PROBE_AVAILABLE,
    VELASU_PROBE_BLOCKED
} velasu_probe_state_t;

typedef struct {
    const char *name;
    velasu_probe_state_t state;
    int32_t detail;
} velasu_probe_result_t;

size_t velasu_probe_static_matrix(velasu_probe_result_t *out, size_t capacity);

#endif
