local terminal = "kitty"
local fileManager = "thunar"
local menu = "rofi -show drun"

local mainMod = "SUPER" -- Sets "Windows" key as main modifier
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
local closeWindowBind = hl.bind(mainMod .. " + Q", hl.dsp.window.close())

-- closeWindowBind:set_enabled(false)
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + Z", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + Space", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit")) -- dwindle only
hl.bind(mainMod .. " + Escape", hl.dsp.exec_cmd("~/.config/rofi/scripts/powermenu"))
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("~/.config/rofi/scripts/clipboard"))
hl.bind("ALT + SHIFT + Insert", hl.dsp.exec_cmd("~/.config/rofi/scripts/wallPicker"))
hl.bind("SUPER + ALT + I", hl.dsp.exec_cmd("~/.config/hypr/nightlight"))
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("swaync-client -t -sw"))
hl.bind("Print", function()
	hl.dsp.exec_cmd("flameshot gui ")
end)
hl.bind("ALT + Space", hl.dsp.exec_cmd("~/.local/bin/rofisearch"))
hl.bind("ALT + R", hl.dsp.exec_cmd("~/.local/bin/term-run"))
-- Window operations --
hl.bind("ALT + SHIFT + A", hl.dsp.window.move({ direction = "l" }))
hl.bind("ALT + SHIFT + S", hl.dsp.window.move({ direction = "d" }))
hl.bind("ALT + SHIFT + W", hl.dsp.window.move({ direction = "u" }))
hl.bind("ALT + SHIFT + D", hl.dsp.window.move({ direction = "r" }))
hl.bind("SUPER + left", hl.dsp.focus({ direction = "left" }))
hl.bind("SUPER + right", hl.dsp.focus({ direction = "right" }))
hl.bind("SUPER + up", hl.dsp.focus({ direction = "up" }))
hl.bind("SUPER + down", hl.dsp.focus({ direction = "down" }))
-- MOVING FLOATING WINDOWS USING ALT+SHIFT AND RESIZING USING ALT+CTRL --
local function ensure_floating()
	local win = hl.get_active_window()
	if win ~= nil and not win.floating then
		hl.dispatch(hl.dsp.window.float({ action = "set" }))
	end
end

-- Alt + Shift + Arrows: Move Floating Window
hl.bind("ALT + SHIFT + left", function()
	ensure_floating()
	hl.dispatch(hl.dsp.window.move({ x = -40, y = 0, relative = true }))
end, { repeating = true })

hl.bind("ALT + SHIFT + right", function()
	ensure_floating()
	hl.dispatch(hl.dsp.window.move({ x = 40, y = 0, relative = true }))
end, { repeating = true })

hl.bind("ALT + SHIFT + up", function()
	ensure_floating()
	hl.dispatch(hl.dsp.window.move({ x = 0, y = -40, relative = true }))
end, { repeating = true })

hl.bind("ALT + SHIFT + down", function()
	ensure_floating()
	hl.dispatch(hl.dsp.window.move({ x = 0, y = 40, relative = true }))
end, { repeating = true })

-- Alt + Ctrl + Arrows: Resize Floating Window
hl.bind("ALT + CONTROL + left", function()
	ensure_floating()
	hl.dispatch(hl.dsp.window.resize({ x = -40, y = 0, relative = true }))
end, { repeating = true })

hl.bind("ALT + CONTROL + right", function()
	ensure_floating()
	hl.dispatch(hl.dsp.window.resize({ x = 40, y = 0, relative = true }))
end, { repeating = true })

hl.bind("ALT + CONTROL + up", function()
	ensure_floating()
	hl.dispatch(hl.dsp.window.resize({ x = 0, y = -40, relative = true }))
end, { repeating = true })

hl.bind("ALT + CONTROL + down", function()
	ensure_floating()
	hl.dispatch(hl.dsp.window.resize({ x = 0, y = 40, relative = true }))
end, { repeating = true })

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
	local key = i % 10 -- 10 maps to key 0
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- SCRATCHPAD --
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("swayosd-client --output-volume raise"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("swayosd-client --output-volume lower"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd("swayosd-client --output-volume mute-toggle"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("swayosd-client --brightness raise"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("swayosd-client --brightness lower"))

-- Brightness change binds for non brightness hotkey keyboards --
-- hl.bind("ALT + Prior", hl.dsp.exec_cmd("swayosd-client --brightness raise"), { locked = true, repeating = true })
-- hl.bind("ALT + Next", hl.dsp.exec_cmd("swayosd-client --brightness lower"), { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-- Special shader toggle for a little better blacks you can change it in the file accordingly --
hl.bind("SUPER + F8", function()
	hl.dispatch(hl.dsp.exec_cmd("~/.config/hypr/scripts/color-calibrate-toggle.fish"))
end)
