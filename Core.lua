local addonname, addon = ...
Numeration = addon
local L = addon.locale
local C = addon.core
local boss = LibStub("LibBossIDs")
addon.events = CreateFrame("Frame")
addon.events:SetScript("OnEvent", function(self, event, ...)
	addon[event](addon, event, ...)
end)
addon.views = {}
-- important GUIDs
addon.guidToClass = {}
addon.guidToName = {}

-- Keybindings
BINDING_NAME_NUMERATION_VISIBILITY = L.binding_visibility
BINDING_NAME_NUMERATION_RESET = L.binding_reset

-- used colors
addon.color = {
	PET = {0.09, 0.61, 0.55},
}
addon.colorhex = {}
do
	local colors = CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS
	for class, c in pairs(colors) do
		addon.color[class] = {c.r, c.g, c.b}
		addon.colorhex[class] = string.format("%02X%02X%02X", c.r * 255, c.g * 255, c.b * 255)
	end
	addon.colorhex["PET"] = string.format("%02X%02X%02X", addon.color.PET[1] * 255, addon.color.PET[2] * 255, addon.color.PET[3] * 255)
end

addon.spellIcon = setmetatable({[75] = "", [88163] = ""}, {__index = function(tbl, i)
	local spell, _, icon = GetSpellInfo(i)
	addon.spellName[i] = spell
	tbl[i] = icon
	return icon
end})
addon.spellName = setmetatable({}, {__index = function(tbl, i)
	local spell, _, icon = GetSpellInfo(i)
	addon.spellIcon[i] = icon
	tbl[i] = spell
	return spell or UNKNOWN
end})
local newSet = function()
	return {
		unit = {},
	}
end

local icon = LibStub("LibDBIcon-1.0")
local ldb = LibStub("LibDataBroker-1.1"):NewDataObject("Numeration", {
	type = "data source",
	text = "Numeration",
	icon = [[Interface\Icons\Ability_Warrior_WeaponMastery]],
})

local current
addon.events:RegisterEvent("ADDON_LOADED")
function addon:ADDON_LOADED(event, addon)
	if addon ~= addonname then return end
	self.events:UnregisterEvent("ADDON_LOADED")

	self:InitOptions()
	if Numeration.windows.title_hide then
		NumerationCharOptions.minimap.hide = false
	end
	icon:Register("Numeration", ldb, NumerationCharOptions.minimap)
	self.window:OnInitialize()
	if NumerationCharOptions.forcehide or NumerationCharOptions.combatshow then
		self.window:Hide()
	end

	if not NumerationCharDB then
		self:Reset()
	end
	current = self:GetSet(1) or newSet()

	self.collect:RemoveUnneededEvents()
	self.events:RegisterEvent("ZONE_CHANGED_NEW_AREA")

	if GetRealZoneText() ~= "" then
		self:ZONE_CHANGED_NEW_AREA(event)
	end
end

local function abrNumber(self, num)
	if num >= 1e6 then
		return ("%.1fm"):format(num / 1e6)
	elseif num >= 1e3 then
		return ("%.1fk"):format(num / 1e3)
	else
		return ("%i"):format(num)
	end
end
local function fullNumber(self, num)
	return ("%i"):format(num)
end

function addon:InitOptions()
	self.ids = {}
	do
		for i, tbl in ipairs(self.types) do
			self.ids[tbl.id] = true
			if tbl.id2 then
				self.ids[tbl.id2] = true
			end
		end
	end

	if not NumerationCharOptions then
		NumerationCharOptions = {}
	end
	if NumerationCharOptions.keeponlybosses == nil then
		NumerationCharOptions.keeponlybosses = false
	end
	if NumerationCharOptions.petsmerged == nil then
		NumerationCharOptions.petsmerged = true
	end
	if NumerationCharOptions.onlyinstance == nil then
		NumerationCharOptions.onlyinstance = false
	end
	if NumerationCharOptions.combathide == nil then
		NumerationCharOptions.combathide = false
	end
	if NumerationCharOptions.combatshow == nil then
		NumerationCharOptions.combatshow = false
	end
	if NumerationCharOptions.combatnone == nil then
		NumerationCharOptions.combatnone = true
	end
	if not NumerationCharOptions.minimap then
		NumerationCharOptions.minimap = {
			hide = false,
		}
	end
	if not NumerationCharOptions.nav then
		NumerationCharOptions.nav = {
			view = "Units",
			set = "current",
			type = 1,
		}
	end
	self.nav = NumerationCharOptions.nav

	self.ModNumber = C.shortnumbers and abrNumber or fullNumber
end

function ldb:OnTooltipShow()
	icon.tooltip:AddLine("Numeration", 1, 1, 1)
	icon.tooltip:AddLine(L.toggle)
	icon.tooltip:AddLine(L.reset)
	if addon.windows.title_hide then
		icon.tooltip:AddLine(L.menu)
	end
