///Max temperature allowed inside the cryotube, should break before reaching this heat
#define MAX_TEMPERATURE 4000

/// This is a visual helper that shows the occupant inside the cryo cell.
/atom/movable/visual/cryo_occupant
	icon = 'icons/obj/cryogenics.dmi'
	// Must be tall, otherwise the filter will consider this as a 32x32 tile
	// and will crop the head off.
	icon_state = "mask_bg"
	layer = ABOVE_MOB_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	pixel_y = 22
	appearance_flags = KEEP_TOGETHER
	/// The current occupant being presented
	var/mob/living/occupant

/atom/movable/visual/cryo_occupant/Initialize(mapload, obj/machinery/atmospherics/components/unary/cryo_cell/parent)
	. = ..()
	// Alpha masking
	// It will follow this as the animation goes, but that's no problem as the "mask" icon state
	// already accounts for this.
	add_filter("alpha_mask", 1, list("type" = "alpha", "icon" = icon('icons/obj/cryogenics.dmi', "mask"), "y" = -22))
	RegisterSignal(parent, COMSIG_MACHINERY_SET_OCCUPANT, PROC_REF(on_set_occupant))
	RegisterSignal(parent, COMSIG_CRYO_SET_ON, PROC_REF(on_set_on))

/// COMSIG_MACHINERY_SET_OCCUPANT callback
/atom/movable/visual/cryo_occupant/proc/on_set_occupant(datum/source, mob/living/new_occupant)
	SIGNAL_HANDLER

	if(occupant)
		vis_contents -= occupant
		occupant.vis_flags &= ~VIS_INHERIT_PLANE
		occupant.remove_traits(list(TRAIT_IMMOBILIZED, TRAIT_FORCED_STANDING), CRYO_TRAIT)
	
	occupant = new_occupant
	if(!occupant)
		return

	occupant.setDir(SOUTH)
	// We want to pull our occupant up to our plane so we look right
	occupant.vis_flags |= VIS_INHERIT_PLANE
	vis_contents += occupant
	pixel_y = 22
	occupant.add_traits(list(TRAIT_IMMOBILIZED, TRAIT_FORCED_STANDING), CRYO_TRAIT)
	occupant.set_resting(FALSE, silent = TRUE)

/// COMSIG_CRYO_SET_ON callback
/atom/movable/visual/cryo_occupant/proc/on_set_on(datum/source, on)
	SIGNAL_HANDLER

	if(on)
		animate(src, pixel_y = 24, time = 20, loop = -1)
		animate(pixel_y = 22, time = 20)
	else
		animate(src)

/// Cryo cell
/obj/machinery/atmospherics/components/unary/cryo_cell
	name = "cryo cell"
	icon = 'icons/obj/cryogenics.dmi'
	icon_state = "pod-off"
	density = TRUE
	max_integrity = 350
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 100, BOMB = 0, BIO = 100, RAD = 100, FIRE = 30, ACID = 30)
	layer = MOB_LAYER
	state_open = FALSE
	circuit = /obj/item/circuitboard/machine/cryo_tube
	pipe_flags = PIPING_ONE_PER_TURF | PIPING_DEFAULT_LAYER_ONLY
	vent_movement = NONE
	occupant_typecache = list(/mob/living/carbon, /mob/living/simple_animal)

	showpipe = FALSE

	var/autoeject = TRUE
	var/volume = 100

	var/efficiency = 1
	var/sleep_factor = 0.00125
	var/unconscious_factor = 0.001
	var/heat_capacity = 20000
	var/conduction_coefficient = 0.3

	var/obj/item/reagent_containers/glass/beaker = null
	var/reagent_transfer = 0

	var/obj/item/radio/radio
	var/radio_key = /obj/item/encryptionkey/headset_med
	var/radio_channel = RADIO_CHANNEL_MEDICAL

	/// Visual content - Occupant
	var/atom/movable/visual/cryo_occupant/occupant_vis

	var/escape_in_progress = FALSE
	var/message_cooldown
	var/breakout_time = 300
	///Cryo will continue to treat people with 0 damage but existing wounds, but will sound off when damage healing is done in case doctors want to directly treat the wounds instead
	var/treating_wounds = FALSE
	/// Cryo should notify doctors if the patient is dead, and eject them if autoeject is enabled
	var/patient_dead = FALSE
	fair_market_price = 10
	payment_department = ACCOUNT_MED

	/// Reference to the datum connector we're using to interface with the pipe network
	//var/datum/gas_machine_connector/internal_connector


