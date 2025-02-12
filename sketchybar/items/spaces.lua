local colors = require("colors")
local settings = require("settings")
local app_icons = require("helpers.app_icons")

-- 最左侧添加padding
sbar.add("item", {
	icon = {
		drawing = false,
	},
	label = {
		drawing = false,
	},
	background = {
		drawing = false,
	},
	padding_left = 6,
	padding_right = 0,
})

-- 空间列表
local spaces = {}

for i = 1, 10, 1 do
	-- 创建空间item
	local space = sbar.add("space", "space." .. i, {
		space = i,
		icon = {
			font = { family = settings.font.numbers },
			string = i,
			padding_left = 10,
			padding_right = 5,
			color = colors.white,
			highlight_color = colors.space_icon_highlight_color,
		},
		label = {
			padding_right = 10,
			highlight_color = colors.space_label_color,
			font = "sketchybar-app-font:Regular:16.0",
			y_offset = -1,
		},
		padding_right = 2,
		padding_left = 2,
		background = {
			color = colors.transparent, -- color必须设置，否则border不会显示，这里设置为透明以防止和bracket颜色重叠
			border_width = 0,
			height = 28,
			border_color = colors.space_border_color,
		},
	})

	-- 写入空间item
	spaces[i] = space

	-- 空间切换时触发事件
	space:subscribe("space_change", function(env)
		-- 判断当前空间是否是被选中的空间
		local selected = env.SELECTED == "true"
		-- 设置空间状态，被选中的空间则高亮
		sbar.animate("circ", 15, function()
			space:set({
				icon = { highlight = selected },
				label = { highlight = selected },
				background = {
					border_width = selected and 1 or 0,
				},
				blur_radius = 20,
			})
		end)
	end)
end

-- 空间窗口观察者
local space_window_observer = sbar.add("item", {
	drawing = false,
	updates = true,
})

-- 在当前空间窗口变化时更新窗口icon列表
space_window_observer:subscribe("space_windows_change", function(env)
	local icon_line = ""
	local no_app = true
	for app, _ in pairs(env.INFO.apps) do
		no_app = false
		local lookup = app_icons[app]
		local icon = ((lookup == nil) and app_icons["Default"] or lookup)
		icon_line = icon_line .. icon
	end

	if no_app then
		icon_line = " —"
	end
	sbar.animate("tanh", 10, function()
		spaces[env.INFO.space]:set({ label = icon_line })
	end)
end)

return spaces
