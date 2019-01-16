/datum/preferences/proc/load_keybindings(var/savefile/S)
	var/list/keybindings
	S["keybindings"] >> keybindings
	if(!islist(keybindings) || !keybindings.len)
		keybindings = GLOB.keybinding_default

	bindings.from_list(keybindings)

/datum/preferences/proc/save_keybindings(var/savefile/S)
	WRITE_FILE(S["keybindings"], bindings.to_list())

/datum/preferences/update_preferences(current_version, savefile/S)
	.=..()
	if(chat_toggles & CHAT_LOOC)
		return .
	chat_toggles ^= CHAT_LOOC

/datum/preferences/update_character(current_version, savefile/S)
	.=..()
	for(var/V in all_quirks)
		var/datum/quirk/T
		for(var/datum/quirk/T2 in subtypesof(/datum/quirk)) //SSquirks may not have loaded yet so we have to find the quirks manually
			if(T2.name != V)
				continue
			T = T2
		if(initial(T.mood_quirk) && CONFIG_GET(flag/disable_human_mood))
			if(T in positive_quirks)
				positive_quirks -= V
			if(T in negative_quirks)
				negative_quirks -= V
			if(T in neutral_quirks)
				neutral_quirks -= V
			all_quirks -= V