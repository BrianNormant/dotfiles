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
local battery_w = require("awesome-wm-widgets.battery-widget.battery")
local wireless_w = require("net-widget.wireless")
local wired_w = require("net-widget.indicator")
local brightness_w = require("awesome-wm-widgets.brightness-widget.brightness")
local pacman_w = require('awesome-wm-widgets.pacman-widget.pacman')

-- define module table
local top_panel = {}


-- ===================================================================
-- Bar Creation
-- ===================================================================
-- _______________/    \_10:27_/    \________________
--todo, ajust the shape and size to have something clean
-- I give up... for now...

top_panel.create = function(s)
   --ghost = awful.wibar({
   --   screen = s,
   --   ontop = false,
   --   visible = true,
   --   opacity = 0
   --})
   -- 1 big wibar witch contain 3 subbar
   --[[
   panel_left = awful.popup {
      screen = s,
      type = "dock",
      ontop = true,
      placement = awful.placement.top_left,
      visible = true,
      hide_on_right_click = true,
      --TODO make the tasklist work god enough
      widget = awful.widget.tasklist {
         screen = s
      },
   }

   panel_center = awful.popup {
      screen = s,
      type = "dock",
      ontop = true,
      placement = awful.placement.top,
      visible = true,
      widget = require("widgets.calendar").create(s),
   }

   panel_right = awful.popup {
      screen = s,
      type = "dock",
      ontop = true,
      placement = awful.placement.top_right,
      visible = true,
      hide_on_right_click = false,
      widget = {
         --TODO add separators
         layout = wibox.layout.fixed.horizontal,
         cmus_w(),
         volume_w({
            widget_type = 'arc'
         }),
         battery_w({
            show_current_level = true
         }),
         fs_w(),
         ram_w(),
         cpu_w({
            color = '#FFFF00',
            timeout = 0.5
         })
      }
   }]]
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
         spacing = 3,
         wibox.layout.margin(wibox.widget.systray(), dpi(5), dpi(5), dpi(5), dpi(5)),
         cmus_w(),
         {
            layout = wibox.layout.fixed.horizontal,
            spacing = 0,
            wibox.widget.textbox ('['),
            awful.widget.keyboardlayout {
               
            },
            wibox.widget.textbox(']')
         },
         {
            layout = wibox.layout.fixed.horizontal,
            spacing = 0,
            wibox.widget.textbox ('['),
            pacman_w(),
            wibox.widget.textbox(']')
         },
         {
            layout = wibox.layout.fixed.horizontal,
            spacing = 2,
            wibox.widget.textbox ('['),
            volume_w({
               widget_type = 'horizontal_bar',
               main_color = '#FF0018',
               mute_color = '#550018',
            }),
            wibox.widget.textbox(']')
         },
         {
            layout = wibox.layout.fixed.horizontal,
            spacing = 2,
            wibox.widget.textbox ('['),
            battery_w({
               font = "Terminus 12",
               show_current_level = true,
               display_notification = true,
            }),
            wibox.widget.textbox(']')
         },
         {
            layout = wibox.layout.fixed.horizontal,
            spacing = 2,
            wibox.widget.textbox ('['),
            brightness_w({
               type = 'icon_and_text',
               program = 'brightnessctl'
            }),
            wibox.widget.textbox(']')
         },
         {
            layout = wibox.layout.fixed.horizontal,
            spacing = 2,
            wibox.widget.textbox ('['),
            fs_w(),
            wibox.widget.textbox(']')
         },
         ram_w(),
         cpu_w({
            color = '#FFFF00',
            timeout = 0.5
         }),
         wireless_w({interface="wlan0"}),
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

--[[
local left_panel = awful.wibar({
      screen = s,
      x = s.geometry.x,
      y = s.geometry.y,
      stretch = false,
      width = s.geometry.width * 2/7,
   })
   left_panel:setup {
      expand = "inside",
      layout = wibox.layout.align.horizontal,
      task_list.create(s),
      nil,
      nil
   }
   -- left_panel.geometry = awful.placement.align(left_panel.geometry, "top_left")
   local center_panel = awful.wibar({
      screen = s,
      position = "top",
      stretch = false,
      width = s.geometry.width * 1/14,
      align = "centered",
   })
   center_panel:setup {
      expand = "inside",
      nil,
      require("widgets.calendar").create(s),
      nil,
      layout = wibox.layout.align.horizontal,
   }
   local right_panel = awful.wibar({
      screen = s,
      position = "top",
      stretch = false,
      width = s.geometry.width * 2/7,
      align = "right",
   })
   right_panel:setup {
      layout = wibox.layout.align.horizontal,
      expand = "inside",
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
]]
