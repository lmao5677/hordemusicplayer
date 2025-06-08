if engine.ActiveGamemode() ~= "horde" then return end

HordeMusicPlayer_ShuffleSeed = -1

-- Load Music Packs on server so client can fetch them later
hook.Add("Initialize", "HMP_ObtainPacksEnabled", function()
	HordeMusicPlayer_LoadEnabledPacks()
	
	local UseAllPacks = GetConVar("hordemusicplayer_useallpacks"):GetBool()
	HordeMusicPlayer_ShuffleSeed = math.random(1000000)
	
	HordeMusicPlayer.BuildAllTracks()
	
	HordeMusicPlayer_CurrentIntermissionTrack = HordeMusicPlayer_PickIntermissionTrack()
	
end)

util.AddNetworkString("HMP_GetMusicPacks")
util.AddNetworkString("HMP_SendClientMusicPacks")

-- Players/Late players recieve music pack loading
net.Receive("HMP_GetMusicPacks",function(len,ply)
	HordeMusicPlayer_SyncMusicPacksToClients(ply)
	
	-- Track playing functionality.
	if HordeMusicPlayer_CurrentIntermissionTrack != -1 and HordeMusicPlayer_TrackingState == 0 then -- Intermission
		HordeMusicPlayer_PlayTrackToClients(HordeMusicPlayer_CurrentIntermissionTrack, 0, false, ply)
	elseif HordeMusicPlayer_CurrentCombatTrack != -1 and HordeMusicPlayer_TrackingState == 1 then -- Combat
		HordeMusicPlayer_PlayTrackToClients(HordeMusicPlayer_CurrentCombatTrack, 1, false, ply)
	elseif HordeMusicPlayer_CurrentBossTrack != -1 and HordeMusicPlayer_TrackingState >= 2 then -- Boss
		HordeMusicPlayer_PlayTrackToClients(HordeMusicPlayer_CurrentBossTrack, 2, false, ply)
	end
end)

