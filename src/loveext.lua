function love.isMouseInside(x, y, w, h)
   local mouseX, mouseY = love.mouse.getPosition()

   return mouseX >= x and mouseX <= x + w and mouseY >= y and mouseY <= y + h
end
