local banner = require("src.banner")
local resolutionList = require("src.resolutionlist")
local imageEditor = require("src.imageeditor")

---@class RootView
---@field private wm WindowManager
---@field private font love.Font
---@field private editor ImageEditor
---@field private resolutions ResolutionList
local M = {}

local dragAndDropText = "Drag and drop an image on me, please!"

---@param wm WindowManager
function M:load(wm)
   local font = Config.res.fonts.default

   self.wm = wm
   self.font = love.graphics.newFont(font.path, font.size)
   self.editor = imageEditor:new {
      wm = wm,
   }
   self.resolutions =
      resolutionList:new(self.wm.resolutions, self.wm, 0, 0, 100, 20, self.font)
end

function M:update(dt)
   self.resolutions:update(dt)
   self.editor:update(dt)
   banner:update(dt)
end

function M:mousepressed(x, y, b, istouch, presses)
   self.resolutions:mousepressed(x, y, b)
   self.editor:mousepressed(x, y, b, istouch, presses)
end

---@param image love.Image
function M:insertImage(image)
   self.editor:insertImage(image)
end

---@param message string
function M:showBanner(message)
   banner:show(message, self.font, self.wm:getWidth() / 2, 0)
end

function M:draw()
   if not self.editor:isAnyImages() then
      love.graphics.setFont(self.font)

      local textW = self.font:getWidth(dragAndDropText)
      local textH = self.font:getHeight()

      love.graphics.print(
         dragAndDropText,
         self:centerX() - textW / 2,
         self:centerY() - textH / 2
      )
   else
      self.editor:draw()
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
