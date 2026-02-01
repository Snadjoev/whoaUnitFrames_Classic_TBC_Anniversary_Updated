whoa = {}
cfg = {}

local ghostText = "Ghost"
local offlineText = "Offline"
local deadText = DEAD

--	Blue shamans instead of pink.
function blueShamans ()
	if (cfg.blueShamans == true) then
		RAID_CLASS_COLORS["SHAMAN"] = CreateColor(0.0, 0.44, 0.87)
		RAID_CLASS_COLORS["SHAMAN"].colorStr = RAID_CLASS_COLORS["SHAMAN"]:GenerateHexColor()
	end
end
		
--	Player class colors HP.
function unitClassColors(healthbar, unit)
	local classColor = cfg.classColor;
	if UnitIsPlayer(unit) and UnitClass(unit) and classColor then
		_, class = UnitClass(unit);
		local class = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class];
		healthbar:SetStatusBarColor(class.r, class.g, class.b);
		
		if not UnitIsConnected(unit) then
			healthbar:SetStatusBarColor(0.6,0.6,0.6,0.5);
		end
	end
end
hooksecurefunc("UnitFrameHealthBar_Update", unitClassColors)
hooksecurefunc("HealthBar_OnValueChanged", function(self)
	unitClassColors(self, self.unit)
end)

--	Blizzard´s target unit reactions HP color
function npcReactionBrightColors()
	if cfg.BlizzardReactionColor == true then
		FACTION_BAR_COLORS = {
			[1] = {r =  0.9, g = 0.0, b = 0.0},
			[2] = {r =  0.9, g = 0.0, b = 0.0},
			[3] = {r =  0.9, g = 0.0, b = 0.0},
			[4] = {r =  1, g =  0.8, b = 0.0},
			[5] = {r = 0.0, g = 0.9, b = 0.0},
			[6] = {r = 0.0, g = 0.9, b = 0.0},
			[7] = {r = 0.0, g = 0.9, b = 0.0},
			[8] = {r = 0.0, g = 0.9, b = 0.0},
		};
	end
end

--	Whoa´s customs target unit reactions HP colors.
local function npcReactionColors(healthbar, unit)
	if cfg.reactionColor then
		if UnitExists(unit) and not UnitIsPlayer(unit) then
			local reaction = FACTION_BAR_COLORS[UnitReaction(unit,"player")];
			if reaction then
				healthbar:SetStatusBarColor(reaction.r, reaction.g, reaction.b);
			else
				healthbar:SetStatusBarColor(0,0.6,0.1)
			end
			if (UnitIsTapDenied(unit)) then
				healthbar:SetStatusBarColor(0.5, 0.5, 0.5)
			elseif UnitIsCivilian(unit) then
				healthbar:SetStatusBarColor(1.0, 1.0, 1.0)
			end
		end
	elseif not cfg.reactionColor then	
		if UnitExists(unit) and not UnitIsPlayer(unit) then
			healthbar:SetStatusBarColor(0,0.9,0)
		end
	end
	if UnitExists(unit) and UnitIsPlayer(unit) and not cfg.classColor then
		healthbar:SetStatusBarColor(0,0.9,0)
	end
end
hooksecurefunc("UnitFrameHealthBar_Update", npcReactionColors)
hooksecurefunc("HealthBar_OnValueChanged", function(self)
	npcReactionColors(self, self.unit)
end)


--	Aura positioning constants.
local LARGE_AURA_SIZE = 25
local SMALL_AURA_SIZE = 20
local AURA_OFFSET_Y = 4
local AURA_ROW_WIDTH = 122
local NUM_TOT_AURA_ROWS = 2

