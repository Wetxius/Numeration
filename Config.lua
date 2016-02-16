local n = select(2, ...)
local L = n.locale

----------------------------------------------------------------------------------------
--	Window options
----------------------------------------------------------------------------------------
n["windows"] = {
	pos = {"TOPLEFT", 4, -4},				-- Position for Main Frame
	width = 280,							-- Width for Main Frame
	maxlines = 9,							-- Maximum lines
	backgroundalpha = 0.6,					-- Alpha for background
	fontshadow = true,						-- Use shadow for all fonts
	scrollbar = true,						-- Show scrollbar
	tpos = "ANCHOR_BOTTOMRIGHT",			-- Tooltip anchor

	-- Title
	titleheight = 16,						-- Height for title
	titlealpha = 0.9,						-- Alpha for title
	titlefont = [[Fonts\ARIALN.TTF]],		-- Set font for title
	titlefontstyle = "NONE",				-- Font style for title
	titlefontsize = 13,						-- Font size for title
	titlefontcolor = {1, 1, 1, 1},			-- Font color for title
	highlight = {1, 0.8, 0, 0.3},			-- Color for button highlight
	title_hide = false,						-- Hide title

	-- Lines
	lineheight = 14,						-- Height for lines
	linegap = 1,							-- Height for line gap
	linealpha = 1,							-- Alpha for lines
	linefont = [[Fonts\ARIALN.TTF]],		-- Set font for line
	linefontstyle = "NONE",					-- Font style for line
	linefontsize = 11,						-- Font size for line
	linefontcolor = {1, 1, 1, 1},			-- Font color for line
	linetexture = [[Interface\Tooltips\UI-Tooltip-Background]],	-- Set texture for line
}

----------------------------------------------------------------------------------------
--	Core options
----------------------------------------------------------------------------------------
n["core"] = {
	refreshinterval = 1,					-- How often to update the numbers
	minfightlength = 15,					-- Time after which the segment will be saved
	combatseconds = 3,						-- Time until new segment will be start
	shortnumbers = true,					-- Use short numbers ("19.2k" instead of "19234")
	silent_reset = false,					-- Auto confirm reset data and hide pop-up
	merge_spells = true,					-- Merge spells with same names (from list)
	remove_realm = true,					-- Don't show realm name
}

----------------------------------------------------------------------------------------
--	Available types and their order
----------------------------------------------------------------------------------------
n["types"] = {
	{	-- Damage
		name = DAMAGE,
		id = "dd",
		c = {.25, .66, .35},
	},
	{	-- Damage Targets
		name = L.dmg_tar,
		id = "dd",
		view = "Targets",
		onlyfights = true,
		c = {.25, .66, .35},
	},
	{	-- Damage Taken: Targets
		name = L.dmg_take_tar,
		id = "dt",
		view = "Targets",
		onlyfights = true,
		c = {.66, .25, .25},
	},
	{	-- Damage Taken: Abilities
		name = L.dmg_take_abil,
		id = "dt",
		view = "Spells",
		c = {.66, .25, .25},
	},
	{	-- Friendly Fire
		name = L.friend_fire,
		id = "ff",
		c = {.63, .58, .24},
	},
	{	-- Healing + Absorb
		name = SHOW_COMBAT_HEALING.." + "..COMBAT_TEXT_ABSORB,
		id = "hd",
		id2 = "ga",
		c = {.25, .5, .85},
	},
--	{	-- Healing Taken: Abilities
--		name = L.heal_take_abil,
--		id = "ht",
--		view = "Spells",
--		c = {.25, .5, .85},
--	},
--	{	-- Healing
--		name = SHOW_COMBAT_HEALING,
--		id = "hd",
--		c = {.25, .5, .85},
--	},
--	{	-- Absorb
--		name = COMBAT_TEXT_ABSORB,
--		id = "ga",
--		c = {.25, .5, .85},
--	},
	{	-- Overhealing
		name = L.overheal,
		id = "oh",
		c = {.25, .5, .85},
	},
	{	-- Dispels
		name = DISPELS,
		id = "dp",
		c = {.58, .24, .63},
	},
	{	-- Interrupts
		name = INTERRUPTS,
		id = "ir",
		c = {.09, .61, .55},
	},
	{	-- Power Gains
		name = POWER_GAINS,
		id = "pg",
		c = {.19, .44, .75},
	},
	{	-- Death Log
		name = L.death_log,
		id = "deathlog",
		view = "Deathlog",
		onlyfights = true,
		c = {.66, .25, .25},
	},
}