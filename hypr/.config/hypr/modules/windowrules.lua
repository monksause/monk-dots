--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

local suppressMaximizeRule = hl.window_rule({
	name = "suppress-maximize-events",
	match = { class = ".*" },
	suppress_event = "maximize",
})
-- suppressMaximizeRule:set_enabled(false)

hl.window_rule({
	name = "fix-xwayland-drags",
	match = {
		class = "^$",
		title = "^$",
		xwayland = true,
		float = true,
		fullscreen = false,
		pin = false,
	},
	no_focus = true,
})
hl.window_rule({
	name = "floating-bluetooth",
	match = { class = "blueman-manager" },
	float = true,
	size = { "monitor_w * 0.5", "monitor_h * 0.5" },
})
hl.window_rule({
	name = "floating-nmgui",
	match = { class = "com/netowrk.manager" },
	float = true,
	size = { "monitor_w * 0.5", "monitor_h * 0.5" },
})
hl.window_rule({
	name = "floating-localsend",
	match = { class = "localsend_app" },
	float = true,
	size = { "monitor_w * 0.5", "monitor_h * 0.5" },
})
hl.window_rule({
	name = "flameshot",
	match = { class = "flameshot" },
	float = true,
})
-- Layer rules also return a handle.
-- local overlayLayerRule = hl.layer_rule({
-- name  = "no-anim-overlay",
-- match = { namespace = "^my-overlay$" },
-- no_anim = true,
-- })
-- overlayLayerRule:set_enabled(false)

-- Hyprland-run windowrule
hl.window_rule({
	name = "move-hyprland-run",
	match = { class = "hyprland-run" },
	move = "20 monitor_h-120",
	float = true,
})
