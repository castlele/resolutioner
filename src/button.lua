---@class Button
---@field private action fun()?
---@field private x number
---@field private y number
---@field private width number
---@field private height number
---@field private image love.Image?
local M = {}

---@class ButtonConfig
---@field action fun()?
---@field x number
---@field y number
---@field width number
---@field height number
---@field image love.Image
---@param config ButtonConfig?
---@return Button
function M:new(config)
   ---@type Button
   local this = {} ---@diagnostic disable-line

   if config then
      this.action = config.action
      this.x = config.x
      this.y = config.y
      this.width = config.width
      this.height = config.height
      this.image = config.image
   else
      this.x = 0
      this.y = 0
      this.width = 0
      this.height = 0
   end

   setmetatable(this, self)

   self.__index = self

   return this
end

function M:update(dt)
   if
      love.mouse.isDown(1)
      and love.isMouseInside(self.x, self.y, self.width, self.height)
   then
      if self.action then
         self.action()
      end
   end
end

function M:draw()
   love.graphics.draw(
      self.image,
      self.x,
      self.y,
      0,
      self.width / self.image:getWidth(),
      self.height / self.image:getHeight()
   )
end

return M
