if engine.ActiveGamemode() ~= "horde" then return end

local MusicMenu
local function ToggleMusicUI()
    if IsValid(MusicMenu) then
        MusicMenu:Close()
        return
    end

    -- VGUI Setup
    MusicMenu = vgui.Create("DFrame")
    MusicMenu:SetSize(400, 400)
    MusicMenu:Center()
    MusicMenu:SetTitle("")
    MusicMenu:ShowCloseButton(true)
    MusicMenu:SetDraggable(true)
    MusicMenu:MakePopup()

    -- Panel Setup
    MusicMenu.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(30, 30, 30, 150))

        -- Apparently \n doesn't work as intended? Sad.
        local TextLines = { "HORDE", "MUSIC", "PLAYER" }
        for i, Line in ipairs(TextLines) do
            draw.SimpleText(Line, "HordeMusicPlayerTitle", 150, 16 + (i - 1) * 40, Color(255, 255, 255), TEXT_ALIGN_LEFT)
        end
		
		-- Client Settings Text
		draw.SimpleText("CLIENT SETTINGS:", "Title", 200, 150, Color(255, 255, 255), TEXT_ALIGN_CENTER)
    end

    -- Logo
    local Logo = vgui.Create("DImage", MusicMenu)
    Logo:SetPos(8, 8)
    Logo:SetSize(150, 150)
    Logo:SetImage("hordemusicplayer/hmpicon.png")
	
	

    -- Volume Slider
    local Slider = vgui.Create("DNumSlider", MusicMenu)
    Slider:SetPos(20, 180)
    Slider:SetSize(360, 40)
    Slider:SetText("Volume")
	Slider:SetDark(true)
    Slider:SetMin(0)
    Slider:SetMax(1)
    Slider:SetDecimals(2)
    Slider:SetValue(GetConVar("hordemusicplayer_client_volume"):GetFloat())

	-- Slider Change
    Slider.OnValueChanged = function(_, val)
       RunConsoleCommand("hordemusicplayer_client_volume", tostring(val))
	   HordeMusicPlayerClient_AdjustMusicVolume()
    end
	
	
	
	-- Checkbox (Popups)
	local Checkbox_Popups = vgui.Create("DCheckBoxLabel", MusicMenu)
	Checkbox_Popups:SetPos(20, 230)
	Checkbox_Popups:SetSize(200, 20)
	Checkbox_Popups:SetText("Music Popups")
	Checkbox_Popups:SetDark(true)
	Checkbox_Popups:SetValue(GetConVar("hordemusicplayer_client_hints_enabled"):GetBool())

	-- Popup Update
	Checkbox_Popups.OnChange = function(self, val)
		RunConsoleCommand("hordemusicplayer_client_hints_enabled", val and "1" or "0")
	end
	
	-- Checkbox (Intermission Music)
	local Checkbox_Interm = vgui.Create("DCheckBoxLabel", MusicMenu)
	Checkbox_Interm:SetPos(20, 250)
	Checkbox_Interm:SetSize(200, 20)
	Checkbox_Interm:SetText("Enable Intermission Music")
	Checkbox_Interm:SetDark(true)
	Checkbox_Interm:SetValue(GetConVar("hordemusicplayer_client_intermission_enabled"):GetBool())

	-- Intermission Music Update
	Checkbox_Interm.OnChange = function(self, val)
		RunConsoleCommand("hordemusicplayer_client_intermission_enabled", val and "1" or "0")
	end
	
	-- Checkbox (Combat Music)
	local Checkbox_Combat = vgui.Create("DCheckBoxLabel", MusicMenu)
	Checkbox_Combat:SetPos(20, 270)
	Checkbox_Combat:SetSize(200, 20)
	Checkbox_Combat:SetText("Enable Combat Music")
	Checkbox_Combat:SetDark(true)
	Checkbox_Combat:SetValue(GetConVar("hordemusicplayer_client_combat_enabled"):GetBool())

	-- Combat Music Update
	Checkbox_Combat.OnChange = function(self, val)
		RunConsoleCommand("hordemusicplayer_client_combat_enabled", val and "1" or "0")
	end
	
	-- Checkbox (Boss Music)
	local Checkbox_Boss = vgui.Create("DCheckBoxLabel", MusicMenu)
	Checkbox_Boss:SetPos(20, 290)
	Checkbox_Boss:SetSize(200, 20)
	Checkbox_Boss:SetText("Enable Boss Music")
	Checkbox_Boss:SetDark(true)
	Checkbox_Boss:SetValue(GetConVar("hordemusicplayer_client_boss_enabled"):GetBool())

	-- Boss Music Update
	Checkbox_Boss.OnChange = function(self, val)
		RunConsoleCommand("hordemusicplayer_client_boss_enabled", val and "1" or "0")
	end
end


concommand.Add("hordemusicplayer_client_settings", function(ply)
    ToggleMusicUI()
end)

