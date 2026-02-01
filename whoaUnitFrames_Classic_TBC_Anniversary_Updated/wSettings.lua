--========================================================
-- Addon tables
--========================================================
whoa = whoa or {}
cfg  = cfg  or {}

--========================================================
-- Defaults
--========================================================
local function SetDefaults()
	cfg.smallAuraSize            = cfg.smallAuraSize            or 20
	cfg.largeAuraSize            = cfg.largeAuraSize            or 25
	cfg.classColor               = cfg.classColor               or true
	cfg.reactionColor            = cfg.reactionColor            or true
	cfg.BlizzardReactionColor    = cfg.BlizzardReactionColor    or true
	cfg.noClickFrame             = cfg.noClickFrame             or false
	cfg.blueShaman               = cfg.blueShaman               or true
	cfg.usePartyFrames           = cfg.usePartyFrames           or true
	cfg.styleFont                = cfg.styleFont                or true
	cfg.bigAuras                 = cfg.bigAuras                 or true
	cfg.useBossFrames            = cfg.useBossFrames            or true
	cfg.whoaTexture              = cfg.whoaTexture              or true
	cfg.darkFrames               = cfg.darkFrames               or false
	-- Handle boolean settings that can be false - only set default if nil
	if cfg.showNameBackground == nil then cfg.showNameBackground = true end
	if cfg.showPlayerName == nil then cfg.showPlayerName = true end
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
	end)
	whoa.checkboxes.cbTexture = cbTexture

	y = y - 30

	local cbNameBG = CreateCheckButton(panel, 16, y, "Show name background")
	cbNameBG:SetChecked(cfg.showNameBackground)
	cbNameBG:SetScript("OnClick", function(self)
		cfg.showNameBackground = self:GetChecked()
	end)
	whoa.checkboxes.cbNameBG = cbNameBG

	local cbPlayerName = CreateCheckButton(panel, 260, y, "Show player name")
	cbPlayerName:SetChecked(cfg.showPlayerName)
	cbPlayerName:SetScript("OnClick", function(self)
		cfg.showPlayerName = self:GetChecked()
	end)
	whoa.checkboxes.cbPlayerName = cbPlayerName

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

	local reset = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
	reset:SetSize(120, 22)
	reset:SetPoint("LEFT", center, "RIGHT", 10, 0)
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
-- Register Settings category
--========================================================
local category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
Settings.RegisterAddOnCategory(category)

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

--========================================================
-- Events
--========================================================
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

eventFrame:SetScript("OnEvent", function(_, event, addon)
	if event == "ADDON_LOADED" and addon == "whoaUnitFrames_Classic" then
		SetDefaults()
		
		-- Update all checkboxes to reflect saved values
		if whoa.checkboxes then
			whoa.checkboxes.cbClass:SetChecked(cfg.classColor)
			whoa.checkboxes.cbBlue:SetChecked(cfg.blueShaman)
			whoa.checkboxes.cbReaction:SetChecked(cfg.reactionColor)
			whoa.checkboxes.cbBright:SetChecked(cfg.BlizzardReactionColor)
			whoa.checkboxes.cbDark:SetChecked(cfg.darkFrames)
			whoa.checkboxes.cbFont:SetChecked(not cfg.styleFont)
			whoa.checkboxes.cbTexture:SetChecked(not cfg.whoaTexture)
			whoa.checkboxes.cbNameBG:SetChecked(cfg.showNameBackground)
			whoa.checkboxes.cbPlayerName:SetChecked(cfg.showPlayerName)
		end

		if cfg.noClickFrame then
			PlayerFrame:SetMouseClickEnabled(false)
			PetFrame:SetMouseClickEnabled(false)
			TargetFrame:SetMouseClickEnabled(false)
		end
		
		-- Force update frames to apply settings on load
		C_Timer.After(0.5, function()
			if PlayerFrame and PlayerFrame.Update then
				PlayerFrame.Update(PlayerFrame)
			end
			if TargetFrame and TargetFrame.Update then
				TargetFrame.Update(TargetFrame)
			end
			if FocusFrame and FocusFrame.Update then
				FocusFrame.Update(FocusFrame)
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

