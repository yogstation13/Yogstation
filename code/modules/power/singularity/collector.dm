// Operation modes
#define POWER "power"
#define SCIENCE "research"
#define MONEY "money"

// stored_power += (pulse_strength-RAD_COLLECTOR_EFFICIENCY)*RAD_COLLECTOR_COEFFICIENT
#define RAD_COLLECTOR_EFFICIENCY 80 	// radiation needs to be over this amount to get power
#define RAD_COLLECTOR_COEFFICIENT 100
#define RAD_COLLECTOR_STORED_OUT 0.1	// (this*100)% of stored power outputted per tick. Doesn't actualy change output total, lower numbers just means collectors output for longer in absence of a source
#define RAD_COLLECTOR_MINING_CONVERSION_RATE 0.000125 //This is gonna need a lot of tweaking to get right. This is the number used to calculate the conversion of watts to research points per process()
#define RAD_COLLECTOR_OUTPUT min(stored_power, (stored_power*RAD_COLLECTOR_STORED_OUT)+1000) //Produces at least 1000 watts if it has more than that stored

/obj/machinery/power/rad_collector
	name = "Radiation Collector Array"
	desc = "A device which uses Hawking Radiation and plasma to produce power."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "ca"
	anchored = FALSE
	density = TRUE
	req_access = list(ACCESS_ENGINE_EQUIP)
	max_integrity = 350
	integrity_failure = 80
	circuit = /obj/item/circuitboard/machine/rad_collector
	rad_insulation = RAD_EXTREME_INSULATION
	/// How much power is stored in its buffer
	var/stored_power = 0
	/// Is it on
	var/active = FALSE
	// Are the controls and tanks locked
	var/locked = FALSE
	/// use modifier for gas use
	var/drainratio = 1
	/// How much gas to drain
	var/drain = 0.01
	/// What is it producing
	var/mode = POWER
	/// What gasses are we using
	var/list/using = list(/datum/gas/plasma)
	/// Gasses we give
	var/list/giving = list(/datum/gas/tritium = 1)
	/// Last output used to calculate per minute
	var/last_output = 0

	var/obj/item/radio/radio
	var/obj/item/tank/internals/plasma/loaded_tank = null

/obj/machinery/power/rad_collector/Initialize(mapload)
	. = ..()

	radio = new(src)
	radio.keyslot = new /obj/item/encryptionkey/headset_eng
	radio.subspace_transmission = TRUE
	radio.canhear_range = 0
	radio.recalculateChannels()

/obj/machinery/power/rad_collector/anchored
	anchored = TRUE

/obj/machinery/power/rad_collector/Destroy()
	QDEL_NULL(radio)
	return ..()

/obj/machinery/power/rad_collector/process()
	if(!loaded_tank || !active)
		return
	var/gasdrained = drain*drainratio
	for(var/gasID in using) // Preliminary check before doing it again
		if(loaded_tank.air_contents.get_moles(gasID) < gasdrained)
			investigate_log("<font color='red'>out of fuel</font>.", INVESTIGATE_SINGULO)
			investigate_log("<font color='red'>out of fuel</font>.", INVESTIGATE_SUPERMATTER) // yogs - so supermatter investigate is useful
			playsound(src, 'sound/machines/ding.ogg', 50, 1)
			var/area/A = get_area(loc)
			var/msg = "Plasma depleted in [A.map_name], replacement tank required."
			radio.talk_into(src, msg, RADIO_CHANNEL_ENGINEERING)
			eject()

	for(var/gasID in using)
		loaded_tank.air_contents.adjust_moles(gasID, -gasdrained)
	
	for(var/gasID in giving)
		loaded_tank.air_contents.adjust_moles(gasID, giving[gasID]*gasdrained)

	var/output = RAD_COLLECTOR_OUTPUT
	switch(mode) // Now handle the special interactions
		if(POWER)
			add_avail(output)
			stored_power -= output
			last_output = output

		if(SCIENCE)
			if(is_station_level(z) && SSresearch.science_tech)
				SSresearch.science_tech.add_point_type(TECHWEB_POINT_TYPE_DEFAULT, output*RAD_COLLECTOR_MINING_CONVERSION_RATE)
				stored_power -= output
				var/datum/bank_account/D = SSeconomy.get_dep_account(ACCOUNT_ENG)
				if(D)
					D.adjust_money(output*RAD_COLLECTOR_MINING_CONVERSION_RATE)
					last_output = output*RAD_COLLECTOR_MINING_CONVERSION_RATE

		if(MONEY)
			if(is_station_level(z))
				var/datum/bank_account/D = SSeconomy.get_dep_account(ACCOUNT_CAR)
				if(D)
					var/payout = output/8000
					stored_power -= min(payout*20000, stored_power)
					D.adjust_money(payout)
					last_output = payout

