/datum/keybinding/client
	category = CATEGORY_CLIENT
	weight = WEIGHT_HIGHEST


/datum/keybinding/client/admin_help
	hotkey_keys = list("F1")
	name = "admin_help"
	full_name = "Admin Help"
	description = "Ask an admin for help."

/datum/keybinding/client/admin_help/down(client/user)
	user.get_adminhelp()
	return TRUE


/datum/keybinding/client/screenshot
	hotkey_keys = list("F2")
	name = "screenshot"
	full_name = "Screenshot"
	description = "Take a screenshot."

/datum/keybinding/client/screenshot/down(client/user)
	winset(user, null, "command=.screenshot [!user.keys_held["shift"] ? "auto" : ""]")
	return TRUE


/datum/keybinding/client/minimal_hud
	hotkey_keys = list("F12")
	name = "minimal_hud"
	full_name = "Minimal HUD"
	description = "Hide most HUD features"

/datum/keybinding/client/minimal_hud/down(client/user)
	user.mob.button_pressed_F12()
	return TRUE  


/datum/keybinding/client/ooc
	hotkey_keys = list("O")
	name = "ooc"
	full_name = "OOC"
	description = ""

/datum/keybinding/client/ooc/down(client/user)
	user.ooc_wrapper()
	return TRUE


/datum/keybinding/client/looc
	hotkey_keys = list("L")
	name = "looc"
	full_name = "LOOC"
	description = ""

/datum/keybinding/client/looc/down(client/user)
	user.looc_wrapper()
	return TRUE
