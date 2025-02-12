-- 使用bracket将多个组件组合在一起
local battery = require("items.widgets.battery")
local volume = require("items.widgets.volume")
local cpu = require("items.widgets.cpu")
local wifi = require("items.widgets.wifi")
local spaces = require("items.spaces")
local apple = require("items.apple")
local calendar = require("items.calendar")
local apps = require("items.widgets.apps")

local colors = require("colors")

sbar.add("bracket", {
	apple.apple.name,
	spaces[1].name,
	spaces[2].name,
	spaces[3].name,
	spaces[4].name,
	spaces[5].name,
	spaces[6].name,
	spaces[7].name,
	spaces[8].name,
	spaces[9].name,
	spaces[10].name,
}, {
	background = {
		color = colors.bg3,
		border_color = colors.bg3,
		border_width = 1,
		height = 30,
		corner_radius = 10,
		padding_right = 200,
	},
})

sbar.add("bracket", {
	cpu.cpu.name,
	wifi.wifi.name,
	wifi.wifi_up.name,
	wifi.wifi_down.name,
	volume.volume_icon.name,
	volume.volume_percent.name,
	apps.wechat.name,
	apps.qq.name,
	calendar.cal.name,
	battery.battery.name,
}, {
	background = {
		color = colors.bg3,
		border_color = colors.bg3,
		border_width = 1,
		height = 30,
		corner_radius = 10,
	},
})

sbar.add("bracket", {
	volume.volume_icon.name,
	volume.volume_percent.name,
	apps.wechat.name,
	apps.qq.name,
	calendar.cal.name,
}, { background = {
	color = 0x90494d64,
	height = 25,
} })