/obj/machinery/atmospherics/components/unary/cryo_cell/Initialize(mapload)
	. = ..()
	initialize_directions = dir
	if(is_operational())
		begin_processing()

	radio = new(src)
	radio.keyslot = new radio_key
	radio.subspace_transmission = TRUE
	radio.canhear_range = 0
	radio.recalculateChannels()

	occupant_vis = new(null, src)
	vis_contents += occupant_vis

/obj/machinery/atmospherics/components/unary/cryo_cell/on_changed_z_level(turf/old_turf, turf/new_turf, same_z_layer, notify_contents)
	. = ..()
	if(same_z_layer)
		return
	SET_PLANE(occupant_vis, PLANE_TO_TRUE(occupant_vis.plane), new_turf)

/obj/machinery/atmospherics/components/unary/cryo_cell/set_occupant(atom/movable/new_occupant)
	. = ..()
	update_appearance()

/obj/machinery/atmospherics/components/unary/cryo_cell/Exited(atom/movable/AM, atom/newloc)
	. = ..()
	if(AM == beaker)
		beaker = null

/obj/machinery/atmospherics/components/unary/cryo_cell/on_construction()
	..(dir, dir)

/obj/machinery/atmospherics/components/unary/cryo_cell/RefreshParts()
	var/C
	for(var/obj/item/stock_parts/matter_bin/M in component_parts)
		C += M.rating

	efficiency = initial(efficiency) * C
	sleep_factor = initial(sleep_factor) * C
	unconscious_factor = initial(unconscious_factor) * C
	heat_capacity = initial(heat_capacity) / C
	conduction_coefficient = initial(conduction_coefficient) * C
	reagent_transfer = efficiency * 10 - 5 // update pause before injecting the next occupant so it doesnt end up as something ludicrous

/obj/machinery/atmospherics/components/unary/cryo_cell/examine(mob/user) //this is leaving out everything but efficiency since they follow the same idea of "better beaker, better results"
	. = ..()
	if(in_range(user, src) || isobserver(user))
		. += "<span class='notice'>The status display reads: Efficiency at <b>[efficiency*100]%</b>.</span>"

/obj/machinery/atmospherics/components/unary/cryo_cell/Destroy()
	vis_contents.Cut()

	QDEL_NULL(occupant_vis)
	QDEL_NULL(radio)
	QDEL_NULL(beaker)
	///Take the turf the cryotube is on
	var/turf/T = get_turf(src)
	if(T)
		///Take the air composition of the turf
		var/datum/gas_mixture/env = T.return_air()
		///Take the air composition inside the cryotube
		var/datum/gas_mixture/air1 = airs[1]
		env.merge(air1)
		T.air_update_turf()

	return ..()

/obj/machinery/atmospherics/components/unary/cryo_cell/contents_explosion(severity, target)
	..()
	if(beaker)
		switch(severity)
			if(EXPLODE_DEVASTATE)
				SSexplosions.high_mov_atom += beaker
			if(EXPLODE_HEAVY)
				SSexplosions.med_mov_atom += beaker
			if(EXPLODE_LIGHT)
				SSexplosions.low_mov_atom += beaker

/obj/machinery/atmospherics/components/unary/cryo_cell/handle_atom_del(atom/A)
	..()
	if(A == beaker)
		beaker = null
		updateUsrDialog()

/obj/machinery/atmospherics/components/unary/cryo_cell/on_deconstruction()
	if(occupant)
		occupant.vis_flags &= ~VIS_INHERIT_PLANE
		REMOVE_TRAIT(occupant, TRAIT_IMMOBILIZED, CRYO_TRAIT)
		REMOVE_TRAIT(occupant, TRAIT_FORCED_STANDING, CRYO_TRAIT)

	if(beaker)
		beaker.forceMove(drop_location())
		beaker = null

