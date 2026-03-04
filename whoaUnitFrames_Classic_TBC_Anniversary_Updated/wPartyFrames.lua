-------------------------
-- CUSTOM PARTY FRAMES
-- Replicating player frame styling and layout
-------------------------

local customPartyFrames = {}
_G.customPartyFrames = customPartyFrames  -- Make accessible to settings

-- Shared state for group dragging
local isGroupDragging = false
local dragStartPositions = {}
local dragUpdateFrame = nil

-- Phantom party frame (shown solo, for layout preview)
local phantomPartyFrame = nil

-------------------------
-- FRAME CREATION
-------------------------

local function createCustomPartyFrame(index, isPhantom)
	local frameName = isPhantom and "WhoanUF_PhantomParty" or ("WhoanUF_Party" .. index)
	local unit = isPhantom and "player" or ("party" .. index)
	
	-- Check if frame already exists (might persist across reloads)
	local existingFrame = _G[frameName]
	if existingFrame and existingFrame:IsObjectType("Frame") and existingFrame.unit == unit then
		-- Frame already exists and is valid, reuse it
		if isPhantom then
			phantomPartyFrame = existingFrame
		else
			customPartyFrames[index] = existingFrame
		end
		existingFrame:Show()
		existingFrame:SetAlpha(1)
		return existingFrame
	end
	
	-- Create main frame (secure button for real frames, plain frame for phantom)
	local frame
	if isPhantom then
		frame = CreateFrame("Frame", frameName, UIParent)
	else
		frame = CreateFrame("Button", frameName, UIParent, "SecureUnitButtonTemplate")
	end
	frame:SetSize(216, 108)
	
	-- Position setup
	if isPhantom then
		if cfg.phantomPartyPosition then
			local p = cfg.phantomPartyPosition
			frame:SetPoint(p[1], UIParent, p[2], p[3], p[4])
		else
			frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 20, 50)
		end
	else
		-- Check if there's a saved position for this frame
		local hasSavedPosition = cfg.partyFramePositions and cfg.partyFramePositions[index]
		
		if hasSavedPosition then
			-- Use saved position
			local savedPos = cfg.partyFramePositions[index]
			frame:SetPoint(savedPos[1], UIParent, savedPos[2], savedPos[3], savedPos[4])
		else
			-- Initial position with scaled spacing
			local scale = cfg.partyFrameScale or 1.0
			local frameHeight = 128
			local gap = 5
			local scaledSpacing = (frameHeight + gap) * scale
			
			if index == 1 then
				frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 20, 50)
			else
				-- Position relative to previous frame with scaled spacing
				local yOffset = 50 - ((index - 1) * scaledSpacing)
				frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 20, yOffset)
			end
		end
	end
	
	frame:SetMovable(true)
	frame:SetFrameStrata("BACKGROUND")
	frame:SetFrameLevel(2)
	
	-- Store unit reference
	frame.unit = unit
	frame.partyIndex = index
	
	-- Secure attributes and unit watch (real party frames only)
	if not isPhantom then
		frame:SetAttribute("unit", unit)
		frame:SetAttribute("type1", "target")
		frame:SetAttribute("type2", "togglemenu")
		-- Use secure visibility driver instead of manual Show/Hide
		-- Only call RegisterUnitWatch once per frame to avoid taint
		if not frame.unitWatchRegistered then
			RegisterUnitWatch(frame)
			frame.unitWatchRegistered = true
		end
		frame:SetAttribute("*type1", "target")
		frame:SetAttribute("*type2", "togglemenu")
		frame:RegisterForClicks("AnyUp")
	end
	frame:EnableMouse(true)
	frame:SetHitRectInsets(0, 0, 0, 0)
	
	-- Make frame draggable (right-click + drag)
	frame:SetClampedToScreen(true)
	frame:RegisterForDrag("RightButton")
	
	if isPhantom then
		-- Phantom: simple individual drag, saves its own position key
		frame:SetScript("OnDragStart", function(self)
			if not InCombatLockdown() and not cfg.lockPartyFrames then
				self:StartMoving()
			end
		end)
		frame:SetScript("OnDragStop", function(self)
			self:StopMovingOrSizing()
			local point, _, relPoint, x, y = self:GetPoint()
			cfg.phantomPartyPosition = { point, relPoint, x, y }
		end)
	else
		-- Real frames: group drag moves all together
		frame:SetScript("OnDragStart", function(self)
			if not InCombatLockdown() and not cfg.lockPartyFrames and not isGroupDragging then
				isGroupDragging = true
				dragStartPositions = {}
				
				-- Store starting positions and mouse position
				local cursorX, cursorY = GetCursorPosition()
				local scale = UIParent:GetEffectiveScale()
				cursorX = cursorX / scale
				cursorY = cursorY / scale
				
				for i = 1, 5 do
					if customPartyFrames[i] then
						local _, _, _, xOfs, yOfs = customPartyFrames[i]:GetPoint()
						dragStartPositions[i] = {
							startX = xOfs,
							startY = yOfs,
							offsetX = cursorX - xOfs,
							offsetY = cursorY - yOfs
						}
					end
				end
				
				-- Create update frame for smooth dragging
				if not dragUpdateFrame then
					dragUpdateFrame = CreateFrame("Frame")
				end
				
				dragUpdateFrame:SetScript("OnUpdate", function()
					if isGroupDragging then
						local x, y = GetCursorPosition()
						local s = UIParent:GetEffectiveScale()
						x = x / s
						y = y / s
						
						-- Move all frames based on cursor position
						for i = 1, 5 do
							if customPartyFrames[i] and dragStartPositions[i] then
								local newX = x - dragStartPositions[i].offsetX
								local newY = y - dragStartPositions[i].offsetY
								customPartyFrames[i]:ClearAllPoints()
								customPartyFrames[i]:SetPoint("TOPLEFT", UIParent, "TOPLEFT", newX, newY)
							end
						end
					end
				end)
			end
		end)
		
		frame:SetScript("OnDragStop", function(self)
			if isGroupDragging then
				-- Stop the update loop
				if dragUpdateFrame then
					dragUpdateFrame:SetScript("OnUpdate", nil)
				end
				
				-- Save positions for all frames
				if not cfg.partyFramePositions then
					cfg.partyFramePositions = {}
				end
				
				for i = 1, 5 do
					if customPartyFrames[i] then
						local point, _, relativePoint, xOfs, yOfs = customPartyFrames[i]:GetPoint()
						cfg.partyFramePositions[i] = {point, relativePoint, xOfs, yOfs}
					end
				end
				
				print("|cffffff00All party frame positions saved.|r")
				isGroupDragging = false
				dragStartPositions = {}
			end
		end)
	end
	
	-- Background texture
	local bgTexture = frameName .. "BG"
	frame:CreateTexture(bgTexture, "BACKGROUND")
	local tex = _G[bgTexture]
	local texturePath = cfg.darkFrames and 
		"Interface\\Addons\\whoaUnitFrames_Classic_TBC_Anniversary_Updated\\media\\dark\\UI-PartyFrame" or
		"Interface\\Addons\\whoaUnitFrames_Classic_TBC_Anniversary_Updated\\media\\light\\UI-PartyFrame"
	tex:SetTexture(texturePath)
	tex:SetSize(216, 108)
	tex:SetPoint("CENTER", frame, "CENTER", 0, 0)
	tex:SetTexCoord(0, 1, 0, 1)
	
	-- Portrait
	frame.portrait = CreateFrame("Frame", frameName .. "PortraitFrame", frame)
	frame.portrait:SetSize(60, 60)
	frame.portrait:SetPoint("CENTER", frame, "TOPLEFT", 42, -44)
	frame.portrait:SetFrameLevel(frame:GetFrameLevel() - 1)
	frame.portrait:EnableMouse(false)
	frame.portrait.texture = frame.portrait:CreateTexture(nil, "BACKGROUND")
	frame.portrait.texture:SetAllPoints(frame.portrait)
	
	-- Status texture (for threat indicator)
	frame.statusTexture = frame:CreateTexture(frameName .. "StatusTexture", "OVERLAY")
	frame.statusTexture:SetTexture("Interface\\Addons\\whoaUnitFrames_Classic_TBC_Anniversary_Updated\\media\\UI-PARTYFRAME-FLASH")
	frame.statusTexture:SetSize(216, 108)
	frame.statusTexture:SetPoint("CENTER", frame, "CENTER", 0, 0)
	frame.statusTexture:SetTexCoord(0, 1, 0, 1)
	frame.statusTexture:SetVertexColor(1, 0.5, 0.5, 0.5)  -- Start invisible
	frame.statusTexture:SetBlendMode("ADD")  -- Makes black background transparent
	
	-- Create health bar
	frame.healthbar = CreateFrame("StatusBar", frameName .. "HealthBar", frame)
	frame.healthbar:SetSize(120, 18)
	frame.healthbar:SetPoint("TOPLEFT", frame, "TOPLEFT", 75, -23)
	frame.healthbar:SetFrameLevel(frame:GetFrameLevel() - 1)
	frame.healthbar:EnableMouse(false)
	
	-- Initialize min/max and value so texture displays from start
	frame.healthbar:SetMinMaxValues(0, 100)
	frame.healthbar:SetValue(100)
	frame.healthbar:SetStatusBarColor(0, 1, 0)
	frame.healthbar.bg = frame.healthbar:CreateTexture(nil, "BACKGROUND")
	frame.healthbar.bg:SetAllPoints(frame.healthbar)
	frame.healthbar.bg:SetColorTexture(0.1, 0.1, 0.1, 0.75)
	
	-- Power bar
	frame.manabar = CreateFrame("StatusBar", frameName .. "ManaBar", frame)
	frame.manabar:SetSize(120, 18)
	frame.manabar:SetPoint("TOPLEFT", frame, "TOPLEFT", 75, -44)
	frame.manabar:SetFrameLevel(frame:GetFrameLevel() - 1)
	frame.manabar:EnableMouse(false)
	frame.manabar:SetMinMaxValues(0, 100)
	frame.manabar:SetValue(100)
	frame.manabar:SetStatusBarColor(0, 0, 1)
	frame.manabar.bg = frame.manabar:CreateTexture(nil, "BACKGROUND")
	frame.manabar.bg:SetAllPoints(frame.manabar)
	frame.manabar.bg:SetColorTexture(0.1, 0.1, 0.1, 0.75)
	
	-- Create heal prediction bar (myIncomingHeal - your heals on this unit)
	frame.healthbar.myHealPrediction = frame.healthbar:CreateTexture(nil, "OVERLAY", nil, 7)
	local healTexture = cfg.whoaTexture and "Interface\\Addons\\whoaUnitFrames_Classic_TBC_Anniversary_Updated\\media\\statusbar\\whoa" or "Interface\\TargetingFrame\\UI-StatusBar"
	frame.healthbar.myHealPrediction:SetTexture(healTexture)
	frame.healthbar.myHealPrediction:SetVertexColor(0, 1, 0.5, 0.6)
	frame.healthbar.myHealPrediction:SetSize(0, 18)
	frame.healthbar.myHealPrediction:SetPoint("TOPLEFT", frame.healthbar, "TOPLEFT", 0, 0)
	frame.healthbar.myHealPrediction:Show()
	
	-- Create heal prediction bar (allIncomingHeal - all other heals on this unit)
	frame.healthbar.otherHealPrediction = frame.healthbar:CreateTexture(nil, "OVERLAY", nil, 6)
	frame.healthbar.otherHealPrediction:SetTexture(healTexture)
	frame.healthbar.otherHealPrediction:SetVertexColor(0, 0.5, 0, 0.6)
	frame.healthbar.otherHealPrediction:SetSize(0, 18)
	frame.healthbar.otherHealPrediction:SetPoint("TOPLEFT", frame.healthbar, "TOPLEFT", 0, 0)
	frame.healthbar.otherHealPrediction:Show()
	
	-- Create name background button first (primary anchor)
	frame.nameButtonBG = CreateFrame("Button", nil, frame, "BigRedThreeSliceButtonTemplate")
	frame.nameButtonBG:SetSize(80, 24)
	frame.nameButtonBG:EnableMouse(false)
	frame.nameButtonBG:SetFrameLevel(frame:GetFrameLevel() - 1)
	-- Position relative to frame directly (above healthbar area)
	frame.nameButtonBG:SetPoint("TOPLEFT", frame, "TOPLEFT", 75, 1)
	
	-- Create name text and parent it to the background
	frame.name = frame.nameButtonBG:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	frame.name:SetFont("Fonts\\FRIZQT__.TTF", 11)
	frame.name:SetPoint("CENTER", frame.nameButtonBG, "CENTER", 0, 0)
	frame.name:SetTextColor(1, 0.82, 0)  -- Golden yellow like player/target frames
	
	-- Create health text (right aligned)
	frame.healthbar.RightText = frame.healthbar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	frame.healthbar.RightText:SetFont("Fonts\\FRIZQT__.TTF", 10)
	frame.healthbar.RightText:SetPoint("RIGHT", frame.healthbar, "RIGHT", -5, 0)
	frame.healthbar.RightText:SetTextColor(1, 1, 1)
	
	-- Create health percent text (left aligned)
	frame.healthbar.LeftText = frame.healthbar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	frame.healthbar.LeftText:SetFont("Fonts\\FRIZQT__.TTF", 10)
	frame.healthbar.LeftText:SetPoint("LEFT", frame.healthbar, "LEFT", 5, 0)
	frame.healthbar.LeftText:SetTextColor(1, 1, 1)
	
	-- Create health center text
	frame.healthbar.TextString = frame.healthbar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	frame.healthbar.TextString:SetFont("Fonts\\FRIZQT__.TTF", 10)
	frame.healthbar.TextString:SetPoint("CENTER", frame.healthbar, "CENTER", 0, 0)
	frame.healthbar.TextString:SetTextColor(1, 1, 1)
	
	-- Create power text (right aligned)
	frame.manabar.RightText = frame.manabar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	frame.manabar.RightText:SetFont("Fonts\\FRIZQT__.TTF", 10)
	frame.manabar.RightText:SetPoint("RIGHT", frame.manabar, "RIGHT", -5, 0)
	frame.manabar.RightText:SetTextColor(1, 1, 1)
	
	-- Create power percent text (left aligned)
	frame.manabar.LeftText = frame.manabar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	frame.manabar.LeftText:SetFont("Fonts\\FRIZQT__.TTF", 10)
	frame.manabar.LeftText:SetPoint("LEFT", frame.manabar, "LEFT", 5, 0)
	frame.manabar.LeftText:SetTextColor(1, 1, 1)
	
	-- Create power center text
	frame.manabar.TextString = frame.manabar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	frame.manabar.TextString:SetFont("Fonts\\FRIZQT__.TTF", 10)
	frame.manabar.TextString:SetPoint("CENTER", frame.manabar, "CENTER", 0, 0)
	frame.manabar.TextString:SetTextColor(1, 1, 1)
	
	-- Create dead text (center of health bar)
	frame.deadText = frame.healthbar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	frame.deadText:SetPoint("CENTER", frame.healthbar, "CENTER", 0, 0)
	frame.deadText:SetText(DEAD)
	frame.deadText:Hide()
	
	-- Create ghost text (center of health bar)
	frame.ghostText = frame.healthbar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	frame.ghostText:SetPoint("CENTER", frame.healthbar, "CENTER", 0, 0)
	frame.ghostText:SetText("Ghost")
	frame.ghostText:Hide()
	
	-- Create offline text (center of health bar)
	frame.offlineText = frame.healthbar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	frame.offlineText:SetPoint("CENTER", frame.healthbar, "CENTER", 0, 0)
	frame.offlineText:SetText("Offline")
	frame.offlineText:Hide()
	
	-- Create level text in the circle below portrait
	frame.levelText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	frame.levelText:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
	frame.levelText:SetPoint("CENTER", frame, "BOTTOMLEFT", 19, 42)
	frame.levelText:SetTextColor(1, 0.82, 0)  -- Golden yellow
	
	-- Create PVP icon (positioned at top left of level text, bigger size)
	frame.pvpIcon = frame:CreateTexture(frameName .. "PVPIcon", "OVERLAY")
	frame.pvpIcon:SetSize(65, 65)
	frame.pvpIcon:SetPoint("BOTTOMRIGHT", frame.levelText, "TOPLEFT", 35, -23)
	frame.pvpIcon:Hide()
	
	-- Role indicator will be created by global createRoleIndicator function
	-- Leader indicator icon (positioned left of healthbar)
	frame.leaderIcon = frame:CreateTexture(nil, "OVERLAY")
	frame.leaderIcon:SetSize(20, 20)
	frame.leaderIcon:SetPoint("TOPLEFT", frame.healthbar, "TOPLEFT", -30, 25)
	frame.leaderIcon:SetTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon")
	frame.leaderIcon:Hide()
	
	-- Create buff frames (below power bar)
	frame.buffs = {}
	for i = 1, 5 do
		local buff = CreateFrame("Frame", frameName .. "Buff" .. i, frame)
		buff:SetSize(24, 24)
		buff:EnableMouse(true)
		buff.unit = unit
		buff.index = i
		
		-- Position buffs in a single row below power bar
		if i == 1 then
			-- First buff: below power bar
			buff:SetPoint("TOPLEFT", frame.manabar, "BOTTOMLEFT", 0, -5)
		else
			-- Continuation: to the right of previous
			buff:SetPoint("LEFT", frame.buffs[i-1], "RIGHT", 2, 0)
		end
		
		-- Buff icon texture
		buff.icon = buff:CreateTexture(nil, "BACKGROUND")
		buff.icon:SetAllPoints(buff)
		buff.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)  -- Crop edges like Blizzard frames
		
		-- Buff border
		buff.border = buff:CreateTexture(nil, "BORDER")
		buff.border:SetAllPoints(buff)
		buff.border:SetTexture("Interface\\Buttons\\UI-Debuff-Overlays")
		buff.border:SetTexCoord(0.296875, 0.5703125, 0, 0.515625)
		
		-- Buff cooldown spiral
		buff.cooldown = CreateFrame("Cooldown", nil, buff, "CooldownFrameTemplate")
		buff.cooldown:SetAllPoints(buff)
		buff.cooldown:SetDrawEdge(true)
		buff.cooldown:SetDrawSwipe(true)
		buff.cooldown:SetHideCountdownNumbers(true)
		buff.cooldown:SetReverse(true)
		
		-- Stack count text
		buff.count = buff:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		buff.count:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", 2, 0)
		buff.count:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
		buff.count:SetTextColor(1, 1, 1)
		
		-- Tooltip on hover
		buff:SetScript("OnEnter", function(self)
			if UnitExists(self.unit) then
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
				GameTooltip:SetUnitBuff(self.unit, self.index)
				GameTooltip:Show()
			end
		end)
		
		buff:SetScript("OnLeave", function(self)
			GameTooltip:Hide()
		end)
		
		buff:Hide()
		frame.buffs[i] = buff
	end
	
	-- Create debuff frames (below buffs)
	frame.debuffs = {}
	for i = 1, 5 do
		local debuff = CreateFrame("Frame", frameName .. "Debuff" .. i, frame)
		debuff:SetSize(24, 24)
		debuff:EnableMouse(true)
		debuff.unit = unit
		debuff.index = i
		
		-- Position debuffs in a single row below buffs
		if i == 1 then
			-- First debuff: below first row of buffs
			debuff:SetPoint("TOPLEFT", frame.buffs[1], "BOTTOMLEFT", 0, -3)
		else
			-- Continuation: to the right of previous
			debuff:SetPoint("LEFT", frame.debuffs[i-1], "RIGHT", 2, 0)
		end
		
		-- Debuff icon texture
		debuff.icon = debuff:CreateTexture(nil, "BACKGROUND")
		debuff.icon:SetAllPoints(debuff)
		debuff.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)  -- Crop edges like Blizzard frames
		
		-- Debuff border (colored based on debuff type)
		debuff.border = debuff:CreateTexture(nil, "BORDER")
		debuff.border:SetAllPoints(debuff)
		debuff.border:SetTexture("Interface\\Buttons\\UI-Debuff-Overlays")
		debuff.border:SetTexCoord(0.296875, 0.5703125, 0, 0.515625)
		
		-- Debuff cooldown spiral
		debuff.cooldown = CreateFrame("Cooldown", nil, debuff, "CooldownFrameTemplate")
		debuff.cooldown:SetAllPoints(debuff)
		debuff.cooldown:SetDrawEdge(true)
		debuff.cooldown:SetDrawSwipe(true)
		debuff.cooldown:SetHideCountdownNumbers(true)
		debuff.cooldown:SetReverse(true)
		
		-- Stack count text
		debuff.count = debuff:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		debuff.count:SetPoint("BOTTOMRIGHT", debuff, "BOTTOMRIGHT", 2, 0)
		debuff.count:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
		debuff.count:SetTextColor(1, 1, 1)
		
		-- Tooltip on hover
		debuff:SetScript("OnEnter", function(self)
			if UnitExists(self.unit) then
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
				GameTooltip:SetUnitDebuff(self.unit, self.index)
				GameTooltip:Show()
			end
		end)
		
		debuff:SetScript("OnLeave", function(self)
			GameTooltip:Hide()
		end)
		
		debuff:Hide()
		frame.debuffs[i] = debuff
	end
	
	-- Mouse enter - show tooltip
	frame:SetScript("OnEnter", function(self)
		if UnitExists(self.unit) then
			GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
			GameTooltip:SetUnit(self.unit)
			GameTooltip:Show()
		end
	end)
	
	-- Mouse leave - hide tooltip
	frame:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)
	
	-- Apply scale during creation (from saved config or default 1.0)
	-- Note: Must be done during creation to avoid taint on secure frames
	local scale = cfg.partyFrameScale or 1.0
	frame:SetScale(scale)
	
	-- Phantom label and final storage
	if isPhantom then
		frame.isPhantom = true
		local lbl = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		lbl:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
		lbl:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -5, 4)
		lbl:SetText("|cffff8000[PHANTOM]|r")
		frame.phantomLabel = lbl
		phantomPartyFrame = frame
	else
		customPartyFrames[index] = frame
	end
	return frame
