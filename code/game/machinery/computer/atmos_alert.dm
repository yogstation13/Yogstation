/obj/machinery/computer/atmos_alert
	name = "atmospheric alert console"
	desc = "Used to monitor the station's air alarms."
	circuit = /obj/item/circuitboard/computer/atmos_alert
	icon_screen = "alert:0"
	icon_keyboard = "atmos_key"
	light_color = LIGHT_COLOR_CYAN

	///List of areas with a priority alarm ongoing.
	var/list/area/priority_alarms = list()
	///List of areas with a minor alarm ongoing.
	var/list/area/minor_alarms = list()

	///The radio connection the computer uses to receive signals.
	var/datum/radio_frequency/radio_connection
	///The frequency that radio_connection listens and retrieves signals from.
	var/receive_frequency = FREQ_ATMOS_ALARMS

/obj/machinery/computer/atmos_alert/Initialize(mapload)
	. = ..()
	set_frequency(receive_frequency)

/obj/machinery/computer/atmos_alert/Destroy()
	SSradio.remove_object(src, receive_frequency)
	return ..()

/obj/machinery/computer/atmos_alert/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AtmosAlertConsole", name)
		ui.open()

/obj/machinery/computer/atmos_alert/ui_data(mob/user)
	var/list/data = list()
	data["priority_alerts"] = list()
	data["minor_alerts"] = list()

	for(var/area/priority_alarm as anything in priority_alarms)
		data["priority_alerts"] += list(list(
			"name" = priority_alarm.name,
			"ref" = REF(priority_alarm),
		))

	for(var/area/minor_alarm as anything in minor_alarms)
		data["minor_alerts"] += list(list(
			"name" = minor_alarm.name,
			"ref" = REF(minor_alarm),
		))

	return data

/obj/machinery/computer/atmos_alert/ui_act(action, params)
	. = ..()
	if(.)
		return TRUE
	if(action != "clear")
		return TRUE

	var/area/zone_from_tgui = locate(params["zone_ref"]) in priority_alarms + minor_alarms
	if(!zone_from_tgui || !istype(zone_from_tgui))
		return TRUE
	
	var/obj/machinery/airalarm/found_air_alarm = locate() in zone_from_tgui
	if(found_air_alarm)
		found_air_alarm.atmos_manualOverride(TRUE)
		found_air_alarm.post_alert(0)
		priority_alarms -= zone_from_tgui
		minor_alarms -= zone_from_tgui
		balloon_alert(usr, "alarm cleared.")
		update_appearance(UPDATE_ICON)
		return TRUE

/obj/machinery/computer/atmos_alert/proc/set_frequency(new_frequency)
	SSradio.remove_object(src, receive_frequency)
	receive_frequency = new_frequency
	radio_connection = SSradio.add_object(src, receive_frequency, RADIO_ATMOSIA)

/obj/machinery/computer/atmos_alert/receive_signal(datum/signal/signal)
	if(!signal)
		return

	var/area/new_zone = signal.data["zone"]
	var/severity = signal.data["alert"]
	if(!new_zone || !istype(new_zone) || !severity)
		return

	//clear current references.
	minor_alarms -= new_zone
	priority_alarms -= new_zone

	switch(severity)
		if(ATMOS_ALARM_SEVERE)
			priority_alarms += new_zone
		if(ATMOS_ALARM_MINOR)
			minor_alarms += new_zone
	update_appearance(UPDATE_ICON)

/obj/machinery/computer/atmos_alert/update_overlays()
	. = ..()
	if(stat & (NOPOWER|BROKEN))
		return

	if(priority_alarms.len)
		. += "alert:2"
	else if(minor_alarms.len)
		. += "alert:1"