/obj/machinery/power/rad_collector/interact(mob/user)
	if(anchored)
		if(!src.locked)
			toggle_power()
			user.visible_message("[user.name] turns the [src.name] [active? "on":"off"].", \
			span_notice("You turn the [src.name] [active? "on":"off"]."))
			//yogs start -- fixes runtime with empty rad collectors
			var/fuel = 0
			if(loaded_tank)
				fuel = loaded_tank.air_contents.get_moles(/datum/gas/plasma)
			//yogs end
			investigate_log("turned [active?"<font color='green'>on</font>":"<font color='red'>off</font>"] by [key_name(user)]. [loaded_tank?"Fuel: [round(fuel/0.29)]%":"<font color='red'>It is empty</font>"].", INVESTIGATE_SINGULO)
			investigate_log("turned [active?"<font color='green'>on</font>":"<font color='red'>off</font>"] by [key_name(user)]. [loaded_tank?"Fuel: [round(fuel/0.29)]%":"<font color='red'>It is empty</font>"].", INVESTIGATE_SUPERMATTER) // yogs - so supermatter investigate is useful
			return
		else
			to_chat(user, span_warning("The controls are locked!"))
			return

/obj/machinery/power/rad_collector/can_be_unfasten_wrench(mob/user, silent)
	if(loaded_tank)
		if(!silent)
			to_chat(user, span_warning("Remove the plasma tank first!"))
		return FAILED_UNFASTEN
	return ..()

/obj/machinery/power/rad_collector/default_unfasten_wrench(mob/user, obj/item/I, time = 20)
	. = ..()
	if(. == SUCCESSFUL_UNFASTEN)
		if(anchored)
			connect_to_network()
		else
			disconnect_from_network()

/obj/machinery/power/rad_collector/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/tank/internals/plasma))
		if(!anchored)
			to_chat(user, span_warning("[src] needs to be secured to the floor first!"))
			return TRUE
		if(loaded_tank)
			to_chat(user, span_warning("There's already a plasma tank loaded!"))
			return TRUE
		if(panel_open)
			to_chat(user, span_warning("Close the maintenance panel first!"))
			return TRUE
		if(!user.transferItemToLoc(W, src))
			return
		loaded_tank = W
		update_icon()
	else if(W.GetID())
		if(togglelock(user))
			return TRUE
	else
		return ..()

/obj/machinery/power/rad_collector/MouseDrop_T(atom/dropping, mob/user)
	if(istype(dropping, /obj/item/tank/internals/plasma))
		attackby(dropping, user)
	else
		..()

/obj/machinery/power/rad_collector/proc/togglelock(mob/user)
	if(!user.canUseTopic(src, BE_CLOSE))
		return
	if(allowed(user))
		if(active)
			locked = !locked
			to_chat(user, span_notice("You [locked ? "lock" : "unlock"] the controls."))
			return TRUE
		else
			to_chat(user, span_warning("The controls can only be locked when \the [src] is active!"))
	else
		to_chat(user, span_danger("Access denied."))

/obj/machinery/power/rad_collector/AltClick(mob/user)
	if(!user.canUseTopic(src, BE_CLOSE) || issilicon(user))
		return
	togglelock(user)

/obj/machinery/power/rad_collector/wrench_act(mob/living/user, obj/item/I)
	if(!(default_unfasten_wrench(user, I)))
		return FALSE
	return TRUE

/obj/machinery/power/rad_collector/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE // No afterattacks
	if(..())
		return
	if(loaded_tank)
		to_chat(user, "<span class='warning'>Remove the plasma tank first!</span>")
		return
	if(!(default_deconstruction_screwdriver(user, icon_state, icon_state, I)))
		return FALSE // If it returns false probably meant to attack it

/obj/machinery/power/rad_collector/crowbar_act(mob/living/user, obj/item/I)
	. = TRUE // Prevents afterattacks
	if(loaded_tank)
		if(locked)
			to_chat(user, "<span class='warning'>The controls are locked!</span>")
			return
		eject()
	if(default_deconstruction_crowbar(I))
		return
	to_chat(user, "<span class='warning'>There isn't a tank loaded!</span>")

