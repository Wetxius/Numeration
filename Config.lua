local n = select(2, ...)
local l = n.locale

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

	-- Title
	titleheight = 16,						-- Heigth for title
	titlealpha = 0.9,						-- Alpha for title
	titlefont = [[Fonts\ARIALN.TTF]],		-- Set font for title
	titlefontstyle = "NONE",				-- Font style for title
	titlefontsize = 13,						-- Font size for title
	titlefontcolor = {1, 1, 1},				-- Font color for title
	highlight = {1, 0.8, 0},				-- Color for button highlight

	-- Lines
	lineheight = 14,						-- Heigth for lines
	linegap = 1,							-- Heigth for line gap
	linealpha = 1,							-- Alpha for lines
	linefont = [[Fonts\ARIALN.TTF]],		-- Set font for line
	linefontstyle = "NONE",					-- Font style for line
	linefontsize = 11,						-- Font size for line
	linefontcolor = {1, 1, 1},				-- Font color for line
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
	silent_reset = false,					-- Confirm reset data and hide pop-up.
}

----------------------------------------------------------------------------------------
--	Available types and their order
----------------------------------------------------------------------------------------
n["types"] = {
	{
		name = DAMAGE,
		id = "dd",
		c = {.25, .66, .35},
	},
	{
		name = l.dmg_tar,
		id = "dd",
		view = "Targets",
		onlyfights = true,
		c = {.25, .66, .35},
	},
	{
		name = l.dmg_take_tar,
		id = "dt",
		view = "Targets",
		onlyfights = true,
		c = {.66, .25, .25},
	},
	{
		name = l.dmg_take_abil,
		id = "dt",
		view = "Spells",
		c = {.66, .25, .25},
	},
	{
		name = l.friend_fire,
		id = "ff",
		c = {.63, .58, .24},
	},
	{
		name = SHOW_COMBAT_HEALING.." + "..COMBAT_TEXT_ABSORB,
		id = "hd",
		id2 = "ga",
		c = {.25, .5, .85},
	},
--	{
--		name = l.heal_take_abil,
--		id = "ht",
--		view = "Spells",
--		c = {.25, .5, .85},
--	},
--	{
--		name = SHOW_COMBAT_HEALING,
--		id = "hd",
--		c = {.25, .5, .85},
--	},
--	{
--		name = COMBAT_TEXT_ABSORB,
--		id = "ga",
--		c = {.25, .5, .85},
--	},
	{
		name = l.overheal,
		id = "oh",
		c = {.25, .5, .85},
	},
	{
		name = DISPELS,
		id = "dp",
		c = {.58, .24, .63},
	},
	{
		name = INTERRUPTS,
		id = "ir",
		c = {.09, .61, .55},
	},
	{
		name = POWER_GAINS,
		id = "pg",
		c = {.19, .44, .75},
	},
	{
		name = l.death_log,
		id = "deathlog",
		view = "Deathlog",
		onlyfights = true,
		c = {.66, .25, .25},
	},
}