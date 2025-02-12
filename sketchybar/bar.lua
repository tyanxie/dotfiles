local colors = require("colors")

-- Equivalent to the --bar domain
sbar.bar({
	topmost = "window",
	height = 35,
	notch_display_height = 33,
	color = colors.bar.bg,
	blur_radius = 20,
	padding_right = 5,
	padding_left = 5,
})
