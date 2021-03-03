#define SCIENCE_AMOUNT 500 // How much science to generate per minute

/obj/machinery/sci_probe
	name = "Lavaland Probe Mainframe"
	desc = "A machine consisting of Bluespace relays and a fauna analyzing mechanism, the L.P.M. tracks megafauna and generates science on them.\n"
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "RD-server-on"
	idle_power_usage = 500
	active_power_usage = 5000
	power_channel = EQUIP
	density = TRUE
	var/obj/item/radio/radio
	var/radio_freq = FREQ_SCIENCE
	var/setup = FALSE // Machine Status
	var/mobs = 0 // Decorational UI Var. used by findmobs()
	var/calibration = 1 // In percentage so 100%
	var/icon_state_on = "RD-server-on"
	var/icon_state_open = "server_t"

/obj/machinery/sci_probe/Initialize()
	. = ..()
	radio = new /obj/item/radio(src)
	radio.frequency = radio_freq
	update_icon()

/obj/machinery/sci_probe/Destroy()
	QDEL_NULL(radio)
	return ..()

/obj/machinery/sci_probe/update_icon()
	if(panel_open)
		icon_state = "server_t"
		return
	if (stat & EMPED || stat & NOPOWER || !setup)
		icon_state = "RD-server-off"
		return
	icon_state = "RD-server-on"

/obj/machinery/sci_probe/attackby(obj/item/O, mob/user, params)
	if(default_deconstruction_screwdriver(user, icon_state_open, icon_state_on, O))
		updateUsrDialog()
		return TRUE
	update_icon()

/obj/machinery/sci_probe/examine(mob/user)
	. = ..()
	. += "It is using [active_power_usage/1000]kW of power and producing [round(SCIENCE_AMOUNT*calibration)] research points per minute.\n"
	if(panel_open)
		. += "The panel is open.\n"

/obj/machinery/sci_probe/ui_state(mob/user)
	return GLOB.not_incapacitated_state

/obj/machinery/sci_probe/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SciProbe", name)
		ui.open()

/obj/machinery/sci_probe/ui_data(mob/user)
	var/list/data = list()
	data["probestatus"] = setup
	data["foundmobs"] = mobs
	data["science"] = SCIENCE_AMOUNT
	data["calibration"] = calibration
	return data

/obj/machinery/sci_probe/ui_act(action, params)
	if(..())
		return

	switch(action)
		if("status")
			setup = !setup
			canoperate()
			if(setup)
				radio.talk_into(src, "L.P.M Engaged. Producing science from local megafauna", radio_freq)
		if("calibrate")
			calibration = initial(calibration)

	update_icon()

/obj/machinery/sci_probe/process()
	canoperate() // Check if it can operate
	if(setup) // Avoid needless processing
		var/ssadjust = 1 MINUTES/SSmachines.wait // This is the science adjustment factor. This allows science generation to stay the same if the subsystem firerate changes
		mobs = findmobs() // Decorational Display
		calibration = clamp((calibration -= 0.0005), 0, initial(calibration)) // Can't just be a cheap science generator
		SSresearch.science_tech.add_point_type(TECHWEB_POINT_TYPE_DEFAULT, (SCIENCE_AMOUNT/ssadjust)*calibration) // Add Science

/obj/machinery/sci_probe/proc/findmobs()
	var/foundmobs = 0
	if(!canoperate()) // Shows detected mobs as 0 if not on lavaland
		return
	for(var/mob/living/simple_animal/hostile/megafauna/S in GLOB.mob_list)
		if(S.stat == DEAD)
			continue
		if(!is_mining_level(S.z))
			continue
		foundmobs += 1
	return foundmobs

/obj/machinery/sci_probe/proc/canoperate() // Code simplification
	var/turf/T = src.loc
	if(!is_mining_level(T.z)) // If it somehow moves
		if(setup) // Anti-Spam
			say("Warning: L.P.M is not on lavaland!")
		setup = FALSE // Turn machine off
		mobs = 0
		return FALSE
	return TRUE
