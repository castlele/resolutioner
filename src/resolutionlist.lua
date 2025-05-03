---@class ResolutionList
---@field resolutions table<string, {w: number, h: number}>
---@field wm WindowManager
---@field x number
---@field y number
---@field width number
---@field rowheight number
---@field font love.Font
local M = {}

---@param resolutions table<string, {w: number, h: number}>
---@param wm WindowManager
---@param x number
---@param y number
---@param width number
---@param rowheight number
---@param font love.Font
---@return ResolutionList
function M:new(resolutions, wm, x, y, width, rowheight, font)
   local this = {
      resolutions = resolutions,
      wm = wm,
      x = x,
      y = y,
      width = width,
      rowheight = rowheight,
      font = font,
   }

   setmetatable(this, self)

   self.__index = self

   return this
end

function M:update(dt)
end

function M:mousepressed(x, y, button)
   if button ~= 1 then
      return
   end

   local i = 0

   for res, size in pairs(self.resolutions) do
      local w = self.font:getWidth(res)
      local h = self.rowheight

      if love.isMouseInside(self.x, self.y + i * h, w, h) then
         self.wm:setResolution(size.w, size.h)
      end

      i = i + 1
   end
end

function M:draw()
   local i = 0
   local w, h = self.wm:getWidth(), self.wm:getHeight()

   for res, size in pairs(self.resolutions) do
      local x = self.x
      local y = self.y + i * self.rowheight

      love.graphics.setFont(self.font)

      if w == size.w and h == size.h then
         love.graphics.setColor(0.5, 0.5, 0.5, 0.5)

         love.graphics.rectangle(
            "fill",
            x,
            y,
            self.font:getWidth(res),
            self.rowheight
         )
      end

      love.graphics.setColor(1, 1, 1, 1)
      love.graphics.print(
         res,
         x,
         y + self.rowheight / 2 - self.font:getHeight() / 2
      )

      i = i + 1
   end
end

return M
