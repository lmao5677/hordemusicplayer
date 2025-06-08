if engine.ActiveGamemode() ~= "horde" then return end

-- Fetching Music Packs for Client lolz
hook.Add("InitPostEntity", "HMP_UpdateClientMusicPacks", function()
	net.Start( "HMP_GetMusicPacks" )
	net.SendToServer()
end )

net.Receive("HMP_SendClientMusicPacks", function()
	local EnabledPacks = net.ReadTable()
	HordeMusicPlayer_EnabledMusicPacks = EnabledPacks
	HordeMusicPlayer.BuildAllTracks()
	print("[HMP] Client Packs Loaded!")
end)
