--========================================================
-- Addon tables
--========================================================
whoa = whoa or {}
cfg  = cfg  or {}

--========================================================
-- Defaults
--========================================================
local function SetDefaults()
	-- Assign defaults only if value is nil
	if cfg.smallAuraSize == nil then cfg.smallAuraSize = 20 end
	if cfg.largeAuraSize == nil then cfg.largeAuraSize = 25 end
	if cfg.classColor == nil then cfg.classColor = true end
	if cfg.reactionColor == nil then cfg.reactionColor = true end
	if cfg.BlizzardReactionColor == nil then cfg.BlizzardReactionColor = true end
	if cfg.noClickFrame == nil then cfg.noClickFrame = false end
	if cfg.blueShaman == nil then cfg.blueShaman = true end
	if cfg.usePartyFrames == nil then cfg.usePartyFrames = true end
	if cfg.styleFont == nil then cfg.styleFont = true end
	if cfg.bigAuras == nil then cfg.bigAuras = true end
	if cfg.useBossFrames == nil then cfg.useBossFrames = true end
	if cfg.whoaTexture == nil then cfg.whoaTexture = true end
	if cfg.darkFrames == nil then cfg.darkFrames = false end
	if cfg.showNameBackground == nil then cfg.showNameBackground = true end
	if cfg.showPlayerName == nil then cfg.showPlayerName = true end
	if cfg.partyFrameScale == nil then cfg.partyFrameScale = 1.0 end
	if cfg.lockPartyFrames == nil then cfg.lockPartyFrames = false end
	-- Store scale as integer (10-30) for better settings compatibility, divide by 20 to get 0.5-1.5
	if cfg.partyFrameScaleInt == nil then 
		cfg.partyFrameScaleInt = 20  -- 20/20 = 1.0 default
	end
	-- Maintain partyFrameScale for backward compatibility
	if cfg.partyFrameScale == nil then
		cfg.partyFrameScale = cfg.partyFrameScaleInt / 20
	end
	if cfg.useWhoaPartyFrames == nil then cfg.useWhoaPartyFrames = true end
	if cfg.showPhantomParty == nil then cfg.showPhantomParty = false end
end

SetDefaults()

--========================================================
-- Font helper
--========================================================
function whoa:CreateFont(parent, name, text, x, y, font, size)
	local fs = parent:CreateFontString(name, "ARTWORK", "GameFontNormal")
	fs:SetPoint("TOPLEFT", x, y)
	fs:SetFont(font or STANDARD_TEXT_FONT, size or 15)
	fs:SetText(text)
	return fs
end

--========================================================
-- Checkbutton factory
--========================================================
local checkIndex = 0
local function CreateCheckButton(parent, x, y, label)
	checkIndex = checkIndex + 1

	local cb = CreateFrame(
		"CheckButton",
		"whoaCheckButton" .. checkIndex,
		parent,
		"ChatConfigCheckButtonTemplate"
	)

	cb:SetPoint("TOPLEFT", x, y)
	_G[cb:GetName() .. "Text"]:SetText(label)

	return cb
end

--========================================================
-- Settings panel (Retail)
--========================================================
local panel = CreateFrame("Frame")
panel.name = "whoa UnitFrames"

local title = whoa:CreateFont(panel, nil, "whoa UnitFrames (TBC Anniversary)", 16, -16)
local note  = whoa:CreateFont(panel, nil,
	"Most options require a /reload to apply correctly.",
	16, -40, nil, 11
)

--========================================================
-- UI creation
--========================================================
-- Store checkbox references globally so we can update them later
whoa.checkboxes = {}

