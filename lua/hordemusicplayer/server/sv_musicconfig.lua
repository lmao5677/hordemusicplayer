if engine.ActiveGamemode() ~= "horde" then return end
-- Handles Server Sided music config related stuff.

local ConvarWhitelist = {
	["hordemusicplayer_enabled"] = true,
	["hordemusicplayer_useallpacks"] = true,
}

util.AddNetworkString("HMP_AdminSettingChanged")
util.AddNetworkString("HMP_ToggleMusicPack")

local function HMP_ServerSettingChanged(ConVarName, NewValue, Player)
	if ConVarName == "hordemusicplayer_enabled" then
		if NewValue then
			Player:ChatPrint( "[HMP] - Horde Music Player Disabled!" )
			HordeMusicPlayer_StopClientTrack()
		else
			Player:ChatPrint( "[HMP] - Horde Music Player Enabled!" )
			HordeMusicPlayer_PickNextTrack()
		end
	elseif ConVarName == "hordemusicplayer_useallpacks" then
		Player:ChatPrint( "[HMP] - Pack Selection Changed!" )
		HordeMusicPlayer.BuildAllTracks()
		HordeMusicPlayer_SyncMusicTracksToClients()
	end
end

net.Receive("HMP_AdminSettingChanged", function(len, ply)
    
	-- Sanity check 1/2: Config whitelist (since we don't want people messing w it)
    if not HordeMusicPlayer_CanPlayerUseConfig(ply) then return end

    -- Recieve data
    local SettingName = net.ReadString()
    local SettingValue = net.ReadBool()

    -- Sanity check 2/2: Making sure they don't change some random cvar lol.
    if not ConvarWhitelist["hordemusicplayer_"..SettingName] then return end
	GetConVar("hordemusicplayer_"..SettingName):SetBool(SettingValue)
	HMP_ServerSettingChanged("hordemusicplayer_"..SettingName,SettingValue,ply)
	
	
end)

net.Receive("HMP_ToggleMusicPack", function(len, ply)

	-- Sanity check to again prevent people who shouldn't be able to change anything here.
    if not HordeMusicPlayer_CanPlayerUseConfig(ply) then return end
	
	local PackID = net.ReadUInt(8)
	
	-- Second sanity check to make sure we're not looking at non-existant music pack ids.
	if not HordeMusicPlayer.MusicPacks[PackID] then return end
	
	local PackName = HordeMusicPlayer.MusicPacks[PackID].Name
	local PackState = HordeMusicPlayer_EnabledMusicPacks[PackName]
	
	HordeMusicPlayer_ChangePackState(PackName,not PackState)
end)