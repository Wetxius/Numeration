local addon = select(2, ...)
local L = addon.locale
local C = addon.windows

local window = CreateFrame("Frame", "NumerationFrame", UIParent)
addon.window = window

local HiddenFrame = CreateFrame("Frame")
HiddenFrame:Hide()
window:RegisterEvent("PET_BATTLE_OPENING_START")
window:RegisterEvent("PET_BATTLE_CLOSE")
window:SetScript("OnEvent", function(self, event)
	if event == "PET_BATTLE_OPENING_START" then
		window:SetParent(HiddenFrame)
	else
		window:SetParent(stateFrame)
	end
end)

local lines = {}
local noop = function() end
local backAction = noop
local reportAction = noop
local backdrop = {
	bgFile = [[Interface\ChatFrame\ChatFrameBackground]]
}
local clickFunction = function(self, btn)
	if btn == "LeftButton" then
		self.detailAction(self)
	elseif btn == "RightButton" then
		backAction(self)
	elseif btn == "MiddleButton" then
		reportAction(self.num)
	end
end

local optionFunction = function(f, id, _, checked)
	addon:SetOption(id, checked)
end
local numReports = 9
local reportFunction = function(f, chatType, channel)
	addon:Report(numReports, chatType, channel)
	CloseDropDownMenus()
end
local dropdown = CreateFrame("Frame", "NumerationMenuFrame", nil, "UIDropDownMenuTemplate")
local menuTable = {
	{text = "Numeration", isTitle = true, notCheckable = true, notClickable = true},
	{text = CHAT_ANNOUNCE, notCheckable = true, hasArrow = true,
		menuList = {
			{text = CHAT_MSG_SAY, arg1 = "SAY", func = reportFunction, notCheckable = 1},
			{text = PARTY, arg1 = "PARTY", func = reportFunction, notCheckable = 1},
			{text = RAID, arg1 = "RAID", func = reportFunction, notCheckable = 1},
			{text = INSTANCE, arg1 = "INSTANCE_CHAT", func = reportFunction, notCheckable = 1},
			{text = GUILD, arg1 = "GUILD", func = reportFunction, notCheckable = 1},
			{text = OFFICER, arg1 = "OFFICER", func = reportFunction, notCheckable = 1},
			{text = WHISPER, func = function()
				StaticPopupDialogs.REPORT_DIALOG.OnAccept = function(self)
					reportFunction(self, "WHISPER", _G[self:GetName().."EditBox"]:GetText())
				end
				StaticPopup_Show("REPORT_DIALOG")
			end, notCheckable = 1},
			{text = CHANNEL, notCheckable = 1, keepShownOnClick = true, hasArrow = true, menuList = {}}
		},
	},
	{text = GAMEOPTIONS_MENU, notCheckable = true, hasArrow = true,
		menuList = {
			{text = L.pet_merge, arg1 = "petsmerged", func = optionFunction, checked = function() return addon:GetOption("petsmerged") end, keepShownOnClick = true},
			{text = L.only_boss, arg1 = "keeponlybosses", func = optionFunction, checked = function() return addon:GetOption("keeponlybosses") end, keepShownOnClick = true},
			{text = L.only_instance, arg1 = "onlyinstance", func = optionFunction, checked = function() return addon:GetOption("onlyinstance") end, keepShownOnClick = true},
			{text = L.combat_hide, arg1 = "combathide", func = optionFunction, checked = function() return addon:GetOption("combathide") end, keepShownOnClick = true},
			{text = L.show_icon, func = function(f, a1, a2, checked) addon:MinimapIconShow(checked) end, checked = function() return not NumerationCharOptions.minimap.hide end, keepShownOnClick = true},
		},
	},
	{text = "", notCheckable = true, notClickable = true},
	{text = RESET, func = function() StaticPopup_Show("RESET_DATA") end, notCheckable = true},
}

local updateReportChannels = function()
	menuTable[2].menuList[8].menuList = table.wipe(menuTable[2].menuList[8].menuList)
	for i = 1, GetNumDisplayChannels() do
		local name, _, _, channelNumber, _, _, category = GetChannelDisplayInfo(i)
		if category == "CHANNEL_CATEGORY_CUSTOM" then
			tinsert(menuTable[2].menuList[8].menuList, {text = name, arg1 = "CHANNEL", arg2 = channelNumber, func = reportFunction, notCheckable = 1})
		end
	end
