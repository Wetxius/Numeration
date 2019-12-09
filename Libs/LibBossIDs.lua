local addon = select(2, ...)
local L = addon.locale
local lib = LibStub:NewLibrary("LibBossIDs", 1)
if not lib then return end

local BossIDs = {
	-------------------------------------------------------------------------------
	-- Pandaria Raids
	-------------------------------------------------------------------------------
	-- Siege of Orgrimmar
	[71543] = true,		-- Immerseus
	[71475] = L.fallen,	-- Rook Stonetoe
	[71479] = L.fallen,	-- He Softfoot
	[71480] = L.fallen,	-- Sun Tenderheart
	[72276] = L.noru,	-- Norushen
	[71734] = true,		-- Sha of Pride
	[72941] = L.gala,	-- Galakras
	[71466] = true,		-- Iron Juggernaut
	[71859] = L.shaman,	-- Earthbreaker Haromm
	[71858] = L.shaman,	-- Wavebinder Kardris
	[71515] = true,		-- General Nazgrim
	[71454] = true,		-- Malkorok
	[71378] = L.spoil,	-- Mogu Spoils
	[71388] = L.spoil,	-- Mantid Spoils
	[71529] = true,		-- Thok the Bloodthirsty
	[71504] = true,		-- Siegecrafter Blackfuse
	[71153] = L.para,	-- Hisek the Swarmkeeper
	[71158] = L.para,	-- Rik'kal the Dissector
	[71152] = L.para,	-- Skeer the Bloodseeker
	[71154] = L.para,	-- Ka'roz the Locust
	[71160] = L.para,	-- Iyyokuk the Lucid
	[71155] = L.para,	-- Korven the Prime
	[71156] = L.para,	-- Kaz'tik the Manipulator
	[71157] = L.para,	-- Xaril the Poisoned Mind
	[71161] = L.para,	-- Kil'ruk the Wind-Reaver
	[71865] = true,		-- Garrosh Hellscream
	-- Throne of Thunder
	[69465] = true,		-- Jin'rokh the Breaker
	[68476] = true,		-- Horridon
	[69078] = L.elder,	-- Sul the Sandcrawler
	[69131] = L.elder,	-- Frost King Malakk
	[69132] = L.elder,	-- High Priestess Mar'li
	[69134] = L.elder,	-- Kazra'jin
	[67977] = true,		-- Tortos
	[70235] = L.mega,	-- Frozen Head
	[70247] = L.mega,	-- Venomous Head
	[69712] = true,		-- Ji-Kun
	[68036] = true,		-- Durumu the Forgotten
	[69017] = true,		-- Primordius
	[69701] = L.anima,	-- Anima Golem
	[68078] = true,		-- Iron Qon
	[68904] = L.twin,	-- Suen
	[68905] = L.twin,	-- Lu'lin
	[68397] = true,		-- Lei Shen
	[69473] = true,		-- Ra-den
	-- Terrace of Endless Spring
	[60583] = L.prot,	-- Protector Kaolan
	[60585] = L.prot,	-- Elder Regail
	[60586] = L.prot,	-- Elder Asani
	[62442] = true,		-- Tsulong
	[62983] = true,		-- Lei Shi
	[60999] = true,		-- Sha of Fear
	-- Heart of Fear
	[62980] = true,		-- Imperial Vizier Zor'lok
	[62543] = true,		-- Blade Lord Ta'yak
	[63191] = true,		-- Garalon
	[62397] = true,		-- Wind Lord Mel'jarak
	[62511] = true,		-- Amber-Shaper Un'sok
	[62837] = true,		-- Grand Empress Shek'zeer
	-- Mogu'Shan Vault
	[59915] = L.stone,	-- Jasper Guardian
	[60043] = L.stone,	-- Jade Guardian
	[60047] = L.stone,	-- Amethyst Guardian
	[60051] = L.stone,	-- Cobalt Guardian
	[60009] = true,		-- Feng the Accursed
	[60143] = true,		-- Gara'jal the Spiritbinder
	[60701] = L.kings,	-- Zian of the Endless Shadow
	[60708] = L.kings,	-- Qiang the Merciless
	[60709] = L.kings,	-- Subetai the Swift
	[60710] = L.kings,	-- Meng the Demented
	[60410] = true,		-- Elegon
	[60396] = L.will,	-- Emperor's Rage
	-- World bosses
	[72057] = true,		-- Ordos
	[71955] = true,		-- Yu'lon
	[71954] = true,		-- Niuzao
	[71953] = true,		-- Xuen
	[71952] = true,		-- Chi-Ji
	[69161] = true,		-- Oondasta
	[69099] = true,		-- Nalak
	[60491] = true,		-- Sha of Anger
	[62346] = true,		-- Galleon
	-------------------------------------------------------------------------------
	-- Pandaria Dungeons
	-------------------------------------------------------------------------------
	-- Gate of the Setting Sun
	[56906] = true,		-- Saboteur Kip'tilak
	[56589] = true,		-- Striker Ga'dok
	[56636] = true,		-- Commander Ri'mok
	[56877] = true,		-- Raigonn
	-- Mogu'Shan Palace
	[61442] = L.trial,	-- Kuai the Brute
	[61444] = L.trial,	-- Ming the Cunning
	[61445] = L.trial,	-- Haiyan the Unstoppable
	[61243] = true,		-- Gekkan
	[61398] = true,		-- Xin the Weaponmaster
	-- Scarlet Halls
	[59303] = true,		-- Houndmaster Braun
	[58632] = true,		-- Armsmaster Harlan
	[59150] = true,		-- Flameweaver Koegler
	-- Scarlet Monastery
	[59789] = true,		-- Thalnos the Soulrender
	[59223] = true,		-- Brother Korloff
	[60040] = L.inq,	-- Commander Durand
	-- Scholomance
	[58633] = true,		-- Instructor Chillheart
	[59184] = true,		-- Jandice Barov
	[59153] = true,		-- Rattlegore
	[58722] = true,		-- Lilian Voss
	[59080] = true,		-- Darkmaster Gandling
	-- Shado-Pan Monastery
	[56747] = true,		-- Gu Cloudstrike
	[56541] = true,		-- Master Snowdrift
	[56719] = true,		-- Sha of Violence
	[56884] = true,		-- Taran Zhu
	-- Siege of Niuzao Temple
	[61567] = true,		-- Vizier Jin'bak
	[61634] = true,		-- Commander Vo'jak
	[61485] = true,		-- General Pa'valak
	[62205] = true,		-- Wing Leader Ner'onok
	-- Stormstout Brewery
	[56637] = true,		-- Ook-Ook
	[56717] = true,		-- Hoptallus
	[59479] = true,		-- Yan-Zhu the Uncasked
	-- Temple of the Jade Serpent
	[56448] = true,		-- Wise Mari
	[59726] = L.lore,	-- Peril
	[59051] = L.lore,	-- Strife
	[56915] = L.lore,	-- Sun
	[56732] = true,		-- Liu Flameheart
	[56439] = true,		-- Sha of Doubt
}

lib.BossIDs = BossIDs