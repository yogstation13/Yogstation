/obj/machinery/computer/station_alert
	name = "station alert console"
	desc = "Used to access the station's automated alert system."
	icon_screen = "alert:0"
	icon_keyboard = "atmos_key"
	circuit = /obj/item/circuitboard/computer/stationalert

	light_color = LIGHT_COLOR_CYAN

/obj/machinery/computer/station_alert/Initialize(mapload)
	. = ..()
	GLOB.alert_consoles += src

/obj/machinery/computer/station_alert/Destroy()
	GLOB.alert_consoles -= src
	return ..()

/obj/machinery/computer/station_alert/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "StationAlertConsole", name)
		ui.open()

/obj/machinery/computer/station_alert/ui_data(mob/user)
	var/list/data = list()

	data["alarms"] = list()
	for(var/class in GLOB.alarms)
		data["alarms"][class] = list()
		for(var/area in GLOB.alarms[class])
			data["alarms"][class] += area

	return data

/obj/machinery/computer/station_alert/proc/triggerAlarm(class, area/A, O, obj/source)
	if(source.z != z)
		return
	if(stat & (BROKEN))
		return

	var/list/L = GLOB.alarms[class]
	for(var/I in L)
		if (I == A.name)
			var/list/alarm = L[I]
			var/list/sources = alarm[3]
			if (!(source in sources))
				sources += source
			update_appearance(UPDATE_ICON)
			return 1
	var/obj/machinery/camera/C = null
	var/list/CL = null
	if(O && islist(O))
		CL = O
		if (CL.len == 1)
			C = CL[1]
	else if(O && istype(O, /obj/machinery/camera))
		C = O
	L[A.name] = list(A, (C ? C : O), list(source))
	update_appearance(UPDATE_ICON)
	return 1


/obj/machinery/computer/station_alert/proc/cancelAlarm(class, area/A, obj/origin)
	if(stat & (BROKEN))
		return
	var/list/L = GLOB.alarms[class]
	var/cleared = 0
	for (var/I in L)
		if (I == A.name)
			var/list/alarm = L[I]
			var/list/srcs  = alarm[3]
			if (origin in srcs)
				srcs -= origin
			if (srcs.len == 0)
				cleared = 1
				L -= I
	update_appearance(UPDATE_ICON)
	return !cleared

/obj/machinery/computer/station_alert/update_overlays()
	. = ..()
	if(stat & (NOPOWER|BROKEN))
		return
	var/active_alarms = FALSE
	for(var/cat in GLOB.alarms)
		var/list/L = GLOB.alarms[cat]
		if(L.len)
			active_alarms = TRUE
	if(active_alarms)
		. += "alert:2"
