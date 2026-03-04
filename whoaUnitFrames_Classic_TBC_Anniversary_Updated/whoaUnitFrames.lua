--========================================================
-- whoaUnitFrames - Core Module
--========================================================

whoa = {}
cfg = {}

-- Text constants
local ghostText = "Ghost"
local offlineText = "Offline"
local deadText = DEAD

--========================================================
-- Class Colors
--========================================================

-- Blue shamans instead of pink
function blueShamans()
	if cfg.blueShamans then
		RAID_CLASS_COLORS["SHAMAN"] = CreateColor(0.0, 0.44, 0.87)
		RAID_CLASS_COLORS["SHAMAN"].colorStr = RAID_CLASS_COLORS["SHAMAN"]:GenerateHexColor()
	end
end
		
-- Player class colors HP
function unitClassColors(healthbar, unit)
	if cfg.classColor and UnitIsPlayer(unit) and UnitClass(unit) then
		local _, class = UnitClass(unit)
		local color = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class]
		if color then
			if UnitIsConnected(unit) then
				healthbar:SetStatusBarColor(color.r, color.g, color.b)
			else
				healthbar:SetStatusBarColor(0.6, 0.6, 0.6, 0.5)
			end
		end
	end
end
hooksecurefunc("UnitFrameHealthBar_Update", unitClassColors)
hooksecurefunc("HealthBar_OnValueChanged", function(self)
	unitClassColors(self, self.unit)
end)

--========================================================
-- NPC Reaction Colors
--========================================================

-- Blizzard's target unit reactions HP color
function npcReactionBrightColors()
	if cfg.BlizzardReactionColor then
		FACTION_BAR_COLORS = {
			[1] = {r = 0.9, g = 0.0, b = 0.0},
			[2] = {r = 0.9, g = 0.0, b = 0.0},
			[3] = {r = 0.9, g = 0.0, b = 0.0},
			[4] = {r = 1, g = 0.8, b = 0.0},
			[5] = {r = 0.0, g = 0.9, b = 0.0},
			[6] = {r = 0.0, g = 0.9, b = 0.0},
			[7] = {r = 0.0, g = 0.9, b = 0.0},
			[8] = {r = 0.0, g = 0.9, b = 0.0}
		}
	end
end

-- Whoa's custom target unit reactions HP colors
local function npcReactionColors(healthbar, unit)
	if not UnitExists(unit) then return end
	
	if UnitIsPlayer(unit) then
		if not cfg.classColor then
			healthbar:SetStatusBarColor(0, 0.9, 0)
		end
		return
	end
	
	-- Handle NPCs
	if cfg.reactionColor then
		if UnitIsTapDenied(unit) then
			healthbar:SetStatusBarColor(0.5, 0.5, 0.5)
		elseif UnitIsCivilian(unit) then
			healthbar:SetStatusBarColor(1.0, 1.0, 1.0)
		else
			local reaction = FACTION_BAR_COLORS[UnitReaction(unit, "player")]
			if reaction then
				healthbar:SetStatusBarColor(reaction.r, reaction.g, reaction.b)
			else
				healthbar:SetStatusBarColor(0, 0.6, 0.1)
			end
		end
	else
		healthbar:SetStatusBarColor(0, 0.9, 0)
	end
end
hooksecurefunc("UnitFrameHealthBar_Update", npcReactionColors)
hooksecurefunc("HealthBar_OnValueChanged", function(self)
	npcReactionColors(self, self.unit)
end)

--========================================================
-- Heal Prediction Bars
--========================================================

