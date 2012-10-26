local n = select(2, ...)

if GetLocale() == "ruRU" then
	n.locale = {
		Damage_Targets = "Урон по целям",
		Damage_Taken_Targets = "Полученный урон: Цели",
		Damage_Taken_Abilities = "Полученный урон: Способности",
		Friendly_Fire = "Огонь по своим",
		Healing_Taken_Abilities = "Полученное лечение: Способности",
		Overhealing = "Переисцеление",
		Death_Log = "Журнал смертей",
		Targets = " по целям",
		Selection_Set = "Выбор режима",
		Overall_Data = "Все битвы",
		Current_Fight = "Текущий бой",
		petsmerged = "Объединять питомцев с хозяевами",
		keeponlybosses = "Сохранять только бои с боссами",
		onlyinstance = "Записывать только в подземельях",
		minimapicon = "Показать иконку у миникарты",
		ttoggle = "ЛКМ, чтобы показать/скрыть окно.",
		treset = "Шифт + ЛКМ, чтобы сбросить данные.",
	}
else
	n.locale = {
		Damage_Targets = "Damage Targets",
		Damage_Taken_Targets = "Damage Taken: Targets",
		Damage_Taken_Abilities = "Damage Taken: Abilities",
		Friendly_Fire = "Friendly Fire",
		Healing_Taken_Abilities = "Healing Taken: Abilities",
		Overhealing = "Overhealing",
		Death_Log = "Death Log",
		Targets = " Targets",
		Selection_Set = "Selection: Set",
		Overall_Data = "Overall Data",
		Current_Fight = "Current Fight",
		petsmerged = "Merge Pets w/ Owners",
		keeponlybosses = "Keep Only Boss Segments",
		onlyinstance = "Record Only In Instances",
		minimapicon = "Show Minimap Icon",
		ttoggle = "Left-Click to toggle window visibility.",
		treset = "Shift + Left-Click to reset data.",
	}
end