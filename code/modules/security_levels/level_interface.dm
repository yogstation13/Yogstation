/obj/machinery/level_interface
	name = "security level interface"
	desc = "A wall-mounted computer used for interfacing with security levels remotely."
	icon = 'icons/obj/modular_telescreen.dmi'
	icon_state = "telescreen"

	light_system = STATIC_LIGHT
	light_range = 2
	light_power = 1
	light_color = LIGHT_COLOR_BLUE

	var/list/default_access
	var/list/emergency_access

	var/obj/item/radio/radio
	var/radio_key = /obj/item/encryptionkey/heads/hos
	var/sec_freq = RADIO_CHANNEL_SECURITY
	var/command_freq = RADIO_CHANNEL_COMMAND

/obj/machinery/level_interface/Initialize(mapload)
	. = ..()
	default_access = list(ACCESS_ARMORY)
	emergency_access = list(ACCESS_SECURITY)
	radio = new(src)
	radio.keyslot = new radio_key
	radio.subspace_transmission = TRUE
	radio.listening = FALSE
	radio.independent = TRUE
	radio.recalculateChannels()
	RegisterSignal(SSsecurity_level, COMSIG_SECURITY_LEVEL_CHANGED, PROC_REF(update_security_level))

/obj/machinery/level_interface/proc/update_security_level()
	update_appearance(UPDATE_ICON)

/obj/machinery/level_interface/update_icon(updates=ALL)
	. = ..()
	if(!is_operational())
		set_light_on(FALSE)
	else
		set_light_on(TRUE)

/obj/machinery/level_interface/update_overlays()
	. = ..()
	switch(SSsecurity_level.get_current_level_as_number())
		if(SEC_LEVEL_GREEN)
			. += "alert-level-green"
		if(SEC_LEVEL_BLUE)
			. += "alert-level-blue"
		if(SEC_LEVEL_RED)
			. += "alert-level-red"
		if(SEC_LEVEL_GAMMA)
			. += "alert-level-gamma"
		if(SEC_LEVEL_EPSILON)
			. += "alert-level-epsilon"
		if(SEC_LEVEL_DELTA)
			. += "alert-level-delta"

/obj/machinery/level_interface/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!is_operational())
		return
	if(!ui)
		ui = new(user, src, "LevelInterface", name)
		ui.open()

/obj/machinery/level_interface/ui_data(mob/user)
	var/list/data = ..()
	data["alertLevel"] = SSsecurity_level.get_current_level_as_number()
	return data

/obj/machinery/level_interface/ui_act(action, list/params, mob/user)
	. = ..()
	if(..())
		return TRUE

	/// If there is a warden or HoS, we can delegate them to be able to swap alerts
	/// If not, let the officers do it
	req_one_access = emergency_access
	for(var/datum/data/record/gen_record in GLOB.data_core.general)
		if(gen_record.fields["real_rank"] == "Head of Security" || gen_record.fields["real_rank"] == "Warden")
			req_one_access = default_access
			break

	switch(action)
		if("set_level")
			if(SSsecurity_level.get_current_level_as_number() >= SEC_LEVEL_GAMMA)
				balloon_alert(usr, "Nanotrasen override in progress!")
				return TRUE
			if(!check_access(usr.get_idcard()))
				balloon_alert(usr, "no access!")
				return TRUE
			var/alert_level = params["level_number"]
			if(!isnum(alert_level))
				return TRUE
			if(!SSsecurity_level.number_level_to_text(alert_level))
				return TRUE
			if(SSsecurity_level.get_current_level_as_number() == alert_level)
				return TRUE
			for(var/obj/machinery/computer/communications/comms_console in GLOB.machines)
				if(!COOLDOWN_FINISHED(comms_console, important_action_cooldown))
					balloon_alert(usr, "on cooldown!")
					to_chat(usr, span_warning("The system is not able to change the security alert level more than once per minute, please wait."))
					return TRUE
				COOLDOWN_START(comms_console, important_action_cooldown, IMPORTANT_ACTION_COOLDOWN)
				break
			SSsecurity_level.set_level(alert_level)
			var/username = "ERR_UNK"
			var/obj/item/card/id/id_card = usr.get_idcard()
			if(istype(id_card) && id_card && id_card.registered_name)
				username = id_card.registered_name
			radio.talk_into(src, "Security level set to [uppertext(SSsecurity_level.number_level_to_text(alert_level))] by [username].", sec_freq)
			radio.talk_into(src, "Security level set to [uppertext(SSsecurity_level.number_level_to_text(alert_level))] by [username].", command_freq)
			return TRUE
