local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local popup_width = 250

local M = {}

M.volume_percent = sbar.add("item", "widgets.volume1", {
	position = "right",
	icon = { drawing = false },
	label = {
		string = "??%",
		padding_left = -1,
		font = { family = settings.font.numbers },
	},
})

M.volume_icon = sbar.add("item", "widgets.volume2", {
	position = "right",
	padding_right = -1,
	icon = {
		string = icons.volume._100,
		width = 0,
		align = "left",
		color = colors.grey,
		font = {
			style = settings.font.style_map["Regular"],
			size = 14.0,
		},
	},
	label = {
		width = 25,
		align = "left",
		font = {
			style = settings.font.style_map["Regular"],
			size = 14.0,
		},
	},
})

M.volume_bracket = sbar.add("bracket", "widgets.volume.bracket", {
	M.volume_icon.name,
	M.volume_percent.name,
}, {
	popup = { align = "center" },
})

sbar.add("item", "widgets.volume.padding", {
	position = "right",
	width = settings.group_paddings,
})

M.volume_slider = sbar.add("slider", popup_width, {
	position = "popup." .. M.volume_bracket.name,
	slider = {
		highlight_color = colors.blue,
		background = {
			height = 6,
			corner_radius = 3,
			color = colors.bg2,
		},
		knob = {
			string = "􀀁",
			drawing = true,
		},
	},
	background = { color = colors.bg1, height = 2, y_offset = -20 },
	click_script = 'osascript -e "set volume output volume $PERCENTAGE"',
})

M.volume_percent:subscribe("volume_change", function(env)
	local volume = tonumber(env.INFO)
	local icon = icons.volume._0
	if volume > 60 then
		icon = icons.volume._100
	elseif volume > 30 then
		icon = icons.volume._66
	elseif volume > 10 then
		icon = icons.volume._33
	elseif volume > 0 then
		icon = icons.volume._10
	end

	local lead = ""
	if volume < 10 then
		lead = "0"
	end

	M.volume_icon:set({ label = icon })
	M.volume_percent:set({ label = lead .. volume .. "%" })
	M.volume_slider:set({ slider = { percentage = volume } })
end)

local function volume_collapse_details()
	local drawing = M.volume_bracket:query().popup.drawing == "on"
	if not drawing then
		return
	end
	M.volume_bracket:set({ popup = { drawing = false } })
	sbar.remove("/volume.device\\.*/")
end

local current_audio_device = "None"
local function volume_toggle_details(env)
	if env.BUTTON == "right" then
		sbar.exec("open /System/Library/PreferencePanes/Sound.prefpane")
		return
	end

	local should_draw = M.volume_bracket:query().popup.drawing == "off"
	if should_draw then
		M.volume_bracket:set({ popup = { drawing = true } })
		sbar.exec("SwitchAudioSource -t output -c", function(result)
			current_audio_device = result:sub(1, -2)
			sbar.exec("SwitchAudioSource -a -t output", function(available)
				local current = current_audio_device
				local color = colors.grey
				local counter = 0

				for device in string.gmatch(available, "[^\r\n]+") do
					color = colors.grey
					if current == device then
						color = colors.white
					end
					sbar.add("item", "volume.device." .. counter, {
						position = "popup." .. M.volume_bracket.name,
						width = popup_width,
						align = "center",
						label = { string = device, color = color },
						click_script = 'SwitchAudioSource -s "'
							.. device
							.. '" && sketchybar --set /volume.device\\.*/ label.color='
							.. colors.grey
							.. " --set $NAME label.color="
							.. colors.white,
					})
					counter = counter + 1
				end
			end)
		end)
	else
		volume_collapse_details()
	end
end

local function volume_scroll(env)
	local delta = env.INFO.delta
	if not (env.INFO.modifier == "ctrl") then
		delta = delta * 10.0
	end

	sbar.exec('osascript -e "set volume output volume (output volume of (get volume settings) + ' .. delta .. ')"')
end

M.volume_icon:subscribe("mouse.clicked", volume_toggle_details)
M.volume_icon:subscribe("mouse.scrolled", volume_scroll)
M.volume_percent:subscribe("mouse.clicked", volume_toggle_details)
M.volume_percent:subscribe("mouse.exited.global", volume_collapse_details)
M.volume_percent:subscribe("mouse.scrolled", volume_scroll)

return M
