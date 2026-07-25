local nix_vars_status, nix = pcall(require, "nix_vars")
local autostart_status = pcall(require, "autostart")

local function exec(cmd, args)
  if args then
    cmd = cmd .. " " .. args
  end
  return hl.dsp.exec_cmd(cmd)
end
local function uwsm(app, args)
  return exec("uwsm app -t service -- " .. app, args)
end

---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER"
local ipc = "noctalia msg "

hl.bind(mainMod .. " + q", hl.dsp.window.close())
hl.bind(mainMod .. " + f", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + CTRL + F", hl.dsp.window.set_prop({ prop = "opaque", value = "toggle", window = "active" }))
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + SHIFT + left", hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "r" }))
hl.bind(mainMod .. " + SHIFT + up", hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + SHIFT + down", hl.dsp.window.move({ direction = "d" }))
hl.bind(mainMod .. " + f5", hl.dsp.force_renderer_reload())
hl.bind(mainMod .. " + SHIFT + f5", hl.dsp.exit())
-- hl.bind(mainMod .. " + f11", hl.dsp.exec_cmd("sleep 1 && hyprctl dispatch dpms off"))
-- hl.bind(mainMod .. " + f12", hl.dsp.exec_cmd("sleep 1 && hyprctl dispatch dpms on"))
hl.bind(mainMod .. " + f11", uwsm("noctalia msg dpms-off"))
hl.bind(mainMod .. " + f12", uwsm("noctalia msg dpms-on"))
hl.bind(mainMod .. " + p", uwsm("wlogout", "-b 5"))
-- hl.bind(mainMod .. " + w", uwsm("walker"))
hl.bind(mainMod .. " + CTRL + w", uwsm("walker"))
hl.bind(mainMod .. " + return", uwsm(nix.term))
hl.bind(mainMod .. " + SHIFT + return", uwsm("nop", "kitti3"))
hl.bind(mainMod .. " + e", uwsm(nix.editor))
-- hl.bind(mainMod .. " + j", uwsm("mpris-ctl", "prev"))
-- hl.bind(mainMod .. " + k", uwsm("mpris-ctl", "pp"))
-- hl.bind(mainMod .. " + l", uwsm("mpris-ctl", "next"))
-- hl.bind(mainMod .. " + SHIFT + J", uwsm("mpris-ctl", "--player Spotify prev"))
-- hl.bind(mainMod .. " + SHIFT + K", uwsm("mpris-ctl", "--player Spotify pp"))
-- hl.bind(mainMod .. " + SHIFT + L", uwsm("mpris-ctl", "--player Spotify next"))
hl.bind(mainMod .. " + j", uwsm("noctalia msg media previous"))
hl.bind(mainMod .. " + k", uwsm("noctalia msg media toggle"))
hl.bind(mainMod .. " + l", uwsm("noctalia msg media next"))
hl.bind(mainMod .. " + SHIFT + J", uwsm("noctalia msg media previous-player"))
hl.bind(mainMod .. " + SHIFT + K", uwsm("noctalia msg media stop"))
hl.bind(mainMod .. " + SHIFT + L", uwsm("noctalia msg media next-player"))
-- hl.bind(mainMod .. " + m", uwsm("pamixer", "-t"))
-- hl.bind(mainMod .. " + comma", uwsm("pamixer", "-d 5"))
-- hl.bind(mainMod .. " + period", uwsm("pamixer", "-i 5"))
-- hl.bind(mainMod .. " + SHIFT + comma", uwsm("pamixer", "-d 2"))
-- hl.bind(mainMod .. " + SHIFT + period", uwsm("pamixer", "-i 2"))
hl.bind(mainMod .. " + i", uwsm("pavucontrol"))
hl.bind(mainMod .. " + d", uwsm(nix.fm))
hl.bind(mainMod .. " + y", uwsm(nix.yt_mpv))
hl.bind(mainMod .. " + SHIFT + Y", uwsm(nix.yt_mpv, "--no-video"))
hl.bind("print", uwsm("noctalia msg screenshot-fullscreen"))
hl.bind(mainMod .. " + print", uwsm("noctalia msg screenshot-region"))
hl.bind(mainMod .. " + CTRL + print", uwsm("noctalia msg screenshot-fullscreen pick"))
-- hl.bind(mainMod .. " + print",
--   uwsm("grim", "$(xdg-user-dir)/Pictures/Screenshots/$(date +'%Y-%m-%d+%H:%M:%S').png && notify-send 'Screenshot Saved'"))
-- hl.bind(mainMod .. " + CTRL + print", uwsm("grim", "- | wl-copy && notify-send 'Screenshot Copied to Clipboard'"))
-- hl.bind(mainMod .. " + SHIFT + print",
--   uwsm("grim",
--     "-g \"$(slurp)\" $(xdg-user-dir)/Pictures/Screenshots/$(date +'%Y-%m-%d+%H:%M:%S').png && notify-send 'Screenshot Saved'"))
-- hl.bind(mainMod .. " + CTRL + SHIFT + print",
--   uwsm("grim -g \"$(slurp)\" - | wl-copy && notify-send 'Screenshot Copied to Clipboard'"))
-- hl.bind("xf86audioplay", uwsm("mpris-ctl", "pp"))
-- hl.bind("xf86audionext", uwsm("mpris-ctl", "next"))
-- hl.bind("xf86audioprev", uwsm("mpris-ctl", "prev"))
hl.bind("xf86audioplay", uwsm("noctalia msg media toggle"))
hl.bind("xf86audionext", uwsm("noctalia msg media next"))
hl.bind("xf86audioprev", uwsm("noctalia msg media previous"))
-- hl.bind("xf86audiolowervolume", uwsm("pamixer", "-d 5"))
-- hl.bind("xf86audioraisevolume", uwsm("pamixer", "-i 5"))
-- hl.bind("xf86audiomute", uwsm("pamixer", "-t"))
-- hl.bind("SHIFT + xf86audiolowervolume", uwsm("pamixer", "-d 2"))
-- hl.bind("SHIFT + xf86audioraisevolume", uwsm("pamixer", "-i 2"))
hl.bind(mainMod .. " + c", hl.dsp.group.prev())
hl.bind(mainMod .. " + v", hl.dsp.group.next())
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("cliphist list | head -n50 | walker -d | cliphist decode | wl-copy"))
hl.bind(mainMod .. " + 1", hl.dsp.focus({ workspace = 1 }))
hl.bind(mainMod .. " + 2", hl.dsp.focus({ workspace = 2 }))
hl.bind(mainMod .. " + 3", hl.dsp.focus({ workspace = 3 }))
hl.bind(mainMod .. " + 4", hl.dsp.focus({ workspace = 4 }))
hl.bind(mainMod .. " + 5", hl.dsp.focus({ workspace = 5 }))
hl.bind(mainMod .. " + 6", hl.dsp.focus({ workspace = 6 }))
hl.bind(mainMod .. " + 7", hl.dsp.focus({ workspace = 7 }))
hl.bind(mainMod .. " + 8", hl.dsp.focus({ workspace = 8 }))
hl.bind(mainMod .. " + 9", hl.dsp.focus({ workspace = 9 }))
hl.bind(mainMod .. " + 0", hl.dsp.focus({ workspace = "name:Email" }))
hl.bind(mainMod .. " + s", hl.dsp.focus({ workspace = "name:Steam" }))
hl.bind(mainMod .. " + b", hl.dsp.focus({ workspace = "name:Music" }))
hl.bind(mainMod .. " + t", hl.dsp.focus({ workspace = "name:Messengers" }))
hl.bind(mainMod .. " + g", hl.dsp.focus({ workspace = "name:Games" }))
hl.bind(mainMod .. " + SHIFT + 1", hl.dsp.window.move({ workspace = 1, follow = false }))
hl.bind(mainMod .. " + SHIFT + 2", hl.dsp.window.move({ workspace = 2, follow = false }))
hl.bind(mainMod .. " + SHIFT + 3", hl.dsp.window.move({ workspace = 3, follow = false }))
hl.bind(mainMod .. " + SHIFT + 4", hl.dsp.window.move({ workspace = 4, follow = false }))
hl.bind(mainMod .. " + SHIFT + 5", hl.dsp.window.move({ workspace = 5, follow = false }))
hl.bind(mainMod .. " + SHIFT + 6", hl.dsp.window.move({ workspace = 6, follow = false }))
hl.bind(mainMod .. " + SHIFT + 7", hl.dsp.window.move({ workspace = 7, follow = false }))
hl.bind(mainMod .. " + SHIFT + 8", hl.dsp.window.move({ workspace = 8, follow = false }))
hl.bind(mainMod .. " + SHIFT + 9", hl.dsp.window.move({ workspace = 9, follow = false }))
hl.bind(mainMod .. " + SHIFT + 0", hl.dsp.window.move({ workspace = "name:Email", follow = false }))
hl.bind(mainMod .. " + SHIFT + s", hl.dsp.window.move({ workspace = "name:Steam", follow = false }))
hl.bind(mainMod .. " + SHIFT + B", hl.dsp.window.move({ workspace = "name:Music", follow = false }))
hl.bind(mainMod .. " + SHIFT + T", hl.dsp.window.move({ workspace = "name:Messengers", follow = false }))
hl.bind(mainMod .. " + SHIFT + g", hl.dsp.focus({ workspace = "name:Games" }))
hl.bind("ALT + 1", hl.dsp.window.move({ workspace = 1, follow = false }))
hl.bind("ALT + 2", hl.dsp.window.move({ workspace = 2, follow = false }))
hl.bind("ALT + 3", hl.dsp.window.move({ workspace = 3, follow = false }))
hl.bind("ALT + 4", hl.dsp.window.move({ workspace = 4, follow = false }))
hl.bind("ALT + 5", hl.dsp.window.move({ workspace = 5, follow = false }))
hl.bind("ALT + 6", hl.dsp.window.move({ workspace = 6, follow = false }))
hl.bind("ALT + 7", hl.dsp.window.move({ workspace = 7, follow = false }))
hl.bind("ALT + 8", hl.dsp.window.move({ workspace = 8, follow = false }))
hl.bind("ALT + 9", hl.dsp.window.move({ workspace = 9, follow = false }))
hl.bind("ALT + 0", hl.dsp.window.move({ workspace = "name:Email", follow = false }))
hl.bind("ALT + s", hl.dsp.window.move({ workspace = "name:Steam", follow = false }))
hl.bind("ALT + b", hl.dsp.window.move({ workspace = "name:Music", follow = false }))
hl.bind("ALT + t", hl.dsp.window.move({ workspace = "name:Messengers", follow = false }))
hl.bind("ALT + g", hl.dsp.window.move({ workspace = "name:Games", follow = false }))
hl.bind(mainMod .. " + ALT + 1", hl.dsp.window.move({ workspace = 1 }))
hl.bind(mainMod .. " + ALT + 2", hl.dsp.window.move({ workspace = 2 }))
hl.bind(mainMod .. " + ALT + 3", hl.dsp.window.move({ workspace = 3 }))
hl.bind(mainMod .. " + ALT + 4", hl.dsp.window.move({ workspace = 4 }))
hl.bind(mainMod .. " + ALT + 5", hl.dsp.window.move({ workspace = 5 }))
hl.bind(mainMod .. " + ALT + 6", hl.dsp.window.move({ workspace = 6 }))
hl.bind(mainMod .. " + ALT + 7", hl.dsp.window.move({ workspace = 7 }))
hl.bind(mainMod .. " + ALT + 8", hl.dsp.window.move({ workspace = 8 }))
hl.bind(mainMod .. " + ALT + 9", hl.dsp.window.move({ workspace = 9 }))
hl.bind(mainMod .. " + ALT + 0", hl.dsp.window.move({ workspace = "name:Email" }))
hl.bind(mainMod .. " + ALT + s", hl.dsp.window.move({ workspace = "name:Steam" }))
hl.bind(mainMod .. " + ALT + b", hl.dsp.window.move({ workspace = "name:Music" }))
hl.bind(mainMod .. " + ALT + t", hl.dsp.window.move({ workspace = "name:Messengers" }))
hl.bind(mainMod .. " + ALT + g", hl.dsp.window.move({ workspace = "name:Games" }))

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag())
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize())

