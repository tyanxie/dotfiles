return {
	black = 0xff181819,
	white = 0xffe2e2e3,
	red = 0xfffc5d7c,
	green = 0xff9ed072,
	blue = 0xff76cce0,
	yellow = 0xffe7c664,
	orange = 0xfff39660,
	magenta = 0xffb39df3,
	grey = 0xff7f8490,
	transparent = 0x00000000,

	space_label_color = 0xffe2e2e3,
	space_border_color = 0xff181819,
	space_label_highlight_color = 0xff9ed072,
	space_icon_highlight_color = 0xffe7c664,
	front_app_color = 0xff181819,

	bar = {
		bg = 0xBFffff,
		border = 0x66494d64,
	},
	popup = {
		bg = 0xc02c2e34,
		border = 0xff7f8490,
	},
	bg1 = 0xff363944,
	bg2 = 0xff414550,
	bg3 = 0x99363944,
	transparency = 0.5,
	blur_radius = 20,

	with_alpha = function(color, alpha)
		if alpha > 1.0 or alpha < 0.0 then
			return color
		end
		return (color & 0x00ffffff) | (math.floor(alpha * 255.0) << 24)
	end,
}