--	Set aura size.
local function auraResize(self, auraName, numAuras, numOppositeAuras, largeAuraList, updateFunc, maxRowWidth, offsetX, mirrorAurasVertically)
	if (cfg.bigAuras == true) then
		local size;
		local offsetY = AURA_OFFSET_Y;
		local rowWidth = 0;
		local firstBuffOnRow = 1;
		for i=1, numAuras do
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
	TargetFrameTextureFrameGhostText = CreateDeadText("GhostText", "TargetFrameHealthBar", TargetFrameHealthBar, "CENTER", 0, 0);
	TargetFrameTextureFrameOfflineText = CreateDeadText("OfflineText", "TargetFrameHealthBar", TargetFrameHealthBar, "CENTER", 0, 0);
	PlayerFrameDeadText = CreateDeadText("DeadText", "PlayerFrame", PlayerFrameHealthBar, "CENTER", 0, 0);
	PlayerFrameGhostText = CreateDeadText("GhostText", "PlayerFrame", PlayerFrameHealthBar, "CENTER", 0, 0);

	PlayerFrameDeadText:SetText(DEAD);
	PlayerFrameGhostText:SetText(ghostText);
	TargetFrameTextureFrameGhostText:SetText(ghostText);
	TargetFrameTextureFrameOfflineText:SetText(offlineText);
end
targetFrameStatusText()

local function playerFontStyle(self)
	if (cfg.styleFont) then
		self.healthbar.LeftText:SetFontObject(SystemFont_Outline_Small);
		self.healthbar.RightText:SetFontObject(SystemFont_Outline_Small);
		self.manabar.LeftText:SetFontObject(SystemFont_Outline_Small);
		self.manabar.RightText:SetFontObject(SystemFont_Outline_Small);
		self.healthbar.TextString:SetFontObject(SystemFont_Outline_Small);
		self.manabar.TextString:SetFontObject(SystemFont_Outline_Small);
	end
end
hooksecurefunc("PlayerFrame_ToPlayerArt", playerFontStyle)

local function targetFontStyle (self)
	if (cfg.styleFont) then
		self.healthbar.LeftText:SetFontObject(SystemFont_Outline_Small);
		self.healthbar.RightText:SetFontObject(SystemFont_Outline_Small);
		self.manabar.LeftText:SetFontObject(SystemFont_Outline_Small);
		self.manabar.RightText:SetFontObject(SystemFont_Outline_Small);
		self.healthbar.TextString:SetFontObject(SystemFont_Outline_Small);
		self.manabar.TextString:SetFontObject(SystemFont_Outline_Small);
	end
end
hooksecurefunc(TargetFrame, "CheckClassification", targetFontStyle)

local function whoaXpBarFontStyle (self)
	if (cfg.styleFont) then
		MainMenuBarExpText:SetFontObject(SystemFont_Outline_Small);
	end
end
--hooksecurefunc(TextStatusBar, "UpdateTextStringWithValues", whoaXpBarFontStyle)

