---@class BannerInfo
---@field text love.Text
---@field x number
---@field y number
---@field width number
---@field height number
local BannerInfo = {}

---@class BannerInfoConfig
---@field text love.Text
---@field x number
---@field y number
---@field width number
---@field height number
---@param args BannerInfoConfig
---@return BannerInfo
function BannerInfo:new(args)
   local this = {}

   this.text = args.text
   this.x = args.x
   this.y = args.y
   this.width = args.width
   this.height = args.height

   setmetatable(this, self)

   self.__index = self

   return this
end

---@class BannerView
---@field private info BannerInfo?
---@field private isShowing boolean
---@field private isDismissing boolean
---@field private progress number animation progress from 0 to 1
---@field private startTime number
local M = {
   isShowing = false,
   isDismissing = false,
   progress = 0,
}

local padding = 8
local timeAlive = 5

function M:update(dt)
   if self.isShowing then
      self.progress = math.min(self.progress + dt, 1)
   end

   if self.isDismissing then
      self.progress = math.max(self.progress - dt, 0)
   end

   if self.progress >= 1 and self.isShowing then
      self.isShowing = false
      self.startTime = love.timer.getTime()
   end

   if self.startTime and love.timer.getTime() - self.startTime >= timeAlive then
      self.isDismissing = true
   end

   if self.progress <= 0 and self.isDismissing then
      self.progress = 0
      self.isDismissing = false
      self.startTime = nil
      self.info = nil
   end
end

---@param message string
---@param font love.Font
---@param sourceX number
---@param sourceY number
---@param width number?
function M:show(message, font, sourceX, sourceY, width)
   local text = love.graphics.newText(font, message)
   local w, wrappedMessage =
      font:getWrap(message, width or love.graphics.getWidth() - padding * 2)
   local h = font:getHeight() * #wrappedMessage + padding * 2

   if #wrappedMessage > 0 then
      text:set(table.concat(wrappedMessage, "\n"))
   end

   local config = BannerInfo:new {
      text = text,
      x = sourceX - w / 2,
      y = sourceY - h,
      width = w + padding * 2,
      height = h,
   }

   self.info = config
   self.isShowing = true
end

function M:draw()
   if not self.info then
      return
   end

   love.graphics.setColor(0, 0, 0, 0.5)

   love.graphics.rectangle(
      "fill",
      self.info.x,
      self.info.y + self.info.height * self.progress,
      self.info.width,
      self.info.height
   )

   love.graphics.setColor(1, 1, 1)

   love.graphics.draw(
      self.info.text,
      self.info.x + padding,
      self.info.y + self.info.height * self.progress
   )
end

return M
