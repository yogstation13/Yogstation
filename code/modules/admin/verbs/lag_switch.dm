/client/proc/lag_switch_panel()
	set name = "Lag Switch Panel"
	set category = "Server"
	if(!check_rights(R_SERVER))
		return
	var/datum/lag_switch_menu/tgui = new(usr)
	tgui.ui_interact(usr)
	
/datum/lag_switch_menu
	var/client/holder

/datum/lag_switch_menu/New(user)
	if(istype(user, /client))
		var/client/user_client = user
		holder = user_client
	else
		var/mob/user_mob = user
		holder = user_mob.client

/datum/lag_switch_menu/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "LagSwitchPanel")
		ui.open()
		ui.set_autoupdate(TRUE)

/datum/lag_switch_menu/ui_state(mob/user)
	return GLOB.admin_state

/datum/lag_switch_menu/ui_close()
	qdel(src)

/datum/lag_switch_menu/ui_data(mob/user)
	var/list/data = list()
	data["dead_keyloop"] = SSlag_switch.measures[DISABLE_DEAD_KEYLOOP]
	data["ghost_zoom_tray"] = SSlag_switch.measures[DISABLE_GHOST_ZOOM_TRAY]
	data["runechat"] = SSlag_switch.measures[DISABLE_RUNECHAT]
	data["icon2html"] = SSlag_switch.measures[DISABLE_USR_ICON2HTML]
	data["observerjobs"] = SSlag_switch.measures[DISABLE_NON_OBSJOBS]
	data["slowmodesay"] = SSlag_switch.measures[SLOWMODE_SAY]
	data["parallax"] = SSlag_switch.measures[DISABLE_PARALLAX]
	data["footsteps"] = SSlag_switch.measures[DISABLE_FOOTSTEPS]
	return data

/datum/lag_switch_menu/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	switch(action)
		if("toggle_keyloop")
			SSlag_switch.measures[DISABLE_DEAD_KEYLOOP] ? SSlag_switch.set_measure(DISABLE_DEAD_KEYLOOP, 0) : SSlag_switch.set_measure(DISABLE_DEAD_KEYLOOP, 1)
		if("toggle_zoomtray")
			SSlag_switch.measures[DISABLE_GHOST_ZOOM_TRAY] ? SSlag_switch.set_measure(DISABLE_GHOST_ZOOM_TRAY, 0) : SSlag_switch.set_measure(DISABLE_GHOST_ZOOM_TRAY, 1)
		if("toggle_runechat")
			SSlag_switch.measures[DISABLE_RUNECHAT] ? SSlag_switch.set_measure(DISABLE_RUNECHAT, 0) : SSlag_switch.set_measure(DISABLE_RUNECHAT, 1)
		if("toggle_icon2html")
			SSlag_switch.measures[DISABLE_USR_ICON2HTML] ? SSlag_switch.set_measure(DISABLE_USR_ICON2HTML, 0) : SSlag_switch.set_measure(DISABLE_USR_ICON2HTML, 1)
		if("toggle_observerjobs")
			SSlag_switch.measures[DISABLE_NON_OBSJOBS] ? SSlag_switch.set_measure(DISABLE_NON_OBSJOBS, 0) : SSlag_switch.set_measure(DISABLE_NON_OBSJOBS, 1)
		if("toggle_slowmodesay")
			SSlag_switch.measures[SLOWMODE_SAY] ? SSlag_switch.set_measure(SLOWMODE_SAY, 0) : SSlag_switch.set_measure(SLOWMODE_SAY, 1)
		if("toggle_parallax")
			SSlag_switch.measures[DISABLE_PARALLAX] ? SSlag_switch.set_measure(DISABLE_PARALLAX, 0) : SSlag_switch.set_measure(DISABLE_PARALLAX, 1)
		if("toggle_footsteps")
			SSlag_switch.measures[DISABLE_FOOTSTEPS] ? SSlag_switch.set_measure(DISABLE_FOOTSTEPS, 0) : SSlag_switch.set_measure(DISABLE_FOOTSTEPS, 1)
		if("enable_all")
			SSlag_switch.set_all_measures(1)
		if("disable_all")
			SSlag_switch.set_all_measures(0)
