-- 初始化wezterm配置
local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- 主题
-- 定义浅色与深色主题
local color_scheme_light = "Catppuccin Latte"
local color_scheme_dark = "Catppuccin Mocha"
-- 获取颜色主题的函数
local function scheme_for_appearance()
	-- 尝试判断系统当前是否是深色主题，如果是则使用深色主题
	if wezterm.gui then
		if wezterm.gui.get_appearance():find("Dark") then
			return color_scheme_dark
		end
	end
	-- 默认使用浅色主题
	return color_scheme_light
end
-- 设置颜色主题
config.color_scheme = scheme_for_appearance()

-- 字体
config.font = wezterm.font("Maple Mono NF CN", { weight = "DemiBold" })
config.font_size = 18

-- 每秒绘制的最大帧数
config.max_fps = 60
-- 闪烁等动画效果的最大帧数
config.animation_fps = 60
-- 渲染前端
config.front_end = "WebGpu"
-- 渲染前端为WebGpu时的功率偏好
config.webgpu_power_preference = "HighPerformance"

-- 窗口打开时的默认大小
config.initial_cols = 135
config.initial_rows = 35
-- 窗口padding
config.window_padding = {
	left = 20,
	right = 20,
	top = 20,
	bottom = 5,
}

-- tab栏配置
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.show_new_tab_button_in_tab_bar = false
-- 关闭窗口的提示：NerverPrompot代表用不提示
config.window_close_confirmation = "NeverPrompt"
-- 顶部标题栏设置
config.window_decorations = "RESIZE"
-- 默认光标风格
config.default_cursor_style = "SteadyBlock"

-- 是否开启背景图片，为ture的时候使用背景图片配置，false时使用透明背景模糊模式
-- TODO: 后续可以联动neovim配置做成环境变量进行一键切换
local enableBackgroundImage = false
if enableBackgroundImage then
	-- 使用背景图片模式
	-- 文字背景透明度
	-- 在Neovim中相当于colorscheme相对于wezterm背景图的不透明度
	config.text_background_opacity = 0.8
	-- 背景图片，配置参考：https://www.bilibili.com/video/BV1miWMe9Esq
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
else
	-- 使用透明背景模糊模式
	-- 窗口背景不透明度
	config.window_background_opacity = 0.75
	-- macOS下窗口背景模糊
	config.macos_window_background_blur = 20
end

-- 蜂鸣提示音
config.audible_bell = "Disabled"

-- 快捷键配置
config.keys = {
	-- <C-N>键触发全屏
	-- 配合配置native_macos_fullscreen_mode的默认值false可以做到使用全屏时使用macOS传统的全屏转换，使得全屏时也能看到背景模糊效果
	{
		key = "n",
		mods = "SHIFT|CTRL",
		action = wezterm.action.ToggleFullScreen,
	},
}

return config