end

local reportActionFunction = function(num)
	updateReportChannels()
	numReports = num
	EasyMenu(menuTable[2].menuList, dropdown, "cursor", 0 , 0, "MENU")
end

function addon:DropdownMenu()
	updateReportChannels()
	numReports = 9
	EasyMenu(menuTable, dropdown, "cursor", 0 , 0, "MENU")
end

if C.title_hide then
	C.titleheight = 1
end

function window:OnInitialize()
	self.maxlines = C.maxlines
	self:SetWidth(C.width)
	self:SetHeight(3 + C.titleheight + C.maxlines * (C.lineheight + C.linegap) - C.linegap)

	self:SetClampedToScreen(true)
	self:EnableMouse(true)
	self:EnableMouseWheel(true)
	self:SetMovable(true)
	self:RegisterForDrag("LeftButton")
	self:SetScript("OnDragStart", function() if IsAltKeyDown() then self:StartMoving() end end)
	self:SetScript("OnDragStop", function()
		self:StopMovingOrSizing()

		-- positioning code taken from recount
		local xOfs, yOfs = self:GetCenter()
		local s = self:GetEffectiveScale()
		local uis = UIParent:GetScale()
		xOfs = xOfs * s - GetScreenWidth() * uis / 2
		yOfs = yOfs * s - GetScreenHeight() * uis / 2

		addon:SetOption("x", xOfs / uis)
		addon:SetOption("y", yOfs / uis)
	end)

	self:SetBackdrop({
		bgFile = [[Interface\ChatFrame\ChatFrameBackground]],
		insets = {left = 0, right = 0, top = C.title_hide and C.titleheight + 1 or 0, bottom = 0}
	})
	self:SetBackdropColor(0, 0, 0, C.backgroundalpha)

	local x, y = addon:GetOption("x"), addon:GetOption("y")
	if not x or not y then
		self:SetPoint(unpack(C.pos))
	else
		-- positioning code taken from recount
		local s = self:GetEffectiveScale()
		local uis = UIParent:GetScale()
		self:SetPoint("CENTER", UIParent, "CENTER", x * uis / s, y * uis / s)
	end

	local scroll = self:CreateTexture(nil, "ARTWORK")
	self.scroll = scroll
	scroll:SetTexture([[Interface\Buttons\WHITE8X8]])
	scroll:SetTexCoord(.8, 1, .8, 1)
	scroll:SetVertexColor(0, 0, 0, .8)
	scroll:SetSize(4, 4)
	scroll:Hide()

	local reset = CreateFrame("Button", nil, self)
	self.reset = reset
	reset:SetBackdrop(backdrop)
	reset:SetBackdropColor(0, 0, 0, C.titlealpha)
	reset:SetSize(C.titleheight, C.titleheight)
	reset:SetPoint("TOPRIGHT", -1, -1)
	reset:SetScript("OnMouseUp", function()
		updateReportChannels()
		numReports = 9
		EasyMenu(menuTable, dropdown, "cursor", 0 , 0, "MENU")
	end)
	reset:SetScript("OnEnter", function() reset:SetBackdropColor(unpack(C.highlight)) end)
	reset:SetScript("OnLeave", function() reset:SetBackdropColor(0, 0, 0, C.titlealpha) end)

	reset.text = reset:CreateFontString(nil, "ARTWORK")
	reset.text:SetFont(C.linefont, C.linefontsize, C.linefontstyle)
	reset.text:SetShadowOffset(C.fontshadow and 1 or 0, C.fontshadow and -1 or 0)
	reset.text:SetPoint("CENTER", 1, 0)
	reset.text:SetText(">")

	local segment = CreateFrame("Button", nil, self)
	self.segment = segment
	segment:SetBackdrop(backdrop)
	segment:SetBackdropColor(0, 0, 0, C.titlealpha / 2)
	segment:SetSize(C.titleheight - 2, C.titleheight - 2)
	segment:SetPoint("RIGHT", reset, "LEFT", -2, 0)
	segment:SetScript("OnMouseUp", function() addon.nav.view = "Sets" addon.nav.set = nil addon:RefreshDisplay() dropdown:Show() end)
	segment:SetScript("OnEnter", function()
		segment:SetBackdropColor(unpack(C.highlight))
		GameTooltip:SetOwner(segment, "ANCHOR_BOTTOMRIGHT")
		local name = ""
		if addon.nav.set == "current" then
			name = L.current
		else
			local set = addon:GetSet(addon.nav.set)
			if set then
				name = set.name
			end
		end
		GameTooltip:AddLine(name)
		GameTooltip:Show()
	end)
	segment:SetScript("OnLeave", function() segment:SetBackdropColor(0, 0, 0, C.titlealpha / 2) GameTooltip:Hide() end)

	segment.text = segment:CreateFontString(nil, "ARTWORK")
	segment.text:SetFont(C.linefont, C.linefontsize, C.linefontstyle)
	segment.text:SetShadowOffset(C.fontshadow and 1 or 0, C.fontshadow and -1 or 0)
	segment.text:SetPoint("CENTER", 0, 0)
	segment.text:SetText("")

	local title = self:CreateTexture(nil, "ARTWORK")
	self.title = title
	title:SetTexture(C.linetexture)
	title:SetVertexColor(.25, .66, .35, C.titlealpha)
	title:SetPoint("TOPLEFT", 1, -1)
	title:SetPoint("BOTTOMRIGHT", reset, "BOTTOMLEFT", -1, 0)

	local font = self:CreateFontString(nil, "ARTWORK")
	self.titletext = font
	font:SetJustifyH("LEFT")
	font:SetFont(C.titlefont, C.titlefontsize, C.titlefontstyle)
	font:SetShadowOffset(C.fontshadow and 1 or 0, C.fontshadow and -1 or 0)
	font:SetTextColor(unpack(C.titlefontcolor))
	font:SetHeight(C.titlefontsize)
	font:SetPoint("LEFT", title, "LEFT", 4, 0)
	font:SetPoint("RIGHT", segment, "LEFT", -1, 0)

	if C.title_hide then
		reset:Hide()
		title:Hide()
		font:Hide()
		segment:Hide()
		segment.Show = function() end
	end

	self.detailAction = noop
	self:SetScript("OnMouseDown", clickFunction)
	self:SetScript("OnMouseWheel", function(self, num)
		addon:Scroll(num)
	end)
