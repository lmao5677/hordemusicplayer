if engine.ActiveGamemode() ~= "horde" then return end

HordeMusicPlayerClient_CurrentMusic = nil
HordeMusicPlayerClient_OldMusic = nil

local PreviousTrackType = 1

net.Receive("HMP_ClientPlayTrack",	function()
	local TrackID = net.ReadUInt(8)
	local TrackType = net.ReadUInt(2)
	local Combat_Structureless = net.ReadBool()
	local ShowHint = net.ReadBool()
	
	-- Remove any timers
	timer.Remove("HMP_ClientTrackLoop")
	HordeMusicPlayer_PlayClientTrack(TrackID, TrackType, Combat_Structureless, ShowHint)
end)

function HordeMusicPlayerClient_FadeTrack(Sound)
	HordeMusicPlayerClient_OldMusic = Sound
	HordeMusicPlayerClient_OldMusic:FadeOut(0.35)
	timer.Create("HMP_ClientFadeTrackOut", 0.35, 1, function()
		HordeMusicPlayerClient_OldMusic:Stop()
		HordeMusicPlayerClient_OldMusic = nil
	end)
end

function HordeMusicPlayerClient_AdjustMusicVolume()
	if not HordeMusicPlayerClient_CurrentMusic then return end
	local MusicVolume = GetConVar("hordemusicplayer_client_volume"):GetFloat()
	HordeMusicPlayerClient_CurrentMusic:ChangeVolume(MusicVolume,0.1)
end

function HordeMusicPlayerClient_FadeTrackIn()
	local MusicVolume = GetConVar("hordemusicplayer_client_volume"):GetFloat()
	HordeMusicPlayerClient_CurrentMusic:ChangeVolume(0,0)
	HordeMusicPlayerClient_CurrentMusic:ChangeVolume(MusicVolume,0.5)
end

net.Receive("HMP_ClientStopTrack", function()
	if HordeMusicPlayerClient_CurrentMusic then
		timer.Remove("HMP_ClientTrackLoop")
		HordeMusicPlayerClient_FadeTrack(HordeMusicPlayerClient_CurrentMusic)
		HordeMusicPlayerClient_CurrentMusic = nil
	end
end)

-- Plays the track to the client.
function HordeMusicPlayer_PlayClientTrack(TrackID, TrackType, Combat_Structureless, ShowHint)
	if HordeMusicPlayerClient_CurrentMusic then
		HordeMusicPlayerClient_FadeTrack(HordeMusicPlayerClient_CurrentMusic)
		HordeMusicPlayerClient_CurrentMusic = nil
	end
	local TrackData = nil
	
	local IntermissionMusicEnabled = GetConVar("hordemusicplayer_client_intermission_enabled"):GetBool()
	local CombatMusicEnabled = GetConVar("hordemusicplayer_client_combat_enabled"):GetBool()
	local BossMusicEnabled = GetConVar("hordemusicplayer_client_boss_enabled"):GetBool()
	
	if TrackType == 0 then -- Intermission
		if not IntermissionMusicEnabled then return end 
		TrackData = HordeMusicPlayer.IntermissionTracks[TrackID]
	elseif TrackType == 1 then
		if not CombatMusicEnabled then return end 
		if Combat_Structureless then -- Combat
			TrackData = HordeMusicPlayer.CombatTracks["NOSTRUCT"][TrackID]
		else
			local Wave = HORDE.current_wave % 10
			TrackData = HordeMusicPlayer.CombatTracks[Wave][TrackID]
		end
	elseif TrackType == 2 then -- Boss Phase 1
		if not BossMusicEnabled then return end
		TrackData = HordeMusicPlayer.BossTracks[TrackID]["Phase1"]
	else -- Boss Phase 2
		if not BossMusicEnabled then return end
		TrackData = HordeMusicPlayer.BossTracks[TrackID]["Phase2"]
		if not TrackData then 
			if PreviousTrackType == 2 then return end -- Don't cut off phase 1 again.
			TrackData = HordeMusicPlayer.BossTracks[TrackID]["Phase1"]
		end
		
	
	end
	
	local PackID = nil
	if TrackType < 2 then
		PackID = TrackData["PackID"]
	else
		PackID = HordeMusicPlayer.BossTracks[TrackID]["PackID"]
	end
	 
	local PackData = HordeMusicPlayer.MusicPacks[PackID]
	local FolderName = PackData.Folder
	
	local TruePath = "hordemusicplayer/"..FolderName.."/"..TrackData["TrackPath"]
	
	HordeMusicPlayerClient_CurrentMusic = CreateSound(LocalPlayer(), TruePath)
	HordeMusicPlayerClient_CurrentMusic:SetSoundLevel(0)
	HordeMusicPlayerClient_CurrentMusic:Play()
	HordeMusicPlayerClient_FadeTrackIn()
	
	if GetConVar("hordemusicplayer_client_hints_enabled"):GetBool() and TrackData and ShowHint then 
		CreateMusicHint(TrackData)
	end
	
	PreviousTrackType = TrackType
end