-- NOTE: Blizzards API will return targets current and max healh as a percentage instead of exact value (ex. 100/100).
local function customStatusTex(statusFrame, textString, value, valueMin, valueMax)
	local xpValue = UnitXP("player");
	local xpMaxValue = UnitXPMax("player");
	
	if( statusFrame.LeftText and statusFrame.RightText ) then
		statusFrame.LeftText:SetText("");
		statusFrame.RightText:SetText("");
		statusFrame.LeftText:Hide();
		statusFrame.RightText:Hide();
	end
	
	if ( ( tonumber(valueMax) ~= valueMax or valueMax > 0 ) and not ( statusFrame.pauseUpdates ) ) then
		statusFrame:Show();
		
		if ( (statusFrame.cvar and GetCVar(statusFrame.cvar) == "1" and statusFrame.textLockable) or statusFrame.forceShow ) then
			textString:Show();
		elseif ( statusFrame.lockShow > 0 and (not statusFrame.forceHideText) ) then
			textString:Show();
		else
			textString:SetText("");
			textString:Hide();
			return;
		end
		
		local k,m=1e3
		local m=k*k
		
		valueDisplay	=	(( value >= 1e3 and value < 1e5 and format("%1.3f",value/k)) or		--	1.000
							( value >= 1e5 and value < 1e6 and format("%1.0f K",value/k)) or	--	100k
							( value >= 1e6 and value < 1e7 and format("%1.1f M",value/m)) or	--	1.0M
							( value >= 1e7 and format("%1.2f M",value/m)) or value )			--	10.00M +
							
		valueMaxDisplay	=	(( valueMax >= 1e3 and valueMax < 1e5 and format("%1.3f",valueMax/k)) or
							( valueMax >= 1e5 and valueMax < 1e6 and format("%1.0f K",valueMax/k)) or
							( valueMax >= 1e6 and valueMax < 1e7 and format("%1.1f M",valueMax/m)) or
							( valueMax >= 1e7 and format("%1.2f M",valueMax/m)) or valueMax )
							
		xpValueDisplay	=	( xpValue >= 1e3 and format("%1.3f",xpValue/k) or xpValue )
		
		xpMaxValueDisplay	=	( xpMaxValue >= 1e3 and format("%1.3f",xpMaxValue/k) or xpMaxValue )
							

		
		local textDisplay = GetCVar("statusTextDisplay");
		if statusFrame == TargetFrameHealthBar or string.match(statusFrame:GetName() or "", "PartyMemberFrame%d+HealthBar") then textDisplay = "BOTH" end
		if ( value and valueMax > 0 and ( (textDisplay ~= "NUMERIC" and textDisplay ~= "NONE") ) and not statusFrame.showNumeric) then
			if ( value == 0 and statusFrame.zeroText ) then
				textString:SetText(statusFrame.zeroText);
				statusFrame.isZero = 1;
				textString:Show();
			elseif ( textDisplay == "BOTH" ) then
				if( statusFrame.LeftText and statusFrame.RightText ) then
					if(not statusFrame.powerToken or statusFrame.powerToken == "MANA") then
						statusFrame.LeftText:SetText(math.ceil((value / valueMax) * 100) .. "%");	-- % both.
						if value == 0 then statusFrame.LeftText:SetText(""); end
						statusFrame.LeftText:Show();
					end
					statusFrame.RightText:SetText(valueDisplay);	-- both rtext.
					if value == 0 then statusFrame.RightText:SetText(""); end
					statusFrame.RightText:Show();
					textString:Hide();
				else
					valueDisplay = math.ceil((value / valueMax) * 100) .. "% " .. valueDisplay .. " / " .. valueMaxDisplay;	-- both in center.
					if value == 0 then textString:SetText(""); end	
				end
				textString:SetText(valueDisplay);
			else
				valueDisplay = math.ceil((value / valueMax) * 100) .. "%";
				if ( statusFrame.prefix and (statusFrame.alwaysPrefix or not (statusFrame.cvar and GetCVar(statusFrame.cvar) == "1" and statusFrame.textLockable) ) ) then
					textString:SetText(statusFrame.prefix .. " " .. valueDisplay);	--	xp %.
				else
					textString:SetText(valueDisplay);	-- %.
				end
				if value == 0 then textString:SetText(""); end
			end
		elseif ( value == 0 and statusFrame.zeroText ) then
			textString:SetText(statusFrame.zeroText);
			statusFrame.isZero = 1;
			textString:Show();
			return;
		else
			statusFrame.isZero = nil;
			if ( statusFrame.prefix and (statusFrame.alwaysPrefix or not (statusFrame.cvar and GetCVar(statusFrame.cvar) == "1" and statusFrame.textLockable) ) ) then
				textString:SetText(statusFrame.prefix.." "..valueDisplay.." / "..valueMaxDisplay);		--	xp # / none, + none.
				MainMenuBarExpText:SetText(statusFrame.prefix.." "..xpValueDisplay .. "  / " .. xpMaxValueDisplay);		-- xp override.
			else
				textString:SetText(valueDisplay.." / "..valueMaxDisplay);		-- #.
			end
			if value == 0 then textString:SetText("") end
		end
	else
		textString:Hide();
		textString:SetText("");
		if ( not statusFrame.alwaysShow ) then
			statusFrame:Hide();
		else
			statusFrame:SetValue(0);
		end
	end
