GLOBAL_LIST_EMPTY(GPS_list)
/obj/item/gps
	name = "global positioning system"
	desc = "Helping lost spacemen find their way through the planets since 2016."
	icon = 'icons/obj/telescience.dmi'
	icon_state = "gps-c"
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	obj_flags = UNIQUE_RENAME
	var/gpstag = "COM0"
	var/emped = FALSE
	var/tracking = TRUE
	var/updating = TRUE //Automatic updating of GPS list. Can be set to manual by user.
	var/global_mode = TRUE //If disabled, only GPS signals of the same Z level are shown

/obj/item/gps/examine(mob/user)
	. = ..()
	. += span_notice("Alt-click to switch it [tracking ? "off":"on"].")

/obj/item/gps/Initialize()
	. = ..()
	GLOB.GPS_list += src
	name = "global positioning system ([gpstag])"
	if(tracking) //Some roundstart GPS are off.
		add_overlay("working")

/obj/item/gps/Destroy()
	GLOB.GPS_list -= src
	return ..()

/obj/item/gps/emp_act(severity)
	. = ..()
	if (. & EMP_PROTECT_SELF)
		return
	emped = TRUE
	cut_overlay("working")
	add_overlay("emp")
	addtimer(CALLBACK(src, .proc/reboot), 300, TIMER_UNIQUE|TIMER_OVERRIDE) //if a new EMP happens, remove the old timer so it doesn't reactivate early
	SStgui.close_uis(src) //Close the UI control if it is open.

/obj/item/gps/proc/reboot()
	emped = FALSE
	cut_overlay("emp")
	add_overlay("working")

/obj/item/gps/AltClick(mob/user)
	if(!user.canUseTopic(src, BE_CLOSE))
		return
	toggletracking(user)

/obj/item/gps/proc/toggletracking(mob/user)
	if(!user.canUseTopic(src, BE_CLOSE))
		return //user not valid to use gps
	if(emped)
		to_chat(user, "It's busted!")
		return
	if(tracking)
		cut_overlay("working")
		to_chat(user, "[src] is no longer tracking, or visible to other GPS devices.")
		tracking = FALSE
	else
		add_overlay("working")
		to_chat(user, "[src] is now tracking, and visible to other GPS devices.")
		tracking = TRUE


/obj/item/gps/ui_interact(mob/user, datum/tgui/ui) // Remember to use the appropriate state.
	if(emped)
		to_chat(user, "[src] fizzles weakly.")
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		// Variable window height, depending on how many GPS units there are
		// to show
		ui = new(user, src, "Gps") //width, height
		ui.open()

	ui.set_autoupdate(updating)


/obj/item/gps/ui_data(mob/user)
	var/list/data = list()
	data["power"] = tracking
	data["tag"] = gpstag
	data["updating"] = updating
	data["globalmode"] = global_mode
	if(!tracking || emped) //Do not bother scanning if the GPS is off or EMPed
		return data

	var/turf/curr = get_turf_global(src) // yogs - get_turf_global instead of get_turf
	data["currentArea"] = "[get_area_name(curr, TRUE)]"
	data["currentCoords"] = "[curr.x], [curr.y], [curr.z]"

	var/list/signals = list()
	data["signals"] = list()

	for(var/gps in GLOB.GPS_list)
		var/obj/item/gps/G = gps
		if(G.emped || !G.tracking || G == src)
			continue
		var/turf/pos = get_turf_global(G) // yogs - get_turf_global instead of get_turf
		if(!pos)
			continue
		if(!global_mode && pos.z != curr.z)
			continue
		var/list/signal = list()
		signal["entrytag"] = G.gpstag //Name or 'tag' of the GPS
		signal["coords"] = "[pos.x], [pos.y], [pos.z]"
		if(pos.z == curr.z) //Distance/Direction calculations for same z-level only
			signal["dist"] = max(get_dist(curr, pos), 0) //Distance between the src and remote GPS turfs
			signal["degrees"] = round(Get_Angle(curr, pos)) //0-360 degree directional bearing, for more precision.

		signals += list(signal) //Add this signal to the list of signals
	data["signals"] = signals
	return data



