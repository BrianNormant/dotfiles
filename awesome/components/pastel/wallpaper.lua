--      ██╗    ██╗ █████╗ ██╗     ██╗     ██████╗  █████╗ ██████╗ ███████╗██████╗
--      ██║    ██║██╔══██╗██║     ██║     ██╔══██╗██╔══██╗██╔══██╗██╔════╝██╔══██╗
--      ██║ █╗ ██║███████║██║     ██║     ██████╔╝███████║██████╔╝█████╗  ██████╔╝
--      ██║███╗██║██╔══██║██║     ██║     ██╔═══╝ ██╔══██║██╔═══╝ ██╔══╝  ██╔══██╗
--      ╚███╔███╔╝██║  ██║███████╗███████╗██║     ██║  ██║██║     ███████╗██║  ██║
--       ╚══╝╚══╝ ╚═╝  ╚═╝╚══════╝╚══════╝╚═╝     ╚═╝  ╚═╝╚═╝     ╚══════╝╚═╝  ╚═╝

-- ===================================================================
-- Imports
-- ===================================================================


local awful = require("awful")
local gears = require("gears")
local naughty = require("naughty")


-- ===================================================================
-- Initialization
-- ===================================================================


local is_blurred = false;

local max = 30 --TODO Make a tools to autofind the wallpapers avaibles
local current = math.random(0,max)
local timeout = 25 -- in seconds
-- By default wallpaper are searched in ~/Wallpapers
local wallpaper_dir = os.getenv("HOME") .. "/Wallpapers"
local wallpaper = wallpaper_dir .. "/".. current.. ".jpg"
local blurred_wallpaper = wallpaper_dir .. "/" .. current .. "b.png"

awful.spawn.with_shell("feh --bg-fill " .. wallpaper)

--- Check if a file or directory exists in this path
function file_exists(name)
   --Make the assumption that if a file exist, it can be read.
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end

-- check if blurred wallpaper needs to be created
for i = 0, max, 1 do
   if not file_exists(wallpaper_dir .. "/" .. i .. "b.png") then
      naughty.notify({
         preset = naughty.config.presets.normal,
         title = wallpaper_dir .. "/" .. i .. "b.png",
         text = "Generating blurred wallpaper..."
      })
      -- uses image magick to create a blurred version of the wallpaper
      awful.spawn.with_shell("convert -filter Gaussian -blur 0x10 " .. wallpaper_dir .. "/" .. i .. ".jpg" .. " " .. wallpaper_dir .. "/" .. i .. "b.png")
   end
end
-- ===================================================================
-- Functionality
-- ===================================================================


-- changes to blurred wallpaper
local function blur()
   if not is_blurred then
      awful.spawn.with_shell("feh --bg-fill " .. blurred_wallpaper)
      is_blurred = true
   end
end

-- changes to normal wallpaper
local function unblur()
   if is_blurred then
      awful.spawn.with_shell("feh --bg-fill " .. wallpaper)
      is_blurred = false
   end
end

-- change the current image to the next one
local function next_image()
   current = (current + math.random(0, 5)) % max
   wallpaper = wallpaper_dir .. "/".. current ..".jpg"
   blurred_wallpaper = wallpaper_dir .. "/" .. current .. "b.png"
   if is_blurred then
      awful.spawn.with_shell("feh --bg-fill " .. blurred_wallpaper)
   else
      awful.spawn.with_shell("feh --bg-fill " .. wallpaper)
   end
   return true
end

-- blur / unblur on tag change
tag.connect_signal("property::selected", function(t)
   -- check if tag has any clients

   for _, c in pairs(t:clients()) do
      if not c.minimized then
          blur()
          return
      end
   end
   -- unblur if tag has no clients
   unblur()
end)

local function any_unminimized()
   local t = awful.screen.focused().selected_tag
   for _, c in pairs(t:clients()) do
      if not c.minimized then
         return true
      end
   end
   return false
end

-- check if wallpaper should be blurred on client open
client.connect_signal("manage", function(c)
   blur()
end)

-- check if wallpaper should be unblurred on client close
client.connect_signal("unmanage", function(c)
   local t = awful.screen.focused().selected_tag
   -- check if tag has any clients unmaximized client
   if any_unminimized() then blur() else unblur() end
end)

client.connect_signal("property::minimized", function(c)
   if any_unminimized() then
      blur()
   else
      unblur()
   end
end)

gears.timer {
   timeout = timeout,
   call_now = true,
   autostart = true,
   callback = next_image
}