end

function window:Clear()
--	self:SetBackAction()
	self.scroll:Hide()
	self:SetDetailAction()
	for id,line in pairs(lines) do
		line:SetIcon()
		line.spellId = nil
		line:Hide()
	end
end

function window:UpdateSegment(segment)
	if not segment then
		self.segment:Hide()
	else
		self.segment.text:SetText(segment)
		self.segment:Show()
	end
end

function window:SetTitle(name, r, g, b)
	self.title:SetVertexColor(r, g, b, C.titlealpha)
	self.titletext:SetText(name)
end

function window:GetTitle()
	return self.titletext:GetText()
end

function window:SetScrollPosition(curPos, maxPos)
	if not C.scrollbar then return end
	if maxPos <= C.maxlines then return end
	local total = C.maxlines * (C.lineheight + C.linegap)
	self.scroll:SetHeight(C.maxlines / maxPos * total)
	self.scroll:SetPoint("TOPLEFT", self.reset, "BOTTOMRIGHT", 2, -1 - (curPos - 1) / maxPos * total)
	self.scroll:Show()
end

function window:SetBackAction(f)
	backAction = f or noop
	reportAction = noop
end

local SetValues = function(f, c, m)
	f:SetMinMaxValues(0, m)
	f:SetValue(c)
end

local SetIcon = function(f, icon)
	if icon then
		f:SetWidth(C.width - C.lineheight - 2)
		f.icon:SetTexture(icon)
		f.icon:Show()
	else
		f:SetWidth(C.width - 2)
		f.icon:Hide()
	end
end

local SetLeftText = function(f, ...)
	f.name:SetFormattedText(...)
end