/obj/machinery/atmospherics/components/unary/cryo_cell/update_icon(updates=ALL)
	. = ..()
	SET_PLANE_IMPLICIT(src, initial(plane))

/obj/machinery/atmospherics/components/unary/cryo_cell/update_icon_state()
	icon_state = (state_open) ? "pod-open" : (on && is_operational()) ? "pod-on" : "pod-off"
	return ..()

/obj/machinery/atmospherics/components/unary/cryo_cell/update_layer()
	return //no updates so we don't end up on layer 4.003 and overlapping mobs

/obj/machinery/atmospherics/components/unary/cryo_cell/update_overlays()
	. = ..()
	if(panel_open)
		. += "pod-panel"
	if(state_open)
		return
	if(on && is_operational())
		. += mutable_appearance('icons/obj/cryogenics.dmi', "cover-on", ABOVE_ALL_MOB_LAYER, src, plane = ABOVE_GAME_PLANE)
	else
		. += mutable_appearance('icons/obj/cryogenics.dmi', "cover-off", ABOVE_ALL_MOB_LAYER, src, plane = ABOVE_GAME_PLANE)

/obj/machinery/atmospherics/components/unary/cryo_cell/proc/set_on(new_value)
	if(on == new_value)
		return
	SEND_SIGNAL(src, COMSIG_CRYO_SET_ON, new_value)
	. = on
	on = new_value
	update_appearance()


/obj/machinery/atmospherics/components/unary/cryo_cell/process(delta_time)
	..()

	if(!on)
		return
	if(!occupant)
		return

	var/mob/living/mob_occupant = occupant
	if(mob_occupant.on_fire)
		mob_occupant.extinguish_mob()
	if(mob_occupant.stat == DEAD) // We don't bother with dead people.
		return

	var/mob/living/carbon/C
	if(iscarbon(mob_occupant))
		C = mob_occupant

	var/robotic_limb_damage = 0 // brute and burn damage to robotic limbs
	if(iscarbon(mob_occupant))
		for(var/obj/item/bodypart/limb in C.get_damaged_bodyparts(TRUE, TRUE, FALSE, BODYPART_ROBOTIC))
			robotic_limb_damage += limb.get_damage(stamina=FALSE)

	if(mob_occupant.health >= mob_occupant.getMaxHealth() - robotic_limb_damage) // Don't bother with fully healed people. Now takes robotic limbs into account.
		var/has_cryo_wound = FALSE
		if(C && C.all_wounds)
			for(var/datum/wound/wound as anything in C.all_wounds)
				if(wound.wound_flags & ACCEPTS_CRYO)
					if(!treating_wounds) // if we have wounds and haven't already alerted the doctors we're only dealing with the wounds, let them know
						playsound(src, 'sound/machines/cryo_warning.ogg', volume) // Bug the doctors.
						var/msg = "Patient vitals fully recovered, continuing automated burn treatment."
						radio.talk_into(src, msg, radio_channel)
					has_cryo_wound = TRUE
					break

		treating_wounds = has_cryo_wound
		if(!treating_wounds)
			set_on(FALSE)
			playsound(src, 'sound/machines/cryo_warning.ogg', volume) // Bug the doctors.
			var/msg = "Patient fully restored."
			if(autoeject) // Eject if configured.
				msg += " Auto ejecting patient now."
				open_machine()
			radio.talk_into(src, msg, radio_channel)
			return

	var/datum/gas_mixture/air1 = airs[1]

	if(air1.total_moles())
		if(mob_occupant.bodytemperature < T0C) // Sleepytime. Why? More cryo magic.
			mob_occupant.Sleeping((mob_occupant.bodytemperature * sleep_factor) * 1000 * delta_time)
			mob_occupant.Unconscious((mob_occupant.bodytemperature * unconscious_factor) * 1000 * delta_time)
		if(beaker)
			if(reagent_transfer == 0) // Magically transfer reagents. Because cryo magic.
				beaker.reagents.trans_to(occupant, 1, efficiency * 0.25) // Transfer reagents.
				beaker.reagents.reaction(occupant, VAPOR)
				if(air1.get_moles(GAS_PLUOXIUM) > 5 )//Use pluoxium over oxygen
					air1.adjust_moles(GAS_PLUOXIUM, -max(0,air1.get_moles(GAS_PLUOXIUM) - 0.5 / efficiency))
				else 
					air1.adjust_moles(GAS_O2, -max(0,air1.get_moles(GAS_O2) - 2 / efficiency)) //Let's use gas for this
				if(occupant.reagents.get_reagent_amount(/datum/reagent/medicine/cryoxadone) >= 100) //prevent cryoxadone overdose
					occupant.reagents.del_reagent(/datum/reagent/medicine/cryoxadone)
					occupant.reagents.add_reagent(/datum/reagent/medicine/cryoxadone, 99)
			reagent_transfer += 0.5 * delta_time
			if(reagent_transfer >= 10 * efficiency) // Throttle reagent transfer (higher efficiency will transfer the same amount but consume less from the beaker).
				reagent_transfer = 0
		if(air1.get_moles(GAS_HEALIUM) > 1) //healium check, if theres enough we get some extra healing from our favorite pink gas.
			var/existing = mob_occupant.reagents.get_reagent_amount(/datum/reagent/healium)
			mob_occupant.reagents.add_reagent(/datum/reagent/healium, 1 - existing)
			air1.set_moles(GAS_HEALIUM, -max(0, air1.get_moles(GAS_HEALIUM) - 0.1 / efficiency))
	return 1

