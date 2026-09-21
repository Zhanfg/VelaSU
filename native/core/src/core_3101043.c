#include <stdint.h>
#include <stddef.h>
#include "runtime_abi.h"

#define BRIDGE_CONFIG "/data/velasu_bridge_path"
#define REQUEST_SUFFIX "/velasu_call_in.txt"
#define RESPONSE_SUFFIX "/velasu_call_out.txt"

#define BRIDGE_DIR_CAP 192
#define PATH_CAP 240
#define REQUEST_CAP 96
#define RESPONSE_CAP 128

static void *g_timer;
static char g_bridge_dir[BRIDGE_DIR_CAP];
static char g_request_path[PATH_CAP];
static char g_response_path[PATH_CAP];
static char g_last_request[REQUEST_CAP];
static int g_last_request_len;
static uint32_t g_heartbeat;
static int g_bridge_ready;

__attribute__((used))
static const char g_target_id[] = "xiaomi-band-10-pro-3.101.043";

static size_t vlen(const char *s)
{
    size_t n = 0;
    while (s && s[n]) n++;
    return n;
}

static int vcopy(char *dst, size_t cap, const char *src)
{
    size_t i = 0;
    if (!dst || !src || cap == 0) return 0;
    while (src[i]) {
        if (i + 1 >= cap) return 0;
        dst[i] = src[i];
        i++;
    }
    dst[i] = 0;
    return 1;
}

static int vappend(char *dst, size_t cap, const char *src)
{
    size_t d = vlen(dst);
    size_t i = 0;
    if (!src || d >= cap) return 0;
    while (src[i]) {
        if (d + i + 1 >= cap) return 0;
        dst[d + i] = src[i];
        i++;
    }
    dst[d + i] = 0;
    return 1;
}

static int vequal_n(const char *a, const char *b, int n)
{
    int i;
    for (i = 0; i < n; ++i) {
        if (a[i] != b[i]) return 0;
    }
    return 1;
}

static int read_small(const char *path, char *out, int cap)
{
    int fd;
    int n;
    if (!path || !out || cap < 2) return -1;
    fd = velasu_fw_open(path, VELASU_NUTTX_O_RDONLY);
    if (fd < 0) return -1;
    n = velasu_fw_read(fd, out, (uint32_t)(cap - 1));
    velasu_fw_close(fd);
    if (n < 0) return -1;
    if (n >= cap) n = cap - 1;
    out[n] = 0;
    return n;
}

static int write_small(const char *path, const char *data, int len)
{
    int fd;
    int n;
    if (!path || !data || len < 0) return -1;
    (void)velasu_fw_unlink(path);
    fd = velasu_fw_open(path, VELASU_NUTTX_O_WRONLY | VELASU_NUTTX_O_CREAT, 0600u);
    if (fd < 0) return -1;
    n = velasu_fw_write(fd, data, (uint32_t)len);
    if (velasu_fw_close(fd) != 0) return -1;
    return n == len ? 0 : -1;
}

static int load_bridge_paths(void)
{
    int n = read_small(BRIDGE_CONFIG, g_bridge_dir, BRIDGE_DIR_CAP);
    if (n <= 0) return 0;

    while (n > 0 &&
          (g_bridge_dir[n - 1] == '\n' ||
           g_bridge_dir[n - 1] == '\r' ||
           g_bridge_dir[n - 1] == '/')) {
        g_bridge_dir[--n] = 0;
    }

    if (n <= 0) return 0;
    if (!vcopy(g_request_path, PATH_CAP, g_bridge_dir)) return 0;
    if (!vappend(g_request_path, PATH_CAP, REQUEST_SUFFIX)) return 0;
    if (!vcopy(g_response_path, PATH_CAP, g_bridge_dir)) return 0;
    if (!vappend(g_response_path, PATH_CAP, RESPONSE_SUFFIX)) return 0;

    g_bridge_ready = 1;
    return 1;
}

static int parse_ping(const char *req, int len, const char **nonce, int *nonce_len)
{
    int i;
    if (!req || len < 6) return 0;
    if (!(req[0] == 'P' && req[1] == 'I' && req[2] == 'N' &&
          req[3] == 'G' && req[4] == ' ')) return 0;

    i = 5;
    while (i < len && req[i] >= '0' && req[i] <= '9') i++;
    if (i == 5) return 0;
    if (i < len && req[i] != '\n' && req[i] != '\r' && req[i] != 0) return 0;

    *nonce = &req[5];
    *nonce_len = i - 5;
    return 1;
}

static int append_u32(char *out, int pos, int cap, uint32_t value)
{
    char tmp[10];
    int n = 0;
    int i;
    do {
        tmp[n++] = (char)('0' + (value % 10u));
        value /= 10u;
    } while (value && n < (int)sizeof(tmp));

    for (i = n - 1; i >= 0; --i) {
        if (pos + 1 >= cap) return -1;
        out[pos++] = tmp[i];
    }
    return pos;
}

static void bridge_tick(void *timer)
{
    char req[REQUEST_CAP];
    char resp[RESPONSE_CAP];
    const char *nonce;
    int nonce_len;
    int n;
    int pos;
    int i;
    (void)timer;

    if (!g_bridge_ready && !load_bridge_paths()) return;

    n = read_small(g_request_path, req, REQUEST_CAP);
    if (n <= 0) return;

    if (n == g_last_request_len && vequal_n(req, g_last_request, n)) return;
    if (!parse_ping(req, n, &nonce, &nonce_len)) return;

    if (n < REQUEST_CAP) {
        for (i = 0; i < n; ++i) g_last_request[i] = req[i];
        g_last_request_len = n;
    }

    g_heartbeat++;

    pos = 0;
    resp[pos++] = 'P'; resp[pos++] = 'O'; resp[pos++] = 'N'; resp[pos++] = 'G'; resp[pos++] = ' ';
    for (i = 0; i < nonce_len; ++i) {
        if (pos + 1 >= RESPONSE_CAP) return;
        resp[pos++] = nonce[i];
    }
    if (pos + 2 >= RESPONSE_CAP) return;
    resp[pos++] = ' ';
    pos = append_u32(resp, pos, RESPONSE_CAP, g_heartbeat);
    if (pos < 0 || pos + 2 >= RESPONSE_CAP) return;
    resp[pos++] = '\n';
    resp[pos] = 0;

    (void)write_small(g_response_path, resp, pos);
}

__attribute__((constructor, used))
int module_initialize(void)
{
    g_timer = velasu_fw_timer_create(bridge_tick, 1500u, 0);
    return g_timer ? 0 : -1;
}

/*
 * This v0 transport is resident-until-reboot. VelaSU never calls rmmod on it.
 * A future supervisor will provide an owner-thread teardown path before
 * unload is enabled.
 */
__attribute__((destructor, used))
static void module_uninitialize(void)
{
    /*
     * Intentionally do not touch LVGL here: rmmod executes in the shell
     * context, while LVGL teardown belongs to the UI owner thread.
     */
}
