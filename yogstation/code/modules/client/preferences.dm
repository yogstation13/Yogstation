/datum/preferences
	var/donor_hat = 0
	var/donor_item = 0
	var/donor_pda = 1
	var/quiet_round = FALSE
	var/yogtoggles = YOGTOGGLES_DEFAULT
	var/purrbation = null
	var/afreeze = FALSE
	var/accent = null // What accent to use (as the string name of that accent). NULL means no accent.

	var/datum/keybindings/bindings = new


/datum/preferences/proc/update_keybindings(mob/user, action, dir)
	var/keybind = input(user, "Select [action] button", "Keybinding Preference") as null|anything in GLOB.keybinding_validkeys
	if(keybind)
		bindings.key_setbinding(keybind, action, text2num(dir))

/datum/preferences/proc/reset_keybindings()
	bindings.from_list(GLOB.keybinding_default)