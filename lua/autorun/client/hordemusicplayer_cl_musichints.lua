if engine.ActiveGamemode() ~= "horde" then return end 

function CreateMusicHint(TrackData)
	if IsValid(MusicHintPanel) then MusicHintPanel:Remove() end -- Remove previous hint.
	
	-- Create new hint.
	MusicHintPanel = vgui.Create("DPanel")
	MusicHintPanel:SetSize(450,90)
	MusicHintPanel:Center()
	MusicHintPanel:SetPos((ScrW() - 400) / 2, -70)
	
	-- Get some track data to use for the hint.
	local TrackName = TrackData.TrackName or "Unknown Track"
	local PackID = TrackData["PackID"]
	local TrackArtist = TrackData.TrackArtist or HordeMusicPlayer.MusicPacks[PackID].Artists
	
	-- Hint styling + text elements.
    MusicHintPanel.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(20, 20, 20, 230))

        draw.SimpleText("Now Playing:", "Title", 225, 5, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
        draw.SimpleText(TrackName, "Title", 225, 25, Color(255, 180, 180, 255), TEXT_ALIGN_CENTER)
        draw.SimpleText("by " .. TrackArtist, "Title", 225, 45, Color(200, 200, 200, 255), TEXT_ALIGN_CENTER)
    end
	
	MusicHintPanel.StartTime = CurTime()
	MusicHintPanel.Think = function(self) -- Appear from screen and display hint.
		local Elapsed = CurTime() - self.StartTime
		local Duration = 1

		if not self.AnimationDone then
			local Progress = math.min(Elapsed / Duration, 1)
			local Eased = math.ease.OutSine(Progress)
			local y = Lerp(Eased, -70, 20)
			self:SetPos(self:GetX(), y)

			if Progress >= 1 then
				self.AnimationDone = true
				self.HoldTime = CurTime()
			end
		elseif CurTime() - self.HoldTime > 5 then
			self:AlphaTo(0, 1, 0, function() self:Remove() end)
		end
	end
	
end
