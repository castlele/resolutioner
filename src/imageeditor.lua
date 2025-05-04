local toolbox = require("src.toolbox")
local utils = require("src.utils")

---@class ImageInfo
---@field source love.Image
---@field x number
---@field y number
---@field width number
---@field height number

---@class ImageEditor
---@field private images table<love.Image>
---@field private wm WindowManager
---@field private selectedImageIndex integer?
---@field private toolbox ToolboxView
---@field private draggingX number?
---@field private draggingY number?
local M = {}

---@class ImageEditorConfig
---@field wm WindowManager
---@param args ImageEditorConfig
---@return ImageEditor
function M:new(args)
   local this = {}

   this.images = {}
   this.wm = args.wm
   this.selectedImageIndex = nil
   this.draggingX = nil
   this.draggingY = nil
   this.toolbox = toolbox:new(this.wm, {
      remove = function()
         if this.selectedImageIndex then
            table.remove(this.images, this.selectedImageIndex)
            this.selectedImageIndex = nil
         end
      end,
   })

   setmetatable(this, self)

   self.__index = self

   return this
end

function M:update(dt)
   self.toolbox:update(dt)

   if self.selectedImageIndex then
      self.toolbox:show()
      self:handleDrag()
   else
      self.toolbox:hide()
   end
end

function M:mousepressed(x, y, b, istouch, presses)
   self.toolbox:mousepressed(x, y, b, istouch, presses)

   for i, image in ipairs(utils.reversed(self.images)) do
      if
         x >= image.x
         and x <= image.x + image.width
         and y >= image.y
         and y <= image.y + image.width
      then
         self.selectedImageIndex = i
         break
      end
   end
end

---@param image love.Image
function M:insertImage(image)
   ---@type ImageInfo
   local info = {
      source = image,
      x = 0,
      y = 0,
      width = image:getWidth(),
      height = image:getHeight(),
   }

   table.insert(self.images, info)
end

---@return boolean
function M:isAnyImages()
   return #self.images > 0
end

function M:draw()
   for _, image in ipairs(self.images) do
      -- local sx = self.wm:getWidth() / image:getWidth()
      -- local sy = self.wm:getHeight() / image:getHeight()

      love.graphics.draw(image.source, image.x, image.y)
   end

   self:drawSelection()
   self.toolbox:draw()
end

---@private
function M:handleDrag()
   if not love.mouse.isDown(1) and self.selectedImageIndex then
      self.draggingX, self.draggingY = nil, nil
      return
   end

   if not self.draggingX or not self.draggingY then
      self.draggingX, self.draggingY = love.mouse.getPosition()
   end

   local x, y = love.mouse.getPosition()

   local image = self.images[self.selectedImageIndex]

   local dx = x - self.draggingX
   local dy = y - self.draggingY

   image.x = image.x + dx
   image.y = image.y + dy

   self.draggingX, self.draggingY = x, y
end

---@private
function M:drawSelection()
   if not self.selectedImageIndex then
      return
   end

   local image = self.images[self.selectedImageIndex]

   love.graphics.setColor(Config.colors.accent)

   love.graphics.setLineWidth(2)

   love.graphics.rectangle("line", image.x, image.y, image.width, image.height)
end

return M
