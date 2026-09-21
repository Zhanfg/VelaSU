#include <stdint.h>

#define VELASU_PROBE_MAGIC UINT32_C(0x56535030)

static volatile uint32_t g_probe_magic = VELASU_PROBE_MAGIC;

__attribute__((used, visibility("default")))
int module_initialize(void)
{
    /* Deliberately side-effect free. Loading this module is the probe. */
    g_probe_magic = VELASU_PROBE_MAGIC;
    return 0;
}

__attribute__((used, visibility("default")))
void module_uninitialize(void)
{
    g_probe_magic = 0;
}
