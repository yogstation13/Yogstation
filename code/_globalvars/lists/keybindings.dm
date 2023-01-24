/// Creates and sorts all the keybinding datums
/proc/init_keybindings()
	for(var/KB in subtypesof(/datum/keybinding))
		var/datum/keybinding/keybinding = KB
		if(!initial(keybinding.name))
			continue
		add_keybinding(new keybinding)

/// Adds an instanced keybinding to the global tracker
/proc/add_keybinding(datum/keybinding/instance)
	GLOB.keybindings_by_name[instance.name] = instance

	// Classic
	if(LAZYLEN(instance.classic_keys))
		for(var/bound_key in instance.classic_keys)
			LAZYADD(GLOB.classic_keybinding_list_by_key[bound_key], list(instance.name))

	// Hotkey
	if(LAZYLEN(instance.hotkey_keys))
		for(var/bound_key in instance.hotkey_keys)
			LAZYADD(GLOB.hotkey_keybinding_list_by_key[bound_key], list(instance.name))