-- Apply correct texture to heal prediction bars
local function updateHealPredictionTexture(frame)
	if not frame then return end
	
	local texture = cfg.whoaTexture and "Interface\\Addons\\whoaUnitFrames_Classic_TBC_Anniversary_Updated\\media\\statusbar\\whoa" or "Interface\\TargetingFrame\\UI-StatusBar"
	
	-- Check for heal prediction child frames
	if frame.myHealPredictionBar and frame.myHealPredictionBar.SetStatusBarTexture then
		frame.myHealPredictionBar:SetStatusBarTexture(texture)
	end
	
	if frame.otherHealPredictionBar and frame.otherHealPredictionBar.SetStatusBarTexture then
		frame.otherHealPredictionBar:SetStatusBarTexture(texture)
	end
	
	if frame.totalAbsorbBar and frame.totalAbsorbBar.SetStatusBarTexture then
		frame.totalAbsorbBar:SetStatusBarTexture(texture)
	end
	
	if frame.healAbsorbBar and frame.healAbsorbBar.SetStatusBarTexture then
		frame.healAbsorbBar:SetStatusBarTexture(texture)
	end
end

-- Global function to update all heal prediction textures
function UpdateAllHealPredictionTextures()
	if PlayerFrame then
		updateHealPredictionTexture(PlayerFrame)
	end
	if TargetFrame then
		updateHealPredictionTexture(TargetFrame)
	end
end

-- Hook to update heal prediction textures when frames update
local function hookHealPredictionTextures()
	-- Update initial textures
	if PlayerFrame then
		updateHealPredictionTexture(PlayerFrame)
	end
	
	if TargetFrame then
		updateHealPredictionTexture(TargetFrame)
	end
	
	-- Hook the update function once for both frames
	hooksecurefunc("UnitFrameHealPredictionBars_Update", function(frame)
		if frame == PlayerFrame or frame == TargetFrame then
			updateHealPredictionTexture(frame)
		end
	end)
end

-- Initialize heal prediction textures after a delay to ensure frames exist
C_Timer.After(1, hookHealPredictionTextures)

--========================================================
-- Aura Positioning & Resizing
--========================================================

-- Aura positioning constants
local LARGE_AURA_SIZE = 25
local SMALL_AURA_SIZE = 20
local AURA_OFFSET_Y = 4
local AURA_ROW_WIDTH = 122
local NUM_TOT_AURA_ROWS = 2

-- Set aura size
local function auraResize(self, auraName, numAuras, numOppositeAuras, largeAuraList, updateFunc, maxRowWidth, offsetX, mirrorAurasVertically)
	if cfg.bigAuras then
		local size
		local offsetY = AURA_OFFSET_Y
		local rowWidth = 0
		local firstBuffOnRow = 1
		for i = 1, numAuras do
			if ( largeAuraList[i] ) then
				size = LARGE_AURA_SIZE
				offsetY = AURA_OFFSET_Y + AURA_OFFSET_Y
			else
				size = SMALL_AURA_SIZE
			end
			if ( i == 1 ) then
				rowWidth = size;
				self.auraRows = self.auraRows + 1;
			else
				rowWidth = rowWidth + size + offsetX;
			end
			if ( rowWidth > maxRowWidth ) then
				updateFunc(self, auraName, i, numOppositeAuras, firstBuffOnRow, size, offsetX, offsetY, mirrorAurasVertically);
				rowWidth = size;
				self.auraRows = self.auraRows + 1;
				firstBuffOnRow = i;
				offsetY = AURA_OFFSET_Y;
				if ( self.auraRows > NUM_TOT_AURA_ROWS ) then
					maxRowWidth = AURA_ROW_WIDTH;
				end
			else
				updateFunc(self, auraName, i, numOppositeAuras, i - 1, size, offsetX, offsetY, mirrorAurasVertically);
			end
		end
	end
end
hooksecurefunc(TargetFrame, "UpdateAuraPositions", auraResize)

--========================================================
-- Status Text & Dead/Offline Status
--========================================================

local function CreateStatusBarText(name, parentName, parent, point, x, y)
	local fontString = parent:CreateFontString(parentName..name, nil, "TextStatusBarText")
	fontString:SetPoint(point, parent, point, x, y)
	return fontString
end
local function CreateDeadText(name, parentName, parent, point, x, y)
	local fontString = parent:CreateFontString(parentName..name, nil, "GameFontNormalSmall")
	fontString:SetPoint(point, parent, point, x, y)
	return fontString
