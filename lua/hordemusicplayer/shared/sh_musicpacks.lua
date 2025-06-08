if engine.ActiveGamemode() ~= "horde" then return end

HordeMusicPlayer = HordeMusicPlayer or {}
HordeMusicPlayer.MusicPacks = HordeMusicPlayer.MusicPacks or {}
HordeMusicPlayer.PackNameToID = HordeMusicPlayer.PackNameToID or {}

HordeMusicPlayer.IntermissionTracks = {}
HordeMusicPlayer.CombatTracks = {}
HordeMusicPlayer.BossTracks = {}

local PacksFound = {}
local ShuffleString = "NewPuncher"

-- Adds the music pack to the music player so it can be recognised and played from. (MusicPack : table). 
function HordeMusicPlayer.RegisterMusicPack(MusicPack)
	-- Sanity checks/requirements
	assert(type(MusicPack) == "table", "Must provide a table to register music pack!")
    assert(MusicPack.Name, "Music pack must have a name!")
    assert(MusicPack.Artists, "Music pack must have an artist!")
	assert(MusicPack.Folder, "Music pack must have a folder!")
	
	if PacksFound[MusicPack.Name] then return end
	PacksFound[MusicPack.Name] = true
	
	-- Add pack
    local PackID = table.insert(HordeMusicPlayer.MusicPacks, MusicPack)
	HordeMusicPlayer.PackNameToID[MusicPack.Name] = PackID
end

function HordeMusicPlayer.SortEnabledPackNames(EnabledPackTable)
	local EnabledPacks = {}
	for PackNameKey, IsEnabled in pairs(EnabledPackTable) do
		if IsEnabled then table.insert(EnabledPacks, PackNameKey) end
	end
	return EnabledPacks
end

function HordeMusicPlayer.CreateTrackStructure(PackID, TrackData)
	return {
		["PackID"] = PackID,
		["TrackName"] = TrackData.Name,
		["TrackPath"] = TrackData.Path,
		["TrackArtist"] = TrackData.Artist
	}
end

function HordeMusicPlayer.CreateTrackStructureBoss(PackID, TrackData)
	return {
		["PackID"] = PackID,
		["Phase1"] = {
			["TrackName"] = TrackData.Phase1.Name,
			["TrackPath"] = TrackData.Phase1.Path,
			["TrackArtist"] = TrackData.Phase1.Artist
		},
		["Phase2"] = {
			["TrackName"] = TrackData.Phase2.Name,
			["TrackPath"] = TrackData.Phase2.Path,
			["TrackArtist"] = TrackData.Phase2.Artist
		},
	}
end

-- Creates a table for intermission tracks. Should only ever be called when the game has finished loading and has all the enabled packs loaded.
function HordeMusicPlayer.BuildIntermissionTracks()
	local EnabledPacks = HordeMusicPlayer.SortEnabledPackNames(HordeMusicPlayer_EnabledMusicPacks)
	for _, PackName in pairs(EnabledPacks) do
		
		local PackID = HordeMusicPlayer.PackNameToID[PackName]
		local PackData = HordeMusicPlayer.MusicPacks[PackID]
		
		if PackData.IntermissionTracks and not table.IsEmpty(PackData.IntermissionTracks) then
			for _, TrackData in pairs(PackData.IntermissionTracks) do
				table.insert(HordeMusicPlayer.IntermissionTracks, HordeMusicPlayer.CreateTrackStructure(PackID, TrackData))
			end
		end
	end
end

-- Builds combat tracks. Should only ever be called when the game has finished loading and has all the enabled packs loaded.
function HordeMusicPlayer.BuildCombatTracks()
	local EnabledPacks = HordeMusicPlayer.SortEnabledPackNames(HordeMusicPlayer_EnabledMusicPacks)
	for _, PackName in pairs(EnabledPacks) do
		local PackID = HordeMusicPlayer.PackNameToID[PackName]
		local PackData = HordeMusicPlayer.MusicPacks[PackID]
		
		if PackData.CombatMusicStructure and not table.IsEmpty(PackData.CombatMusicStructure) then
			for WaveID, WaveData in pairs(PackData.CombatMusicStructure) do
				for TrackID, TrackData in pairs(WaveData) do 
					if type(WaveID) == "number" then -- Wave specific
						HordeMusicPlayer.CombatTracks[WaveID] = HordeMusicPlayer.CombatTracks[WaveID] or {}
						table.insert(HordeMusicPlayer.CombatTracks[WaveID], HordeMusicPlayer.CreateTrackStructure(PackID, TrackData))
					else -- Generic
						HordeMusicPlayer.CombatTracks["NOSTRUCT"] = HordeMusicPlayer.CombatTracks["NOSTRUCT"] or {}
						table.insert(HordeMusicPlayer.CombatTracks["NOSTRUCT"], HordeMusicPlayer.CreateTrackStructure(PackID, TrackData))
					end
				end
			end
		end
	end
end

-- Builds boss tracks. Should only ever be called when the game has finished loading and has all the enabled packs loaded.
function HordeMusicPlayer.BuildBossTracks()
	local EnabledPacks = HordeMusicPlayer.SortEnabledPackNames(HordeMusicPlayer_EnabledMusicPacks)
	for _, PackName in pairs(EnabledPacks) do
		
		local PackID = HordeMusicPlayer.PackNameToID[PackName]
		local PackData = HordeMusicPlayer.MusicPacks[PackID]
		
		if PackData.BossMusicStructure and not table.IsEmpty(PackData.BossMusicStructure) then
			for _, TrackData in pairs(PackData.BossMusicStructure) do
				table.insert(HordeMusicPlayer.BossTracks, HordeMusicPlayer.CreateTrackStructureBoss(PackID, TrackData))
			end
		end
	end
end

function HordeMusicPlayer.BuildAllTracks(ShuffleAll, RandomSeed)
	-- Reset tables
	HordeMusicPlayer.IntermissionTracks = {}
	HordeMusicPlayer.CombatTracks = {}
	HordeMusicPlayer.BossTracks = {}
	
	-- Call build functions
	HordeMusicPlayer.BuildIntermissionTracks()
	HordeMusicPlayer.BuildCombatTracks()
	HordeMusicPlayer.BuildBossTracks()
end

local MusicPackFolder = "hordemusicplayer/packs/"


local Files, Folders = file.Find(MusicPackFolder .. "*.lua", "LUA")
table.sort(Files) -- Sort in order so we can serialise and iterate through these.

for _, Filename in ipairs(Files) do
	if PacksFound[Filename] then continue end
	PacksFound[Filename] = true
	local Path = MusicPackFolder .. Filename
    if SERVER then AddCSLuaFile(Path) end -- Add to client
    include(Path) -- Run on server/client to be registered
end