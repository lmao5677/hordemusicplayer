if engine.ActiveGamemode() ~= "horde" then return end

local AdminConfigMenu

local function ToggleConfigUI()
	if IsValid(AdminConfigMenu) then
        AdminConfigMenu:Close()
        return
    end
	
	-- VGUI Setup
    AdminConfigMenu = vgui.Create("DFrame")
    AdminConfigMenu:SetSize(400, 600)
    AdminConfigMenu:Center()
    AdminConfigMenu:SetTitle("Horde Music Server Config")
    AdminConfigMenu:ShowCloseButton(true)
    AdminConfigMenu:SetDraggable(true)
    AdminConfigMenu:MakePopup()
	
	-- Sheet
	local Sheet = vgui.Create("DPropertySheet", AdminConfigMenu)
	Sheet:Dock(FILL)
	
	-- Tab 1: Settings
	local SettingsPanel = vgui.Create("DPanel", Sheet)
	SettingsPanel:Dock(FILL)
	SettingsPanel.Paint = function(self, w, h)
		draw.RoundedBox(8, 0, 0, w, h, Color(30, 30, 30))
		
		-- Server Config Text
		draw.SimpleText("SERVER CONFIG SETTINGS:", "Title", 200, 10, Color(255, 255, 255), TEXT_ALIGN_CENTER)
	end
	
	-- Settings Checkbox - Music Enabled
	local Settings_Checkbox_MusicEnabled = vgui.Create("DCheckBoxLabel", SettingsPanel)
	Settings_Checkbox_MusicEnabled:SetPos(20, 50)
	Settings_Checkbox_MusicEnabled:SetSize(200, 20)
	Settings_Checkbox_MusicEnabled:SetText("Horde Music Player Enabled")
	Settings_Checkbox_MusicEnabled:SetDark(true)
	Settings_Checkbox_MusicEnabled:SetValue(GetConVar("hordemusicplayer_enabled"):GetBool())
	Settings_Checkbox_MusicEnabled:SetTooltip("Enables or disables the horde music player")

	--Music Enabled Update
	Settings_Checkbox_MusicEnabled.OnChange = function(self, val)
		net.Start("HMP_AdminSettingChanged")
		net.WriteString("enabled")
		net.WriteBool(val)
		net.SendToServer()
	end
	
	-- Settings Checkbox - Use All Music Packs
	local Settings_Checkbox_UseAllPacks = vgui.Create("DCheckBoxLabel", SettingsPanel)
	Settings_Checkbox_UseAllPacks:SetPos(20, 70)
	Settings_Checkbox_UseAllPacks:SetSize(200, 20)
	Settings_Checkbox_UseAllPacks:SetText("Use All Music Packs")
	Settings_Checkbox_UseAllPacks:SetDark(true)
	Settings_Checkbox_UseAllPacks:SetValue(GetConVar("hordemusicplayer_useallpacks"):GetBool())
	Settings_Checkbox_UseAllPacks:SetTooltip("If enabled, random songs from more than one music pack will play. If disabled, one music pack is chosen to play music from.")
	
	-- Use all Packs
	Settings_Checkbox_UseAllPacks.OnChange = function(self, val)
		net.Start("HMP_AdminSettingChanged")
		net.WriteString("useallpacks")
		net.WriteBool(val)
		net.SendToServer()
	end

	Sheet:AddSheet("General", SettingsPanel, "icon16/cog.png")

	-- Tab 2: Music Packs
	local MusicPacksPanel = vgui.Create("DPanel", Sheet)
	MusicPacksPanel:Dock(FILL)
	MusicPacksPanel.Paint = function(self, w, h)
		draw.RoundedBox(8, 0, 0, w, h, Color(30, 30, 30))
		draw.SimpleText("CLICK TO ENABLE/DISABLE", "Title", 200, 10, Color(255, 255, 255), TEXT_ALIGN_CENTER)
	end
	
	-- Scroll Panel
	local Scroller = vgui.Create("DScrollPanel", MusicPacksPanel)
	Scroller:Dock(FILL)

	local SBar = Scroller:GetVBar()
	SBar:SetWide(8)

	-- Scroll Panel Elements
	for PackID, PackData in ipairs(HordeMusicPlayer.MusicPacks) do
		local PackButton = vgui.Create("DButton", Scroller)
		local PackName = PackData.Name
		PackButton:SetText("")
		PackButton:SetFont("Title")
		PackButton:SetSize(200, 70)
		PackButton:Dock(TOP)
		PackButton:DockMargin(0, 0, 0, 5)
		
		PackButton.Paint = function(self, w, h)
			local BoxColor = HordeMusicPlayer_EnabledMusicPacks[PackName] and Color(220, 20, 60) or Color(40,40,40)
			draw.RoundedBox(6, 0, 0, w, h, BoxColor)
			--Pack Title Text
			local PackDisplay = HordeMusicPlayer_EnabledMusicPacks[PackName] and "✓ - "..PackName or "X - "..PackName
			draw.SimpleText(PackDisplay, "Title", 200, 10, Color(255, 255, 255), TEXT_ALIGN_CENTER)
			
			-- Artists Text
			draw.SimpleText(PackData.Artists, "TargetID", 200, 40, Color(255, 255, 255), TEXT_ALIGN_CENTER)
		end
		
		-- Send request to enable/disable music pack.
		PackButton.DoClick = function()
			surface.PlaySound("ui/buttonclick.wav")
		
			net.Start("HMP_ToggleMusicPack")
			net.WriteUInt(PackID,8)
			net.SendToServer()
		end
	end

	Sheet:AddSheet("Music Packs", MusicPacksPanel, "icon16/music.png")

end

concommand.Add("hordemusicplayer_config", function(ply)
	local HasPerms = HordeMusicPlayer_CanPlayerUseConfig(ply)
	if not HasPerms then
		ply:PrintMessage(HUD_PRINTTALK, "You do not have permission to use the config.")
		return
	end
    ToggleConfigUI()
end)
