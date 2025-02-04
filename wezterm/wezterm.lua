-- 初始化wezterm配置
local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- 字体
config.font = wezterm.font("Maple Mono NF CN", { weight = "DemiBold" })
config.font_size = 18

-- 窗口打开时的默认大小
config.initial_cols = 135
config.initial_rows = 35

-- tab栏配置
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.show_new_tab_button_in_tab_bar = false
-- 关闭窗口的提示：NerverPrompot代表用不提示
config.window_close_confirmation = "NeverPrompt"
-- 顶部状态栏设置
config.window_decorations = "TITLE | RESIZE"
-- 默认光标风格
config.default_cursor_style = "SteadyBlock"

-- macOS下窗口背景模糊
config.macos_window_background_blur = 70
-- 文字背景透明度
-- 在Neovim中相当于colorscheme相对于wezterm背景图的不透明度
config.text_background_opacity = 0.8

-- 背景，配置参考：https://www.bilibili.com/video/BV1miWMe9Esq?vd_source=66989d6205583753c78874fada7f0721
config.background = {
	-- 背景图片
	{
		source = {
			File = wezterm.config_dir .. "/background.jpg",
		},
		hsb = {
			-- 色相
			hue = 1.0,
			-- 饱和度
			saturation = 1.02,
			-- 亮度
			brightness = 0.25,
		},
	},
	-- 为背景图片覆盖一层蒙版，防止过亮
	{
		source = {
			Color = "#282c35",
		},
		width = "100%",
		height = "100%",
		opacity = 0.55,
	},
}

-- 窗口padding
config.window_padding = {
	left = 20,
	right = 20,
	top = 20,
	bottom = 5,
}

return config
