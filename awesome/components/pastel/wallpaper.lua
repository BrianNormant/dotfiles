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

local wallpapers = {"1","2","3","4","5","6","7","8","9","10"}
local current = 1
local max = 7
local timeout = 20 -- in seconds

local wallpaper_dir = "~/Wallpapers"
local wallpaper = wallpaper_dir .. "/".. wallpapers[current].. ".jpg"
local blurred_wallpaper = wallpaper_dir .. "/" .. wallpapers[current] .. "b.png"

awful.spawn.with_shell("feh --bg-fill " .. wallpaper)

--- Check if a file or directory exists in this path
local function exists(file)
   local ok, err, code = os.rename(file, file)
   if not ok then
      if code == 13 then
         -- Permission denied, but it exists
         return true
      end
   end
   return ok, err
end

-- check if blurred wallpaper needs to be created
for i = 1, 10, 1 do
   current = i
   wallpaper = wallpaper_dir .. "/".. wallpapers[current].. ".jpg"
   blurred_wallpaper = wallpaper_dir .. "/" .. wallpapers[current] .. "b.png"
   if not exists(blurred_wallpaper) then
      naughty.notify({
         preset = naughty.config.presets.normal,
         title = "Wallpaper",
         text = "Generating blurred wallpaper..."
      })
      -- uses image magick to create a blurred version of the wallpaper
      awful.spawn.with_shell("convert -filter Gaussian -blur 0x10 " .. wallpaper .. " " .. blurred_wallpaper)
   end
end

current = math.random(1,max)
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
   current = current + 1
   if (current > max) then
      current = 1
   end
   wallpaper = wallpaper_dir .. "/".. wallpapers[current] ..".jpg"
   blurred_wallpaper = wallpaper_dir .. "/" .. wallpapers[current] .. "b.png"
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
   for _ in pairs(t:clients()) do
      blur()
      return
   end
   -- unblur if tag has no clients
   unblur()
end)

-- check if wallpaper should be blurred on client open
client.connect_signal("manage", function(c)
   blur()
end)

-- check if wallpaper should be unblurred on client close
client.connect_signal("unmanage", function(c)
   local t = awful.screen.focused().selected_tag
   -- check if tag has any clients
   for _ in pairs(t:clients()) do
      return
   end
   -- unblur if tag has no clients
   unblur()
end)

gears.timer {
   timeout = timeout,
   call_now = true,
   autostart = true,
   callback = next_image
}