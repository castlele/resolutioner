local toolbox = require("src.toolbox")
local imageView = require("src.imageview")

---@class ViewInfo
---@field x number
---@field y number
---@field width number
---@field height number
---@field isHidden boolean
---@field text love.Text

---@class ImageEditor
---@field private images table<ImageView>
---@field private wm WindowManager
---@field private selectedImageIndex integer?
---@field private toolbox ToolboxView
---@field private imageInfo ViewInfo
---@field private draggingX number?
---@field private draggingY number?
local M = {}

local infoViewConstants = {
   height = 32,
}

---@class ImageEditorConfig
---@field wm WindowManager
---@param args ImageEditorConfig
---@return ImageEditor
function M:new(args)
   local this = {}

   local font = love.graphics.newFont(
      Config.res.fonts.default.path,
      Config.res.fonts.default.size
   )

   this.images = {}
   this.wm = args.wm
   this.selectedImageIndex = nil
   this.draggingX = nil
   this.draggingY = nil
   this.imageInfo = {
      x = 0,
      y = this.wm:getHeight() - infoViewConstants.height,
      width = 0,
      height = infoViewConstants.height,
      isHidden = true,
      text = love.graphics.newText(font),
   }
   this.toolbox = toolbox:new(this.wm, {
      -- frameSetup = function()
      --    if this.selectedImageIndex then
      --       local isFrameEditing = self.images[self.selectedImageIndex].isFrameEditing
      --       self.images[self.selectedImageIndex].isFrameEditing = not isFrameEditing
      --    end
      -- end,
      layerUp = function()
         if
            this.selectedImageIndex
            and this.selectedImageIndex < #this.images
         then
            local image = this.images[this.selectedImageIndex]
            local nextImage = this.images[this.selectedImageIndex + 1]

            this.images[this.selectedImageIndex] = nextImage
            this.images[this.selectedImageIndex + 1] = image
            this.selectedImageIndex = this.selectedImageIndex + 1
         end
      end,
      layerDown = function()
         if this.selectedImageIndex and this.selectedImageIndex > 1 then
            local image = this.images[this.selectedImageIndex]
            local prevImage = this.images[this.selectedImageIndex - 1]

            this.images[this.selectedImageIndex] = prevImage
            this.images[this.selectedImageIndex - 1] = image
            this.selectedImageIndex = this.selectedImageIndex - 1
         end
      end,
      addScale = function()
         if this.selectedImageIndex then
            local image = this.images[this.selectedImageIndex]

            image.sx = image.sx * 1.1
            image.sy = image.sy * 1.1
         end
      end,
      subtractScale = function()
         if this.selectedImageIndex then
            local image = this.images[this.selectedImageIndex]

            image.sx = image.sx / 1.1
            image.sy = image.sy / 1.1
         end
      end,
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

   for _, image in ipairs(self.images) do
      image:update(dt)
   end

   if self.selectedImageIndex then
      self.toolbox:show()
      self:handleDrag()
   else
      self.toolbox:hide()
   end

   self:updateImageInfo()
end

function M:mousepressed(x, y, b, istouch, presses)
   if self.toolbox:mousepressed(x, y, b, istouch, presses) then
      return
   end

   for i = #self.images, 1, -1 do
      local image = self.images[i]

      if love.isMouseInside(image.x, image.y, image.width, image.height) then
         if b == 1 then
            if self.selectedImageIndex == i then
               image.isFrameEditing = not image.isFrameEditing
            end

            self.selectedImageIndex = i
         end

         if b == 2 then
            self.selectedImageIndex = nil
         end

         break
      end
   end
end

---@param image love.ImageData
function M:insertImage(image)
   ---@type ImageView
   local info = imageView:new {
      source = image,
      x = 0,
      y = 0,
      sx = 1,
      sy = 1,
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
   for i, image in ipairs(self.images) do
      image:draw(i == self.selectedImageIndex)
   end

   self:drawImageInfo()
   self.toolbox:draw()
end

---@private
---@return boolean
function M:isAnyImageFrameEditing()
   for _, image in ipairs(self.images) do
      if image.isFrameEditing then
         return true
      end
   end

   return false
end

---@private
function M:handleDrag()
   if self.images[self.selectedImageIndex].isFrameEditing then
      self.draggingX, self.draggingY = nil, nil
      return
   end

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
function M:updateImageInfo()
   if not self.selectedImageIndex then
      self.imageInfo.isHidden = true
      return
   end

   local image = self.images[self.selectedImageIndex]

   local text = string.format(
      "%dx%d; scale: %.2fx%.2f",
      image.source:getWidth(),
      image.source:getHeight(),
      image.sx,
      image.sy
   )

   self.imageInfo.text:set(text)
   self.imageInfo.width = self.imageInfo.text:getWidth()
   self.imageInfo.x = (self.wm:getWidth() - self.imageInfo.width) / 2
   self.imageInfo.y = self.wm:getHeight() - infoViewConstants.height
   self.imageInfo.isHidden = false
end

function M:drawImageInfo()
   if self.imageInfo.isHidden then
      return
   end

   love.graphics.setColor(0, 0, 0, 0.5)
   love.graphics.rectangle(
      "fill",
      self.imageInfo.x,
      self.imageInfo.y,
      self.imageInfo.width,
      self.imageInfo.height
   )

   love.graphics.setColor(Config.colors.white)
   love.graphics.draw(self.imageInfo.text, self.imageInfo.x, self.imageInfo.y)
end

return M
