
/datum/preferences/proc/load_keybindings(var/savefile/S)
	S["movement_keys"] >> movement_keys
	if(!movement_keys)
		movement_keys = SSinput.movement_default

	movement_keys_inv = list()
	for(var/K in movement_keys)
		var/V = movement_keys[K]
		movement_keys_inv[num2text(V)] = K // nice sequential lists
	
/datum/preferences/proc/save_keybindings(var/savefile/S)
	WRITE_FILE(S["movement_keys"], movement_keys)