---@class WindowManager
local M = {
   resolutions = {
      -- 16:9
      ["2560x1440"] = { w = 2560, h = 1440 },
      ["1920x1080"] = { w = 1920, h = 1080 },
      ["1366x768"] = { w = 1366, h = 768 },
      ["1280x720"] = { w = 1280, h = 720 },

      -- 16:10
      ["1920x1200"] = { w = 1920, h = 1200 },
      ["1680x1050"] = { w = 1680, h = 1050 },
      ["1440x900"] = { w = 1440, h = 900 },
      ["1280x800"] = { w = 1280, h = 800 },

      -- 4:3
      ["1024x768"] = { w = 1024, h = 768 },
      ["800x600"] = { w = 800, h = 600 },
      ["640x480"] = { w = 640, h = 480 },
   }
}

function M:load()
   love.window.setTitle(Config.app.name)
end

function M:update()
end

function M:setResolution(w, h)
   love.window.setMode(w, h, {
      resizable = true,
   })
end

function M:getWidth()
   return love.graphics.getWidth()
end

function M:getHeight()
   return love.graphics.getHeight()
end

return M
