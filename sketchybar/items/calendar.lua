local settings = require("settings")
local colors = require("colors")

-- Padding item required because of bracket
sbar.add("item", { position = "right", width = settings.group_paddings })

local M = {}

M.cal = sbar.add("item", {
	icon = {
		color = colors.white,
		padding_left = 6,
		font = {
			style = settings.font.style_map["Black"],
			size = 12.0,
		},
	},
	label = {
		color = colors.white,
		padding_right = 10,
		width = 80,
		align = "right",
		font = { family = settings.font.numbers },
	},
	position = "right",
	update_freq = 1,
	padding_left = 1,
	padding_right = 1,
	background = {
		color = colors.transparent,
		border_color = colors.black,
		border_width = 0,
	},
})

M.cal:subscribe({ "forced", "routine", "system_woke" }, function(_)
	local data = os.date("*t")
	local weekdays = { "日", "一", "二", "三", "四", "五", "六" }
	M.cal:set({
		label = {
			width = "dynamic",
			string = string.format(
				"%d月%d日 周%s %02d:%02d",
				data.month,
				data.day,
				weekdays[data.wday],
				data.hour,
				data.min
			),
		},
	})
end)

return M
