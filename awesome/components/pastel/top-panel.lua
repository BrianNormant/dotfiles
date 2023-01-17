--      ████████╗ ██████╗ ██████╗     ██████╗  █████╗ ███╗   ██╗███████╗██╗
--      ╚══██╔══╝██╔═══██╗██╔══██╗    ██╔══██╗██╔══██╗████╗  ██║██╔════╝██║
--         ██║   ██║   ██║██████╔╝    ██████╔╝███████║██╔██╗ ██║█████╗  ██║
--         ██║   ██║   ██║██╔═══╝     ██╔═══╝ ██╔══██║██║╚██╗██║██╔══╝  ██║
--         ██║   ╚██████╔╝██║         ██║     ██║  ██║██║ ╚████║███████╗███████╗
--         ╚═╝    ╚═════╝ ╚═╝         ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝╚══════╝

-- ===================================================================
-- Initialization
-- ===================================================================


local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")
local gears = require("gears")
local dpi = beautiful.xresources.apply_dpi

-- import widgets
local task_list = require("widgets.task-list")
local cpu_w = require("awesome-wm-widgets.cpu-widget.cpu-widget")
local ram_w = require("awesome-wm-widgets.ram-widget.ram-widget")
local volume_w = require("awesome-wm-widgets.volume-widget.volume")
local cmus_w = require('awesome-wm-widgets.cmus-widget.cmus')
local fs_w = require("awesome-wm-widgets.fs-widget.fs-widget")
local battery_w = require("awesome-wm-widgets.batteryarc-widget.batteryarc")
local wireless_w = require("net-widget.wireless")
local wired_w = require("net-widget.indicator")

-- define module table
local top_panel = {}


-- ===================================================================
-- Bar Creation
-- ===================================================================


top_panel.create = function(s)
   local panel = awful.wibar({
      screen = s,
      position = "top",
      ontop = true,
      height = beautiful.top_panel_height,
      width = s.geometry.width,
   })

   panel:setup {
      expand = "none",
      layout = wibox.layout.align.horizontal,
      task_list.create(s),
      require("widgets.calendar").create(s),
      {
         layout = wibox.layout.fixed.horizontal,
         wibox.layout.margin(wibox.widget.systray(), dpi(5), dpi(5), dpi(5), dpi(5)),
         cmus_w(),
         volume_w({
            widget_type = 'arc'
         }),
         battery_w({
            --font = "Bitstream Charter",
            show_current_level = true
         }),
         fs_w(),
         ram_w(),
         cpu_w({
            color = '#FFFF00',
            timeout = 0.5
         }),
         wireless_w({interface="wlp1s0"}),
         wired_w({
            interfaces  = {"enp1s0"},
            timeout     = 5
         }),
         wibox.layout.margin(require("widgets.layout-box"), dpi(5), dpi(5), dpi(5), dpi(5))
      }
   }


   -- ===================================================================
   -- Functionality
   -- ===================================================================


   -- hide panel when client is fullscreen
   local function change_panel_visibility(client)
      if client.screen == s then
         panel.ontop = not client.fullscreen
      end
   end

   -- connect panel visibility function to relevant signals
   client.connect_signal("property::fullscreen", change_panel_visibility)
   client.connect_signal("focus", change_panel_visibility)

end

return top_panel
