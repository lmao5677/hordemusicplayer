if engine.ActiveGamemode() ~= "horde" then return end

if SERVER then
	 CreateConVar("hordemusicplayer_enabled", "1", FCVAR_ARCHIVE + FCVAR_REPLICATED, "Enable or disable Horde Music Player.")
	 CreateConVar("hordemusicplayer_useallpacks", "1", FCVAR_ARCHIVE + FCVAR_REPLICATED, "Uses all music packs when picking music if enabled, or use only one music pack per game.") -- WIP
	 CreateConVar("hordemusicplayer_admins_use_config", "1", FCVAR_ARCHIVE + FCVAR_REPLICATED, "Determines if admins can use the config, otherwise limited to Super-Admin.") -- probably doesnt do much atm?
end

if CLIENT then
	CreateConVar("hordemusicplayer_client_volume", "0.5", FCVAR_ARCHIVE, "Controls the volume of the music heard in game.")
	CreateConVar("hordemusicplayer_client_intermission_enabled", "1", FCVAR_ARCHIVE, "Enables if intermission tracks should be heard.")
	CreateConVar("hordemusicplayer_client_combat_enabled", "1", FCVAR_ARCHIVE, "Enables if combat tracks should be heard.")
	CreateConVar("hordemusicplayer_client_boss_enabled", "1", FCVAR_ARCHIVE, "Enables if boss tracks should be heard in game.")
	CreateConVar("hordemusicplayer_client_hints_enabled", "1", FCVAR_ARCHIVE, "Enables small music hints popping up when a track is played.")
end