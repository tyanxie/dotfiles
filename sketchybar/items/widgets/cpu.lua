local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

-- Execute the event provider binary which provides the event "cpu_update" for
-- the cpu load data, which is fired every 2.0 seconds.
sbar.exec("killall cpu_load >/dev/null; $CONFIG_DIR/helpers/event_providers/cpu_load/bin/cpu_load cpu_update 2.0")

local M = {}

M.cpu = sbar.add("graph", "widgets.cpu", 42, {
	position = "right",
	graph = { color = colors.blue },
	background = {
		height = 22,
		color = { alpha = 0 },
		border_color = { alpha = 0 },
		drawing = true,
	},
	icon = { string = icons.cpu },
	label = {
		string = icons.percent._0 .. "  ??%",
		font = {
			family = settings.font.numbers,
			style = settings.font.style_map["Bold"],
			size = 9.0,
		},
		align = "right",
		padding_right = 0,
		width = 0,
		y_offset = 4,
	},
	padding_right = -6,
})

M.cpu:subscribe("cpu_update", function(env)
	-- Also available: env.user_load, env.sys_load
	local load = tonumber(env.total_load)
	M.cpu:push({ load / 100. })

	local label_icon = icons.percent._0
	if load > 80 then
		label_icon = icons.percent._100
	elseif load > 75 then
		label_icon = icons.percent._75
	elseif load > 50 then
		label_icon = icons.percent._50
	elseif load > 25 then
		label_icon = icons.percent._25
	else
		label_icon = icons.percent._0
	end

	local color = colors.blue
	if load > 30 then
		if load < 60 then
			color = colors.yellow
		elseif load < 80 then
			color = colors.orange
		else
			color = colors.red
		end
	end

	M.cpu:set({
		graph = { color = color },
		label = label_icon .. "  " .. env.total_load .. "%",
	})
end)

M.cpu:subscribe("mouse.clicked", function(_)
	sbar.exec("open -a 'Activity Monitor'")
end)

sbar.add("item", "widgets.cpu.padding", {
	position = "right",
	width = settings.group_paddings,
})

return M
