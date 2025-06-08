if engine.ActiveGamemode() ~= "horde" then return end
-- Handles a lot of music track related things.

util.AddNetworkString("HMP_ClientPlayTrack")
util.AddNetworkString("HMP_ClientStopTrack")

HordeMusicPlayer_CurrentIntermissionTrack = -1
HordeMusicPlayer_CurrentCombatTrack = -1
HordeMusicPlayer_CurrentBossTrack = -1
HordeMusicPlayer_TrackingState = 0 -- Intermission
HordeMusicPlayer_TrackStructureless = false

-- Picks an intermission track to be played.
function HordeMusicPlayer_PickIntermissionTrack()
	if table.IsEmpty(HordeMusicPlayer.IntermissionTracks) then return -1 end
	
	local SongIndex = math.random(#HordeMusicPlayer.IntermissionTracks)
	return SongIndex
end

function HordeMusicPlayer_GetSpecificWave()
	return HORDE.current_wave % 10
end

-- Picks a combat track to be played.
function HordeMusicPlayer_PickCombatTrack()
	if table.IsEmpty(HordeMusicPlayer.CombatTracks) then print("exit code 1") return -1 end
	local CurrentWave = HORDE.current_wave 
	local Wave = CurrentWave % 10
	
	local TracksToPick = {}
	local NonStructureTracks = 0
	if HordeMusicPlayer.CombatTracks[Wave] and not table.IsEmpty(HordeMusicPlayer.CombatTracks[Wave]) then
		NonStructureTracks = #HordeMusicPlayer.CombatTracks[Wave]
		for _, TrackData in pairs(HordeMusicPlayer.CombatTracks[Wave]) do
			table.insert(TracksToPick, TrackData)
		end
	end
	
	if HordeMusicPlayer.CombatTracks["NOSTRUCT"] and not table.IsEmpty(HordeMusicPlayer.CombatTracks["NOSTRUCT"]) then
		for _, TrackData in pairs(HordeMusicPlayer.CombatTracks["NOSTRUCT"]) do
			table.insert(TracksToPick, TrackData)
		end
	end
	
	if table.IsEmpty(TracksToPick) then return -1, false end
	
	local SongIndex = math.random(#TracksToPick)
	local IsStructureless = SongIndex > NonStructureTracks
	HordeMusicPlayer_TrackStructureless = IsStructureless
	
	return SongIndex, IsStructureless
end

function HordeMusicPlayer_PickBossTrack()
	if table.IsEmpty(HordeMusicPlayer.BossTracks) then return -1 end
	
	local SongIndex = math.random(#HordeMusicPlayer.BossTracks)
	return SongIndex
end

function HordeMusicPlayer_GetCurrentPlayingSound()
	if HordeMusicPlayer_CurrentIntermissionTrack ~= -1 and HordeMusicPlayer_TrackingState == 0 then
		local TrackData = HordeMusicPlayer.IntermissionTracks[HordeMusicPlayer_CurrentIntermissionTrack]
		local PackData = HordeMusicPlayer.MusicPacks[TrackData["PackID"]]
		
		return "hordemusicplayer/"..PackData.Folder.."/"..TrackData["TrackPath"]
	elseif HordeMusicPlayer_CurrentCombatTrack ~= -1 and HordeMusicPlayer_TrackingState == 1 then
		local TrackData = nil 
		local PackData = nil 
		if HordeMusicPlayer_TrackStructureless then
			TrackData = HordeMusicPlayer.CombatTracks["NOSTRUCT"][HordeMusicPlayer_CurrentCombatTrack]
			PackData = HordeMusicPlayer.MusicPacks[TrackData["PackID"]]
		else
			TrackData = HordeMusicPlayer.CombatTracks[HordeMusicPlayer_GetSpecificWave()][HordeMusicPlayer_CurrentCombatTrack]
			PackData = HordeMusicPlayer.MusicPacks[TrackData["PackID"]]
		end
		
		return "hordemusicplayer/"..PackData.Folder.."/"..TrackData["TrackPath"]
	elseif HordeMusicPlayer_CurrentBossTrack ~= -1 and HordeMusicPlayer_TrackingState >= 2 then
		if HordeMusicPlayer_TrackingState == 2 then
			TrackData = HordeMusicPlayer.BossTracks[HordeMusicPlayer_CurrentBossTrack]["Phase1"]
			PackData = HordeMusicPlayer.MusicPacks[HordeMusicPlayer.BossTracks[HordeMusicPlayer_CurrentBossTrack]["PackID"]]
		else
			TrackData = HordeMusicPlayer.BossTracks[HordeMusicPlayer_CurrentBossTrack]["Phase2"]
			PackData = HordeMusicPlayer.MusicPacks[HordeMusicPlayer.BossTracks[HordeMusicPlayer_CurrentBossTrack]["PackID"]]
		end
		return "hordemusicplayer/"..PackData.Folder.."/"..TrackData["TrackPath"]
	end
	return ""
end

function HordeMusicPlayer_PickNextTrack()
	if HordeMusicPlayer_TrackingState == 0 then -- Intermission
		local TrackID = HordeMusicPlayer_PickIntermissionTrack()
		if TrackID == -1 then return end
		
		HordeMusicPlayer_CurrentIntermissionTrack = TrackID
		HordeMusicPlayer_PlayTrackToClients(TrackID, HordeMusicPlayer_TrackingState, false) 
	elseif HordeMusicPlayer_TrackingState == 1 then -- Combat
		local TrackID, NonStructure = HordeMusicPlayer_PickCombatTrack()
		if TrackID == -1 then return end
		
		HordeMusicPlayer_CurrentCombatTrack = TrackID
		HordeMusicPlayer_PlayTrackToClients(TrackID, HordeMusicPlayer_TrackingState, NonStructure) 
	else
		HordeMusicPlayer_PlayTrackToClients(HordeMusicPlayer_CurrentBossTrack, HordeMusicPlayer_TrackingState, NonStructure, nil, false) 
	end
end

-- Main logic that cycles through tracks.
function HordeMusicPlayer_RunTrackLogic()
	timer.Remove("HMP_ServerTrackTimer")
	
	local CurrentSound = HordeMusicPlayer_GetCurrentPlayingSound()
	if not CurrentSound then print("no current sound lawl") return end 
	
	timer.Create("HMP_ServerTrackTimer",SoundDuration(CurrentSound),1,function()
		HordeMusicPlayer_PickNextTrack()
	end)
end

-- Sends the relevant track information to a client (or clients)
function HordeMusicPlayer_PlayTrackToClients(TrackID, State, NoStructure, Player, ShowHint)
	if ShowHint == nil then ShowHint = true end
	net.Start("HMP_ClientPlayTrack")
	net.WriteUInt(TrackID,8) -- Track ID
	net.WriteUInt(State,2) -- Track type (intermission, combat, boss phase 1, boss phase2)
	net.WriteBool(false) -- NoStructure flag (only really used for combat)
	net.WriteBool(ShowHint) -- If it SHOULD display a hint.
	
	if Player then
		net.Send(Player)
	else
		net.Broadcast()
	end
	HordeMusicPlayer_RunTrackLogic()
end

function HordeMusicPlayer_StopClientTrack(Player)
	net.Start("HMP_ClientStopTrack")
	if Player then
		net.Send(Player)
	else
		net.Broadcast()
	end
end

-- Intermission Track Handling
hook.Add("HordeWaveEnd","HMP_WaveEndEvent",function(WaveNumber)
	HordeMusicPlayer_CurrentCombatTrack = -1
	HordeMusicPlayer_CurrentBossTrack = -1
	HordeMusicPlayer_TrackingState = 0
	if WaveNumber == 10 then HordeMusicPlayer_StopClientTrack() return end -- Game over, don't overwrite victory music.
	
	local TrackID = HordeMusicPlayer_PickIntermissionTrack()
	HordeMusicPlayer_CurrentIntermissionTrack = TrackID
	HordeMusicPlayer_PlayTrackToClients(TrackID, HordeMusicPlayer_TrackingState, false) 
end)

-- Combat Track Handling
hook.Add("HordeWaveStart", "HMP_WaveStartEvent", function(WaveNumber)
    HordeMusicPlayer_CurrentIntermissionTrack = -1
	
	HordeMusicPlayer_TrackingState = 1
	
	local TrackID, Structureless = HordeMusicPlayer_PickCombatTrack()
	if TrackID == -1 then return end
		
	HordeMusicPlayer_CurrentCombatTrack = TrackID
	HordeMusicPlayer_PlayTrackToClients(TrackID, HordeMusicPlayer_TrackingState, Structureless) 
		

end)

-- Phase 2 detection
hook.Add("PostEntityTakeDamage", "HMP_EntityPostDamage", function(ent, dmg, took)
	if took then
        if ent:IsNPC() and HordeMusicPlayer_TrackingState == 2 and dmg:GetAttacker():IsPlayer() and HORDE.horde_boss and HORDE.horde_boss:IsValid() and ent.Critical and ent == HORDE.horde_boss then
			timer.Create("HMP_OverwriteBossMusic",0.5,1,function()
				
				-- Yeah a little hacky but this will have to do
				timer.Remove("Horde_BossMusic")
				game.GetWorld():StopSound("music/hl1_song10.mp3")
				game.GetWorld():StopSound("music/hl2_song4.mp3")
				game.GetWorld():StopSound("music/hl2_song25_teleporter.mp3")
			end)
		
			HordeMusicPlayer_TrackingState = 3
			HordeMusicPlayer_PlayTrackToClients(HordeMusicPlayer_CurrentBossTrack, HordeMusicPlayer_TrackingState, Structureless) 
		end
	end
end)

-- Initial Boss Spawn
hook.Add("HordeBossSpawn","HMP_ListenForBoss",function(HordeBoss)

	if not HordeBoss then return end -- I think this gets called pre-maturely, had it error on Wave 1 (on a regular horde config)

	timer.Create("HMP_OverwriteBossMusic",1,1,function()
		-- Again, very hacky but will have to do.
		timer.Remove("Horde_BossMusic")
		local Properties = HordeBoss:Horde_GetBossProperties()
		local Music = Properties.music
		game.GetWorld():StopSound(Music)
	end)
	
	
	HordeMusicPlayer_TrackingState = 2
	local TrackID, Structureless = HordeMusicPlayer_PickBossTrack()
	if TrackID == -1 then return end
		
	HordeMusicPlayer_CurrentBossTrack = TrackID
	HordeMusicPlayer_PlayTrackToClients(TrackID, HordeMusicPlayer_TrackingState, Structureless) 
end)