end

function ldb:OnClick(button)
	if button == "LeftButton" then
		if IsShiftKeyDown() then
			if C.silent_reset then
				addon:Reset()
			else
				StaticPopup_Show("RESET_DATA")
			end
		else
			addon:ToggleVisibility()
		end
	elseif addon.windows.title_hide then
		addon:DropdownMenu()
	end
end

function addon:ToggleVisibility()
	NumerationCharOptions.forcehide = not NumerationCharOptions.forcehide
	if NumerationCharOptions.forcehide then
		self.window:Hide()
	else
		self.window:Show()
		self:RefreshDisplay()
	end
end

function addon:MinimapIconShow(show)
	if addon.windows.title_hide then
		NumerationCharOptions.minimap.hide = false
		return
	end
	NumerationCharOptions.minimap.hide = not show
	if show then
		icon:Show("Numeration")
	else
		icon:Hide("Numeration")
	end
end

function addon:CombatShow(option)
	NumerationCharOptions.combathide = false
	NumerationCharOptions.combatshow = false
	NumerationCharOptions.combatnone = false

	NumerationCharOptions[option] = true
end

function addon:SetOption(option, value)
	NumerationCharOptions[option] = value
	if option == "onlyinstance" then
		self:ZONE_CHANGED_NEW_AREA(true)
	elseif option == "petsmerged" then
		self:RefreshDisplay(true)
	end
end

function addon:GetOption(option)
	return NumerationCharOptions[option]
end

function addon:Reset()
	local lastZone = NumerationCharDB and NumerationCharDB.zone
	NumerationCharDB = {
		[0] = newSet(),
		zone = lastZone,
	}
	NumerationCharDB[0].name = L.overall
	current = newSet()
	if self.nav.set and self.nav.set ~= "total" and self.nav.set ~= "current" then
		self.nav.set = "current"
	end
	self:RefreshDisplay()
	collectgarbage("collect")
end

local updateTimer = CreateFrame("Frame")
updateTimer:Hide()
updateTimer:SetScript("OnUpdate", function(self, elapsed)
	self.timer = self.timer - elapsed
	if self.timer > 0 then return end
	self.timer = C.refreshinterval

	if current.changed then
		ldb.text = addon.views["Units"]:GetXps(current, UnitName("player"), "dd", NumerationCharOptions.petsmerged)
	end

	local set = addon.nav.set and addon:GetSet(addon.nav.set) or current
	if not set or not set.changed then return end
	set.changed = nil

	addon:RefreshDisplay(true)
end)
function updateTimer:Activate()
	self.timer = C.refreshinterval
	self:Show()
end
function updateTimer:Refresh()
	self.timer = C.refreshinterval
end

function addon:RefreshDisplay(update)
	if self.window:IsShown() then
		self.window:Clear()

		if not update then
			self.views[self.nav.view]:Init()
			local segment = self.nav.set == "total" and "O" or self.nav.set == "current" and "C" or self.nav.set
			self.window:UpdateSegment(segment)
		end
		self.views[self.nav.view]:Update(NumerationCharOptions.petsmerged)
	end
	if not update then
		ldb.text = self.views["Units"]:GetXps(current, UnitName("player"), "dd", NumerationCharOptions.petsmerged)
	end

	updateTimer:Refresh()
end

local useChatType, useChannel
function addon:Report(lines, chatType, channel)
	useChatType, useChannel = chatType, channel
	if chatType == "WHISPER" then
		whispname = StaticPopup1EditBox:GetText()
		if whispname == nil or whispname == "" then
			print("|cffffff00Numeration|r: "..L.bad_whisp)
			return
		end
	end

	local view = self.views[self.nav.view]
	if view.Report and lines then
		view:Report(NumerationCharOptions.petsmerged, lines)
	else
		print("|cffffff00Numeration|r: "..L.bad_report)
	end
end

function addon:PrintHeaderLine(set)
	local datetext, timetext = self:GetDuration(set)
	self:PrintLine("Numeration: %s - %s%s", self.window:GetTitle(), set.name, datetext and format(" [%s %s]", datetext, timetext) or "")
end

function addon:PrintLine(...)
	SendChatMessage(format(...), useChatType, nil, useChannel)
end

function addon:Scroll(dir)
	local view = self.views[self.nav.view]
	if dir > 0 and view.first > 1 then
		if IsShiftKeyDown() then
			view.first = 1
		else
			view.first = view.first - 1
		end
	elseif dir < 0 then
		if IsShiftKeyDown() then
			view.first = 9999
		else
			view.first = view.first + 1
		end
	end
	self:RefreshDisplay(true)
end