-- Core binds
hl.bind(mainMod .. " + w", hl.dsp.exec_cmd(ipc .. "panel-toggle launcher"))
hl.bind(mainMod .. " + semicolon", hl.dsp.exec_cmd(ipc .. "panel-toggle control-center"))
hl.bind(mainMod .. " + apostrophe", hl.dsp.exec_cmd(ipc .. "settings-toggle"))
hl.bind("ALT + Tab", hl.dsp.exec_cmd(ipc .. "window-switcher"))

-- Media keys
hl.bind(mainMod .. " + comma", hl.dsp.exec_cmd(ipc .. "volume-down"))
hl.bind(mainMod .. " + period", hl.dsp.exec_cmd(ipc .. "volume-up"))
hl.bind(mainMod .. " + m", hl.dsp.exec_cmd(ipc .. "volume-mute"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(ipc .. "volume-down"))
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(ipc .. "volume-up"))
hl.bind("XF86AudioMute", hl.dsp.exec_cmd(ipc .. "volume-mute"))
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd(ipc .. "brightness-up"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(ipc .. "brightness-down"))

------------------
---- MONITORS ----
------------------

hl.monitor({
  output = "DP-3",
  mode = "2560x1440@164.998993",
  position = "0x0",
  scale = "1",
  bitdepth = 10,
  cm = "srgb",
  vrr = 1,
})

