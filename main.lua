require("src.loveext")
require("src.config")
local listener = require("src.eventlistener")
local wm = require("src.windowmanager")
local root = require("src.rootview")

function love.load()
   wm:load()
   root:load(wm)
end

function love.update(dt)
   listener:listen()
   wm:update()
   root:update(dt)
end

---@param file love.DroppedFile
function love.filedropped(file)
   file:open("r")

   local fileData = file:read("data")
   local success, imageData = pcall(love.image.newImageData, fileData)

   if success then
      local image = love.graphics.newImage(imageData)
      root:insertImage(image)
   else
      root:showBanner(
         string.format("File isn't an image: %s", file:getFilename())
      )
   end

   file:close()
end

function love.mousepressed(x, y, button, istouch, presses)
   root:mousepressed(x, y, button, istouch, presses)
end

function love.draw()
   love.graphics.clear(0.2, 0.2, 0.2, 1)
   root:draw()
end
