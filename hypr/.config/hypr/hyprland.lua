-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("_JAVA_AWT_WM_NONREPARENTING", "1")
hl.env("XDG_CURRENT_DESKTOP", "sway")
--hl.env("HYPRCUROSR_THEME", "")    <cursor theme>
--hl.env("XCURSOR_THEME", "") <cursor theme for xwayland applications>

-----------------------
----- PERMISSIONS -----
-----------------------
----------------------------------- Checkout the hyprland wiki to tweak these -------------------------------------

-- hl.config({
-- enablecosystem = {
-- enforce_permissions = true,
-- },
-- })

-- hl.permission("/usr/(bin|local/bin)/grim", "screencopy", "allow")
-- hl.permission("/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland", "screencopy", "allow")
-- hl.permission("/usr/(bin|local/bin)/hyprpm", "plugin", "allow")
----------------
----  MISC  ----
----------------
hl.config({
	misc = {
		force_default_wallpaper = 0, -- Set to 0 or 1 to disable the anime mascot wallpapers
		disable_hyprland_logo = true, -- If true disables the random hyprland logo / anime girl background. :(
	},
})

require("modules/keybinds")
require("modules/windowrules")
require("modules/input")
require("modules/animations")
require("modules/monitor")
require("modules/environments")
require("modules/autostart")
require("modules/looknfeel")
require("modules/layouts")
require("modules/optionals")

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
