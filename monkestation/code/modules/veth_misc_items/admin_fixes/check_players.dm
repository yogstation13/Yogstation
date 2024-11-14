/client/proc/check_players()
	set name = "Check Players"
	set category = "Admin.Game"
	if(!check_rights(NONE)) // Rights check for admin access
		message_admins("[key_name(src)] attempted to use CheckPlayers without sufficient rights.") //messages admins if rights check fails
		return
	var/datum/check_players/tgui = new
	tgui.ui_interact(mob)
	to_chat(src, span_interface("Player statistics displayed."), confidential = TRUE)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Check Players") //Logging
	message_admins("[key_name(src)] checked players.") //Logging

/datum/check_players/ui_data(mob/user) //Data required for the frontend
	return list(
		"total_clients" = length(GLOB.player_list),
		"living_players" = length(GLOB.alive_player_list),
		"dead_players" = length(GLOB.dead_player_list),
		"observers" = length(GLOB.current_observers_list),
		"living_antags" = length(GLOB.current_living_antags),
	)

/datum/check_players //datum required for the tgui window

/datum/check_players/ui_close()
	qdel(src)

/datum/check_players/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PlayerStatistics")
		ui.open()

/datum/check_players/ui_state(mob/user)
	return GLOB.admin_state
