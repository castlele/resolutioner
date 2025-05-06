---@class ImageView
---@field private source love.ImageData
---@field private drawable love.Image?
---@field private x number
---@field private y number
---@field private sx number
---@field private sy number
---@field private width number
---@field private height number
---@field private isFrameEditing boolean
local M = {}

local frameBorderWidth = 2.5
local frameBorderDragArea = 5

---@class ImageInfo
---@field source love.ImageData
---@field x number
---@field y number
---@field sx number
---@field sy number
---@field width number
---@field height number
---@param args ImageInfo
---@return ImageView
function M:new(args)
   local this = {
      source = args.source,
      x = args.x,
      y = args.y,
      sx = args.sx,
      sy = args.sy,
      width = args.width,
      height = args.height,
      isFrameEditing = false,
      isSelected = false,
   }

   setmetatable(this, self)

   self.__index = self

   return this
end

function M:update(dt)
   if not self.drawable then
      self.drawable = love.graphics.newImage(self.source)
   end

   if self.isFrameEditing then
      self:handleCursorAppearance()
      self:handleFrameDrag()
      self:cropIfNeeded()
   end
end

---@private
function M:cropIfNeeded()
   local cropped = love.image.newImageData(self.width, self.height)
   cropped:paste(self.source, 0, 0, 0, 0, self.width, self.height)

   self.drawable = love.graphics.newImage(cropped)
end

---@param isSelected boolean
function M:draw(isSelected)
   if self.drawable then
      love.graphics.draw(self.drawable, self.x, self.y, 0, self.sx, self.sy)
   end

   if isSelected then
      self:drawSelection()
   end
end

---@private
function M:handleCursorAppearance()
   ---@type love.Cursor
   local cursor
   local side = self:getDraggingSide()

   if side == "left" or side == "right" then
      cursor = love.mouse.getSystemCursor("sizewe")
   elseif side == "top" or side == "bottom" then
      cursor = love.mouse.getSystemCursor("sizens")
   else
      cursor = love.mouse.getSystemCursor("arrow")
   end

   love.mouse.setCursor(cursor)
end

---@private
function M:handleFrameDrag()
   if not love.mouse.isDown(1) then
      return
   end

   local x, y = love.mouse.getPosition()
   local side = self:getDraggingSide()

   if side == "left" then
      local delta = self.x - x
      self.x = x
      self.width = self.width + delta
   elseif side == "right" then
      self.width = x - self.x
   elseif side == "top" then
      local delta = self.y - y
      self.y = y
      self.height = self.height + delta
   elseif side == "bottom" then
      self.height = y - self.y
   end
end

---@return "left"|"right"|"top"|"bottom"|"none"
function M:getDraggingSide()
   ---@type "left"|"right"|"top"|"bottom"|"none"
   local side = "none"

   if
      love.isMouseInside(
         self.x - frameBorderDragArea,
         self.y,
         frameBorderDragArea * 2,
         self.height
      )
   then
      side = "left"
   elseif
      love.isMouseInside(
         self.x + self.width - frameBorderDragArea,
         self.y,
         self.width + frameBorderDragArea,
         self.height
      )
   then
      side = "right"
   elseif
      love.isMouseInside(
         self.x + frameBorderDragArea,
         self.y - frameBorderDragArea,
         self.width - frameBorderDragArea * 2,
         frameBorderDragArea * 2
      )
   then
      side = "top"
   elseif
      love.isMouseInside(
         self.x + frameBorderDragArea,
         self.y + self.height - frameBorderDragArea,
         self.width - frameBorderDragArea * 2,
         frameBorderDragArea * 2
      )
   then
      side = "bottom"
   end

   return side
end

---@private
function M:drawSelection()
   love.graphics.setColor(Config.colors.accent)

   love.graphics.setLineWidth(frameBorderWidth)

   love.graphics.rectangle(
      "line",
      self.x,
      self.y,
      self.width * self.sx,
      self.height * self.sy
   )
end

return M
