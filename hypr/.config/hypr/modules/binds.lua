-- =====================================================================
-- FIX: NIRI-STYLE FLOATING MOVE & RESIZE BINDS (NO TOGGLE LOOP)
-- =====================================================================

-- Helper function to ensure a window floats only if it is currently tiled
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

