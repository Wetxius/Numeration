local addonname, addon = ...
Numeration = addon
local l = addon.locale
addon.events = CreateFrame("Frame")
addon.events:SetScript("OnEvent", function(self, event, ...)
	addon[event](addon, event, ...)
end)
addon.views = {}
-- important GUIDs
addon.guidToClass = {}
addon.guidToName = {}

-- Keybindings
BINDING_HEADER_NUMERATION = "Numeration"
BINDING_NAME_NUMERATION_VISIBILITY = l.binding_visibility
BINDING_NAME_NUMERATION_RESET = l.binding_reset

local bossIds = {
	-- Pandaria
	-- Terrace of Endless Spring
	[60583] = l.prot,	-- Protector Kaolan
	[60585] = l.prot,	-- Elder Regail
	[60586] = l.prot,	-- Elder Asani
	[62442] = true,		-- Tsulong
	[63099] = true,		-- Lei Shi
	[60999] = true,		-- Sha of Fear
	-- Heart of Fear
	[66791] = true,		-- Imperial Vizier Zor'lok
	[63664] = true,		-- Blade Lord Ta'yak
	[63667] = true,		-- Garalon
	[65501] = true,		-- Wind Lord Mel'jarak
	[63666] = true,		-- Amber-Shaper Un'sok
	[62837] = true,		-- Grand Empress Shek'zeer
	-- Mogu'Shan Vault
	[59915] = l.stone,	-- Jasper, Stone Guard
	[60043] = l.stone,	-- Jade, Stone Guard
	[60047] = l.stone,	-- Amethyst, Stone Guard
	[60051] = l.stone,	-- Cobalt, Stone Guard
	[60009] = true,		-- Feng the Accursed
	[60143] = true,		-- Gara'jal the Spiritbinder
	[60701] = l.kings,	-- Zian of the Endless Shadow
	[60708] = l.kings,	-- Qiang the Merciless
	[60709] = l.kings,	-- Subetai the Swift
	[60710] = l.kings,	-- Meng the Demented
	[60410] = true,		-- Elegon
	[60396] = l.will,	-- Emperor's Rage
	[60397] = l.will,	-- Emperor's Strength
	[60399] = l.will,	-- Qin-xi
	[60400] = l.will,	-- Jan-xi
	-- World bosses
	[60491] = true,		-- Sha of Anger
	[62346] = true,		-- Galleon
	-------------------------------------------------------------------------------
	-- Shado-Pan Monastery
	[56719] = true,		-- Sha of Violence
	[56747] = true,		-- Gu Cloudstrike
	[56884] = true,		-- Taran Zhu
	[64387] = true,		-- Master Snowdrift
	-- Stormstout Brewery
	[56717] = true,		-- Hoptallus
	[57963] = true,		-- Ook-Ook
	[59479] = true,		-- Yan-Zhu the Unsacked
	-- Temple of the Jade Serpent
	[56448] = true,		-- Wise Mari
	[58826] = true,		-- Zao Sunseeker
	[59051] = true,		-- Strife
	[59726] = true,		-- Anger
	[56732] = true,		-- Liu Flameheart
	[56439] = true,		-- Sha of Doubt
	-- Mogu'Shan Palace
	[61442] = true,		-- Kuai the Brute, Trial of the King
	[61444] = true,		-- Ming the Cunning, Trial of the King
	[61445] = true,		-- Haiyan the Unstoppable, Trial of the King
	[61243] = true,		-- Gekkan
	[61398] = true,		-- Xin the Weaponmaster
	-- Nizuao Temple
	[61634] = true,		-- Vojak
	[61567] = true,		-- Jinbak
	[62205] = true,		-- Neronok
	[61485] = true,		-- Pavalak
	-------------------------------------------------------------------------------
	-- Cataclysm
	-- Dragon Soul
	[55265]	= true,		-- Morchok
	[55308]	= true,		-- Warlord Zon'ozz
	[55312]	= true,		-- Yor'sahj the Unsleeping
	[55689]	= true,		-- Hagara the Stormbinder
	[55294]	= true,		-- Ultraxion
	[56855] = l.horn,	-- Twilight Assault Drake
	[56854] = l.horn,	-- Twilight Elite Dreadblade
	[56848] = l.horn,	-- Twilight Elite Slayer
	[53879]	= true,		-- Spine of Deathwing
	[56167] = l.mad,	-- Arm Tentacle
	[56846] = l.mad,	-- Arm Tentacle
	[56168] = l.mad,	-- Wing Tentacle
	-- Firelands
	[52558] = true,		-- Lord Rhyolith
	[52498] = true,		-- Beth'tilac
	[52530] = true,		-- Alysrazor
	[53691] = true,		-- Shannox
	[53494] = true,		-- Baleroc
	[52571] = true,		-- Majordomo Staghelm
	[52409] = true,		-- Ragnaros
	-- Blackwing Descent
	[41570] = true,		-- Magmaw
	[42166] = l.omno,	-- Arcanotron
	[42178] = l.omno,	-- Magmatron
	[42179] = l.omno,	-- Electron
	[42180] = l.omno,	-- Toxitron
	[41378] = true,		-- Maloriak
	[41442] = true,		-- Atramedes
	[43296] = true,		-- Chimaeron
	[41376] = true,		-- Nefarian
	-- Throne of the Four Winds
	[45870] = l.wind,	-- Anshal
	[45871] = l.wind,	-- Nezir
	[45872] = l.wind,	-- Rohash
	[46753] = true,		-- Al'Akir
	-- The Bastion of Twilight
	[44600] = true,		-- Halfus Wyrmbreaker
	[45992] = l.drag,	-- Valiona
	[45993] = l.drag,	-- Theralion
	[43686] = l.elem,	-- Ignacious
	[43687] = l.elem,	-- Feludius
	[43324] = true,		-- Cho'gall
	[45213] = true,		-- Sinestra
	-- Baradin Hold
	[47120] = true,		-- Argaloth
	[52363]	= true,		-- Occu'thar
	[55869]	= true,		-- Alizabal
}

