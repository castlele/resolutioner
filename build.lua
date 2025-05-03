---@diagnostic disable

---@return string
local function getCurrentFileName()
   local filePath = vim.fn.expand("%")
   local pathComponents = vim.fn.split(filePath, "/")
   return pathComponents[#pathComponents]
end

local function getLove()
   return io.popen("which love", "r"):read("*l")
end

local function getOpenCmd()
   local osname = require("cluautils.os").getName()

   if osname == "Linux" then
      return "xdg-open"
   elseif osname == "MacOS" then
      return "open"
   end
end

local function publishCmd()
   local osname = require("cluautils.os").getName()

   local pack = "zip -9 -r ./bin/LovePlayer.love ."
   -- local pack = "rm -rf ./bin/*"

   local downloadAppImage

   if osname == "Linux" then
      local deskFile = [[
[Desktop Entry]\n\
Name=LovePlayer\n\
Comment=Simple music player made with LÖVE\n\
MimeType=application/x-love-game;\n\
Exec=LovePlayer %f\n\
Type=Application\n\
Categories=AudioVideo;\n\
Terminal=false\n\
Icon=love\n\
NoDisplay=true]]
      downloadAppImage = string.format(
         [[
         wget https://github.com/love2d/love/releases/download/11.5/love-11.5-x86_64.AppImage && \
         chmod +x love-11.5-x86_64.AppImage && \
         ./love-11.5-x86_64.AppImage --appimage-extract && \
         cat squashfs-root/bin/love LovePlayer.love > squashfs-root/bin/LovePlayer && \
         rm squashfs-root/bin/love && \
         chmod +x squashfs-root/bin/LovePlayer && \
         echo "%s" > squashfs-root/love.desktop && \
         appimagetool squashfs-root LovePlayer.AppImage]],
         deskFile
      )
   else
      downloadAppImage = "echo 'Installation for " .. osname .. "'"
   end

   return string.format(
      [[
   rm -rf ./bin/* && \
   %s && \
   cd ./bin && \
   %s && \
   cd ..
   ]],
      pack,
      downloadAppImage
   )
end

conf = {
   run = getLove() .. " .",
   publish = publishCmd(),
}
