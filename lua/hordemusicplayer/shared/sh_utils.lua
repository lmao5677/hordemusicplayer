if engine.ActiveGamemode() ~= "horde" then return end
-- Checks for admin privelleges when we want to change admin config stuff.
function HordeMusicPlayer_CanPlayerUseConfig(ply)
	local AdminsAllowed = GetConVar("hordemusicplayer_admins_use_config"):GetBool()
	return (AdminsAllowed and ply:IsAdmin()) or (not AdminsAllowed and ply:IsSuperAdmin())
end

-- Music Packs currently enabled, shared between server and client (for reading and writing).
HordeMusicPlayer_EnabledMusicPacks = {}