end

-------------------------
-- PHANTOM FRAME
-------------------------

-- Phantom frame: reuses createCustomPartyFrame with "player" unit so layout is identical.
local function createPhantomPartyFrame()
	return createCustomPartyFrame(nil, true)
end

-- Update threat indicator for a party frame
local function updatePartyThreat(frame)
	if not frame or not frame.unit or not UnitExists(frame.unit) then
		if frame and frame.statusTexture then
			frame.statusTexture:SetVertexColor(1, 0, 0, 0)
		end
		return
	end
	
	local status = UnitThreatSituation(frame.unit)
	
	if status and status == 3 then
		-- Securely tanking - show solid red
		frame.statusTexture:SetVertexColor(1, 0, 0, 1)
	else
		-- No secure aggro - invisible
		frame.statusTexture:SetVertexColor(1, 0, 0, 0)
	end
end

-- Apply font styling based on config
local function applyPartyFrameFontStyle(frame)
	if (cfg.styleFont) then
		if frame.healthbar.LeftText then
			frame.healthbar.LeftText:SetFontObject(SystemFont_Outline_Small)
		end
		if frame.healthbar.RightText then
			frame.healthbar.RightText:SetFontObject(SystemFont_Outline_Small)
		end
		if frame.manabar.LeftText then
			frame.manabar.LeftText:SetFontObject(SystemFont_Outline_Small)
		end
		if frame.manabar.RightText then
			frame.manabar.RightText:SetFontObject(SystemFont_Outline_Small)
		end
		if frame.name then
			frame.name:SetFontObject(SystemFont_Outline_Small)
		end
	end