function whoa:CreateUI()
	local y = -80

	whoa:CreateFont(panel, nil, "Main options", 16, y)
	y = y - 30

	local cbClass = CreateCheckButton(panel, 16, y, "Player class colors")
	cbClass:SetChecked(cfg.classColor)
	cbClass:SetScript("OnClick", function(self)
		cfg.classColor = self:GetChecked()
		if not cfg.classColor then
			cfg.blueShaman = false
			_G["whoaCheckButton2"]:SetChecked(false)
		end
	end)
	whoa.checkboxes.cbClass = cbClass

	local cbBlue = CreateCheckButton(panel, 260, y, "Blue shamans")
	cbBlue:SetChecked(cfg.blueShaman)
	cbBlue:SetScript("OnClick", function(self)
		cfg.blueShaman = self:GetChecked()
		if cfg.blueShaman then
			cfg.classColor = true
			cbClass:SetChecked(true)
		end
	end)
	whoa.checkboxes.cbBlue = cbBlue

	y = y - 30

	local cbReaction = CreateCheckButton(panel, 16, y, "Target reaction colors")
	cbReaction:SetChecked(cfg.reactionColor)
	cbReaction:SetScript("OnClick", function(self)
		cfg.reactionColor = self:GetChecked()
		if not cfg.reactionColor then
			cfg.BlizzardReactionColor = false
			_G["whoaCheckButton4"]:SetChecked(false)
		end
	end)
	whoa.checkboxes.cbReaction = cbReaction

	local cbBright = CreateCheckButton(panel, 260, y, "Bright reaction colors")
	cbBright:SetChecked(cfg.BlizzardReactionColor)
	cbBright:SetScript("OnClick", function(self)
		cfg.BlizzardReactionColor = self:GetChecked()
		if cfg.BlizzardReactionColor then
			cfg.reactionColor = true
			cbReaction:SetChecked(true)
		end
	end)
	whoa.checkboxes.cbBright = cbBright

	y = y - 40
	whoa:CreateFont(panel, nil, "Style options", 16, y)
	y = y - 30

	local cbDark = CreateCheckButton(panel, 16, y, "Enable dark frames")
	cbDark:SetChecked(cfg.darkFrames)
	cbDark:SetScript("OnClick", function(self)
		cfg.darkFrames = self:GetChecked()
		if ShowOrHidePhantomPartyFrame then ShowOrHidePhantomPartyFrame() end
	end)
	whoa.checkboxes.cbDark = cbDark

	y = y - 30

	local cbFont = CreateCheckButton(panel, 16, y, "Use Blizzard status bar font")
	cbFont:SetChecked(not cfg.styleFont)
	cbFont:SetScript("OnClick", function(self)
		cfg.styleFont = not self:GetChecked()
	end)
	whoa.checkboxes.cbFont = cbFont

	y = y - 30

	local cbTexture = CreateCheckButton(panel, 16, y, "Use Blizzard bar textures")
	cbTexture:SetChecked(not cfg.whoaTexture)
	cbTexture:SetScript("OnClick", function(self)
		cfg.whoaTexture = not self:GetChecked()
		-- Update heal prediction textures immediately
		if UpdateAllHealPredictionTextures then
			UpdateAllHealPredictionTextures()
		end
		if ShowOrHidePhantomPartyFrame then ShowOrHidePhantomPartyFrame() end
	end)
	whoa.checkboxes.cbTexture = cbTexture

	y = y - 30

	local cbNameBG = CreateCheckButton(panel, 16, y, "Show name background")
	cbNameBG:SetChecked(cfg.showNameBackground)
	cbNameBG:SetScript("OnClick", function(self)
		cfg.showNameBackground = self:GetChecked()
		if ShowOrHidePhantomPartyFrame then ShowOrHidePhantomPartyFrame() end
	end)
	whoa.checkboxes.cbNameBG = cbNameBG

	local cbPlayerName = CreateCheckButton(panel, 260, y, "Show player name")
	cbPlayerName:SetChecked(cfg.showPlayerName)
	cbPlayerName:SetScript("OnClick", function(self)
		cfg.showPlayerName = self:GetChecked()
		if ShowOrHidePhantomPartyFrame then ShowOrHidePhantomPartyFrame() end
	end)
	whoa.checkboxes.cbPlayerName = cbPlayerName

	y = y - 40
	whoa:CreateFont(panel, nil, "Party Frame Scale", 16, y)
	y = y - 30

	-- Scale slider (stores as integer 10-30, displays as 50%-150%)
	local scaleSlider = CreateFrame("Slider", "whoaPartyScaleSlider", panel, "OptionsSliderTemplate")
	scaleSlider:SetPoint("TOPLEFT", 16, y)
	scaleSlider:SetMinMaxValues(10, 30)
	scaleSlider:SetValue(cfg.partyFrameScaleInt or 20)
	scaleSlider:SetValueStep(1)
	scaleSlider:SetObeyStepOnDrag(true)
	scaleSlider:SetWidth(200)
	
	_G[scaleSlider:GetName() .. "Low"]:SetText("50%")
	_G[scaleSlider:GetName() .. "High"]:SetText("150%")
	_G[scaleSlider:GetName() .. "Text"]:SetText(string.format("%d%%", (cfg.partyFrameScaleInt or 20) * 5))
	scaleSlider:SetScript("OnValueChanged", function(self, value)
		value = math.floor(value + 0.5)  -- Round to nearest integer
		cfg.partyFrameScaleInt = value
		cfg.partyFrameScale = value / 20  -- Update actual scale value
		_G[self:GetName() .. "Text"]:SetText(string.format("%d%%", value * 5))
		if ShowOrHidePhantomPartyFrame then ShowOrHidePhantomPartyFrame() end
	end)
	whoa.scaleSlider = scaleSlider
	
	-- Scale info text
	local scaleInfo = whoa:CreateFont(panel, nil, "(Scale applies live to phantom; real frames need /reload)", 230, y + 15, nil, 10)
	scaleInfo:SetTextColor(1, 0.82, 0)

	y = y - 40

	local cbWhoaParty = CreateCheckButton(panel, 16, y, "Use whoa party frames")
	cbWhoaParty:SetChecked(cfg.useWhoaPartyFrames)
	cbWhoaParty:SetScript("OnClick", function(self)
		cfg.useWhoaPartyFrames = self:GetChecked()
		print("|cffffff00Party frame setting changed. Please /reload to apply.|r")
	end)
	whoa.checkboxes.cbWhoaParty = cbWhoaParty

	y = y - 30

	local cbLockParty = CreateCheckButton(panel, 16, y, "Lock party frames (disable dragging)")
	cbLockParty:SetChecked(cfg.lockPartyFrames)
	cbLockParty:SetScript("OnClick", function(self)
		cfg.lockPartyFrames = self:GetChecked()
	end)
	whoa.checkboxes.cbLockParty = cbLockParty

	y = y - 30

	local cbPhantom = CreateCheckButton(panel, 16, y, "Show phantom party frame (preview when solo)")
	cbPhantom:SetChecked(cfg.showPhantomParty)
	cbPhantom:SetScript("OnClick", function(self)
		cfg.showPhantomParty = self:GetChecked()
		if ShowOrHidePhantomPartyFrame then
			ShowOrHidePhantomPartyFrame()
		end
	end)
	whoa.checkboxes.cbPhantom = cbPhantom

	-- Buttons
	local center = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
	center:SetSize(120, 22)
	center:SetPoint("BOTTOMLEFT", 16, 16)
	center:SetText("Center frames")
	center:SetScript("OnClick", function()
		if InCombatLockdown() then return end
		PlayerFrame:ClearAllPoints()
		PlayerFrame:SetPoint("RIGHT", UIParent, "CENTER", -20, -150)
		PlayerFrame:SetUserPlaced(true)

		TargetFrame:ClearAllPoints()
		TargetFrame:SetPoint("LEFT", UIParent, "CENTER", 20, -150)
		TargetFrame:SetUserPlaced(true)
	end)

	local resetParty = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
	resetParty:SetSize(150, 22)
	resetParty:SetPoint("BOTTOMLEFT", 290, 16)
	resetParty:SetText("Reset party frames")
	resetParty:SetScript("OnClick", function()
		if InCombatLockdown() then
			print("|cffffff00Cannot reset party frames in combat.|r")
			return
		end
		cfg.partyFramePositions = nil
		print("|cffffff00Party frame positions cleared. Please /reload to apply.|r")
	end)

	local reset = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
	reset:SetSize(120, 22)
	reset:SetPoint("BOTTOMLEFT", 146, 16)
	reset:SetText("Reset frames")
	reset:SetScript("OnClick", function()
		PlayerFrame_ResetUserPlacedPosition()
		TargetFrame_ResetUserPlacedPosition()
	end)

	local reload = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
	reload:SetSize(100, 22)
	reload:SetPoint("BOTTOMRIGHT", -16, 16)
	reload:SetText("Reload UI")
	reload:SetScript("OnClick", ReloadUI)
