local MusicPackFolder = "hordemusicplayer/packs/"

local Files, Folders = file.Find(MusicPackFolder .. "*.lua", "LUA")

print(MusicPackFolder)
for _, Filename in ipairs(Files) do
	print("FOUND FILE!")
	AddCSLuaFile(MusicPackFolder .. Filename) -- Register on Client aswell 
    include(MusicPackFolder .. Filename) -- Register Pack file
end