function addon:GetArea(start, total)
	if total == 0 then return start end

	local first = start
	local last = start + self.window.maxlines - 1
	if last > total then
		first = first - last + total
		last = total
	end
	if first < 1 then
		first = 1
	end
	self.window:SetScrollPosition(first, total)
	return first, last
end

function addon:GetSet(id)
	if not id then return end

	if id == "current" then
		return current
	elseif id == "total" then
		id = 0
	end
	return NumerationCharDB[id]
end

function addon:GetSets()
	return NumerationCharDB[0], current.active and current
end

function addon:GetDuration(set)
	if not set.start or not set.now then return end
	local duration = math.ceil(set.now - set.start)
	local durationtext = duration < 60 and format("%i"..L.s.."", duration%60) or format("%i"..L.m.."%i"..L.s.."", math.floor(duration/60), duration%60)
	return date("%H:%M", set.start), durationtext
end

function addon:GetUnitClass(playerID)
	if not playerID then return end

	local class = self.guidToClass[playerID]
	return self.guidToName[class] and "PET" or class
end

function addon:GetUnit(set, id)
	local name, class = self.guidToName[id], self.guidToClass[id]
	local owner = self.guidToName[class]

	if not owner then
		-- unit
		local u = set.unit[name]
		if not u then
			u = {
				name = name,
				class = class,
			}
			set.unit[name] = u
		end
		return u
	else
		-- pet
		local key = format("%s:%s", owner, name or UNKNOWN)
		local p = set.unit[key]
		if not p then
			local ownertable = self:GetUnit(set, class)
			if not ownertable.pets then
				ownertable.pets = {}
			end
			ownertable.pets[key] = true

			p = {
				name = name,
				class = "PET",
				owner = owner,
			}
			set.unit[key] = p
		end
		return p
	end
end

local summonOwner, summonName = {}, {}
do
	local addPlayerPet = function(unit, pet)
		local unitID = UnitGUID(unit)
		if not unitID then return end

		local unitName, unitRealm = UnitName(unit)
		local _, unitClass = UnitClass(unit)
		local petID = UnitGUID(pet)

		addon.guidToClass[unitID] = unitClass
		addon.guidToName[unitID] = unitRealm and unitRealm ~= "" and format("%s-%s", unitName, unitRealm) or unitName
		if petID then
			addon.guidToClass[petID] = unitID
			addon.guidToName[petID] = UnitName(pet)
		end
	end
	function addon:UpdateGUIDS()
		self.guidToName = wipe(self.guidToName)
		self.guidToClass = wipe(self.guidToClass)

		local num = GetNumGroupMembers()
		if num > 5 then
			for i = 1, num do
				addPlayerPet("raid"..i, "raid"..i.."pet")
			end
		else
			addPlayerPet("player", "pet")
			if num > 0 then
				for i = 1, num do
					addPlayerPet("party"..i, "party"..i.."pet")
				end
			end
		end

		-- remove summons from guid list, if owner is gone
		for pid, uid in pairs(summonOwner) do
			if self.guidToClass[uid] then
				self.guidToClass[pid] = uid
				self.guidToName[pid] = summonName[pid]
			else
				summonOwner[pid] = nil
				summonName[pid] = nil
			end
		end
		self:GUIDsUpdated()
	end
end

function addon:COMBAT_LOG_EVENT_UNFILTERED(e)
	local timestamp, eventtype, _, srcGUID, _, _, _, dstGUID, dstName = CombatLogGetCurrentEventInfo()
	if self.collect[eventtype] then
		self.collect[eventtype](timestamp, select(4, CombatLogGetCurrentEventInfo()))
	end

	local ClassOrOwnerGUID = self.guidToClass[srcGUID]
	if eventtype == "SPELL_SUMMON" and ClassOrOwnerGUID then
		local realSrcGUID = self.guidToClass[ClassOrOwnerGUID] and ClassOrOwnerGUID or srcGUID
		summonOwner[dstGUID] = realSrcGUID
		summonName[dstGUID] = dstName
		self.guidToClass[dstGUID] = realSrcGUID
		self.guidToName[dstGUID] = dstName
	elseif eventtype == "UNIT_DIED" and summonOwner[srcGUID] then
		summonOwner[srcGUID] = nil
		summonName[srcGUID] = nil
		self.guidToClass[srcGUID] = nil
		self.guidToName[srcGUID] = nil
	end
end

