--========================================================
-- Focus Frame Styling
--========================================================

local function FocusFrameLayout(forceNormalTexture)
	if not FocusFrame or not FocusFrame:IsShown() then return end

	local unit = "focus"
	local classification = UnitClassification(unit)

	local healthBar = FocusFrame.healthbar
	local manaBar   = FocusFrame.manabar
	local name      = FocusFrame.name
	local levelText = FocusFrame.levelText
	local texture   = FocusFrameTextureFrameTexture
	
	
	FocusFrameBackground:Hide()
	FocusFrameNameBackground:Hide()

	if not (healthBar and manaBar and name) then return end

	-- Name color
	if UnitIsCivilian(unit) then
		name:SetTextColor(1, 0, 0)
	else
		name:SetTextColor(1, 0.82, 0)
	end

	-- Create BigRedButton background for name if enabled and doesn't exist
	if cfg.showNameBackground and not FocusFrame.nameButtonBG then
		FocusFrame.nameButtonBG = CreateFrame("Button", nil, FocusFrame, "BigRedThreeSliceButtonTemplate")
		FocusFrame.nameButtonBG:SetSize(100, 24)
		FocusFrame.nameButtonBG:EnableMouse(false)
		FocusFrame.nameButtonBG:SetFrameLevel(FocusFrame:GetFrameLevel() - 1)
		-- Ensure name text appears above the button
		name:SetParent(FocusFrame.nameButtonBG)
		name:SetFont("Fonts\\FRIZQT__.TTF", 12)
	end
	
	-- Show/hide name background based on setting
	if FocusFrame.nameButtonBG then
		if cfg.showNameBackground then
			FocusFrame.nameButtonBG:Show()
			-- Position button and name
			FocusFrame.nameButtonBG:SetPoint("RIGHT", healthBar, "TOPRIGHT", 0, 12)
			name:SetPoint("CENTER", FocusFrame.nameButtonBG, "CENTER", 0, 0)
			-- Update button width to match name
			local textWidth = name:GetStringWidth() or 50
			local padding = 15
			FocusFrame.nameButtonBG:SetWidth(math.max(textWidth + padding, 50))
		else
			FocusFrame.nameButtonBG:Hide()
			-- Reset name parent if background is hidden
			if name:GetParent() == FocusFrame.nameButtonBG then
				name:SetParent(FocusFrame)
			end
		end
	end
	
	-- Position name above healthbar when background is off
	if not cfg.showNameBackground then
		name:ClearAllPoints()
		name:SetPoint("BOTTOM", healthBar, "TOP", 0, 2)
		name:SetFont("Fonts\\FRIZQT__.TTF", 12)
	end

	-- Health bar
	healthBar:ClearAllPoints()
	healthBar:SetPoint("TOPLEFT", FocusFrame, "TOPLEFT", 22, -28)
	healthBar:SetSize(120, 18)

	if healthBar.LeftText then
		healthBar.LeftText:SetPoint("LEFT", healthBar, "LEFT", 5, 0)
	end
	if healthBar.RightText then
		healthBar.RightText:SetPoint("RIGHT", healthBar, "RIGHT", -3, 0)
	end
	if healthBar.TextString then
		healthBar.TextString:SetPoint("CENTER", healthBar, "CENTER", 0, 0)
	end

	-- Mana bar
	manaBar:ClearAllPoints()
	manaBar:SetPoint("TOPLEFT", FocusFrame, "TOPLEFT", 22, -49)
	manaBar:SetSize(120, 18)

	if manaBar.LeftText then
		manaBar.LeftText:SetPoint("LEFT", manaBar, "LEFT", 5, 0)
	end
	if manaBar.RightText then
		manaBar.RightText:SetPoint("RIGHT", manaBar, "RIGHT", -3, 0)
	end
	if manaBar.TextString then
		manaBar.TextString:SetPoint("CENTER", manaBar, "CENTER", 0, 0)
	end

	-- Statusbar texture
	if cfg.whoaTexture then
		healthBar:SetStatusBarTexture(
			"Interface\\AddOns\\whoaUnitFrames_Classic_TBC_Anniversary_Updated\\media\\statusbar\\whoa"
		)
		manaBar:SetStatusBarTexture(
			"Interface\\AddOns\\whoaUnitFrames_Classic_TBC_Anniversary_Updated\\media\\statusbar\\whoa"
		)
	end
end

--========================================================
-- Focus Frame Texture Selector
--========================================================
local function FocusFrameTextureSelector(forceNormalTexture)
	if not FocusFrameTextureFrameTexture then return end

	local unit = "focus"
	local classification = UnitClassification(unit)

	local path = "Interface\\AddOns\\whoaUnitFrames_Classic_TBC_Anniversary_Updated\\media\\light\\"
	if cfg.darkFrames then
		path = "Interface\\AddOns\\whoaUnitFrames_Classic_TBC_Anniversary_Updated\\media\\dark\\"
	end

	if forceNormalTexture then
		FocusFrameTextureFrameTexture:SetTexture(path.."UI-TargetingFrame")
	elseif classification == "minus" then
		FocusFrameTextureFrameTexture:SetTexture(path.."UI-TargetingFrame-Minus")
	elseif classification == "worldboss" or classification == "elite" then
		FocusFrameTextureFrameTexture:SetTexture(path.."UI-TargetingFrame-Elite")
	elseif classification == "rareelite" then
		FocusFrameTextureFrameTexture:SetTexture(path.."UI-TargetingFrame-Rare-Elite")
	elseif classification == "rare" then
		FocusFrameTextureFrameTexture:SetTexture(path.."UI-TargetingFrame-Rare")
	else
		FocusFrameTextureFrameTexture:SetTexture(path.."UI-TargetingFrame")
	end
end

--========================================================
-- Event-driven updates (Retail replacement for hooks)
--========================================================
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_FOCUS_CHANGED")
f:RegisterEvent("UNIT_HEALTH")
f:RegisterEvent("UNIT_POWER_UPDATE")
f:RegisterEvent("UNIT_CLASSIFICATION_CHANGED")

f:SetScript("OnEvent", function(_, event, unit)
	if unit and unit ~= "focus" and event ~= "PLAYER_FOCUS_CHANGED" then return end

	FocusFrameLayout()
	FocusFrameTextureSelector()
end)

--========================================================
-- Apply on show (frame creation / reload)
--========================================================
FocusFrame:HookScript("OnShow", function()
	FocusFrameLayout()
	FocusFrameTextureSelector()
end)
