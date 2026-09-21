local lvgl = require("lvgl")

local root = lvgl.Object(nil, {
  w = lvgl.HOR_RES(),
  h = lvgl.VER_RES(),
  bg_color = 0x080C12,
  border_width = 0,
})

root:clear_flag(lvgl.FLAG.SCROLLABLE)

local title = lvgl.Label(root, {
  text = "VelaSU",
  text_color = 0x5CFFB9,
  text_font = lvgl.Font("montserrat", 30, "normal"),
  align = { type = lvgl.ALIGN.TOP_MID, y_ofs = 90 },
})

local subtitle = lvgl.Label(root, {
  text = "SAFE BOOTSTRAP",
  text_color = 0x8391A5,
  text_font = lvgl.Font("montserrat", 18, "normal"),
  align = { type = lvgl.ALIGN.TOP_MID, y_ofs = 136 },
})

local status = lvgl.Label(root, {
  text = "Probe payload not installed",
  text_color = 0xE8EEF5,
  text_font = lvgl.Font("montserrat", 18, "normal"),
  align = lvgl.ALIGN.CENTER,
})

local note = lvgl.Label(root, {
  text = "No persistent modification",
  text_color = 0x607086,
  text_font = lvgl.Font("montserrat", 15, "normal"),
  align = { type = lvgl.ALIGN.BOTTOM_MID, y_ofs = -56 },
})
