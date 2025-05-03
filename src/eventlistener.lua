require("lovekit.ext.loveext")

---@class EventListener
local M = {
   quit = "lctrl+q",
}

function M:listen()
   love.quitIfNeeded(self.quit)
end

return M
