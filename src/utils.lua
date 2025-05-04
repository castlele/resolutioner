local M = {}

---@param t table<T>
---@return table<T>
function M.reversed(t)
   local reversed = {}

   for i = #t, 1, -1 do
      table.insert(reversed, t[i])
   end

   return reversed
end

return M
