-- Areas marked in REQUIRED must be filled. If the values are not present, they will not load!
-- Your music files should be located in youraddonname/sound/hordemusicplayer/ADDONNAME/SOUNDNAME. 
-- Your path names do not need the "youraddonname/sound/hordemusicplayer/ADDONNAME" segment, so all you need is to provide the name of the sound file.
local Pack = {
    Name = "Custom Pack Example", -- REQUIRED: Name of your music pack. Try to make it unique, clashing names will be skipped.
    Artists = "Example Artist", -- REQUIRED: Names of the artists behind the music pack.
	Folder = "musicexamplepack", -- REQUIRED: Folder where your music files are located. (See line 2)
	
	-- Add music paths here. 
	CombatMusicStructure = { -- 5 and 10 are boss waves, so they are culled out of this table. See BossMusicStructure (below)
		[1] = {
			[1] = { -- This number (1) is the key. Make sure its unique for each track you add.
			    -- This is the format for each track you want to add. You can put as many but make sure they don't use the same key or they'll get overwritten
				["Name"] = "ExampleTrack", -- Track Name
				["Path"] = "ExampleSong.mp3", -- Name of the sound file.
				["Artist"] = "Artist",
			},
		},
		[2] = { -- You can leave these blank if you don't want to specify a track for a certain wave.
		}, 
		[3] = {
		},
		[4] = {
		},
		-- WAVE 5 AND 10 ARE CULLED FROM THE LIST BECAUSE USUALLY THEY ARE THE BOSS WAVES. If you want, you can add tracks for wave 5 and 10 but they'll only be heard if theres no boss.
		[6] = {
		},
		[7] = {
		},
		[8] = {
		},
		[9] = {
		},
		["NOSTRUCTURE"] = {}, -- These songs are not wave specific and play randomly. Use this if you don't want wave specific music for this pack.
	},
	
	-- Provide Phase 1 and Phase 2 (optional) music paths here. If Phase 2 is left out, it will keep playing Phase 1, though it's recommended you provide a second phase track so players understand.
	BossMusicStructure = {
		[1] = {
			
		},
	},
	
	-- Music for intermission/pre round. 
	IntermissionTracks = {
		[1] = { 
			
		},
		
	}
	
}

HordeMusicPlayer.RegisterMusicPack(Pack) -- LEAVE THIS LINE HERE! OTHERWISE YOUR PACK WILL NOT BE VISIBLE!