/obj/item/gps/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("rename")
			var/a = stripped_input(usr, "Please enter desired tag.", name, gpstag, 20)
			gpstag = a
			. = TRUE
			name = "global positioning system ([gpstag])"

		if("power")
			toggletracking(usr)
			. = TRUE
		if("updating")
			updating = !updating
			. = TRUE
		if("globalmode")
			global_mode = !global_mode
			. = TRUE


/obj/item/gps/science
	icon_state = "gps-s"
	gpstag = "SCI0"

/obj/item/gps/engineering
	icon_state = "gps-e"
	gpstag = "ENG0"

/obj/item/gps/mining
	icon_state = "gps-m"
	gpstag = "MINE0"
	desc = "A positioning system helpful for rescuing trapped or injured miners, keeping one on you at all times while mining might just save your life."

/obj/item/gps/cyborg
	icon_state = "gps-b"
	gpstag = "BORG0"
	desc = "A mining cyborg internal positioning system. Used as a recovery beacon for damaged cyborg assets, or a collaboration tool for mining teams."

/obj/item/gps/cyborg/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CYBORG_ITEM_TRAIT)

/obj/item/gps/internal
	icon_state = null
	item_flags = ABSTRACT
	gpstag = "Eerie Signal"
	desc = "Report to a coder immediately."
	invisibility = INVISIBILITY_MAXIMUM

/obj/item/gps/mining/internal
	icon_state = "gps-m"
	gpstag = "MINER"
	desc = "A positioning system helpful for rescuing trapped or injured miners, keeping one on you at all times while mining might just save your life."

/obj/item/gps/internal/base
	gpstag = "NT_AUX"
	desc = "A homing signal from Nanotrasen's mining base."

/obj/item/gps/visible_debug
	name = "visible GPS"
	gpstag = "ADMIN"
	desc = "This admin-spawn GPS unit leaves the coordinates visible \
		on any turf that it passes over, for debugging. Especially useful \
		for marking the area around the transition edges."
	var/list/turf/tagged

/obj/item/gps/visible_debug/Initialize()
	. = ..()
	tagged = list()
	START_PROCESSING(SSfastprocess, src)

/obj/item/gps/visible_debug/process()
	var/turf/T = get_turf(src)
	if(T)
		// I assume it's faster to color,tag and OR the turf in, rather
		// then checking if its there
		T.color = RANDOM_COLOUR
		T.maptext = "[T.x],[T.y],[T.z]"
		tagged |= T

/obj/item/gps/visible_debug/proc/clear()
	while(tagged.len)
		var/turf/T = pop(tagged)
		T.color = initial(T.color)
		T.maptext = initial(T.maptext)

/obj/item/gps/visible_debug/Destroy()
	if(tagged)
		clear()
	tagged = null
	STOP_PROCESSING(SSfastprocess, src)
	. = ..()

/**
  * # Pirate GPS
  *
  *	Pirate GPS used for targeting by the [Blue Space Artillery] [/obj/machinery/computer/bsa_control]
  *
  * When shot at, relays the fact that it was shot at to [the pirate event] [/datum/round_event/pirates] so it cancels
  */

/obj/item/gps/pirate

/**
  *	Initializes the GPS with the correct name, taken from the pirate ship's name
  *	If no name is provided, it'll default to "Jolly Robuster"
  *
  *	Arguments:
  *	* ship_name - The name that of the ship that we're pretending to be, defaults to "Jolly Robuster"
  */
/obj/item/gps/pirate/Initialize(ship_name = "Jolly Robuster")
	.=..()
	if(ship_name)
		name = ship_name
		gpstag = ship_name

/**
  * Relays that the [Blue Space Artillery] [/obj/machinery/computer/bsa_control] has shot the ship to the event, then qdels
  */
/obj/item/gps/pirate/proc/on_shoot()
	var/datum/round_event/pirates/r = locate() in SSevents.running
	r?.shot_down()
	qdel(src)