end

whoa:CreateUI()

--========================================================
-- Function to sync all checkboxes with current cfg values
--========================================================
local function SyncCheckboxes()
	if not whoa.checkboxes then return end
	
	whoa.checkboxes.cbClass:SetChecked(cfg.classColor)
	whoa.checkboxes.cbBlue:SetChecked(cfg.blueShaman)
	whoa.checkboxes.cbReaction:SetChecked(cfg.reactionColor)
	whoa.checkboxes.cbBright:SetChecked(cfg.BlizzardReactionColor)
	whoa.checkboxes.cbDark:SetChecked(cfg.darkFrames)
	whoa.checkboxes.cbFont:SetChecked(not cfg.styleFont)
	whoa.checkboxes.cbTexture:SetChecked(not cfg.whoaTexture)
	whoa.checkboxes.cbNameBG:SetChecked(cfg.showNameBackground)
	whoa.checkboxes.cbPlayerName:SetChecked(cfg.showPlayerName)
	whoa.checkboxes.cbWhoaParty:SetChecked(cfg.useWhoaPartyFrames)
	whoa.checkboxes.cbLockParty:SetChecked(cfg.lockPartyFrames)
	if whoa.checkboxes.cbPhantom then
		whoa.checkboxes.cbPhantom:SetChecked(cfg.showPhantomParty)
	end
