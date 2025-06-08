if engine.ActiveGamemode() ~= "horde" then return end
-- Shared
include("hordemusicplayer/shared/sh_utils.lua")
include("hordemusicplayer/shared/sh_musicpacks.lua")

if SERVER then
	include("hordemusicplayer/server/sv_musicpack_data.lua")
	include("hordemusicplayer/server/sv_musicconfig.lua")
	include("hordemusicplayer/server/sv_musictrack.lua")
end