end

-- Update heal prediction for a frame
local function updateHealPrediction(frame, unit)
	if not frame or not frame.healthbar or not UnitExists(unit) then
		if frame and frame.healthbar then
			if frame.healthbar.myHealPrediction then
				frame.healthbar.myHealPrediction:SetWidth(0)
			end
			if frame.healthbar.otherHealPrediction then
				frame.healthbar.otherHealPrediction:SetWidth(0)
			end
		end
		return
	end
	
	local health = UnitHealth(unit)
	local maxHealth = UnitHealthMax(unit)
	
	if maxHealth == 0 then return end
	
	-- Get incoming heals
	local myIncomingHeal = UnitGetIncomingHeals(unit, "player") or 0
	local allIncomingHeal = UnitGetIncomingHeals(unit) or 0
	local otherIncomingHeal = allIncomingHeal - myIncomingHeal
	
	-- Calculate bar width
	local barWidth = frame.healthbar:GetWidth()
	local healthFraction = health / maxHealth
	
	-- Update heal prediction textures to match healthbar texture setting
	local healTexture = cfg.whoaTexture and "Interface\\Addons\\whoaUnitFrames_Classic_TBC_Anniversary_Updated\\media\\statusbar\\whoa" or "Interface\\TargetingFrame\\UI-StatusBar"
	frame.healthbar.myHealPrediction:SetTexture(healTexture)
	frame.healthbar.otherHealPrediction:SetTexture(healTexture)
	
	-- Ensure heals don't go over max health
	local totalPredictedHealth = health + allIncomingHeal
	if totalPredictedHealth > maxHealth then
		local overflow = totalPredictedHealth - maxHealth
		allIncomingHeal = allIncomingHeal - overflow
		if myIncomingHeal > allIncomingHeal then
			myIncomingHeal = allIncomingHeal
		end
		otherIncomingHeal = allIncomingHeal - myIncomingHeal
	end
	
	-- Calculate offset based on current health
	local healthWidth = healthFraction * barWidth
	
	-- Set my heal prediction width
	if myIncomingHeal > 0 then
		local myHealWidth = (myIncomingHeal / maxHealth) * barWidth
		frame.healthbar.myHealPrediction:SetWidth(myHealWidth)
		frame.healthbar.myHealPrediction:SetPoint("TOPLEFT", frame.healthbar, "TOPLEFT", healthWidth, 0)
		frame.healthbar.myHealPrediction:Show()
	else
		frame.healthbar.myHealPrediction:SetWidth(0)
		frame.healthbar.myHealPrediction:Hide()
	end
	
	-- Set other heal prediction width
	if otherIncomingHeal > 0 then
		local otherHealWidth = (otherIncomingHeal / maxHealth) * barWidth
		frame.healthbar.otherHealPrediction:SetWidth(otherHealWidth)
		frame.healthbar.otherHealPrediction:SetPoint("TOPLEFT", frame.healthbar, "TOPLEFT", healthWidth + (myIncomingHeal / maxHealth * barWidth), 0)
		frame.healthbar.otherHealPrediction:Show()
	else
		frame.healthbar.otherHealPrediction:SetWidth(0)
		frame.healthbar.otherHealPrediction:Hide()
	end