/obj/machinery/atmospherics/components/unary/cryo_cell/process_atmos()
	if(!on)
		return

	var/datum/gas_mixture/air1 = airs[1]

	if(!nodes[1] || !airs[1] || (air1.get_moles(GAS_O2) < 5 && air1.get_moles(GAS_PLUOXIUM) < 5)) // Turn off if the machine won't work.
		set_on(FALSE)
		return

	if(occupant)
		var/mob/living/mob_occupant = occupant
		var/cold_protection = 0
		var/temperature_delta = air1.return_temperature() - mob_occupant.bodytemperature // The only semi-realistic thing here: share temperature between the cell and the occupant.

		if(ishuman(occupant))
			var/mob/living/carbon/human/H = occupant
			cold_protection = H.get_cold_protection(air1.return_temperature())

		if(abs(temperature_delta) > 1)
			var/air_heat_capacity = air1.heat_capacity()

			var/heat = ((1 - cold_protection) * 0.1 + conduction_coefficient) * temperature_delta * (air_heat_capacity * heat_capacity / (air_heat_capacity + heat_capacity))

			air1.set_temperature(max(air1.return_temperature() - heat / air_heat_capacity, TCMB))
			mob_occupant.adjust_bodytemperature(heat / heat_capacity, TCMB)

		if(air1.get_moles(GAS_PLUOXIUM) > 5) //use pluoxium over oxygen
			air1.set_moles(GAS_PLUOXIUM, max(0,air1.get_moles(GAS_PLUOXIUM) - 0.125 / efficiency))
		else 
			air1.set_moles(GAS_O2, max(0,air1.get_moles(GAS_O2) - 0.5 / efficiency)) // Magically consume gas? Why not, we run on cryo magic.

		if(air1.return_temperature() > 2000)
			take_damage(clamp((air1.return_temperature())/200, 10, 20), BURN)

/obj/machinery/atmospherics/components/unary/cryo_cell/relaymove(mob/user)
	if(message_cooldown <= world.time)
		message_cooldown = world.time + 50
		to_chat(user, "<span class='warning'>[src]'s door won't budge!</span>")

/obj/machinery/atmospherics/components/unary/cryo_cell/open_machine(drop = FALSE)
	if(!state_open && !panel_open)
		set_on(FALSE)
	for(var/mob/M in contents) //only drop mobs
		M.forceMove(get_turf(src))
	set_occupant(null)
	flick("pod-open-anim", src)
	reagent_transfer = efficiency * 10 - 5 // wait before injecting the next occupant
	..()

