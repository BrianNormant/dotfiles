--      ██████╗  █████╗ ███████╗████████╗███████╗██╗
--      ██╔══██╗██╔══██╗██╔════╝╚══██╔══╝██╔════╝██║
--      ██████╔╝███████║███████╗   ██║   █████╗  ██║
--      ██╔═══╝ ██╔══██║╚════██║   ██║   ██╔══╝  ██║
--      ██║     ██║  ██║███████║   ██║   ███████╗███████╗
--      ╚═╝     ╚═╝  ╚═╝╚══════╝   ╚═╝   ╚══════╝╚══════╝

-- ===================================================================
-- Initialization
-- ===================================================================


local awful = require("awful")
local gears = require("gears")

local pastel = {}

-- ===================================================================
-- Pastel setup
-- ===================================================================
-- Import panels
pastel.left_panel = require("components.pastel.left-panel")
pastel.top_panel = require("components.pastel.top-panel")


pastel.initialize = function()
   -- Import components
   require("components.pastel.wallpaper")
   require("components.exit-screen")
   require("components.volume-adjust")

   -- Set up each screen (add tags & panels)
   awful.screen.connect_for_each_screen(function(s)
      for i = 1, 9, 1
      do
         awful.tag.add(i, {
            icon = gears.filesystem.get_configuration_dir() .. "/icons/tags/pastel/" .. i .. ".png",
            icon_only = true,
            layout = awful.layout.suit.tile,
            screen = s,
            selected = i == 1
         })
      end

      -- Only add the left panel on the primary screen
      if s.index == 1 then
         pastel.left_panel.create(s)
         s:connect_signal("ouse::press", function()
            local naughty = require("naughty")
            naughty.notify({
               text = "Mouse enter"
            })
         end)
      end

      -- Add the top panel to every screen
      pastel.top_panel.create(s)
   end)
end

return pastel
