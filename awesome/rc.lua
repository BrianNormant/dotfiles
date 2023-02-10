--       █████╗ ██╗    ██╗███████╗███████╗ ██████╗ ███╗   ███╗███████╗
--      ██╔══██╗██║    ██║██╔════╝██╔════╝██╔═══██╗████╗ ████║██╔════╝
--      ███████║██║ █╗ ██║█████╗  ███████╗██║   ██║██╔████╔██║█████╗
--      ██╔══██║██║███╗██║██╔══╝  ╚════██║██║   ██║██║╚██╔╝██║██╔══╝
--      ██║  ██║╚███╔███╔╝███████╗███████║╚██████╔╝██║ ╚═╝ ██║███████╗
--      ╚═╝  ╚═╝ ╚══╝╚══╝ ╚══════╝╚══════╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝


-- Standard awesome libraries
local gears = require("gears")
local awful = require("awful")


-- ===================================================================
-- User Configuration
-- ===================================================================


local themes = {
   "pastel", -- 1
   "mirage"  -- 2
}

-- change this number to use the corresponding theme
local theme = themes[1]
local theme_config_dir = gears.filesystem.get_configuration_dir() .. "configuration/" .. theme .. "/"

-- define default apps (global variable so other components can access it)
apps = {
   network_manager = "", -- recommended: nm-connection-editor
   power_manager = "", -- recommended: xfce4-power-manager
   terminal = "cool-retro-term",
   terminal_b = "alacritty",
   launcher = "rofi -normal-window -modi drun -show drun -theme " .. theme_config_dir .. "rofi.rasi",
   lock = "i3lock",
   screenshot = "scrot -e 'mv $f ~/Pictures/ 2>/dev/null'",
   filebrowser = "mc"
}

-- define wireless and ethernet interface names for the network widget
-- use `ip link` command to determine these
network_interfaces = {
   wlan = 'wlp1s0',
   lan = 'enp1s0'
}

-- Small utils to get the xinput id of the touchpad
local id = 11
awful.spawn.easy_async_with_shell("xinput list | awk '/Touchpad/{print substr($6,4,5)}'", function(out, err, _, _)
   require("naughty").notify{ text = out}
   local id = out
end)

-- List of apps to run on start-up
local run_on_start_up = {
   "pkill fusuma", -- In case of a awesome reload
   "pkill redshift", -- In case of a awesome reload 
   "picom &",
   "redshift -l 45.51678:-73.64918",
   "unclutter",
   "copyq",
   "fusuma",
   "setxkbmap us",
   "pulseaudio --start",
   "xinput --set-prop " .. id .." \"libinput Tapping Enabled\" 1",
   "xinput --set-prop " .. id .." \"libinput Tapping Drag Enabled\" 0",
}


-- ===================================================================
-- Initialization
-- ===================================================================


-- Import notification appearance
require("components.notifications")

-- Run all the apps listed in run_on_start_up
for _, command in ipairs(run_on_start_up) do
   awful.spawn.with_shell(command, false)
end

-- Import theme
local beautiful = require("beautiful")
beautiful.init(gears.filesystem.get_configuration_dir() .. "themes/" .. theme .. "-theme.lua")

-- Initialize theme
selected_theme = require(theme)
selected_theme.initialize()

-- Import Keybinds
keys = require("keys")
root.keys(keys.globalkeys)
root.buttons(keys.desktopbuttons)

-- Import rules
local create_rules = require("rules").create
awful.rules.rules = create_rules(keys.clientkeys, keys.clientbuttons)

-- Define layouts
awful.layout.layouts = {
   awful.layout.suit.floating,
   awful.layout.suit.tile,
   awful.layout.suit.tile.left,
   awful.layout.suit.tile.bottom,
   awful.layout.suit.tile.top,
   --awful.layout.suit.fair,
   --awful.layout.suit.fair.horizontal,
   --awful.layout.suit.spiral,
   --awful.layout.suit.spiral.dwindle,
   awful.layout.suit.max,
   --awful.layout.suit.max.fullscreen,
   --awful.layout.suit.magnifier,
   --awful.layout.suit.corner.nw,
   -- awful.layout.suit.corner.ne,
   -- awful.layout.suit.corner.sw,
   -- awful.layout.suit.corner.se,
}

-- remove gaps if layout is set to max
tag.connect_signal('property::layout', function(t)
   local current_layout = awful.tag.getproperty(t, 'layout')
   if (current_layout == awful.layout.suit.max) then
      t.gap = 0
   else
      t.gap = beautiful.useless_gap
   end
end)

-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
   -- Set the window as a slave (put it at the end of others instead of setting it as master)
   if not awesome.startup then
      awful.client.setslave(c)
   end

   if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
      -- Prevent clients from being unreachable after screen count changes.
      awful.placement.no_offscreen(c)
   end
end)


-- ===================================================================
-- Client Focusing
-- ===================================================================


-- Autofocus a new client when previously focused one is closed
require("awful.autofocus")

-- Focus clients under mouse
client.connect_signal("mouse::enter", function(c)
   c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)


-- ===================================================================
-- Screen Change Functions (ie multi monitor)
-- ===================================================================


-- Reload config when screen geometry changes
screen.connect_signal("property::geometry", awesome.restart)


-- ===================================================================
-- Garbage collection (allows for lower memory consumption)
-- ===================================================================


collectgarbage("setpause", 110)
collectgarbage("setstepmul", 1000)