hl.monitor({
  output = "HDMI-A-1",
  mode = "1920x1080@60",
  position = "-1920x360",
  scale = "1",
  vrr = 0,
})

hl.monitor({
  output = "",
  mode = "highres",
  position = "auto",
  scale = "1",
})

----------------------
---- WINDOW RULES ----
----------------------

hl.window_rule({
  match = {
    class = "^(Waydroid)$",
  },
  center = true,
})

hl.window_rule({
  match = {
    class = "^(gamescope)$",
  },
  float = true,
})

hl.window_rule({
  match = {
    class = "^(Waydroid)$",
  },
  float = true,
})

hl.window_rule({
  match = {
    class = ".*(jellyfin).*",
  },
  opaque = true,
})

hl.window_rule({
  match = {
    class = ".*(qemu).*",
  },
  opaque = true,
})

hl.window_rule({
  match = {
    class = ".*(virt-manager).*",
  },
  opaque = true,
})

hl.window_rule({
  match = {
    class = "^(.*winbox64.exe)$",
  },
  opaque = true,
})

hl.window_rule({
  match = {
    class = "^(Chromium-browser)$",
  },
  opaque = true,
})

hl.window_rule({
  match = {
    class = "^(firefox)$",
  },
  opaque = true,
})

hl.window_rule({
  match = {
    class = "^(zen)$",
  },
  opaque = true,
})

