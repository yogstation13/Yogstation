/// Handle the migrations necessary from pre-tgui prefs to post-tgui prefs
/datum/preferences/proc/migrate_preferences_to_tgui_prefs_menu()
	migrate_key_bindings()

/// Handle the migrations necessary from pre-tgui prefs to post-tgui prefs, for characters
/datum/preferences/proc/migrate_character_to_tgui_prefs_menu()
	//migrate_hair()

// Key bindings used to be "key" -> list("action"),
// such as "X" -> list("swap_hands").
// This made it impossible to determine any order, meaning placing a new
// hotkey would produce non-deterministic order.
// tgui prefs menu moves this over to "swap_hands" -> list("X").
/datum/preferences/proc/migrate_key_bindings()
	var/new_key_bindings = list()

	for (var/unbound_hotkey in key_bindings["Unbound"])
		new_key_bindings[unbound_hotkey] = list()

	for (var/hotkey in key_bindings)
		if (hotkey == "Unbound")
			continue

		for (var/keybind in key_bindings[hotkey])
			if (keybind in new_key_bindings)
				new_key_bindings[keybind] |= hotkey
			else
				new_key_bindings[keybind] = list(hotkey)

	key_bindings = new_key_bindings
