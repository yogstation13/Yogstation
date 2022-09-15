//this is the program that lets you change the theme of your device

/datum/computer_file/program/themeify
	filename = "themeify"
	filedesc = "Themeify"
	extended_desc = "This program allows configuration of your device's theme."
	program_icon_state = "generic"
	unsendable = TRUE
	undeletable = FALSE
	size = 2
	available_on_ntnet = TRUE
	requires_ntnet = FALSE
	tgui_id = "NtosThemeConfigure"
	program_icon="paint-roller"


/datum/computer_file/program/themeify/ui_data(mob/user)
	var/list/data = get_header_data()
	var/list/theme_collection = list()
	for(var/theme_key in GLOB.pda_themes)
		theme_collection += list(list("theme_name" = theme_key, "theme_file" = GLOB.pda_themes[theme_key]))
	data["theme_collection"] = theme_collection
	return data

/datum/computer_file/program/themeify/ui_act(action,params)
	if(..())
		return
	switch(action)
		if("PRG_change_theme")
			computer.device_theme = GLOB.pda_themes[sanitize_inlist(params["theme_title"], GLOB.pda_themes, PDA_THEME_TITLE_NTOS)]