addon.PLAYER_ENTERING_WORLD = addon.UpdateGUIDS
addon.GROUP_ROSTER_UPDATE = addon.UpdateGUIDS
addon.UNIT_PET = addon.UpdateGUIDS
addon.UNIT_NAME_UPDATE = addon.UpdateGUIDS
function addon:ZONE_CHANGED_NEW_AREA(force)
	local _, instanceType, difficultyID = GetInstanceInfo()

	if force == true or instanceType ~= self.instanceType then
		self.instanceType = instanceType

		if not NumerationCharOptions.onlyinstance or (IsInInstance() and difficultyID ~= 0) then
			if IsInInstance() and difficultyID ~= 0 then
				local curZone = GetRealZoneText()
				if curZone ~= NumerationCharDB.zone then
					NumerationCharDB.zone = curZone
					if C.silent_reset then
						addon:Reset()
					else
						StaticPopup_Show("RESET_DATA")
					end
				end
			end
			self:UpdateGUIDS()

			self.events:RegisterEvent("PLAYER_ENTERING_WORLD")
			self.events:RegisterEvent("GROUP_ROSTER_UPDATE")
			self.events:RegisterEvent("UNIT_PET")
			self.events:RegisterEvent("UNIT_NAME_UPDATE")

			self.events:RegisterEvent("PLAYER_REGEN_DISABLED")
			self.events:RegisterEvent("PLAYER_REGEN_ENABLED")

			self.events:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
			self.events:RegisterEvent("ENCOUNTER_START")

			updateTimer:Activate()
			if not NumerationCharOptions.forcehide and not NumerationCharOptions.combatshow then
				self:RefreshDisplay()
				self.window:Show()
			end
		else
			self.events:UnregisterEvent("PLAYER_ENTERING_WORLD")
			self.events:UnregisterEvent("GROUP_ROSTER_UPDATE")
			self.events:UnregisterEvent("UNIT_PET")
			self.events:UnregisterEvent("UNIT_NAME_UPDATE")

			self.events:UnregisterEvent("PLAYER_REGEN_DISABLED")
			self.events:UnregisterEvent("PLAYER_REGEN_ENABLED")

			self.events:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
			self.events:UnregisterEvent("ENCOUNTER_START")
			updateTimer:Hide()
			if instanceType == "none" then
				if not NumerationCharOptions.forcehide then
					self:RefreshDisplay()
					self.window:Show()
				end
			else
				self.window:Hide()
			end
		end
	end
end

local IsGroupInCombat = function()
	if GetNumGroupMembers() > 0 then
		local unit = IsInRaid() and "raid" or "party"
		for i = 1, GetNumGroupMembers(), 1 do
			if UnitExists(unit..i) and UnitAffectingCombat(unit..i) then
				return true
			end
		end
	end
	return false
end

local inCombat = nil
local combatTimer = CreateFrame("Frame")
combatTimer:Hide()
combatTimer:SetScript("OnUpdate", function(self, elapsed)
	self.timer = self.timer - elapsed
	if self.timer > 0 then return end
	if IsGroupInCombat() then self.timer = C.combatseconds return end
	addon:LeaveCombatEvent()
	self:Hide()
end)
function combatTimer:Activate()
	self.timer = C.combatseconds
	self:Show()
end

function addon:PLAYER_REGEN_DISABLED()
	inCombat = true
	combatTimer:Hide()

	if NumerationCharOptions.combathide then
		self.window:Hide()
	end
	if not NumerationCharOptions.forcehide then
		if NumerationCharOptions.combatshow then
			self.window:Show()
			self:RefreshDisplay()
		end
	end
end

function addon:PLAYER_REGEN_ENABLED()
	inCombat = nil
	combatTimer:Activate()

	if not NumerationCharOptions.forcehide then
		if NumerationCharOptions.combathide then
			self.window:Show()
			self:RefreshDisplay()
		end
	end

	if NumerationCharOptions.combatshow then
		self.window:Hide()
	end
end

function addon:ENCOUNTER_START(_, _, encounterName)
	addon.encounterName = encounterName
end

function addon:EnterCombatEvent(timestamp, guid, name)
	if not current.active then
		current = newSet()
		current.start = timestamp
		addon.start = timestamp
		current.active = true
	end

	current.now = timestamp
	addon.now = timestamp
	if not current.boss then
		local mobid = boss.BossIDs[tonumber(({('-'):split(guid)})[6])]
		if not name then name = UNKNOWN end
		if mobid then
			current.name = mobid == true and name or mobid
			current.boss = true
			addon.encounterName = nil
		elseif addon.encounterName then
			current.name = addon.encounterName
			current.boss = true
			addon.encounterName = nil
		elseif not current.name then
			current.name = name
		end
	end
	if not inCombat then
		combatTimer:Activate()
	end
end

function addon:LeaveCombatEvent()
	if current.active then
		current.active = nil
		if ((current.now - current.start) < C.minfightlength) or (NumerationCharOptions.keeponlybosses and not current.boss) then
			return
		end
		tinsert(NumerationCharDB, 1, current)
		if type(self.nav.set) == "number" then
			self.nav.set = self.nav.set + 1
		end

		-- Refresh View
		self:RefreshDisplay(true)
	end
end
