local Button = require("src.button")

---@class ToolboxView
---@field private wm WindowManager
---@field private buttons table<Button>
---@field private x number
---@field private y number
---@field private width number
---@field private height number
---@field private isShowing boolean
---@field private isDismissing boolean
---@field private presentingAnimationSpeed number
---@field private progress number animation progress from 0 to 1
local M = {}

local buttonSize = 32

---@class ActionsConfig
---@field remove fun()
---@param wm WindowManager
---@param actions ActionsConfig
---@return ToolboxView
function M:new(wm, actions)
   local this = {}

   this.wm = wm
   this.y = 0
   this.width = buttonSize
   this.buttons = {}
   this.isShowing = false
   this.isDismissing = false
   this.progress = 0
   this.presentingAnimationSpeed = 0.1

   local buttonIndex = 0

   for actionName, action in pairs(actions) do
      local buttonConfig = {
         action = action,
         x = 0,
         y = buttonIndex * buttonSize,
         width = buttonSize,
         height = buttonSize,
         image = love.graphics.newImage(Config.res.images[actionName]),
      }
      local button = Button:new(buttonConfig)
      table.insert(this.buttons, button)
   end

   setmetatable(this, self)

   self.__index = self

   return this
end

function M:update(dt)
   self.height = self.wm:getHeight()

   local p = dt + self.presentingAnimationSpeed

   if self.isShowing then
      self.progress = math.min(self.progress + p, 1)
   end

   if self.isDismissing then
      self.progress = math.max(self.progress - p, 0)
   end

   if self.progress >= 1 and self.isShowing then
      self.isShowing = false
   end

   if self.progress <= 0 and self.isDismissing then
      self.progress = 0
      self.isDismissing = false
   end

   local newX = self.wm:getWidth() - buttonSize * self.progress

   if newX ~= self.x then
      self.x = newX

      for _, button in ipairs(self.buttons) do
         button.x = self.x
      end
   end
end

function M:mousepressed(x, y, b, istouch, presses)
   for _, button in ipairs(self.buttons) do
      button:mousepressed(x, y, b, istouch, presses)
   end
end

function M:show()
   self.isShowing = true
   self.isDismissing = false
end

function M:hide()
   self.isShowing = false
   self.isDismissing = true
end

function M:draw()
   love.graphics.setColor(Config.colors.secondary)
   love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

   for _, button in ipairs(self.buttons) do
      button:draw()
   end
end

return M