end
local function targetFrameStatusText()
	if not PlayerFrameHealthBar or not TargetFrameHealthBar then
		return
	end
	
	TargetFrameTextureFrameGhostText = CreateDeadText("GhostText", "TargetFrameHealthBar", TargetFrameHealthBar, "CENTER", 0, 0);
	TargetFrameTextureFrameOfflineText = CreateDeadText("OfflineText", "TargetFrameHealthBar", TargetFrameHealthBar, "CENTER", 0, 0);
	PlayerFrameDeadText = CreateDeadText("DeadText", "PlayerFrame", PlayerFrameHealthBar, "CENTER", 0, 0);
	PlayerFrameGhostText = CreateDeadText("GhostText", "PlayerFrame", PlayerFrameHealthBar, "CENTER", 0, 0);

	PlayerFrameDeadText:SetText(DEAD);
	PlayerFrameGhostText:SetText(ghostText);
	TargetFrameTextureFrameGhostText:SetText(ghostText);
	TargetFrameTextureFrameOfflineText:SetText(offlineText);
end
-- Call this after frames are loaded
if PlayerFrameHealthBar and TargetFrameHealthBar then
	targetFrameStatusText()
end

-- Font styling for player and target frames
local function applyFontStyle(frame)
	if not cfg.styleFont then return end
	
	if frame.healthbar then
		if frame.healthbar.LeftText then frame.healthbar.LeftText:SetFontObject(SystemFont_Outline_Small) end
		if frame.healthbar.RightText then frame.healthbar.RightText:SetFontObject(SystemFont_Outline_Small) end
		if frame.healthbar.TextString then frame.healthbar.TextString:SetFontObject(SystemFont_Outline_Small) end
	end
	if frame.manabar then
		if frame.manabar.LeftText then frame.manabar.LeftText:SetFontObject(SystemFont_Outline_Small) end
		if frame.manabar.RightText then frame.manabar.RightText:SetFontObject(SystemFont_Outline_Small) end
		if frame.manabar.TextString then frame.manabar.TextString:SetFontObject(SystemFont_Outline_Small) end
	end
	if frame.name then
		frame.name:SetFontObject(SystemFont_Outline_Small)
	end
end

hooksecurefunc("PlayerFrame_ToPlayerArt", function(self) applyFontStyle(self) end)
hooksecurefunc(TargetFrame, "CheckClassification", function(self) applyFontStyle(self) end)

