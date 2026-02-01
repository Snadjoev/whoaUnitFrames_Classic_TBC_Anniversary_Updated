--	Target frame
local function targetFrame (self, forceNormalTexture)
	local classification = UnitClassification(self.unit);
	self.highLevelTexture:ClearAllPoints();
	self.highLevelTexture:SetPoint("CENTER", self.levelText, "CENTER", 1,0);
	self.deadText:SetPoint("CENTER", self.healthbar, "CENTER",0,0);
	self.unconsciousText:SetPoint("CENTER", self.manabar, "CENTER",0,0);
	self.nameBackground:Hide();
	if UnitIsCivilian(self.unit) then
		self.name:SetTextColor(1.0,0,0);
	else
		self.name:SetTextColor(1.0,0.82,0,1)
		self.name:SetFont("Fonts\\FRIZQT__.TTF", 12)
	end
	
	-- Create BigRedButton background for name if enabled and doesn't exist
	if cfg.showNameBackground and not self.nameButtonBG then
		self.nameButtonBG = CreateFrame("Button", nil, self, "BigRedThreeSliceButtonTemplate")
		self.nameButtonBG:SetSize(100, 24)
		self.nameButtonBG:EnableMouse(false)
		self.nameButtonBG:SetFrameLevel(self:GetFrameLevel() - 1)
		-- Ensure name text appears above the button
		self.name:SetParent(self.nameButtonBG)
	end
	
	-- Show/hide name background based on setting
	if self.nameButtonBG then
		if cfg.showNameBackground then
			self.nameButtonBG:Show()
			-- Position button and name
			self.nameButtonBG:SetPoint("RIGHT", self.healthbar, "TOPRIGHT", 0, 12)
			self.name:SetPoint("CENTER", self.nameButtonBG, "CENTER", 0, 0)
			-- Update button width to match name
			local textWidth = self.name:GetStringWidth() or 50
			local padding = 15
			self.nameButtonBG:SetWidth(math.max(textWidth + padding, 50))
		else
			self.nameButtonBG:Hide()
			-- Reset name parent and position if background is hidden
			if self.name:GetParent() == self.nameButtonBG then
				self.name:SetParent(self)
			end
		end
	end
	
	-- Position name above healthbar when background is off
	if not cfg.showNameBackground then
		self.name:ClearAllPoints()
		self.name:SetPoint("BOTTOM", self.healthbar, "TOP", 0, 2)
	end
	self.healthbar:SetSize(100, 18); -- 119, 28);
	self.healthbar:SetPoint("TOPLEFT", 22, -28); -- 5, -24);
	self.healthbar:SetAlpha(1);
	self.manabar:SetHeight(18);
	self.manabar:SetPoint("TOPLEFT", 22, -48);
	self.healthbar.LeftText:SetPoint("LEFT", self.healthbar, "LEFT", 5, 0);
	self.healthbar.RightText:SetPoint("RIGHT", self.healthbar, "RIGHT", -3, 0);
    self.healthbar.TextString:SetPoint("CENTER", self.healthbar, "CENTER", 0, 0);
	self.manabar.LeftText:SetPoint("LEFT", self.manabar, "LEFT", 4, 0);	
	self.manabar.RightText:ClearAllPoints()
	self.manabar.RightText:SetPoint("RIGHT", self.manabar, "RIGHT", -4, 0)
	self.manabar.TextString:SetPoint("CENTER", self.manabar, "CENTER", 0, 0)
	if ( forceNormalTexture ) then
		self.haveElite = nil;
		if ( classification == "minus" ) then
			self.Background:SetSize(119,12);
			self.Background:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 7, 47);
			self.name:SetPoint("LEFT", self, 16, 19);
			self.healthbar:ClearAllPoints();
			self.healthbar:SetPoint("LEFT", 5, 3);
			self.healthbar:SetHeight(12);
			self.healthbar.LeftText:SetPoint("LEFT", self.healthbar, "LEFT", 3, 0);
			self.healthbar.RightText:SetPoint("RIGHT", self.healthbar, "RIGHT", -2, 0);
		else
			self.Background:SetSize(119,42);
			self.Background:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 7, 35);
		end
		if ( self.threatIndicator ) then
			if ( classification == "minus" ) then
				self.threatIndicator:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Minus-Flash");
				self.threatIndicator:SetTexCoord(0, 1, 0, 1);
				self.threatIndicator:SetWidth(256);
				self.threatIndicator:SetHeight(128);
				self.threatIndicator:SetPoint("TOPLEFT", self, "TOPLEFT", -24, 0);
			else
				self.threatIndicator:SetTexCoord(0, 0.9453125, 0, 0.181640625);
				self.threatIndicator:SetWidth(242);
				self.threatIndicator:SetHeight(93);
				self.threatIndicator:SetPoint("TOPLEFT", self, "TOPLEFT", -24, 0);
			end
		end	
	else
		self.haveElite = true;
		self.Background:SetSize(119,42);
		if ( self.threatIndicator ) then
			self.threatIndicator:SetTexCoord(0, 0.9453125, 0.181640625, 0.400390625);
			self.threatIndicator:SetWidth(242);
			self.threatIndicator:SetHeight(112);
		end		
	end
	self.healthbar.lockColor = true;
	if ( cfg.whoaTexture == true) then
		self.healthbar:SetStatusBarTexture("Interface\\Addons\\whoaUnitFrames_Classic_TBC_Anniversary_Updated\\media\\statusbar\\whoa");
	end
end
hooksecurefunc(TargetFrame, "CheckClassification", targetFrame)

