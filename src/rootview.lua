local banner = require("src.banner")
local button = require("src.button")
local resolutionList = require("src.resolutionlist")

---@class RootView
---@field private backgroundImage love.Image?
---@field private wm WindowManager
---@field private font love.Font
---@field private closeButton Button
---@field private resolutions ResolutionList
local M = {}

local dragAndDropText = "Drag and drop an image on me, please!"

---@param wm WindowManager
function M:load(wm)
   local font = Config.res.fonts.default

   self.wm = wm
   self.font = love.graphics.newFont(font.path, font.size)
   self.closeButton = button:new {
      action = function()
         if self.backgroundImage then
            self.backgroundImage = nil
         end
      end,
      x = self.wm:getWidth() - 32 - 16,
      y = 16,
      width = 32,
      height = 32,
      image = love.graphics.newImage(Config.res.images.close),
   }
   self.resolutions =
      resolutionList:new(self.wm.resolutions, self.wm, 0, 0, 100, 20, self.font)
end

function M:update(dt)
   self.closeButton:update(dt)
   self.resolutions:update(dt)
   banner:update(dt)
end

function M:mousepressed(x, y, b, istouch, presses)
   self.resolutions:mousepressed(x, y, b)

   if presses == 2 then
      self.isFillScreen = not self.isFillScreen
   end
end

---@return boolean
function M:isImageShown()
   return self.backgroundImage ~= nil
end

---@param image love.Image?
function M:setImage(image)
   self.backgroundImage = image
end

---@param message string
function M:showBanner(message)
   banner:show(message, self.font, self.wm:getWidth() / 2, 0)
end

function M:draw()
   if not self.backgroundImage then
      love.graphics.setFont(self.font)

      local textW = self.font:getWidth(dragAndDropText)
      local textH = self.font:getHeight()

      love.graphics.print(
         dragAndDropText,
         self:centerX() - textW / 2,
         self:centerY() - textH / 2
      )
   else
      if self.isFillScreen then
         local sx = self.wm:getWidth() / self.backgroundImage:getWidth()
         local sy = self.wm:getHeight() / self.backgroundImage:getHeight()

         love.graphics.draw(self.backgroundImage, 0, 0, 0, sx, sy)
      else
         local x = self:centerX() - self.backgroundImage:getWidth() / 2
         local y = self:centerY() - self.backgroundImage:getHeight() / 2

         love.graphics.draw(self.backgroundImage, x, y)
      end
      self.closeButton:draw()
   end

   self.resolutions:draw()
   banner:draw()
end

---@private
---@return number
function M:centerX()
   return self.wm:getWidth() / 2
end

---@private
---@return number
function M:centerY()
   return self.wm:getHeight() / 2
end

return M