/obj/machinery/atmospherics/components/unary/cryo_cell/close_machine(mob/living/carbon/user)
	treating_wounds = FALSE
	if((isnull(user) || istype(user)) && state_open && !panel_open)
		flick("pod-close-anim", src)
		..(user)
		return occupant

/obj/machinery/atmospherics/components/unary/cryo_cell/container_resist(mob/living/user)
	user.changeNext_move(CLICK_CD_BREAKOUT)
	user.last_special = world.time + CLICK_CD_BREAKOUT
	user.visible_message("<span class='notice'>You see [user] kicking against the glass of [src]!</span>", \
		"<span class='notice'>You struggle inside [src], kicking the release with your foot... (this will take about [DisplayTimeText(breakout_time)].)</span>", \
		"<span class='hear'>You hear a thump from [src].</span>")
	if(do_after(user, breakout_time, src))
		if(!user || user.stat != CONSCIOUS || user.loc != src )
			return
		user.visible_message("<span class='warning'>[user] successfully broke out of [src]!</span>", \
			"<span class='notice'>You successfully break out of [src]!</span>")
		open_machine()

/obj/machinery/atmospherics/components/unary/cryo_cell/examine(mob/user)
	. = ..()
	if(occupant)
		if(on)
			. += "Someone's inside [src]!"
		else
			. += "You can barely make out a form floating in [src]."
	else
		. += "[src] seems empty."

/obj/machinery/atmospherics/components/unary/cryo_cell/MouseDrop_T(mob/target, mob/user)
	if(user.incapacitated() || !Adjacent(user) || !user.Adjacent(target) || !iscarbon(target) || !user.IsAdvancedToolUser())
		return
	if(isliving(target))
		var/mob/living/L = target
		if(L.incapacitated())
			close_machine(target)
	else
		user.visible_message("<span class='notice'>[user] starts shoving [target] inside [src].</span>", "<span class='notice'>You start shoving [target] inside [src].</span>")
		if (do_after(user, 25, target))
			close_machine(target)

/obj/machinery/atmospherics/components/unary/cryo_cell/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/reagent_containers/glass))
		. = 1 //no afterattack
		if(beaker)
			to_chat(user, "<span class='warning'>A beaker is already loaded into [src]!</span>")
			return
		if(!user.transferItemToLoc(I, src))
			return
		beaker = I
		user.visible_message("<span class='notice'>[user] places [I] in [src].</span>", \
							"<span class='notice'>You place [I] in [src].</span>")
		var/reagentlist = pretty_string_from_reagent_list(I.reagents.reagent_list)
		log_game("[key_name(user)] added an [I] to cryo containing [reagentlist]")
		return
	if(!on && !occupant && !state_open && (default_deconstruction_screwdriver(user, "pod-off", "pod-off", I)) \
		|| default_change_direction_wrench(user, I) \
		|| default_pry_open(I) \
		|| default_deconstruction_crowbar(I))
		update_appearance()
		return
	else if(I.tool_behaviour == TOOL_SCREWDRIVER)
		to_chat(user, "<span class='warning'>You can't access the maintenance panel while the pod is " \
		+ (on ? "active" : (occupant ? "full" : "open")) + "!</span>")
		return
	return ..()

/obj/machinery/atmospherics/components/unary/cryo_cell/ui_state(mob/user)
	return GLOB.notcontained_state


/obj/machinery/atmospherics/components/unary/cryo_cell/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Cryo", name)
		ui.open()