end

-- Update buffs for a frame
local function updateBuffs(frame, unit)
	if not frame or not frame.buffs or not UnitExists(unit) then
		if frame and frame.buffs then
			for i = 1, #frame.buffs do
				frame.buffs[i]:Hide()
			end
		end
		return
	end
	
	-- Collect all buffs with their data
	local buffList = {}
	for i = 1, 40 do
		local name, icon, count, debuffType, duration, expirationTime, caster = UnitBuff(unit, i)
		if not name then break end
		
		local remaining = 0
		if duration and duration > 0 then
			remaining = expirationTime - GetTime()
		end
		
		local isPlayerBuff = (caster == "player")
		
		-- Filter: only show player's own buffs with duration between 0 and 60 minutes (3600 seconds)
		if isPlayerBuff and duration > 0 and duration <= 3600 then
			table.insert(buffList, {
				name = name,
				icon = icon,
				count = count,
				duration = duration,
				expirationTime = expirationTime,
				remaining = remaining,
				isPlayerBuff = isPlayerBuff,
				index = i  -- Store original index for stable sorting
			})
		end
	end
	
	-- Sort by shortest remaining duration first
	table.sort(buffList, function(a, b)
		return a.remaining < b.remaining
	end)

	-- Display up to 5 buffs
	local maxBuffs = math.min(#buffList, 5)
	for i = 1, maxBuffs do
		local buffData = buffList[i]
		local buff = frame.buffs[i]
		
		-- Update API index so tooltip matches the sorted slot
		buff.index = buffData.index
		
		buff.icon:SetTexture(buffData.icon)
		
		-- Update stack count
		if buffData.count and buffData.count > 1 then
			buff.count:SetText(buffData.count)
			buff.count:Show()
		else
			buff.count:Hide()
		end
		
		-- Update cooldown spiral
		if buffData.duration and buffData.duration > 0 and buff.cooldown then
			buff.cooldown:SetCooldown(buffData.expirationTime - buffData.duration, buffData.duration)
			buff.cooldown:Show()
		else
			if buff.cooldown then
				buff.cooldown:Hide()
			end
		end
		
		buff:Show()
	end
	
	-- Hide unused buff frames
	for i = maxBuffs + 1, #frame.buffs do
		frame.buffs[i]:Hide()
	end
end

-- Update debuffs for a frame
local function updateDebuffs(frame, unit)
	if not frame or not frame.debuffs or not UnitExists(unit) then
		if frame and frame.debuffs then
			for i = 1, #frame.debuffs do
				frame.debuffs[i]:Hide()
			end
		end
		return
	end
	
	-- Collect all debuffs with their data
	local debuffList = {}
	for i = 1, 40 do
		local name, icon, count, debuffType, duration, expirationTime = UnitDebuff(unit, i)
		if not name then break end
		
		local remaining = 0
		if duration and duration > 0 then
			remaining = expirationTime - GetTime()
		end
		
		-- Filter: show all debuffs with duration between 0 and 60 minutes (3600 seconds)
		if duration > 0 and duration <= 3600 then
			table.insert(debuffList, {
				name = name,
				icon = icon,
				count = count,
				debuffType = debuffType,
				duration = duration,
				expirationTime = expirationTime,
				remaining = remaining,
				index = i  -- Store original index for stable sorting
			})
		end
	end
	
	-- Sort by shortest remaining duration first
	table.sort(debuffList, function(a, b)
		return a.remaining < b.remaining
	end)

	-- Display up to 5 debuffs
	local maxDebuffs = math.min(#debuffList, 5)
	for i = 1, maxDebuffs do
		local debuffData = debuffList[i]
		local debuff = frame.debuffs[i]
		
		-- Update API index so tooltip matches the sorted slot
		debuff.index = debuffData.index
		
		debuff.icon:SetTexture(debuffData.icon)
		
		-- Color border based on debuff type
		local color = DebuffTypeColor[debuffData.debuffType] or DebuffTypeColor["none"]
		debuff.border:SetVertexColor(color.r, color.g, color.b)
		
		-- Update stack count
		if debuffData.count and debuffData.count > 1 then
			debuff.count:SetText(debuffData.count)
			debuff.count:Show()
		else
			debuff.count:Hide()
		end
		
		-- Update cooldown spiral
		if debuffData.duration and debuffData.duration > 0 and debuff.cooldown then
			debuff.cooldown:SetCooldown(debuffData.expirationTime - debuffData.duration, debuffData.duration)
			debuff.cooldown:Show()
		else
			if debuff.cooldown then
				debuff.cooldown:Hide()
			end
		end
		
		debuff:Show()
	end
	
	-- Hide unused debuff frames
	for i = maxDebuffs + 1, #frame.debuffs do
		frame.debuffs[i]:Hide()
	end
end

-- Update leader indicator
local function updateLeaderIndicator(frame, unit)
	if not frame or not frame.leaderIcon or not unit then return end
	
	if UnitIsGroupLeader(unit) then
		frame.leaderIcon:Show()
	else
		frame.leaderIcon:Hide()
	end
end

local function updateCustomPartyFrame(frame, unit)
	if not frame or not unit then return end
	
	-- Don't update if unit doesn't exist
	if not UnitExists(unit) then
		return
	end
	
	-- Update name with styling (no level, just name)
	if frame.name then
		local name = UnitName(unit)
		if name then
			frame.name:SetText(name)
			
			-- Show/hide name background based on settings
			if frame.nameButtonBG then
				if cfg.showNameBackground then
					frame.nameButtonBG:Show()
					-- Update button width to match name (name is always centered on background)
					local textWidth = frame.name:GetStringWidth() or 50
					local padding = 15
					frame.nameButtonBG:SetWidth(math.max(textWidth + padding, 50))
				else
					-- Hide background but keep name visible (name stays on hidden background)
					frame.nameButtonBG:Hide()
				end
			end
		end
	end
	
	-- Update level text
	if frame.levelText then
		local level = UnitLevel(unit)
		if level and level > 0 then
			frame.levelText:SetText(level)
			frame.levelText:Show()
		else
			frame.levelText:Hide()
		end
	end
	
	-- Update PVP icon
	if frame.pvpIcon then
		local factionGroup = UnitFactionGroup(unit)
		if factionGroup and factionGroup ~= "Neutral" and UnitIsPVP(unit) then
			frame.pvpIcon:Show()
			if cfg.darkFrames then
				frame.pvpIcon:SetTexture("Interface\\Addons\\whoaUnitFrames_Classic_TBC_Anniversary_Updated\\media\\dark\\UI-PVP-" .. factionGroup)
			else
				frame.pvpIcon:SetTexture("Interface\\TargetingFrame\\UI-PVP-" .. factionGroup)
			end
		else
			frame.pvpIcon:Hide()
		end
	end
	
	-- Update role indicator
	createRoleIndicator(frame, unit)
	
	-- Update leader indicator
	updateLeaderIndicator(frame, unit)
	
	-- Check for dead/offline status
	-- Note: whoaCheckDead in whoaUnitFrames.lua handles Blizzard frames (PartyMemberFrame1-4)
	-- This handles our custom party frames with different structure
	local isDead = UnitIsDead(unit)
	local isGhost = UnitIsGhost(unit)
	local isOffline = not UnitIsConnected(unit)
	
	-- Update health bar
	if frame.healthbar then
		-- Update texture based on config
		if cfg.whoaTexture then
			frame.healthbar:SetStatusBarTexture("Interface\\Addons\\whoaUnitFrames_Classic_TBC_Anniversary_Updated\\media\\statusbar\\whoa")
		else
			frame.healthbar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
		end
		
		local health = UnitHealth(unit)
		local maxHealth = UnitHealthMax(unit)
		frame.healthbar:SetMinMaxValues(0, maxHealth)
		frame.healthbar:SetValue(health)
		
		-- Handle dead/offline status
		if isOffline then
			-- Gray out health bar for offline
			frame.healthbar:SetStatusBarColor(0.5, 0.5, 0.5)
			frame.healthbar.LeftText:Hide()
			frame.healthbar.RightText:Hide()
			frame.deadText:Hide()
			frame.ghostText:Hide()
			frame.offlineText:Show()
		elseif isDead then
			-- Gray out health bar for dead
			frame.healthbar:SetStatusBarColor(0.5, 0.5, 0.5)
			frame.healthbar.LeftText:Hide()
			frame.healthbar.RightText:Hide()
			frame.deadText:Show()
			frame.ghostText:Hide()
			frame.offlineText:Hide()
		elseif isGhost then
			-- Gray out health bar for ghost
			frame.healthbar:SetStatusBarColor(0.5, 0.5, 0.5)
			frame.healthbar.LeftText:Hide()
			frame.healthbar.RightText:Hide()
			frame.deadText:Hide()
			frame.ghostText:Show()
			frame.offlineText:Hide()
		else
			-- Show normal text and hide status text
			frame.deadText:Hide()
			frame.ghostText:Hide()
			frame.offlineText:Hide()
			
			-- Update health bar color based on class (only when alive and online)
			if UnitExists(unit) then
				local _, class = UnitClass(unit)
				if class and RAID_CLASS_COLORS[class] then
					local color = RAID_CLASS_COLORS[class]
					frame.healthbar:SetStatusBarColor(color.r, color.g, color.b)
				else
					-- Default to green if no class color
					frame.healthbar:SetStatusBarColor(0, 1, 0)
				end
			end
			
			-- Get display mode from CVar (can be "0"/"1"/"2"/"3" or "NONE"/"NUMERIC"/"PERCENTAGE"/"BOTH")
			local textDisplay = GetCVar("statusTextDisplay")
			
			-- Update health text based on display mode
			if textDisplay == "NONE" or textDisplay == "0" then
				-- Hide all text
				frame.healthbar.LeftText:Hide()
				frame.healthbar.RightText:Hide()
				frame.healthbar.TextString:Hide()
			elseif textDisplay == "BOTH" or textDisplay == "3" then
				-- Show both percentage (left) and current (right)
				local healthPercent = maxHealth > 0 and math.floor((health / maxHealth) * 100) or 0
				frame.healthbar.LeftText:SetText(healthPercent .. "%")
				frame.healthbar.LeftText:Show()
				frame.healthbar.RightText:SetText(health)
				frame.healthbar.RightText:Show()
				frame.healthbar.TextString:Hide()
			elseif textDisplay == "NUMERIC" or textDisplay == "1" then
				-- NUMERIC - show current / max in center
				frame.healthbar.TextString:SetText(health .. " / " .. maxHealth)
				frame.healthbar.TextString:Show()
				frame.healthbar.LeftText:Hide()
				frame.healthbar.RightText:Hide()
			else
				-- PERCENTAGE ("2" or "PERCENTAGE") - show only percentage in center
				local healthPercent = maxHealth > 0 and math.floor((health / maxHealth) * 100) or 0
				frame.healthbar.TextString:SetText(healthPercent .. "%")
				frame.healthbar.TextString:Show()
				frame.healthbar.LeftText:Hide()
				frame.healthbar.RightText:Hide()
			end
		end
	end
	
	-- Update power bar
	if frame.manabar then
		-- Update texture based on config
		if (cfg.whoaTexture == true) then
			frame.manabar:SetStatusBarTexture("Interface\\Addons\\whoaUnitFrames_Classic_TBC_Anniversary_Updated\\media\\statusbar\\whoa")
		else
			frame.manabar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
		end
		
		local power = UnitPower(unit)
		local maxPower = UnitPowerMax(unit)
		frame.manabar:SetMinMaxValues(0, maxPower)
		frame.manabar:SetValue(power)
		
		-- Handle dead/offline status for mana bar
		if isOffline or isDead or isGhost then
			-- Gray out mana bar
			frame.manabar:SetStatusBarColor(0.5, 0.5, 0.5)
			if frame.manabar.LeftText then
				frame.manabar.LeftText:Hide()
			end
			if frame.manabar.RightText then
				frame.manabar.RightText:Hide()
			end
		else
			-- Color power bar based on power type
			local powerType, powerToken = UnitPowerType(unit)
			local powerColor = PowerBarColor[powerToken] or PowerBarColor[powerType]
			if powerColor then
				frame.manabar:SetStatusBarColor(powerColor.r, powerColor.g, powerColor.b)
			else
				-- Default to blue if no color found
				frame.manabar:SetStatusBarColor(0, 0, 1)
			end
			
			-- Get display mode from CVar (can be "0"/"1"/"2"/"3" or "NONE"/"NUMERIC"/"PERCENTAGE"/"BOTH")
			local textDisplay = GetCVar("statusTextDisplay")
			
			-- Update power text based on display mode
			if textDisplay == "NONE" or textDisplay == "0" then
				-- Hide all text
				frame.manabar.LeftText:Hide()
				frame.manabar.RightText:Hide()
				frame.manabar.TextString:Hide()
			elseif textDisplay == "BOTH" or textDisplay == "3" then
				-- Show both percentage (left) and current (right)
				local powerPercent = maxPower > 0 and math.floor((power / maxPower) * 100) or 0
				frame.manabar.LeftText:SetText(powerPercent .. "%")
				frame.manabar.LeftText:Show()
				frame.manabar.RightText:SetText(power)
				frame.manabar.RightText:Show()
				frame.manabar.TextString:Hide()
			elseif textDisplay == "NUMERIC" or textDisplay == "1" then
				-- NUMERIC - show current / max in center
				frame.manabar.TextString:SetText(power .. " / " .. maxPower)
				frame.manabar.TextString:Show()
				frame.manabar.LeftText:Hide()
				frame.manabar.RightText:Hide()
			else
				-- PERCENTAGE ("2" or "PERCENTAGE") - show only percentage in center
				local powerPercent = maxPower > 0 and math.floor((power / maxPower) * 100) or 0
				frame.manabar.TextString:SetText(powerPercent .. "%")
				frame.manabar.TextString:Show()
				frame.manabar.LeftText:Hide()
				frame.manabar.RightText:Hide()
			end
		end
	end
	
	-- Update portrait
	if frame.portrait and frame.portrait.texture then
		SetPortraitTexture(frame.portrait.texture, unit)
	end
	
	-- Update heal prediction
	updateHealPrediction(frame, unit)
	
	-- Update buffs and debuffs
	updateBuffs(frame, unit)
	updateDebuffs(frame, unit)
	
	-- Update threat indicator
	updatePartyThreat(frame)
end

-- Update all party frames
local function updateAllPartyFrames()
	for i = 1, 5 do
		if customPartyFrames[i] then
			updateCustomPartyFrame(customPartyFrames[i], "party" .. i)
		end
	end
end

-- Populate the phantom frame with live player data
-- Populate the phantom frame with live player data (delegates to the shared update function)
local function updatePhantomPartyFrame()
	if not phantomPartyFrame then return end
	-- Refresh background texture (changed by darkFrames setting)
	local bgTex = _G["WhoanUF_PhantomPartyBG"]
	if bgTex then
		local texturePath = cfg.darkFrames
			and "Interface\\Addons\\whoaUnitFrames_Classic_TBC_Anniversary_Updated\\media\\dark\\UI-PartyFrame"
			or  "Interface\\Addons\\whoaUnitFrames_Classic_TBC_Anniversary_Updated\\media\\light\\UI-PartyFrame"
		bgTex:SetTexture(texturePath)
	end
	-- Refresh scale (changed by scale slider)
	phantomPartyFrame:SetScale(cfg.partyFrameScale or 1.0)
	-- Refresh all other frame elements via the shared update path
	updateCustomPartyFrame(phantomPartyFrame, "player")
end

-- Show phantom only when setting is on AND player is not in a group.
-- Called after initialization and on every GROUP_ROSTER_UPDATE.
local function showOrHidePhantomPartyFrame()
	if not cfg.showPhantomParty then
		if phantomPartyFrame then phantomPartyFrame:Hide() end
		return
	end

	if GetNumGroupMembers() == 0 then
		if not phantomPartyFrame then
			createPhantomPartyFrame()
		end
		updatePhantomPartyFrame()
		phantomPartyFrame:Show()
	else
		if phantomPartyFrame then phantomPartyFrame:Hide() end
	end
end

-- Expose so the settings panel can call it when the checkbox is toggled
_G.ShowOrHidePhantomPartyFrame = showOrHidePhantomPartyFrame

-------------------------
-- EVENT HANDLERS
-------------------------

-- Group changes and unit updates
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
eventFrame:RegisterEvent("UNIT_NAME_UPDATE")
eventFrame:RegisterEvent("UNIT_HEALTH")
eventFrame:RegisterEvent("UNIT_POWER_UPDATE")
eventFrame:RegisterEvent("UNIT_HEAL_PREDICTION")
eventFrame:RegisterEvent("UNIT_FACTION")
eventFrame:RegisterEvent("PLAYER_FLAGS_CHANGED")
eventFrame:RegisterEvent("UNIT_AURA")
eventFrame:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE")
eventFrame:RegisterEvent("UNIT_THREAT_LIST_UPDATE")
eventFrame:SetScript("OnEvent", function(self, event, arg1)
	-- Update all frames on roster change
	if event == "GROUP_ROSTER_UPDATE" then
		updateAllPartyFrames()
		showOrHidePhantomPartyFrame()
	-- Update heal prediction for specific unit
	elseif event == "UNIT_HEAL_PREDICTION" then
		if arg1 and string.match(arg1, "^party%d") then
			local index = tonumber(arg1:sub(6))
			if customPartyFrames[index] then
				updateHealPrediction(customPartyFrames[index], arg1)
			end
		end
	-- Update buffs/debuffs for specific unit
	elseif event == "UNIT_AURA" then
		if arg1 and string.match(arg1, "^party%d") then
			local index = tonumber(arg1:sub(6))
			if customPartyFrames[index] then
				updateBuffs(customPartyFrames[index], arg1)
				updateDebuffs(customPartyFrames[index], arg1)
			end
		end
	-- Update threat for specific unit
	elseif event == "UNIT_THREAT_SITUATION_UPDATE" or event == "UNIT_THREAT_LIST_UPDATE" then
		if arg1 and string.match(arg1, "^party%d") then
			local index = tonumber(arg1:sub(6))
			if customPartyFrames[index] then
				updatePartyThreat(customPartyFrames[index])
			end
		end
	-- Update specific frame for health/name changes
	elseif arg1 and string.match(arg1, "^party%d") then
		local index = tonumber(arg1:sub(6))
		if customPartyFrames[index] then
			updateCustomPartyFrame(customPartyFrames[index], arg1)
		end
	-- Keep phantom frame data live when player stats change
	elseif arg1 == "player" and phantomPartyFrame and phantomPartyFrame:IsShown() then
		updatePhantomPartyFrame()
	end
end)

-------------------------
-- BLIZZARD FRAME HIDING
-------------------------

-- Hide default Blizzard party frames using multiple methods
local function HideBlizzardPartyFrames()
	-- Set CVar to disable compact party frames
	SetCVar("useCompactPartyFrames", "0")
	
	-- Try to use Edit Mode to hide party frames if available (Modern client)
	if C_EditMode and C_EditMode.SetAccountSetting and Enum.EditModeAccountSetting then
		pcall(function()
			C_EditMode.SetAccountSetting(Enum.EditModeAccountSetting.PartyFrameShown, 0)
		end)
	end
	
	-- Hide CompactPartyFrame (modern party frames)
	if CompactPartyFrame then
		CompactPartyFrame:UnregisterAllEvents()
		CompactPartyFrame:Hide()
		CompactPartyFrame:SetAlpha(0)
		if CompactPartyFrame.SetShown then
			CompactPartyFrame:SetShown(false)
		end
	end
	
	-- Use RegisterAttributeDriver to securely hide classic party frames
	for i = 1, MAX_PARTY_MEMBERS or 4 do
		local frame = _G["PartyMemberFrame" .. i]
		if frame then
			-- Multiple hiding methods for maximum compatibility
			RegisterAttributeDriver(frame, "state-visibility", "hide")
			frame:UnregisterAllEvents()
			frame:Hide()
			frame:SetAlpha(0)
			if frame.SetShown then
				frame:SetShown(false)
			end
		end
	end
	
	-- Hide party container frames
	if PartyFrame then
		PartyFrame:UnregisterAllEvents()
		PartyFrame:Hide()
		PartyFrame:SetAlpha(0)
	end
end

local function ShowBlizzardPartyFrames()
	-- Set CVar to use classic party frames (not compact)
	SetCVar("useCompactPartyFrames", "0")
	
	-- Try to use Edit Mode to show party frames if available (Modern client)
	if C_EditMode and C_EditMode.SetAccountSetting and Enum.EditModeAccountSetting then
		pcall(function()
			C_EditMode.SetAccountSetting(Enum.EditModeAccountSetting.PartyFrameShown, 1)
		end)
	end
	
	-- Show CompactPartyFrame if it exists (modern party frames)
	if CompactPartyFrame then
		CompactPartyFrame:SetAlpha(1)
		if CompactPartyFrame.SetShown then
			CompactPartyFrame:SetShown(true)
		end
		CompactPartyFrame:Show()
	end
	
	-- Restore classic party frames
	for i = 1, MAX_PARTY_MEMBERS or 4 do
		local frame = _G["PartyMemberFrame" .. i]
		if frame then
			-- Clear attribute driver and restore visibility
			RegisterAttributeDriver(frame, "state-visibility", "show")
			frame:SetAlpha(1)
			if frame.SetShown then
				frame:SetShown(true)
			end
			frame:Show()
		end
	end
	
	-- Show party container frame
	if PartyFrame then
		PartyFrame:SetAlpha(1)
		PartyFrame:Show()
	end
end

-------------------------
-- INITIALIZATION
-------------------------

-- Restore saved positions
local function RestoreFramePositions()
	if cfg.partyFramePositions then
		for i = 1, 5 do
			local frame = customPartyFrames[i]
			local savedPos = cfg.partyFramePositions[i]
			if frame and savedPos then
				-- Can only restore positions during frame creation to avoid taint
				-- Positions are now set when dragging ends
			end
		end
	end
end

-- Initialize with delay to ensure cfg is loaded
local hasInitialized = false

local function InitializePartyFrames()
	if not hasInitialized then
		hasInitialized = true
		
		-- Check if user wants to use whoa party frames (default true for backwards compatibility)
		if cfg.useWhoaPartyFrames ~= false then
			-- Create party frames after cfg is loaded
			for i = 1, 5 do
				createCustomPartyFrame(i)
			end
			
			RestoreFramePositions()
			updateAllPartyFrames()
			showOrHidePhantomPartyFrame()
			C_Timer.After(1, HideBlizzardPartyFrames)
		else
			-- User wants to use Blizzard party frames
			C_Timer.After(0.5, ShowBlizzardPartyFrames)
		end
	end
end

-- Setup initialization on login
local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
initFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
initFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
initFrame:SetScript("OnEvent", function(self, event)
	if event == "PLAYER_ENTERING_WORLD" then
		-- Call InitializePartyFrames directly (not from timer) to avoid taint when calling RegisterUnitWatch
		InitializePartyFrames()
		-- Only hide/show Blizzard frames based on user setting (with delays for stability)
		if cfg.useWhoaPartyFrames ~= false then
			C_Timer.After(0.5, HideBlizzardPartyFrames)
			C_Timer.After(2, HideBlizzardPartyFrames)  -- Extra delay for safety
		else
			C_Timer.After(0.5, ShowBlizzardPartyFrames)
		end
		-- Unregister PLAYER_ENTERING_WORLD after first initialization to prevent repeated calls
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	elseif event == "PLAYER_REGEN_ENABLED" then
		-- Reapply frame visibility after leaving combat
		if cfg.useWhoaPartyFrames ~= false then
			C_Timer.After(0.5, HideBlizzardPartyFrames)
		else
			HideWhoaPartyFrames()
			C_Timer.After(0.5, ShowBlizzardPartyFrames)
		end
	elseif event == "GROUP_ROSTER_UPDATE" then
		-- Reapply frame visibility when group changes
		if cfg.useWhoaPartyFrames ~= false then
			C_Timer.After(0.2, HideBlizzardPartyFrames)
		else
			HideWhoaPartyFrames()
			C_Timer.After(0.2, ShowBlizzardPartyFrames)
		end
	end
end)

-- Portrait update handler
local portraitFrame = CreateFrame("Frame")
portraitFrame:RegisterEvent("UNIT_PORTRAIT_UPDATE")
portraitFrame:SetScript("OnEvent", function(self, event, unit)
	if unit and string.match(unit, "^party%d") then
		local index = tonumber(unit:sub(6))
		if customPartyFrames[index] and customPartyFrames[index].portrait and customPartyFrames[index].portrait.texture then
			SetPortraitTexture(customPartyFrames[index].portrait.texture, unit)
		end
	end
end)
