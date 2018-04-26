
/datum/preferences/proc/load_keybindings(var/savefile/S)
	var/keybindings
	S["keybindings"] >> keybindings 
	if(!keybindings) 
		keybindings = GLOB.keybinding_default

	bindings.from_list(keybindings)
	
/datum/preferences/proc/save_keybindings(var/savefile/S)
	WRITE_FILE(S["keybindings"], bindings.to_list())

/datum/preferences/proc/reset_keybindings()
	bindings.from_list(GLOB.keybinding_default)