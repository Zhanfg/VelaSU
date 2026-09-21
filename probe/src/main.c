#include <stdio.h>
#include "velasu/probe.h"

static const char *state_name(velasu_probe_state_t state) {
    switch (state) {
        case VELASU_PROBE_UNAVAILABLE: return "unavailable";
        case VELASU_PROBE_AVAILABLE: return "available";
        case VELASU_PROBE_BLOCKED: return "blocked";
        default: return "unknown";
    }
}

int main(void) {
    velasu_probe_result_t results[32];
    size_t total = velasu_probe_static_matrix(results, 32);
    size_t shown = total < 32 ? total : 32;

    puts("VelaSU capability probe skeleton");
    puts("No privileged operations are performed by this host build.");

    for (size_t i = 0; i < shown; ++i) {
        printf("%-28s %s\n", results[i].name, state_name(results[i].state));
    }
    return 0;
}
