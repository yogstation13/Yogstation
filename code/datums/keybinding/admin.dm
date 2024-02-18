/datum/keybinding/admin
    category = CATEGORY_ADMIN
    weight = WEIGHT_ADMIN

/datum/keybinding/admin/can_use(client/user)
	return user.holder ? TRUE : FALSE


/datum/keybinding/admin/admin_say
    hotkey_keys = list("F3")
    name = ASAY_CHANNEL
    full_name = "Admin say"
    description = "Talk with other admins."


/datum/keybinding/admin/admin_ghost
    hotkey_keys = list("F5")
    name = "admin_ghost"
    full_name = "Aghost"
    description = "Go ghost"

/datum/keybinding/admin/admin_ghost/down(client/user)
    user.admin_ghost()
    return TRUE


/datum/keybinding/admin/player_panel
    hotkey_keys = list("F6")
    name = "player_panel"
    full_name = "Player Panel"
    description = "Opens up the player panel"

/datum/keybinding/admin/player_panel/down(client/user)
	user.holder.player_panel_new()
	return TRUE


/datum/keybinding/admin/toggle_buildmode_self
	hotkey_keys = list("F7")
	name = "toggle_buildmode_self"
	full_name = "Toggle Buildmode Self"
	description = "Toggles buildmode"

/datum/keybinding/admin/toggle_buildmode_self/down(client/user)
	user.togglebuildmodeself()
	return TRUE


/datum/keybinding/admin/stealthmode
	hotkey_keys = list("Ctrl-F8")
	name = "stealth_mode"
	full_name = "Stealth mode"
	description = "Enters stealth mode"

/datum/keybinding/admin/stealthmode/down(client/user)
	user.stealth()
	return TRUE


/datum/keybinding/admin/invisimin
	hotkey_keys = list("F8")
	name = "invisimin"
	full_name = "Admin invisibility"
	description = "Toggles ghost-like invisibility (Don't abuse this)"

/datum/keybinding/admin/invisimin/down(client/user)
	user.invisimin()
	return TRUE


/datum/keybinding/admin/deadsay
	hotkey_keys = list("F10")
	name = DEADSAY_CHANNEL
	full_name = "deadsay"
	description = "Allows you to send a message to dead chat"


/datum/keybinding/admin/deadmin
	hotkey_keys = list("Unbound")
	name = "deadmin"
	full_name = "Deadmin"
	description = "Shed your admin powers"

/datum/keybinding/admin/deadmin/down(client/user)
	user.deadmin()
	return TRUE

/datum/keybinding/admin/readmin
	hotkey_keys = list("Unbound")
	name = "readmin"
	full_name = "Readmin"
	description = "Regain your admin powers"

/datum/keybinding/admin/readmin/down(client/user)
	user.readmin()
	return TRUE
