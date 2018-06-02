/datum/preferences/proc/load_keybindings(var/savefile/S)
	var/list/keybindings
	S["keybindings"] >> keybindings
	if(!islist(keybindings) || !keybindings.len)
		keybindings = GLOB.keybinding_default

	bindings.from_list(keybindings)
	
/datum/preferences/proc/save_keybindings(var/savefile/S)
	WRITE_FILE(S["keybindings"], bindings.to_list())