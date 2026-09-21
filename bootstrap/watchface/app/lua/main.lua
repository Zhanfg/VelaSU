local lvgl = require("lvgl")

local MANAGER_APP_ID = "io.github.zhanfg.velasu.manager"
local MODULE_NAME = "velasu_probe"
local PROBE_DYN = "velasu_probe_dyn.elf"
local PROBE_REL = "velasu_probe_rel.elf"
local DST_DYN = "/data/velasu_probe_dyn.elf"
local DST_REL = "/data/velasu_probe_rel.elf"

local function read_first_line(path)
  local f = io.open(path, "r")
  if not f then return nil end
  local s = f:read("*l")
  f:close()
  return s
end

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

local function module_loaded()
  return shell_ok("lsmod 2>/dev/null | grep -q '^" .. MODULE_NAME .. "'")
end

local function try_load(src_name, dst, format_name)
  local src = SCRIPT_PATH .. src_name
  if not file_exists(src) then
    return false, "payload missing: " .. src_name
  end

  os.execute("rmmod " .. MODULE_NAME .. " >/dev/null 2>&1")
  if not shell_ok("cp '" .. src .. "' '" .. dst .. "'") then
    return false, "copy failed: " .. src_name
  end

  local rc = os.execute("insmod '" .. dst .. "' " .. MODULE_NAME .. " >/tmp/velasu_insmod 2>&1")
  if (rc == true or rc == 0) and module_loaded() then
    return true, format_name
  end

  local err = capture("cat /tmp/velasu_insmod", "insmod_err")
  return false, err ~= "" and err or ("insmod failed: " .. format_name)
end

local function detect_firmware()
  local raw = capture("getprop ro.build.version", "fw")
  return (raw:match("^%s*([%d._]+)") or "unknown"):gsub("%s+", "")
end

local function build_result(manager_dir, loaded, format_name, error_text)
  local proc_modules = file_exists("/proc/modules")
  local uorb = file_exists("/dev/uorb")
  local unionfs = shell_ok("grep -qi union /proc/filesystems 2>/dev/null")
  local tmpfs = shell_ok("grep -qi tmpfs /proc/filesystems 2>/dev/null")
  local mount_cmd = shell_ok("mount >/dev/null 2>&1")
  local lsmod_cmd = shell_ok("lsmod >/dev/null 2>&1")

  return "{" ..
    '"protocol":1,' ..
    '"firmware":"' .. json_escape(detect_firmware()) .. '",' ..
    '"native_loaded":' .. jbool(loaded) .. "," ..
    '"native_format":"' .. json_escape(format_name or "") .. '",' ..
    '"error":"' .. json_escape(error_text or "") .. '",' ..
    '"manager_bridge":' .. jbool(manager_dir ~= nil) .. "," ..
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

  local loaded, info = try_load(PROBE_DYN, DST_DYN, "ET_DYN")
  local format_name = loaded and info or ""
  local err = loaded and "" or tostring(info)

  if not loaded then
    local ok2, info2 = try_load(PROBE_REL, DST_REL, "ET_REL")
    loaded = ok2
    if loaded then
      format_name = info2
      err = ""
    else
      err = err .. " | " .. tostring(info2)
    end
  end

  local result = build_result(manager_dir, loaded, format_name, err)
  local out_path = manager_dir .. "/velasu_probe.json"

  if not write_text(out_path, result) then
    status:set({
      text = "Probe ran, but bridge write failed.",
      text_color = 0xFF9A9A,
    })
    return
  end

  if loaded then
    status:set({
      text = "Native probe ONLINE\n" .. format_name .. "\nReturn to Manager.",
      text_color = 0x8FF0A4,
    })
  else
    status:set({
      text = "Native load failed.\nResult sent to Manager.",
      text_color = 0xFF9A9A,
    })
  end
end)

lvgl.Label(root, {
  text = "Runtime only - reboot clears module",
  text_color = 0x607086,
  text_font = lvgl.Font("montserrat", 14, "normal"),
  align = { type = lvgl.ALIGN.BOTTOM_MID, y_ofs = -40 },
})