end

--========================================================
-- Register Settings category
--========================================================
local category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
Settings.RegisterAddOnCategory(category)

-- Sync checkboxes whenever the panel is shown
panel:SetScript("OnShow", function()
	SyncCheckboxes()
	-- Sync slider value using integer storage
	if whoa.scaleSlider then
		whoa.scaleSlider:SetValue(cfg.partyFrameScaleInt or 20)
	end
end)

--========================================================
-- Slash commands
--========================================================
SLASH_WHOA1 = "/whoa"
SLASH_WHOA2 = "/wtf"
SlashCmdList.WHOA = function()
	Settings.OpenToCategory(category.ID)
end

SLASH_RL1 = "/rl"
SlashCmdList.RL = ReloadUI

SLASH_RESETPARTY1 = "/resetparty"
SlashCmdList.RESETPARTY = function()
	if InCombatLockdown() then
		print("|cffffff00Cannot reset party frames in combat.|r")
		return
	end
	cfg.partyFramePositions = {}
	-- Also clear SetUserPlaced flag on existing frames
	if _G.customPartyFrames then
		for i = 1, 5 do
			if _G.customPartyFrames[i] then
				_G.customPartyFrames[i]:SetUserPlaced(false)
			end
		end
	end
	print("|cffffff00Party frame positions cleared. Please /reload to apply.|r")
end

SLASH_SHOWPARTY1 = "/showparty"
SlashCmdList.SHOWPARTY = function()
	if cfg.partyFramePositions then
		print("|cffffff00Saved party positions:|r")
		for i = 1, 5 do
			if cfg.partyFramePositions[i] then
				local pos = cfg.partyFramePositions[i]
				print(string.format("Frame %d: %s, %s, %.1f, %.1f", i, pos[1] or "nil", pos[2] or "nil", pos[3] or 0, pos[4] or 0))
			else
				print(string.format("Frame %d: no saved position", i))
			end
		end
	else
		print("|cffffff00No saved party positions.|r")
	end
end

--========================================================
-- Events
--========================================================
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

eventFrame:SetScript("OnEvent", function(_, event, addon)
	if event == "ADDON_LOADED" and addon == "whoaUnitFrames_Classic_TBC_Anniversary_Updated" then
		SetDefaults()
		
		-- Update all checkboxes to reflect saved values
		SyncCheckboxes()

		if cfg.noClickFrame then
			PlayerFrame:SetMouseClickEnabled(false)
			PetFrame:SetMouseClickEnabled(false)
			TargetFrame:SetMouseClickEnabled(false)
		end
		
		-- Force update frames to apply settings on load
		C_Timer.After(0.5, function()
			-- Use pcall to prevent taint errors from Update calls
			if PlayerFrame and PlayerFrame.Update then
				pcall(PlayerFrame.Update, PlayerFrame)
			end
			if TargetFrame and TargetFrame.Update then
				pcall(TargetFrame.Update, TargetFrame)
			end
			if FocusFrame and FocusFrame.Update then
				pcall(FocusFrame.Update, FocusFrame)
			end
			
			-- Update heal prediction textures
			if UpdateAllHealPredictionTextures then
				UpdateAllHealPredictionTextures()
			end
		end)
	end
end)

--========================================================
-- Minimap zoom (Retail-safe)
--========================================================
Minimap:EnableMouseWheel(true)
Minimap:SetScript("OnMouseWheel", function(self, delta)
	local zoom = self:GetZoom()
	if delta > 0 and zoom < 5 then
		self:SetZoom(zoom + 1)
	elseif delta < 0 and zoom > 0 then
		self:SetZoom(zoom - 1)
	end
end)

