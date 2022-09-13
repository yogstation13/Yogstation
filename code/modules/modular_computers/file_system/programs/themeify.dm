//this is the program that lets you change the theme of your device

/datum/computer_file/program/themeify
	filename = "themeify"
	filedesc = "Themeify"
	extended_desc = "This program allows configuration of your device's theme."
	program_icon_state = "generic"
	unsendable = 1
	undeletable = 0
	size = 2
	available_on_ntnet = 1
	requires_ntnet = 0
	tgui_id = "NtosThemeConfigure"
	program_icon="paint-roller"


/datum/computer_file/program/themeify/ui_data(mob/user)
	var/list/data = get_header_data()
	data["themes"] = GLOB.pda_themes

	return data

/datum/computer_file/program/themeify/ui_act(action,params)
	if(..())
		return
	switch(action)
		if("PRG_change_theme")
			computer.device_theme = params["theme"]