local function targetFrameSelector (self, forceNormalTexture)
	local classification = UnitClassification(self.unit);
	local path = "Interface\\Addons\\whoaUnitFrames_Classic_TBC_Anniversary_Updated\\media\\light\\";
	if (cfg.darkFrames == true) then
		path = "Interface\\Addons\\whoaUnitFrames_Classic_TBC_Anniversary_Updated\\media\\dark\\"
	end
	if ( forceNormalTexture ) then
		self.borderTexture:SetTexture(path.."UI-TargetingFrame");
	elseif ( classification == "minus" ) then
		self.borderTexture:SetTexture(path.."UI-TargetingFrame-Minus");
		forceNormalTexture = true;
	elseif ( classification == "worldboss" or classification == "elite" ) then
		self.borderTexture:SetTexture(path.."UI-TargetingFrame-Elite");
	elseif ( classification == "rareelite" ) then
		self.borderTexture:SetTexture(path.."UI-TargetingFrame-Rare-Elite");
	elseif ( classification == "rare" ) then
		self.borderTexture:SetTexture(path.."UI-TargetingFrame-Rare");
	else
		self.borderTexture:SetTexture(path.."UI-TargetingFrame");
		forceNormalTexture = true;
	end
	if ( self.showPVP ) then
		local factionGroup = UnitFactionGroup(self.unit);
		if ( UnitIsPVPFreeForAll(self.unit) ) then
			if cfg.darkFrames then
				self.pvpIcon:SetTexture("Interface\\Addons\\whoaUnitFrames_Classic_TBC_Anniversary_Updated\\media\\dark\\UI-PVP-FFA");
			else
				self.pvpIcon:SetTexture("Interface\\TargetingFrame\\UI-PVP-FFA");
			end
		elseif ( factionGroup and factionGroup ~= "Neutral" and UnitIsPVP(self.unit) ) then
			if cfg.darkFrames then
				self.pvpIcon:SetTexture("Interface\\Addons\\whoaUnitFrames_Classic_TBC_Anniversary_Updated\\media\\dark\\UI-PVP-"..factionGroup);
			else
				self.pvpIcon:SetTexture("Interface\\TargetingFrame\\UI-PVP-"..factionGroup);
			end
		end
		if (UnitIsCivilian(self.unit)) then
			if cfg.darkFrames then
				self.questIcon:SetTexture("Interface\\Addons\\whoaUnitFrames_Classic_TBC_Anniversary_Updated\\media\\dark\\PortraitWarningBadge");
			else
				self.questIcon:SetTexture("Interface\\Addons\\whoaUnitFrames_Classic_TBC_Anniversary_Updated\\media\\light\\PortraitWarningBadge");
			end
			self.questIcon:Show();
		else
			self.questIcon:Hide();
		end
		
	end
end
hooksecurefunc(TargetFrame, "CheckClassification", targetFrameSelector)

-- Mana texture
local function manabarTexture (manaBar)
	local powerType, powerToken, altR, altG, altB = UnitPowerType(manaBar.unit);
	local info = PowerBarColor[powerToken];
	if ( info ) then
		if ( not manaBar.lockColor ) then
			if not ( info.atlas ) and ( cfg.statusbarTexture == true) then
				manaBar:SetStatusBarTexture("Interface\\Addons\\whoaUnitFrames_Classic_TBC_Anniversary_Updated\\media\\statusbar\\whoa");
			end
		end
	end
end
hooksecurefunc("UnitFrameManaBar_UpdateType", manabarTexture)

--	ToT
local function totFrame()
	TargetFrameToTTextureFrameDeadText:ClearAllPoints();
	TargetFrameToTTextureFrameDeadText:SetPoint("CENTER", "TargetFrameToTHealthBar","CENTER",1, 0);
	TargetFrameToTTextureFrameUnconsciousText:ClearAllPoints();
	TargetFrameToTTextureFrameUnconsciousText:SetPoint("CENTER", "TargetFrameToTHealthBar","CENTER",1, 0);
	TargetFrameToTTextureFrameName:SetSize(65,10);
	TargetFrameToTHealthBar:ClearAllPoints();
	TargetFrameToTHealthBar:SetPoint("TOPLEFT", 45, -15);
    TargetFrameToTHealthBar:SetHeight(10);
    TargetFrameToTManaBar:ClearAllPoints();
    TargetFrameToTManaBar:SetPoint("TOPLEFT", 45, -25);
    TargetFrameToTManaBar:SetHeight(5);
	TargetFrameToTBackground:SetSize(50,14);
	TargetFrameToTBackground:ClearAllPoints();
	TargetFrameToTBackground:SetPoint("CENTER", "TargetFrameToT","CENTER",20, 0);
end

hooksecurefunc(TargetFrameToT, "Update", totFrame)
hooksecurefunc(TargetFrame, "CheckClassification", totFrame)

local function totFrameSelector()
	if ( cfg.darkFrames == true ) then
		TargetFrameToTTextureFrameTexture:SetTexture("Interface\\Addons\\whoaUnitFrames_Classic_TBC_Anniversary_Updated\\media\\dark\\UI-TargetofTargetFrame");
	elseif ( cfg.darkFrames == false ) then
		TargetFrameToTTextureFrameTexture:SetTexture("Interface\\Addons\\whoaUnitFrames_Classic_TBC_Anniversary_Updated\\media\\light\\UI-TargetofTargetFrame");
	end
end
hooksecurefunc(TargetFrameToT, "Update", totFrameSelector)
hooksecurefunc(TargetFrame, "CheckClassification", totFrameSelector)