hl.window_rule({
  match = {
    class = "^(brave-browser)$",
  },
  opaque = true,
})

hl.window_rule({
  match = {
    class = "^(gamescope)$",
  },
  opaque = true,
})

hl.window_rule({
  match = {
    class = "^(mpv)$",
  },
  opaque = true,
})

hl.window_rule({
  match = {
    class = "^(steam)$",
  },
  opaque = true,
})

hl.window_rule({
  match = {
    class = "^(steam_app_default)$",
  },
  opaque = true,
})

hl.window_rule({
  match = {
    class = "^(xfreerdp)$",
  },
  opaque = true,
})

hl.window_rule({
  match = {
    class = "^(Waydroid)$",
  },
  opaque = true,
})

hl.window_rule({
  match = {
    class = "^.*(freesmlauncher).*$",
  },
  opaque = true,
})

hl.window_rule({
  match = {
    class = "^(Waydroid)$",
  },
  size = "1600 900",
})

hl.window_rule({
  match = {
    class = "^(.*winbox64.exe)$",
  },
  float = false,
})

hl.window_rule({
  match = {
    class = "^(spotify)$",
  },
  float = false,
})

hl.window_rule({
  match = {
    class = "^(geary)$",
  },
  workspace = "name:Email silent",
})

hl.window_rule({
  match = {
    class = "^(thunderbird)$",
  },
  workspace = "name:Email silent",
})

