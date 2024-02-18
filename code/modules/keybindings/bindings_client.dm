// yogs - Replicated for custom keybindings
// Clients aren't datums so we have to define these procs indpendently.
// These verbs are called for all key press and release events
/client/verb/keyDown(_key as text)
	set instant = TRUE
	set hidden = TRUE

	//Focus Chat failsafe. Overrides movement checks to prevent WASD.
	if(!hotkeys && length(_key) == 1 && _key != "Alt" && _key != "Ctrl" && _key != "Shift")
		winset(src, null, "input.focus=true ; input.text=[url_encode(_key)]")
		return

	if(length(keys_held) >= HELD_KEY_BUFFER_LENGTH && !keys_held[_key])
		keyUp(keys_held[1]) //We are going over the number of possible held keys, so let's remove the first one.

	keys_held[_key] = world.time
	if(!movement_locked)
		var/movement = movement_keys[_key]
		if(!(next_move_dir_sub & movement))
			next_move_dir_add |= movement

	// Client-level keybindings are ones anyone should be able to do at any time
	// Things like taking screenshots, hitting tab, and adminhelps.
	var/AltMod = keys_held["Alt"] ? "Alt" : ""
	var/CtrlMod = keys_held["Ctrl"] ? "Ctrl" : ""
	var/ShiftMod = keys_held["Shift"] ? "Shift" : ""
	var/full_key
	switch(_key)
		if("Alt", "Ctrl", "Shift")
			full_key = "[AltMod][CtrlMod][ShiftMod]"
		else
			if(AltMod || CtrlMod || ShiftMod)
				full_key = "[AltMod][CtrlMod][ShiftMod][_key]"
				key_combos_held[_key] = full_key
			else
				full_key = _key

	var/keycount = 0
	for(var/kb_name in prefs.key_bindings_by_key[full_key])
		keycount++
		var/datum/keybinding/kb = GLOB.keybindings_by_name[kb_name]
		if(kb.can_use(src) && kb.down(src) && keycount >= MAX_COMMANDS_PER_KEY)
			break

	holder?.key_down(_key, src)
	mob.focus?.key_down(_key, src)

/client/verb/keyUp(_key as text)
	set instant = TRUE
	set hidden = TRUE

	var/key_combo = key_combos_held[_key]
	if(key_combo)
		key_combos_held -= _key
		keyUp(key_combo)

	if(!keys_held[_key])
		return

	keys_held -= _key

	if(!movement_locked)
		var/movement = movement_keys[_key]
		if(!(next_move_dir_add & movement))
			next_move_dir_sub |= movement

	// We don't do full key for release, because for mod keys you
	// can hold different keys and releasing any should be handled by the key binding specifically
	for (var/kb_name in prefs.key_bindings_by_key[_key])
		var/datum/keybinding/kb = GLOB.keybindings_by_name[kb_name]
		if (!kb)
			stack_trace("Invalid keybind found in keyUp: _key=[_key]; kb_name=[kb_name]")
			continue

		if(kb.can_use(src) && kb.up(src))
			break
	holder?.key_up(_key, src)
	mob.focus?.key_up(_key, src)
