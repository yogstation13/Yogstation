/* Antag Menus
 * 
 * Used for specific uplink-like menus for some antags, currently Changeling and Darkspawn,
 * Linked to their antag datum directly.
 * 
*/

/datum/antag_menu
	var/name = "le bug report"
	var/ui_name = ""
	var/datum/antagonist/antag_datum

/datum/antag_menu/New(antag_datum)
	. = ..()
	src.antag_datum = antag_datum

/datum/antag_menu/Destroy()
	antag_datum = null
	. = ..()

/datum/antag_menu/ui_state(mob/user)
	return GLOB.always_state

/datum/antag_menu/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, ui_name, name)
		ui.open()