/obj/machinery/power/rad_collector/multitool_act(mob/living/user, obj/item/I)
	. = TRUE // No afterattack
	if(locked)
		to_chat(user, "<span class='warning'>[src] is locked!</span>")
		return
	if(active)
		to_chat(user, "<span class='warning'>[src] is currently active, producing [mode].</span>")
		return

	var/choice = input(user,"Select a mode","Mode Selection:",null) as null|anything in list(POWER, SCIENCE, MONEY)
	if(!choice)
		return
	switch(choice)
		if(POWER)
			if(!powernet)
				to_chat(user, "<span class='warning'>[src] isn't connected to a powernet!</span>")
				return
			mode = POWER
			using = list(/datum/gas/plasma)
			giving = list(/datum/gas/tritium = 1)
		if(SCIENCE)
			if(!is_station_level(z) && !SSresearch.science_tech)
				to_chat(user, "<span class='warning'>[src] isn't linked to a research system!</span>")
				return // Dont switch over
			mode = SCIENCE
			using = list(/datum/gas/tritium, /datum/gas/oxygen)
			giving = list(/datum/gas/carbon_dioxide = 2) // Conservation of mass
		if(MONEY)
			var/datum/bank_account/D = SSeconomy.get_dep_account(ACCOUNT_CAR)
			if(!D)
				to_chat(user, "<span class='warning'>[src] couldn't find the cargo budget!</span>")
				return // Dont switch over
			mode = MONEY
			using = list(/datum/gas/plasma)
			giving = list(/datum/gas/tritium = 0.5) // money

	to_chat(user, "<span class='warning'>You set the [src] mode to [mode] production.</span>")

/obj/machinery/power/rad_collector/analyzer_act(mob/living/user, obj/item/I)
	if(loaded_tank)
		loaded_tank.analyzer_act(user, I)

/obj/machinery/power/rad_collector/examine(mob/user)
	. = ..()
	if(active)
		if(mode == POWER)
			. += "<span class='notice'>[src]'s display states that it has stored <b>[DisplayPower(stored_power)]</b>, and processing <b>[DisplayPower(RAD_COLLECTOR_OUTPUT)]</b>.</span>"
		else if(mode == SCIENCE)
			. += "<span class='notice'>[src]'s display states that it has stored a total of <b>[stored_power*RAD_COLLECTOR_MINING_CONVERSION_RATE]</b>, and producing [last_output*60] research points per minute.</span>"
		else if(mode == MONEY)
			. += "<span class='notice'>[src]'s display states that it has stored a total of <b>[stored_power*RAD_COLLECTOR_MINING_CONVERSION_RATE] credits</b>, and producing [last_output*60] credits per minute.</span>"
	else
		if(mode == POWER)
			. += "<span class='notice'><b>[src]'s display displays the words:</b> \"Power production mode. Please insert <b>Plasma</b>. Use a multitool to change production modes.\"</span>"
		else if(mode == SCIENCE)
			. += "<span class='notice'><b>[src]'s display displays the words:</b> \"Research point production mode. Please insert <b>Tritium</b> and <b>Oxygen</b>. Use a multitool to change production modes.\"</span>"
		else if(mode == MONEY)
			. += "<span class='notice'><b>[src]'s display displays the words:</b> \"Money production mode. Please insert <b>Plasma</b>. Use a multitool to change production modes.\"</span>"

/obj/machinery/power/rad_collector/obj_break(damage_flag)
	. = ..()
	if(.)
		eject()

/obj/machinery/power/rad_collector/proc/eject()
	locked = FALSE
	var/obj/item/tank/internals/plasma/Z = src.loaded_tank
	if (!Z)
		return
	Z.forceMove(drop_location())
	Z.layer = initial(Z.layer)
	Z.plane = initial(Z.plane)
	src.loaded_tank = null
	if(active)
		toggle_power()
	else
		update_icon()

/obj/machinery/power/rad_collector/rad_act(pulse_strength)
	. = ..()
	if(loaded_tank && active && pulse_strength > RAD_COLLECTOR_EFFICIENCY)
		stored_power += (pulse_strength-RAD_COLLECTOR_EFFICIENCY)*RAD_COLLECTOR_COEFFICIENT

/obj/machinery/power/rad_collector/update_icon()
	cut_overlays()
	if(loaded_tank)
		add_overlay("ptank")
	if(stat & (NOPOWER|BROKEN))
		return
	if(active)
		add_overlay("on")


/obj/machinery/power/rad_collector/proc/toggle_power()
	active = !active
	if(active)
		icon_state = "ca_on"
		flick("ca_active", src)
	else
		icon_state = "ca"
		flick("ca_deactive", src)
	update_icon()

#undef RAD_COLLECTOR_EFFICIENCY
#undef RAD_COLLECTOR_COEFFICIENT
#undef RAD_COLLECTOR_STORED_OUT
#undef RAD_COLLECTOR_MINING_CONVERSION_RATE
#undef RAD_COLLECTOR_OUTPUT
#undef POWER
#undef SCIENCE
#undef MONEY
