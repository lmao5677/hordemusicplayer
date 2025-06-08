if engine.ActiveGamemode() ~= "horde" then return end
-- Handles music pack reading and loading.
HordeMusicPlayer_InitialPacksLoaded = false

-- Gets the save file of currently enabled music packs.
function HordeMusicPlayer_LoadEnabledPacks()
	if HordeMusicPlayer_InitialPacksLoaded then return end
	
	HordeMusicPlayer_InitialPacksLoaded = true
	-- Create folder if empty.
	if not file.Exists("hordemusicplayer", "DATA") then
		file.CreateDir("hordemusicplayer")
	end
	if not file.Exists("hordemusicplayer/enabled_packs.json", "DATA") then
		file.Write("hordemusicplayer/enabled_packs.json","{}")
	end
	
	local PackJson = file.Read("hordemusicplayer/enabled_packs.json","DATA")
	local PackTable = util.JSONToTable(PackJson) or {}
	HordeMusicPlayer_EnabledMusicPacks = PackTable
	
	print("[HMP] - Music Packs loaded.")
end

function HordeMusicPlayer_SaveEnabledPacks()
	-- Create folder if empty.
	if not file.Exists("hordemusicplayer", "DATA") then
		file.CreateDir("hordemusicplayer")
	end
	
	local JSONValue = util.TableToJSON(HordeMusicPlayer_EnabledMusicPacks)
	file.Write("hordemusicplayer/enabled_packs.json",JSONValue)
end

-- Checks if the music pack is enabled (PackName : string)
function HordeMusicPlayer_PackIsEnabled(PackName)
	return HordeMusicPlayer_EnabledMusicPacks[PackName] or false
end

-- Networks music pack data from the server to a client (or all clients if none provided)
function HordeMusicPlayer_SyncMusicPacksToClients(ply)
	net.Start("HMP_SendClientMusicPacks")
	net.WriteTable(HordeMusicPlayer_EnabledMusicPacks)
	if IsValid(ply) then
		net.Send(ply)
	else
		net.Broadcast()
	end
end

-- Enables/Disables music pack (PackName : string, Enabled : boolean)
function HordeMusicPlayer_ChangePackState(PackName, Enabled)
	HordeMusicPlayer_EnabledMusicPacks[PackName] = Enabled
	HordeMusicPlayer.BuildAllTracks()
	HordeMusicPlayer_SyncMusicPacksToClients()
	HordeMusicPlayer_SaveEnabledPacks()
end

HordeMusicPlayer_LoadEnabledPacks()