local SetRightText = function(f, ...)
	f.value:SetFormattedText(...)
end

local SetColor = function(f, r, g, b, a)
	f:SetStatusBarColor(r, g, b, a or C.linealpha)
end

local SetDetailAction = function(f, func)
	f.detailAction = func or noop
end

local SetReportNumber = function(f, num)
	reportAction = reportActionFunction
	f.num = num
end
window.SetDetailAction = SetDetailAction

local onEnter = function(self)
	if not self.spellId then return end
	GameTooltip:SetOwner(self, C.tpos and C.tpos or "ANCHOR_BOTTOMRIGHT", 4, C.lineheight)
	GameTooltip:SetHyperlink("spell:"..self.spellId)
end
local onLeave = function(self)
	GameTooltip:Hide()
end
function window:GetLine(id)
	if lines[id] then return lines[id] end

	local f = CreateFrame("StatusBar", nil, self)
	lines[id] = f
	f:EnableMouse(true)
	f.detailAction = noop
	f:SetScript("OnMouseDown", clickFunction)
	f:SetScript("OnEnter", onEnter)
	f:SetScript("OnLeave", onLeave)
	f:SetStatusBarTexture(C.linetexture)
	f:SetStatusBarColor(.6, .6, .6, 1)
	f:SetSize(C.width - 2, C.lineheight)

	if id == 0 then
		f:SetPoint("TOPRIGHT", self.reset, "BOTTOMRIGHT", 0, -1)
	else
		f:SetPoint("TOPRIGHT", lines[id-1], "BOTTOMRIGHT", 0, -C.linegap)
	end

	local icon = f:CreateTexture(nil, "OVERLAY")
	f.icon = icon
	icon:SetSize(C.lineheight, C.lineheight)
	icon:SetPoint("RIGHT", f, "LEFT")
	icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	icon:Hide()

	local value = f:CreateFontString(nil, "ARTWORK")
	f.value = value
	value:SetHeight(C.lineheight)
	value:SetJustifyH("RIGHT")
	value:SetFont(C.linefont, C.linefontsize, C.linefontstyle)
	value:SetShadowOffset(C.fontshadow and 1 or 0, C.fontshadow and -1 or 0)
	value:SetTextColor(unpack(C.linefontcolor))
	value:SetPoint("RIGHT", -1, 0)

	local name = f:CreateFontString(nil, "ARTWORK")
	f.name = name
	name:SetHeight(C.lineheight)
	name:SetNonSpaceWrap(false)
	name:SetJustifyH("LEFT")
	name:SetFont(C.linefont, C.linefontsize, C.linefontstyle)
	name:SetShadowOffset(C.fontshadow and 1 or 0, C.fontshadow and -1 or 0)
	name:SetTextColor(unpack(C.linefontcolor))
	name:SetPoint("LEFT", icon, "RIGHT", 1, 0)
	name:SetPoint("RIGHT", value, "LEFT", -1, 0)

	f.SetValues = SetValues
	f.SetIcon = SetIcon
	f.SetLeftText = SetLeftText
	f.SetRightText = SetRightText
	f.SetColor = SetColor
	f.SetDetailAction = SetDetailAction
	f.SetReportNumber = SetReportNumber

	return f
end

StaticPopupDialogs.RESET_DATA = {
	text = "Numeration: "..L.reset_data,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function() addon:Reset() end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = true,
	preferredIndex = 5,
}

StaticPopupDialogs.REPORT_DIALOG = {
	text = "Numeration: "..L.whisp_target,
	OnShow = function (self)
		if UnitCanCooperate("player", "target") or UnitIsUnit("player", "target") then
			self.editBox:SetText(GetUnitName("target", true))
			reportFunction(self, "WHISPER", StaticPopup1EditBox:GetText())
			StaticPopup_Hide("REPORT_DIALOG")
		end
	end,
	button1 = WHISPER,
	button2 = CANCEL,
	timeout = 0,
	hasEditBox = 1,
	whileDead = 1,
	EditBoxOnEnterPressed = function(self) reportFunction(self, "WHISPER", StaticPopup1EditBox:GetText()) self:GetParent():Hide() end,
	EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
	preferredIndex = 5,
}