hl.window_rule({
  match = {
    class = "^(org.telegram.desktop)$",
  },
  workspace = "name:Messengers silent",
})

hl.window_rule({
  match = {
    class = "^(spotify)$",
  },
  workspace = "name:Music silent",
})

hl.window_rule({
  match = {
    class = "^(.gamescope-wrapped)$",
    title = "Steam",
  },
  workspace = "name:Steam silent",
})

hl.window_rule({
  match = {
    class = "^(steam)$",
  },
  workspace = "name:Steam silent",
})

hl.window_rule({
  match = {
    title = ".*Bitwarden.*",
  },
  float = true,
})

hl.window_rule({
  match = { class = "dev.noctalia.Noctalia" },
  float = true,
  size = { 1080, 920 },
})

hl.layer_rule({
  name = "noctalia",
  match = {
    namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher)$",
  },
  no_anim = true,
  ignore_alpha = 0.5,
  blur = true,
  blur_popups = true,
})

hl.window_rule({
  match = { class = "^(com.gabm.satty)$" },
  float = true,
  center = true,
  size = "(monitor_w*0.7) (monitor_h*0.8)",
})

--------------
---- MISC ----
--------------

hl.config({
  animations = {
    enabled = true,
  },
  debug = {
    full_cm_proto = true,
  },
  decoration = {
    blur = {
      enabled = true,
      -- ignore_opacity = true,
      passes = 2,
      size = 3,
      vibrancy = 0.1696,
    },
    shadow = {
      color = 0xee1a1a1a,
      -- color = 0xAAf38ba8,
      enabled = true,
      -- offset = "0 0",
      range = 4,
      render_power = 3,
      -- range = 6,
    },
    active_opacity = 0.950000,
    fullscreen_opacity = 1.000000,
    inactive_opacity = 0.850000,
    rounding = 10,
    rounding_power = 2,
    -- rounding = 0,
  },
  ecosystem = {
    no_update_news = true,
  },
  general = {
    border_size = 1,
    -- gaps_in = 6,
    -- gaps_out = 12,
    gaps_in = 5,
    gaps_out = 10,
  },
  input = {
    tablet = {
      output = "current",
      active_area_position = "50 60",
      active_area_size = "39 22",
    },
    touchpad = {
      clickfinger_behavior = true,
      middle_button_emulation = true,
      natural_scroll = true,
      -- ["tap-to-click"] = true,
    },
    follow_mouse = true,
    force_no_accel = true,
    kb_layout = "us,ru",
    kb_options = "grp:win_space_toggle",
    natural_scroll = false,
    numlock_by_default = true,
    scroll_method = "2fg",
    sensitivity = 0.300000,
  },
  misc = {
    disable_hyprland_logo = true,
    disable_splash_rendering = true,
    enable_anr_dialog = false,
    mouse_move_enables_dpms = true,
    vrr = 1,
  },
})

-----------------
---- STARTUP ----
-----------------

-- hl.on("hyprland.start", function()
--     hl.exec_cmd("uwsm app -- " .. polkit_agent)
--     hl.exec_cmd("uwsm app -- " .. nix.mail)
--     hl.exec_cmd("uwsm app -- " .. nix.messenger)
--     hl.exec_cmd("uwsm app -- " .. nix.spotify)
--     hl.exec_cmd("uwsm app -- " .. jellyfin)
--     hl.exec_cmd("uwsm app -- " .. steam)
--     hl.exec_cmd("hyprctl setcursor 'PRTS-hypr' 48")
--     hl.exec_cmd(xrandr .. " --output DP-3 --primary")
-- end)

-- For Noctalia Color templates
require("noctalia").apply_theme()