end
hooksecurefunc(PlayerFrameHealthBar, "UpdateTextStringWithValues",customStatusTex)
hooksecurefunc(TargetFrameHealthBar, "UpdateTextStringWithValues",customStatusTex)
for i = 1, 4 do
	local bar = _G["PartyMemberFrame" .. i .. "HealthBar"]
	if bar then
		hooksecurefunc(bar, "UpdateTextStringWithValues", customStatusTex)
	end
end

-- Dead, Ghost and Offline text.
function whoaCheckDead (self)
	local unit = self.unit
	local textDisplay = GetCVar("statusTextDisplay");
	
	if UnitIsDeadOrGhost(unit) then
		if textDisplay == "BOTH" then
			if unit == "player" then
				PlayerFrameHealthBarTextLeft:Hide();
				PlayerFrameHealthBarTextRight:Hide();
				PlayerFrameManaBarTextLeft:Hide();
				PlayerFrameManaBarTextRight:Hide();
			elseif unit == "target" then
				--TargetFrameHealthBarTextLeft:Hide();
				--TargetFrameHealthBarTextRight:Hide();
				--TargetFrameManaBarTextLeft:Hide();
				--TargetFrameManaBarTextRight:Hide();
			end
		else
			if unit == "player" then
				PlayerFrameHealthBarText:Hide();
				PlayerFrameManaBarText:Hide();
			end
		end
	end
	if UnitIsDead(unit) then
		if unit == "player" then
			PlayerFrameDeadText:Show();
			PlayerFrameGhostText:Hide();
		elseif unit == "target" then
			TargetFrameTextureFrameDeadText:Show();
			TargetFrameTextureFrameGhostText:Hide();
		elseif string.match(unit, "party%d+") then
			local i = string.match(unit, "party(%d+)")
			_G["PartyMemberFrame" .. i .. "DeadText"]:Show();
		end
	elseif UnitIsGhost(unit) then
		if unit == "player" then
			PlayerFrameDeadText:Hide();
			PlayerFrameGhostText:Show();
		elseif unit == "target" then
			TargetFrameTextureFrameDeadText:Hide();
			TargetFrameTextureFrameGhostText:Show();
		elseif string.match(unit, "party%d+") then
			local i = string.match(unit, "party(%d+)")
			_G["PartyMemberFrame" .. i .. "DeadText"]:Hide();
		end
	else
		if unit == "player" then
			PlayerFrameDeadText:Hide();
			PlayerFrameGhostText:Hide();
		elseif unit == "target" then
			TargetFrameTextureFrameDeadText:Hide();
			TargetFrameTextureFrameGhostText:Hide();
		elseif string.match(unit, "party%d+") then
			local i = string.match(unit, "party(%d+)")
			_G["PartyMemberFrame" .. i .. "DeadText"]:Hide();
		end
	end
	if not UnitIsConnected(unit) then
		if unit == "target" then
			TargetFrameTextureFrameOfflineText:Show();
			TargetFrameManaBar:Hide();
		elseif string.match(unit, "party%d+") then
			local i = string.match(unit, "party(%d+)")
			_G["PartyMemberFrame" .. i .. "OfflineText"]:Show();
		end
	else
		if unit == "target" then
			TargetFrameTextureFrameOfflineText:Hide();
		elseif string.match(unit, "party%d+") then
			local i = string.match(unit, "party(%d+)")
			_G["PartyMemberFrame" .. i .. "OfflineText"]:Hide();
		end
	end
end
hooksecurefunc(PlayerFrameHealthBar, "UpdateTextStringWithValues",whoaCheckDead)
hooksecurefunc(TargetFrameHealthBar, "UpdateTextStringWithValues",whoaCheckDead)
for i = 1, 4 do
	local bar = _G["PartyMemberFrame" .. i .. "HealthBar"]
	if bar then
		hooksecurefunc(bar, "UpdateTextStringWithValues", whoaCheckDead)
	end
end