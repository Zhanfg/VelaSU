local lvgl = require("lvgl")

local MANAGER_APP_ID = "io.github.zhanfg.velasu.manager"
local PROBE_MODULE = "velasu_probe"
local CORE_MODULE = "velasu_core"

local PROBE_DYN = "velasu_probe_dyn.elf"
local PROBE_REL = "velasu_probe_rel.elf"
local CORE_3101043 = "velasu_core_3.101.043.elf"

local DST_DYN = "/data/velasu_probe_dyn.elf"
local DST_REL = "/data/velasu_probe_rel.elf"
local DST_CORE = "/data/velasu_core_3.101.043.elf"
local BRIDGE_CONFIG = "/data/velasu_bridge_path"

local function file_exists(path)
  local f = io.open(path, "rb")
  if not f then return false end
  f:close()
  return true
end

local function write_text(path, text)
  local f = io.open(path, "w")
  if not f then return false end
  f:write(text)
  f:close()
  return true
end

local function shell_ok(cmd)
  local rc = os.execute(cmd)
  return rc == true or rc == 0
end

local function capture(cmd, tag)
  local path = "/tmp/velasu_" .. tostring(tag or "capture")
  os.execute(cmd .. " > " .. path .. " 2>/dev/null")
  local f = io.open(path, "r")
  if not f then return "" end
  local data = f:read("*a") or ""
  f:close()
  os.remove(path)
  return data
end

local function json_escape(s)
  s = tostring(s or "")
  s = s:gsub("\\", "\\\\")
       :gsub('"', '\\"')
       :gsub("\r", "\\r")
       :gsub("\n", "\\n")
  return s
end

local function jbool(v)
  return v and "true" or "false"
end

local function find_manager_dir()
  local list = "/tmp/velasu_manager_dirs"
  os.execute("find /data -type d -name '" .. MANAGER_APP_ID .. "' 2>/dev/null > " .. list)
  local f = io.open(list, "r")
  if not f then return nil end

  for dir in f:lines() do
    if file_exists(dir .. "/velasu_manager.marker") then
      f:close()
      os.remove(list)
      return dir
    end
  end

  f:close()
  os.remove(list)
  return nil
end

local function module_loaded(name)
  return shell_ok("lsmod 2>/dev/null | grep -q '^" .. name .. "'")
end

local function try_probe(src_name, dst, format_name)
  local src = SCRIPT_PATH .. src_name
  if not file_exists(src) then
    return false, "payload missing: " .. src_name
  end

  os.execute("rmmod " .. PROBE_MODULE .. " >/dev/null 2>&1")
  if not shell_ok("cp '" .. src .. "' '" .. dst .. "'") then
    return false, "copy failed: " .. src_name
  end

  local rc = os.execute("insmod '" .. dst .. "' " .. PROBE_MODULE .. " >/tmp/velasu_insmod 2>&1")
  if (rc == true or rc == 0) and module_loaded(PROBE_MODULE) then
    return true, format_name
  end

  local err = capture("cat /tmp/velasu_insmod", "insmod_err")
  return false, err ~= "" and err or ("insmod failed: " .. format_name)
end

local function detect_firmware()
  local raw = capture("getprop ro.build.version", "fw")
  return (raw:match("^%s*([%d._]+)") or "unknown"):gsub("%s+", "")
end

local function load_live_core(manager_dir, fw)
  if not write_text(BRIDGE_CONFIG, manager_dir) then
    return false, "failed to write bridge config"
  end

  if module_loaded(CORE_MODULE) then
    return true, "already loaded"
  end

  if fw ~= "3.101.043" then
    return false, "unsupported live-core firmware: " .. tostring(fw)
  end

  local src = SCRIPT_PATH .. CORE_3101043
  if not file_exists(src) then
    return false, "core payload missing"
  end

  if not shell_ok("cp '" .. src .. "' '" .. DST_CORE .. "'") then
    return false, "failed to copy live core"
  end

  local rc = os.execute("insmod '" .. DST_CORE .. "' " .. CORE_MODULE .. " >/tmp/velasu_core_insmod 2>&1")
  if (rc == true or rc == 0) and module_loaded(CORE_MODULE) then
    return true, "3.101.043"
  end

  local err = capture("cat /tmp/velasu_core_insmod", "core_err")
  return false, err ~= "" and err or "live core insmod failed"
end