-- Custom status text with value formatting
local function customStatusTex(statusFrame, textString, value, valueMin, valueMax)
	local xpValue = UnitXP("player")
	local xpMaxValue = UnitXPMax("player")
	
	-- Hide left/right text if they exist
	if statusFrame.LeftText then
		statusFrame.LeftText:SetText("")
		statusFrame.LeftText:Hide()
	end
	if statusFrame.RightText then
		statusFrame.RightText:SetText("")
		statusFrame.RightText:Hide()
	end
	
	if tonumber(valueMax) ~= valueMax or valueMax <= 0 or statusFrame.pauseUpdates then
		textString:Hide()
		textString:SetText("")
		if not statusFrame.alwaysShow then
			statusFrame:Hide()
		else
			statusFrame:SetValue(0)
		end
		return
	end
	
	statusFrame:Show()
	
	-- Determine if text should be shown
	local shouldShowText = (statusFrame.cvar and GetCVar(statusFrame.cvar) == "1" and statusFrame.textLockable) 
						or statusFrame.forceShow 
						or (statusFrame.lockShow and statusFrame.lockShow > 0 and not statusFrame.forceHideText)
	
	if not shouldShowText then
		textString:SetText("")
		textString:Hide()
		return
	end
	
	textString:Show()
	
	-- Format large numbers with K/M suffix
	local function formatValue(val)
		if val >= 10000000 then return format("%1.2f M", val/1000000)
		elseif val >= 1000000 then return format("%1.1f M", val/1000000)
		elseif val >= 100000 then return format("%1.0f K", val/1000)
		elseif val >= 1000 then return format("%1.3f", val/1000)
		else return tostring(val) end
	end
	
	local valueDisplay = formatValue(value)
	local valueMaxDisplay = formatValue(valueMax)
	local xpValueDisplay = xpValue >= 1000 and format("%1.3f", xpValue/1000) or xpValue
	local xpMaxValueDisplay = xpMaxValue >= 1000 and format("%1.3f", xpMaxValue/1000) or xpMaxValue
	
	-- Get display mode
	local textDisplay = GetCVar("statusTextDisplay")
	if statusFrame == TargetFrameHealthBar then textDisplay = "BOTH" end
	
	-- Handle zero value special case
	if value == 0 then
		if statusFrame.zeroText then
			textString:SetText(statusFrame.zeroText)
			statusFrame.isZero = 1
		else
			textString:SetText("")
		end
		return
	end
	
	statusFrame.isZero = nil
	
	-- Format text based on display mode
	if textDisplay == "BOTH" and not statusFrame.showNumeric then
		local percent = math.ceil((value / valueMax) * 100)
		
		if statusFrame.LeftText and statusFrame.RightText then
			if not statusFrame.powerToken or statusFrame.powerToken == "MANA" then
				statusFrame.LeftText:SetText(percent .. "%")
				statusFrame.LeftText:Show()
			end
			statusFrame.RightText:SetText(valueDisplay)
			statusFrame.RightText:Show()
			textString:Hide()
		else
			textString:SetText(percent .. "% " .. valueDisplay .. " / " .. valueMaxDisplay)
		end
	elseif textDisplay ~= "NUMERIC" and textDisplay ~= "NONE" and not statusFrame.showNumeric then
		local percent = math.ceil((value / valueMax) * 100) .. "%"
		if statusFrame.prefix and (statusFrame.alwaysPrefix or not (statusFrame.cvar and GetCVar(statusFrame.cvar) == "1" and statusFrame.textLockable)) then
			textString:SetText(statusFrame.prefix .. " " .. percent)
		else
			textString:SetText(percent)
		end
	else
		if statusFrame.prefix and (statusFrame.alwaysPrefix or not (statusFrame.cvar and GetCVar(statusFrame.cvar) == "1" and statusFrame.textLockable)) then
			textString:SetText(statusFrame.prefix .. " " .. valueDisplay .. " / " .. valueMaxDisplay)
			MainMenuBarExpText:SetText(statusFrame.prefix .. " " .. xpValueDisplay .. "  / " .. xpMaxValueDisplay)
		else
			textString:SetText(valueDisplay .. " / " .. valueMaxDisplay)
		end
	end
end
-- Hook health bar updates only if the method exists
if PlayerFrameHealthBar and PlayerFrameHealthBar.UpdateTextStringWithValues then
	hooksecurefunc(PlayerFrameHealthBar, "UpdateTextStringWithValues",customStatusTex)
end
if TargetFrameHealthBar and TargetFrameHealthBar.UpdateTextStringWithValues then
	hooksecurefunc(TargetFrameHealthBar, "UpdateTextStringWithValues",customStatusTex)
end