/obj/machinery/atmospherics/components/unary/cryo_cell/ui_data()
	var/list/data = list()
	data["isOperating"] = on
	data["hasOccupant"] = occupant ? TRUE : FALSE
	data["isOpen"] = state_open
	data["autoEject"] = autoeject

	data["occupant"] = list()
	if(occupant)
		var/mob/living/mob_occupant = occupant
		data["occupant"]["name"] = mob_occupant.name
		switch(mob_occupant.stat)
			if(CONSCIOUS)
				data["occupant"]["stat"] = "Conscious"
				data["occupant"]["statstate"] = "good"
			if(SOFT_CRIT)
				data["occupant"]["stat"] = "Conscious"
				data["occupant"]["statstate"] = "average"
			if(UNCONSCIOUS)
				data["occupant"]["stat"] = "Unconscious"
				data["occupant"]["statstate"] = "average"
			if(DEAD)
				data["occupant"]["stat"] = "Dead"
				data["occupant"]["statstate"] = "bad"
		data["occupant"]["health"] = round(mob_occupant.health, 1)
		data["occupant"]["maxHealth"] = mob_occupant.maxHealth
		data["occupant"]["minHealth"] = HEALTH_THRESHOLD_DEAD
		data["occupant"]["bruteLoss"] = round(mob_occupant.getBruteLoss(), 1)
		data["occupant"]["oxyLoss"] = round(mob_occupant.getOxyLoss(), 1)
		data["occupant"]["toxLoss"] = round(mob_occupant.getToxLoss(), 1)
		data["occupant"]["fireLoss"] = round(mob_occupant.getFireLoss(), 1)
		data["occupant"]["bodyTemperature"] = round(mob_occupant.bodytemperature, 1)
		if(mob_occupant.bodytemperature < TCRYO)
			data["occupant"]["temperaturestatus"] = "good"
		else if(mob_occupant.bodytemperature < T0C)
			data["occupant"]["temperaturestatus"] = "average"
		else
			data["occupant"]["temperaturestatus"] = "bad"

	var/datum/gas_mixture/air1 = airs[1]
	data["cellTemperature"] = round(air1.return_temperature(), 1)

	data["isBeakerLoaded"] = beaker ? TRUE : FALSE
	var/beakerContents = list()
	if(beaker && beaker.reagents && beaker.reagents.reagent_list.len)
		for(var/datum/reagent/R in beaker.reagents.reagent_list)
			beakerContents += list(list("name" = R.name, "volume" = R.volume))
	data["beakerContents"] = beakerContents
	return data

/obj/machinery/atmospherics/components/unary/cryo_cell/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("power")
			if(on)
				set_on(FALSE)
			else if(!state_open)
				set_on(TRUE)
			. = TRUE
		if("door")
			if(state_open)
				close_machine()
			else
				open_machine()
			. = TRUE
		if("autoeject")
			autoeject = !autoeject
			. = TRUE
		if("ejectbeaker")
			if(beaker)
				beaker.forceMove(drop_location())
				if(Adjacent(usr) && !issilicon(usr))
					usr.put_in_hands(beaker)
				beaker = null
				. = TRUE

/obj/machinery/atmospherics/components/unary/cryo_cell/CtrlClick(mob/user)
	if(can_interact(user) && !state_open)
		set_on(!on)
	return ..()

/obj/machinery/atmospherics/components/unary/cryo_cell/AltClick(mob/user)
	if(can_interact(user))
		if(state_open)
			close_machine()
		else
			open_machine()
	return ..()

/obj/machinery/atmospherics/components/unary/cryo_cell/update_remote_sight(mob/living/user)
	return // we don't see the pipe network while inside cryo.

/obj/machinery/atmospherics/components/unary/cryo_cell/can_crawl_through()
	return // can't ventcrawl in or out of cryo.

/obj/machinery/atmospherics/components/unary/cryo_cell/can_see_pipes()
	return FALSE // you can't see the pipe network when inside a cryo cell.

/obj/machinery/atmospherics/components/unary/cryo_cell/return_temperature()
	var/datum/gas_mixture/G = airs[1]

	if(G.total_moles() > 10)
		return G.return_temperature()
	return ..()

/obj/machinery/atmospherics/components/unary/cryo_cell/default_change_direction_wrench(mob/user, obj/item/wrench/W)
	. = ..()
	if(.)
		set_init_directions()
		var/obj/machinery/atmospherics/node = nodes[1]
		if(node)
			node.disconnect(src)
			nodes[1] = null
			if(parents[1])
				nullify_pipenet(parents[1])
		atmos_init()
		node = nodes[1]
		if(node)
			node.atmos_init()
			node.add_member(src)
		SSair.add_to_rebuild_queue(src)

#undef MAX_TEMPERATURE