local function build_result(manager_dir, fw, loaded, format_name, error_text, live_bridge, core_info)
  local proc_modules = file_exists("/proc/modules")
  local uorb = file_exists("/dev/uorb")
  local unionfs = shell_ok("grep -qi union /proc/filesystems 2>/dev/null")
  local tmpfs = shell_ok("grep -qi tmpfs /proc/filesystems 2>/dev/null")
  local mount_cmd = shell_ok("mount >/dev/null 2>&1")
  local lsmod_cmd = shell_ok("lsmod >/dev/null 2>&1")

  return "{" ..
    '"protocol":1,' ..
    '"firmware":"' .. json_escape(fw) .. '",' ..
    '"native_loaded":' .. jbool(loaded) .. "," ..
    '"native_format":"' .. json_escape(format_name or "") .. '",' ..
    '"error":"' .. json_escape(error_text or "") .. '",' ..
    '"manager_bridge":' .. jbool(manager_dir ~= nil) .. "," ..
    '"live_bridge":' .. jbool(live_bridge) .. "," ..
    '"core_target":"' .. json_escape(core_info or "") .. '",' ..
    '"capabilities":{' ..
      '"elf.module_loader":' .. jbool(lsmod_cmd) .. "," ..
      '"proc.modules":' .. jbool(proc_modules) .. "," ..
      '"fs.mount":' .. jbool(mount_cmd) .. "," ..
      '"fs.unionfs":' .. jbool(unionfs) .. "," ..
      '"fs.tmpfs":' .. jbool(tmpfs) .. "," ..
      '"sensor.uorb":' .. jbool(uorb) ..
    "}" ..
  "}"
end

local root = lvgl.Object(nil, {
  w = lvgl.HOR_RES(),
  h = lvgl.VER_RES(),
  bg_color = 0x080C12,
  border_width = 0,
})
root:clear_flag(lvgl.FLAG.SCROLLABLE)

lvgl.Label(root, {
  text = "VelaSU",
  text_color = 0x5CFFB9,
  text_font = lvgl.Font("montserrat", 30, "normal"),
  align = { type = lvgl.ALIGN.TOP_MID, y_ofs = 66 },
})

lvgl.Label(root, {
  text = "RUNTIME PROBE",
  text_color = 0x8391A5,
  text_font = lvgl.Font("montserrat", 17, "normal"),
  align = { type = lvgl.ALIGN.TOP_MID, y_ofs = 108 },
})

local status = lvgl.Label(root, {
  text = "Open VelaSU Manager once,\nthen tap ACTIVATE.",
  text_color = 0xE8EEF5,
  width = 300,
  text_font = lvgl.Font("montserrat", 17, "normal"),
  align = { type = lvgl.ALIGN.CENTER, y_ofs = -18 },
})

local button = lvgl.Object(root, {
  w = 250,
  h = 66,
  radius = 20,
  bg_color = 0x133A31,
  border_width = 1,
  border_color = 0x5CFFB9,
  align = { type = lvgl.ALIGN.CENTER, y_ofs = 82 },
})
button:clear_flag(lvgl.FLAG.SCROLLABLE)
button:add_flag(lvgl.FLAG.CLICKABLE)

lvgl.Label(button, {
  text = "ACTIVATE",
  text_color = 0xFFFFFF,
  text_font = lvgl.Font("montserrat", 20, "normal"),
  align = lvgl.ALIGN.CENTER,
})

button:onevent(lvgl.EVENT.CLICKED, function()
  status:set({ text = "Locating Manager sandbox..." })

  local manager_dir = find_manager_dir()
  if not manager_dir then
    status:set({
      text = "Manager sandbox not found.\nOpen Manager once first.",
      text_color = 0xFF9A9A,
    })
    return
  end

  status:set({ text = "Loading native probe..." })

  local loaded, info = try_probe(PROBE_REL, DST_REL, "ET_REL")
  local format_name = loaded and info or ""
  local err = loaded and "" or tostring(info)

  if not loaded then
    local ok2, info2 = try_probe(PROBE_DYN, DST_DYN, "ET_DYN")
    loaded = ok2
    if loaded then
      format_name = info2
      err = ""
    else
      err = err .. " | " .. tostring(info2)
    end
  end

  local fw = detect_firmware()
  local live_bridge = false
  local core_info = ""

  if loaded then
    live_bridge, core_info = load_live_core(manager_dir, fw)
  else
    core_info = "probe loader failed; core not attempted"
  end

  local result = build_result(
    manager_dir, fw, loaded, format_name, err, live_bridge, core_info
  )

  if not write_text(manager_dir .. "/velasu_probe.json", result) then
    status:set({
      text = "Probe ran, but bridge write failed.",
      text_color = 0xFF9A9A,
    })
    return
  end

  if live_bridge then
    status:set({
      text = "LIVE BRIDGE STARTED\n" .. fw .. "\nReturn to Manager.",
      text_color = 0x8FF0A4,
    })
  elseif loaded then
    status:set({
      text = "Probe ONLINE\nLive bridge unavailable:\n" .. tostring(core_info),
      text_color = 0xFFD27A,
    })
  else
    status:set({
      text = "Native load failed.\nResult sent to Manager.",
      text_color = 0xFF9A9A,
    })
  end
end)

lvgl.Label(root, {
  text = "Runtime only - reboot clears modules",
  text_color = 0x607086,
  text_font = lvgl.Font("montserrat", 14, "normal"),
  align = { type = lvgl.ALIGN.BOTTOM_MID, y_ofs = -40 },
})