-- Dead, Ghost and Offline text
function whoaCheckDead(self)
	local unit = self.unit
	local textDisplay = GetCVar("statusTextDisplay")
	
	if not unit or (unit ~= "player" and unit ~= "target") then return end
	
	local isDead = UnitIsDead(unit)
	local isGhost = UnitIsGhost(unit)
	local isDeadOrGhost = UnitIsDeadOrGhost(unit)
	local isOffline = not UnitIsConnected(unit)
	
	if unit == "player" then
		-- Hide health/mana text when dead/ghost
		if isDeadOrGhost then
			if textDisplay == "BOTH" then
				PlayerFrameHealthBarTextLeft:Hide()
				PlayerFrameHealthBarTextRight:Hide()
				PlayerFrameManaBarTextLeft:Hide()
				PlayerFrameManaBarTextRight:Hide()
			else
				PlayerFrameHealthBarText:Hide()
				PlayerFrameManaBarText:Hide()
			end
		end
		
		-- Show appropriate status text
		if isDead then
			PlayerFrameDeadText:Show()
			PlayerFrameGhostText:Hide()
		elseif isGhost then
			PlayerFrameDeadText:Hide()
			PlayerFrameGhostText:Show()
		else
			PlayerFrameDeadText:Hide()
			PlayerFrameGhostText:Hide()
		end
	elseif unit == "target" then
		-- Show appropriate status text
		if isDead then
			TargetFrameTextureFrameDeadText:Show()
			TargetFrameTextureFrameGhostText:Hide()
			TargetFrameTextureFrameOfflineText:Hide()
		elseif isGhost then
			TargetFrameTextureFrameDeadText:Hide()
			TargetFrameTextureFrameGhostText:Show()
			TargetFrameTextureFrameOfflineText:Hide()
		elseif isOffline then
			TargetFrameTextureFrameDeadText:Hide()
			TargetFrameTextureFrameGhostText:Hide()
			TargetFrameTextureFrameOfflineText:Show()
		else
			TargetFrameTextureFrameDeadText:Hide()
			TargetFrameTextureFrameGhostText:Hide()
			TargetFrameTextureFrameOfflineText:Hide()
		end
	end
end
-- Hook health bar updates only if the method exists
if PlayerFrameHealthBar and PlayerFrameHealthBar.UpdateTextStringWithValues then
	hooksecurefunc(PlayerFrameHealthBar, "UpdateTextStringWithValues", whoaCheckDead)
end
if TargetFrameHealthBar and TargetFrameHealthBar.UpdateTextStringWithValues then
	hooksecurefunc(TargetFrameHealthBar, "UpdateTextStringWithValues", whoaCheckDead)
end

--========================================================
-- Role Indicators
--========================================================

-- Role indicator atlas mapping
local roleAtlas = {
	TANK = "UI-LFG-RoleIcon-Tank-Micro",
	HEALER = "UI-LFG-RoleIcon-Healer-Micro",
	DAMAGER = "UI-LFG-RoleIcon-DPS-Micro"
}

-- Create and update role indicator for any unit frame
function createRoleIndicator(frame, unit)
	if not frame or not frame:IsShown() then return end
	
	if not frame.roleIndicator then
		frame.roleIndicator = CreateFrame("Frame", nil, frame)
		frame.roleIndicator:SetSize(20, 20)
		frame.roleIndicator:SetFrameLevel(frame:GetFrameLevel() + 4)
		
		local texture = frame.roleIndicator:CreateTexture(nil, "OVERLAY")
		texture:SetAllPoints(frame.roleIndicator)
		frame.roleIndicator.texture = texture
	end
	
	-- Get the unit from frame if not provided
	if not unit then
		unit = frame.unit
	end
	
	if not unit then return end
	
	-- Try to get role
	local role = UnitGroupRolesAssigned(unit)
	
	if role and role ~= "NONE" then
		frame.roleIndicator:Show()
		
		-- Set the appropriate atlas
		local roleAtlasName = roleAtlas[role]
		if roleAtlasName then
			frame.roleIndicator.texture:SetAtlas(roleAtlasName)
		end
		
		-- Position based on unit type
		local healthBar = frame.healthbar
		if healthBar then
			if unit == "player" then
				-- Top left corner of healthbar for player
				frame.roleIndicator:SetPoint("TOPLEFT", healthBar, "TOPLEFT", -15, 12)
			elseif string.match(unit, "^party%d") then
				-- Left of healthbar for party frames (changed from name anchor)
				frame.roleIndicator:SetPoint("TOPLEFT", healthBar, "TOPLEFT", -15, 12)
			else
				-- Top right corner of healthbar for target and focus
				frame.roleIndicator:SetPoint("TOPRIGHT", healthBar, "TOPRIGHT", 15, 12)
			end
		end
	else
		frame.roleIndicator:Hide()
	end
end