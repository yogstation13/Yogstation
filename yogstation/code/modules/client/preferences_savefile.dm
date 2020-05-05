/datum/preferences/proc/load_keybindings(var/savefile/S)
	var/list/keybindings
	S["keybindings"] >> keybindings
	if(!islist(keybindings) || !keybindings.len)
		keybindings = GLOB.keybinding_default

	bindings.from_list(keybindings)

/datum/preferences/proc/save_keybindings(var/savefile/S)
	WRITE_FILE(S["keybindings"], bindings.to_list())

/datum/preferences/update_character(current_version, savefile/S)
	.=..()
	var/value = 0
	for(var/V in all_quirks)
		var/datum/quirk/T
		for(var/datum/quirk/T2 in subtypesof(/datum/quirk)) //SSquirks may not have loaded yet so we have to find the quirks manually
			if(T2.name != V)
				continue
			T = T2
		if(initial(T.mood_quirk) && CONFIG_GET(flag/disable_human_mood))
			all_quirks -= V
		else
			value += initial(T.value)

	if(value < 0)
		to_chat(parent, "<span class='userdanger'>Your quirks have been reset due to an insufficient balance because certain quirks have been disabled.</span>")
		to_chat(parent, "<span class='notice'>Your previously selected quirks:</span>")
		for(var/V in all_quirks)
			to_chat(parent, "<span class='notice'>[V]</span>")
		all_quirks = list()
