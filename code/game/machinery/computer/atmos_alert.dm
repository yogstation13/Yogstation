/obj/machinery/computer/atmos_alert
	name = "atmospheric alert console"
	desc = "Used to monitor the station's air alarms."
	circuit = /obj/item/circuitboard/computer/atmos_alert
	icon_screen = "alert:0"
	icon_keyboard = "atmos_key"
	var/list/priority_alarms = list()
	var/list/minor_alarms = list()
	var/receive_frequency = FREQ_ATMOS_ALARMS
	var/datum/radio_frequency/radio_connection

	light_color = LIGHT_COLOR_CYAN

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

	data["priority"] = list()
	for(var/zone in priority_alarms)
		data["priority"] += zone
	data["minor"] = list()
	for(var/zone in minor_alarms)
		data["minor"] += zone

	return data

/obj/machinery/computer/atmos_alert/ui_act(action, datum/params/params)
	if(..())
		return
	switch(action)
		if("clear")
			var/priority_zone = params.get_text_in_list("zone", priority_alarms)
			if(priority_zone)
				to_chat(usr, "Priority alarm for [priority_zone] cleared.")
				priority_alarms -= priority_zone
				. = TRUE
			var/minor_zone = params.get_text_in_list("zone", minor_alarms)
			if(zone in minor_alarms)
				to_chat(usr, "Minor alarm for [minor_zone] cleared.")
				minor_alarms -= minor_zone
				. = TRUE
	update_icon()

/obj/machinery/computer/atmos_alert/proc/set_frequency(new_frequency)
	SSradio.remove_object(src, receive_frequency)
	receive_frequency = new_frequency
	radio_connection = SSradio.add_object(src, receive_frequency, RADIO_ATMOSIA)

/obj/machinery/computer/atmos_alert/receive_signal(datum/signal/signal)
	if(!signal)
		return

	var/zone = signal.data["zone"]
	var/severity = signal.data["alert"]

	if(!zone || !severity)
		return

	minor_alarms -= zone
	priority_alarms -= zone
	if(severity == "severe")
		priority_alarms += zone
	else if (severity == "minor")
		minor_alarms += zone
	update_icon()
	return

/obj/machinery/computer/atmos_alert/update_icon()
	..()
	if(stat & (NOPOWER|BROKEN))
		return
	if(priority_alarms.len)
		add_overlay("alert:2")
	else if(minor_alarms.len)
		add_overlay("alert:1")
