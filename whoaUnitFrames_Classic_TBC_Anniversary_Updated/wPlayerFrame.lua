--	Player frame.
local function playerFrame(self)
	if (cfg.whoaTexture == true) then
		self.healthbar:SetStatusBarTexture("Interface\\Addons\\whoaUnitFrames_Classic\\media\\statusbar\\whoa");
	end
	PlayerStatusTexture:SetTexture("Interface\\Addons\\whoaUnitFrames_Classic\\media\\UI-Player-Status");
	PlayerStatusTexture:ClearAllPoints();
	PlayerStatusTexture:SetPoint("CENTER", PlayerFrame, "CENTER", -2, 4); -- 16, 8
	PlayerFrameBackground:SetWidth(120)
	
	-- Create BigRedButton background for name if enabled and doesn't exist
	if cfg.showNameBackground and cfg.showPlayerName and not PlayerFrame.nameButtonBG then
		PlayerFrame.nameButtonBG = CreateFrame("Button", nil, PlayerFrame, "BigRedThreeSliceButtonTemplate")
		PlayerFrame.nameButtonBG:SetSize(80, 24)
		PlayerFrame.nameButtonBG:EnableMouse(false)
		PlayerFrame.nameButtonBG:SetFrameLevel(PlayerFrame:GetFrameLevel() - 1)
		-- Ensure name text appears above the button
		self.name:SetParent(PlayerFrame.nameButtonBG)
		self.name:SetFont("Fonts\\FRIZQT__.TTF", 12)
	end
	
	-- Show/hide name background based on settings (only show if both name and background are enabled)
	if PlayerFrame.nameButtonBG then
		if cfg.showNameBackground and cfg.showPlayerName then
			PlayerFrame.nameButtonBG:Show()
			-- Position button and name
			PlayerFrame.nameButtonBG:SetPoint("LEFT", self.healthbar, "TOPLEFT", 0, 12)
			self.name:SetPoint("CENTER", PlayerFrame.nameButtonBG, "CENTER", 0, 0)
			-- Update button width to match name
			local textWidth = self.name:GetStringWidth() or 50
			local padding = 15
			PlayerFrame.nameButtonBG:SetWidth(math.max(textWidth + padding, 50))
		else
			PlayerFrame.nameButtonBG:Hide()
			-- Reset name parent if background is hidden
			if self.name:GetParent() == PlayerFrame.nameButtonBG then
				self.name:SetParent(PlayerFrame)
			end
		end
	end
	
	-- Show/hide and position player name based on setting
	if cfg.showPlayerName then
		self.name:Show()
		if not cfg.showNameBackground then
			-- Position name above healthbar when background is off
			self.name:ClearAllPoints()
			self.name:SetPoint("BOTTOM", self.healthbar, "TOP", 0, 2)
			self.name:SetFont("Fonts\\FRIZQT__.TTF", 12)
		end
	else
		self.name:Hide()
	end
	self.healthbar:SetPoint("TOPLEFT",89,-28); --108,-24);
	self.healthbar:SetHeight(18);
	self.manabar:SetHeight(18);
	self.healthbar.LeftText:SetPoint("LEFT",self.healthbar,"LEFT",5,0);	
	self.healthbar.RightText:SetPoint("RIGHT",self.healthbar,"RIGHT",-5,0);
	self.healthbar.TextString:SetPoint("CENTER", self.healthbar, "CENTER", 0, 0);
	self.manabar:SetPoint("TOPLEFT",89,-48); -- 108,-51);
	self.manabar.LeftText:SetPoint("LEFT",self.manabar,"LEFT",5,-1)		;
	self.manabar.RightText:SetPoint("RIGHT",self.manabar,"RIGHT",-4,-1);
	self.manabar.TextString:SetPoint("CENTER",self.manabar,"CENTER",0,-1);
	PlayerFrameGroupIndicatorText:SetPoint("BOTTOMLEFT", PlayerFrame,"TOP",0,-20);
	PlayerFrameGroupIndicatorLeft:Hide();
	PlayerFrameGroupIndicatorMiddle:Hide();
	PlayerFrameGroupIndicatorRight:Hide();
end
hooksecurefunc("PlayerFrame_ToPlayerArt", playerFrame)