-- used colors
addon.color = {
	PET = {0.09, 0.61, 0.55},
}
addon.colorhex = {}
do
	local colors = CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS
	for class, c in pairs(colors) do
		addon.color[class] = { c.r, c.g, c.b }
		addon.colorhex[class] = string.format("%02X%02X%02X", c.r * 255, c.g * 255, c.b * 255)
	end
	addon.colorhex["PET"] = string.format("%02X%02X%02X", addon.color.PET[1] * 255, addon.color.PET[2] * 255, addon.color.PET[3] * 255)
end

addon.spellIcon = setmetatable({ [75] = "", [6603] = "", }, { __index = function(tbl, i)
	local spell, _, icon = GetSpellInfo(i)
	addon.spellName[i] = spell
	tbl[i] = icon
	return icon
end})
addon.spellName = setmetatable({}, {__index = function(tbl, i)
	local spell, _, icon = GetSpellInfo(i)
	addon.spellIcon[i] = icon
	tbl[i] = spell
	return spell
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
	icon:Register("Numeration", ldb, NumerationCharOptions.minimap)
	self.window:OnInitialize()
	if NumerationCharOptions.forcehide then
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

local s
function addon:InitOptions()
	s = self.coresettings
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

	self.ModNumber = s.shortnumbers and abrNumber or fullNumber
end

function ldb:OnTooltipShow()
    GameTooltip:AddLine("Numeration", 1, .8, 0)
    GameTooltip:AddLine(l.ttoggle)
    GameTooltip:AddLine(l.treset)
end

function ldb:OnClick(button)
	if button == "LeftButton" then
		if IsShiftKeyDown() then
			StaticPopup_Show("RESET_DATA")
		else
			addon:ToggleVisibility()
		end
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
	NumerationCharOptions.minimap.hide = not show
	if show then
		icon:Show("Numeration")
	else
		icon:Hide("Numeration")
	end
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
	NumerationCharDB[0].name = l.Overall_Data
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
	self.timer = s.refreshinterval

	if current.changed then
		ldb.text = addon.views["Units"]:GetXps(current, UnitName("player"), "dd", NumerationCharOptions.petsmerged)
	end

	local set = addon.nav.set and addon:GetSet(addon.nav.set) or current
	if not set or not set.changed then return end
	set.changed = nil

	addon:RefreshDisplay(true)
end)
function updateTimer:Activate()
	self.timer = s.refreshinterval
	self:Show()
end
function updateTimer:Refresh()
	self.timer = s.refreshinterval
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
		if not useChannel or not UnitIsPlayer(useChannel) or not UnitCanCooperate("player", useChannel) then
			print(l.bad_whisp)
			return
		end
	end

	local view = self.views[self.nav.view]
	if view.Report then
		view:Report(NumerationCharOptions.petsmerged, lines)
	else
		print(l.bad_report)
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
	local last = start+self.window.maxlines-1
	if last > total then
		first = first-last+total
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
	local duration = math.ceil(set.now-set.start)
	local durationtext = duration < 60 and format("%is", duration%60) or format("%im%is", math.floor(duration/60), duration%60)
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
		local key = format("%s:%s", owner, name)
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
addon.PLAYER_ENTERING_WORLD = addon.UpdateGUIDS
addon.GROUP_ROSTER_UPDATE = addon.UpdateGUIDS
addon.UNIT_PET = addon.UpdateGUIDS
addon.UNIT_NAME_UPDATE = addon.UpdateGUIDS
function addon:ZONE_CHANGED_NEW_AREA(force)
	local _, zoneType = IsInInstance()

	if force == true or zoneType ~= self.zoneType then
		self.zoneType = zoneType

		if not NumerationCharOptions.onlyinstance or zoneType == "party" or zoneType == "raid" then
			if zoneType == "party" or zoneType == "raid" or zoneType == "pvp" then
				local curZone = GetRealZoneText()
				if curZone ~= NumerationCharDB.zone then
					NumerationCharDB.zone = curZone
					addon.window:ShowResetWindow()
				end
			end
			self:UpdateGUIDS()

			self.events:RegisterEvent("PLAYER_ENTERING_WORLD")
			self.events:RegisterEvent("GROUP_ROSTER_UPDATE")
			self.events:RegisterEvent("UNIT_PET")
			self.events:RegisterEvent("UNIT_NAME_UPDATE")

			self.events:RegisterEvent("UNIT_HEALTH")
			self.events:RegisterEvent("PLAYER_REGEN_DISABLED")
			self.events:RegisterEvent("PLAYER_REGEN_ENABLED")

			self.events:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

			updateTimer:Activate()
			if not NumerationCharOptions.forcehide then
				self:RefreshDisplay()
				self.window:Show()
			end
		else
			self.events:UnregisterEvent("PLAYER_ENTERING_WORLD")
			self.events:UnregisterEvent("GROUP_ROSTER_UPDATE")
			self.events:UnregisterEvent("UNIT_PET")
			self.events:UnregisterEvent("UNIT_NAME_UPDATE")

			self.events:UnregisterEvent("UNIT_HEALTH")
			self.events:UnregisterEvent("PLAYER_REGEN_DISABLED")
			self.events:UnregisterEvent("PLAYER_REGEN_ENABLED")

			self.events:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
			updateTimer:Hide()
			if zoneType == "none" then
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

local inCombat = nil
local meDead = nil
local combatTimer = CreateFrame("Frame")
combatTimer:Hide()
combatTimer:SetScript("OnUpdate", function(self, elapsed)
	self.timer = self.timer - elapsed
	if self.timer > 0 then return end
	addon:LeaveCombatEvent()
	self:Hide()
end)
function combatTimer:Activate()
	self.timer = s.combatseconds
	self:Show()
end
function addon:UNIT_HEALTH(unit)
	if unit ~= "player" then return end
	local dead = UnitIsDead("player")
	if dead ~= meDead then
		meDead = dead
		if inCombat then return end
		if meDead then
			combatTimer:Hide()
		else
			combatTimer:Activate()
		end
	end
end
function addon:PLAYER_REGEN_DISABLED()
	inCombat = true
	combatTimer:Hide()
end
function addon:PLAYER_REGEN_ENABLED()
	inCombat = nil
	if not meDead then
		combatTimer:Activate()
	end
end

function addon:IsRaidInCombat()
	if GetNumGroupMembers() > 0 then
		local unit = IsInRaid() and "raid" or "party"
		for i = 1, GetNumGroupMembers(), 1 do
			if UnitExists(unit..i) and UnitAffectingCombat(unit..i) then
				inCombat = true
			end
		end
	end
	inCombat = nil
end

function addon:EnterCombatEvent(timestamp, guid, name)
	if not current.active then
		current = newSet()
		current.start = timestamp
		current.active = true
	end

	current.now = timestamp
	if not current.boss then
		local mobid = bossIds[tonumber(guid:sub(7, 10), 16)]
		if mobid then
			current.name = mobid == true and name or mobid
			current.boss = true
		elseif not current.name then
			current.name = name
		end
	end
	if not inCombat and not meDead then
		combatTimer:Activate()
	end
end

function addon:LeaveCombatEvent()
	if current.active then
		current.active = nil
		if ((current.now - current.start) < s.minfightlength) or (NumerationCharOptions.keeponlybosses and not current.boss) then
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

local prevSummonDst, prevSummonSrc, prevSummonName = nil, nil, nil
function addon:COMBAT_LOG_EVENT_UNFILTERED(e, timestamp, eventtype, hideCaster, srcGUID, srcName, srcFlags, srcRaidFlags, dstGUID, dstName, dstFlags, dstRaidFlags, ...)
	if self.collect[eventtype] then
		self.collect[eventtype](timestamp, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, ...)
	end

	if eventtype == "SPELL_SUMMON" then
		local ClassOrOwnerGUID = self.guidToClass[srcGUID]
		if ClassOrOwnerGUID then
			local realSrcGUID = self.guidToClass[ClassOrOwnerGUID] and ClassOrOwnerGUID or srcGUID
			summonOwner[dstGUID] = realSrcGUID
			summonName[dstGUID] = dstName
			self.guidToClass[dstGUID] = realSrcGUID
			self.guidToName[dstGUID] = dstName
			if prevSummonSrc ~= nil and dstGUID == prevSummonSrc then
				summonOwner[prevSummonDst] = realSrcGUID
				summonName[prevSummonDst] = prevSummonName
				self.guidToClass[prevSummonDst] = realSrcGUID
				self.guidToName[prevSummonDst] = prevSummonName
				prevSummonDst, prevSummonSrc, prevSummonName = nil, nil, nil
			end
		else
			prevSummonDst, prevSummonSrc, prevSummonName = dstGUID, srcGUID, dstName
		end
	elseif eventtype == "UNIT_DIED" and summonOwner[dstGUID] then
		summonOwner[dstGUID] = nil
		summonName[dstGUID] = nil
		self.guidToClass[dstGUID] = nil
		self.guidToName[dstGUID] = nil
	end
end