local function playerFrameSelector(self)
	if (cfg.darkFrames == true) then
		PlayerFrameTexture:SetTexture("Interface\\Addons\\whoaUnitFrames_Classic\\media\\dark\\UI-TargetingFrame")
		PlayerPVPIcon:SetTexture("Interface\\Addons\\whoaUnitFrames_Classic\\media\\dark\\UI-PVP-FFA")
	elseif (cfg.darkFrames == false) then
		PlayerFrameTexture:SetTexture("Interface\\Addons\\whoaUnitFrames_Classic\\media\\light\\UI-TargetingFrame")
		PlayerPVPIcon:SetTexture("Interface\\TargetingFrame\\UI-PVP-FFA")
	end
end
hooksecurefunc("PlayerFrame_ToPlayerArt", playerFrameSelector)

function playerPvpIcon()
	local factionGroup, factionName = UnitFactionGroup("player");
	if ( factionGroup and factionGroup ~= "Neutral" and UnitIsPVP("player") ) then
		if cfg.darkFrames then
			PlayerPVPIcon:SetTexture("Interface\\Addons\\whoaUnitFrames_Classic\\media\\dark\\UI-PVP-"..factionGroup);
		else
			PlayerPVPIcon:SetTexture("Interface\\TargetingFrame\\UI-PVP-"..factionGroup);
		end
	end
end
hooksecurefunc("PlayerFrame_UpdatePvPStatus", playerPvpIcon)

--	Player vehicle frame.
local function vehicleFrame(self, vehicleType)
	if ( vehicleType == "Natural" ) then
		PlayerFrameVehicleTexture:SetTexture("Interface\\Vehicles\\UI-Vehicle-Frame-Organic");
		PlayerFrameFlash:SetTexture("Interface\\Vehicles\\UI-Vehicle-Frame-Organic-Flash");
		PlayerFrameFlash:SetTexCoord(-0.02, 1, 0.07, 0.86);
		self.healthbar:SetSize(103,12);
		self.healthbar:SetPoint("TOPLEFT",116,-41);
		self.manabar:SetSize(103,12);
		self.manabar:SetPoint("TOPLEFT",116,-52);
	else
		PlayerFrameVehicleTexture:SetTexture("Interface\\Vehicles\\UI-Vehicle-Frame");
		PlayerFrameFlash:SetTexture("Interface\\Vehicles\\UI-Vehicle-Frame-Flash");
		PlayerFrameFlash:SetTexCoord(-0.02, 1, 0.07, 0.86);
		self.healthbar:SetSize(100,12);
		self.healthbar:SetPoint("TOPLEFT",119,-41);
		self.manabar:SetSize(100,12);
		self.manabar:SetPoint("TOPLEFT",119,-52);
	end
	PlayerName:SetPoint("CENTER",50,23);
	PlayerFrameBackground:SetWidth(114);
end
hooksecurefunc("PlayerFrame_ToVehicleArt", vehicleFrame)

-- Pet frame
local function petFrame()
	PetFrameHealthBarTextRight:SetPoint("RIGHT",PetFrameHealthBar,"RIGHT",2,0);
	PetFrameManaBarTextRight:SetPoint("RIGHT",PetFrameManaBar,"RIGHT",2,-5);
	if (cfg.styleFont) then
		PetFrameHealthBarTextLeft:SetPoint("LEFT",PetFrameHealthBar,"LEFT",0,0);
		PetFrameHealthBarTextRight:SetPoint("RIGHT",PetFrameHealthBar,"RIGHT",2,0);
		PetFrameManaBarText:SetPoint("CENTER",PetFrameManaBar,"CENTER",0,-3);
		PetFrameManaBarTextLeft:SetPoint("LEFT",PetFrameManaBar,"LEFT",0,-3);
		PetFrameManaBarTextRight:SetPoint("RIGHT",PetFrameManaBar,"RIGHT",2,-3);
		PetFrameHealthBarText:SetFontObject(SystemFont_Outline_Small);
		PetFrameHealthBarTextLeft:SetFontObject(SystemFont_Outline_Small);
		PetFrameHealthBarTextRight:SetFontObject(SystemFont_Outline_Small);
		PetFrameManaBarText:SetFontObject(SystemFont_Outline_Small);
		PetFrameManaBarTextLeft:SetFontObject(SystemFont_Outline_Small);
		PetFrameManaBarTextRight:SetFontObject(SystemFont_Outline_Small);
	end
end
hooksecurefunc("PlayerFrame_ToPlayerArt", petFrame)

