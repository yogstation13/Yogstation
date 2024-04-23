/obj/item/tank
	name = "tank"
	icon = 'yogstation/icons/obj/tank.dmi'
	lefthand_file = 'icons/mob/inhands/equipment/tanks_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tanks_righthand.dmi'
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BACK
	hitsound = 'sound/weapons/smash.ogg'
	pressure_resistance = ONE_ATMOSPHERE * 5
	force = 5
	throwforce = 10
	throw_speed = 1
	throw_range = 4
	materials = list(/datum/material/iron = 500)
	actions_types = list(/datum/action/item_action/set_internals)
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 10, BIO = 0, RAD = 0, FIRE = 80, ACID = 30)
	/// The gases this tank contains. Don't modify this directly, use return_air() to get it instead
	var/datum/gas_mixture/air_contents = null
	/// The pressure of the gases this tank supplies to internals.
	var/distribute_pressure = ONE_ATMOSPHERE
	var/integrity = 3
	/// The volume of this tank. Among other things gas tank explosions (including TTVs) scale off of this. Be sure to account for that if you change this or you will break ~~toxins~~ordinance.
	var/volume = 70
	/// Mob that is currently breathing from the tank.
	var/mob/living/carbon/breathing_mob
	/// Attached igniter assembly, used to ignite its contents
	var/obj/item/assembly_holder/tank_assembly
	/// Whether or not it can explode when it receives a signal
	var/bomb_status = FALSE

/obj/item/tank/dropped(mob/living/user, silent)
	. = ..()
	// Close open air tank if its current user got sent to the shadowrealm.
	if (QDELETED(breathing_mob))
		breathing_mob = null
		return
	// Close open air tank if it got dropped by it's current user.
	if (loc != breathing_mob)
		breathing_mob.cutoff_internals()

/// Closes the tank if given to another mob while open.
/obj/item/tank/equipped(mob/living/user, slot, initial)
	. = ..()
	// Close open air tank if it was equipped by a mob other than the current user.
	if (breathing_mob && (user != breathing_mob))
		breathing_mob.cutoff_internals()

/// Called by carbons after they connect the tank to their breathing apparatus.
/obj/item/tank/proc/after_internals_opened(mob/living/carbon/carbon_target)
	breathing_mob = carbon_target
	RegisterSignal(carbon_target, COMSIG_MOB_GET_STATUS_TAB_ITEMS, PROC_REF(get_status_tab_item))

/// Called by carbons after they disconnect the tank from their breathing apparatus.
/obj/item/tank/proc/after_internals_closed(mob/living/carbon/carbon_target)
	breathing_mob = null
	UnregisterSignal(carbon_target, COMSIG_MOB_GET_STATUS_TAB_ITEMS)

/obj/item/tank/proc/get_status_tab_item(mob/living/source, list/items)
	SIGNAL_HANDLER
	items += "Internal Atmosphere Info: [name]"
	items += "Tank Pressure: [air_contents.return_pressure()] kPa"
	items += "Distribution Pressure: [distribute_pressure] kPa"

/// Attempts to toggle the mob's internals on or off using this tank. Returns TRUE if successful.
/obj/item/tank/proc/toggle_internals(mob/living/carbon/mob_target)
	return mob_target.toggle_internals(src)

/obj/item/tank/ui_action_click(mob/user)
	toggle_internals(user)

/obj/item/tank/Initialize(mapload)
	. = ..()

	air_contents = new(volume) //liters
	air_contents.set_temperature(T20C)

	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

	populate_gas()

	START_PROCESSING(SSobj, src)

/obj/item/tank/proc/populate_gas()
	return

/obj/item/tank/Destroy()
	if(air_contents)
		qdel(air_contents)

	if(tank_assembly)
		tank_assembly.master = null
		QDEL_NULL(tank_assembly)

	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/tank/examine(mob/user)
	var/obj/icon = src
	. = ..()
	if(istype(loc, /obj/item/assembly))
		icon = loc
	if(!in_range(src, user) && !isobserver(user))
		if(icon == src)
			. += span_notice("If you want any more information you'll need to get closer.")
		return

	. += span_notice("The gauge reads [round(air_contents.total_moles(), 0.01)] mol at [round(src.air_contents.return_pressure(),0.01)] kPa.")	//yogs can read mols

	var/celsius_temperature = src.air_contents.return_temperature()-T0C
	var/descriptive

	if (celsius_temperature < 20)
		descriptive = "cold"
	else if (celsius_temperature < 40)
		descriptive = "room temperature"
	else if (celsius_temperature < 80)
		descriptive = "lukewarm"
	else if (celsius_temperature < 100)
		descriptive = "warm"
	else if (celsius_temperature < 300)
		descriptive = "hot"
	else
		descriptive = "furiously hot"

	. += span_notice("It feels [descriptive].")

/obj/item/tank/blob_act(obj/structure/blob/B)
	if(B && B.loc == loc)
		var/turf/location = get_turf(src)
		if(!location)
			qdel(src)

		if(air_contents)
			location.assume_air(air_contents)

		qdel(src)

/obj/item/tank/deconstruct(disassembled = TRUE)
	if(!disassembled)
		var/turf/T = get_turf(src)
		if(T)
			T.assume_air(air_contents)
		playsound(src.loc, 'sound/effects/spray.ogg', 10, 1, -3)
	qdel(src)

/obj/item/tank/suicide_act(mob/user)
	var/mob/living/carbon/human/human_user = user
	user.visible_message(span_suicide("[user] is putting [src]'s valve to [user.p_their()] lips! It looks like [user.p_theyre()] trying to commit suicide!"))
	playsound(loc, 'sound/effects/spray.ogg', 10, 1, -3)
	if (!QDELETED(human_user) && air_contents && air_contents.return_pressure() >= 1000)
		for(var/obj/item/W in human_user)
			human_user.dropItemToGround(W)
			if(prob(50))
				step(W, pick(GLOB.alldirs))
		ADD_TRAIT(human_user, TRAIT_DISFIGURED, TRAIT_GENERIC)
		for(var/i in human_user.bodyparts)
			var/obj/item/bodypart/BP = i
			BP.generic_bleedstacks += 5
		human_user.gib_animation()
		sleep(0.3 SECONDS)
		human_user.adjustBruteLoss(1000) //to make the body super-bloody
		human_user.spawn_gibs()
		human_user.spill_organs()
		human_user.spread_bodyparts()

	return (BRUTELOSS)

/obj/item/tank/attackby(obj/item/attacking_item, mob/user, params)
	add_fingerprint(user)
	if(istype(attacking_item, /obj/item/assembly_holder))
		playsound(src, 'sound/items/tape_flip.ogg', 25, TRUE)
		bomb_assemble(attacking_item, user)
	else
		. = ..()

/obj/item/tank/ui_state(mob/user)
	return GLOB.hands_state

/obj/item/tank/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Tank", name)
		ui.open()

/obj/item/tank/ui_static_data(mob/user)
	. = list (
		"defaultReleasePressure" = round(TANK_DEFAULT_RELEASE_PRESSURE),
		"minReleasePressure" = round(TANK_MIN_RELEASE_PRESSURE),
		"maxReleasePressure" = round(TANK_MAX_RELEASE_PRESSURE),
		"leakPressure" = round(TANK_LEAK_PRESSURE),
		"fragmentPressure" = round(TANK_FRAGMENT_PRESSURE)
	)

/obj/item/tank/ui_data(mob/user)
	. = list(
		"tankPressure" = round(air_contents.return_pressure()),
		"releasePressure" = round(distribute_pressure)
	)

	var/mob/living/carbon/carbon_user = user
	if(!istype(carbon_user))
		carbon_user = loc
	if(istype(carbon_user) && carbon_user.internal == src)
		.["connected"] = TRUE

/obj/item/tank/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("pressure")
			var/pressure = params["pressure"]
			if(pressure == "reset")
				pressure = initial(distribute_pressure)
				. = TRUE
			else if(pressure == "min")
				pressure = TANK_MIN_RELEASE_PRESSURE
				. = TRUE
			else if(pressure == "max")
				pressure = TANK_MAX_RELEASE_PRESSURE
				. = TRUE
			else if(pressure == "input")
				pressure = input("New release pressure ([TANK_MIN_RELEASE_PRESSURE]-[TANK_MAX_RELEASE_PRESSURE] kPa):", name, distribute_pressure) as num|null
				if(!isnull(pressure) && !..())
					. = TRUE
			else if(text2num(pressure) != null)
				pressure = text2num(pressure)
				. = TRUE
			if(.)
				distribute_pressure = clamp(round(pressure), TANK_MIN_RELEASE_PRESSURE, TANK_MAX_RELEASE_PRESSURE)

/obj/item/tank/remove_air(amount)
	return air_contents.remove(amount)

/obj/item/tank/remove_air_ratio(ratio)
	return air_contents.remove_ratio(ratio)

/obj/item/tank/return_air()
	return air_contents

/obj/item/tank/return_analyzable_air()
	return air_contents

/obj/item/tank/assume_air(datum/gas_mixture/giver)
	air_contents.merge(giver)

	check_status()
	return 1

/obj/item/tank/assume_air_moles(datum/gas_mixture/giver, moles)
	giver.transfer_to(air_contents, moles)

	check_status()
	return TRUE

/obj/item/tank/assume_air_ratio(datum/gas_mixture/giver, ratio)
	giver.transfer_ratio_to(air_contents, ratio)

	check_status()
	return TRUE

/obj/item/tank/proc/remove_air_volume(volume_to_return)
	if(!air_contents)
		return null

	var/tank_pressure = air_contents.return_pressure()
	if(tank_pressure < distribute_pressure)
		distribute_pressure = tank_pressure

	var/moles_needed = distribute_pressure*volume_to_return/(R_IDEAL_GAS_EQUATION*air_contents.return_temperature())

	return remove_air(moles_needed)

/obj/item/tank/process()
	//Allow for reactions
	air_contents.react(src)
	check_status()

/obj/item/tank/proc/check_status()
	//Handle exploding, leaking, and rupturing of the tank

	if(!air_contents)
		return 0

	var/pressure = air_contents.return_pressure()
	var/temperature = air_contents.return_temperature()

	if(pressure > TANK_FRAGMENT_PRESSURE)
		if(!istype(src.loc, /obj/item/transfer_valve))
			log_bomber(get_mob_by_key(fingerprintslast), "was last key to touch", src, "which ruptured explosively")
		//Give the gas a chance to build up more pressure through reacting
		air_contents.react(src)
		air_contents.react(src)
		air_contents.react(src)
		pressure = air_contents.return_pressure()
		var/range = (pressure-TANK_FRAGMENT_PRESSURE)/TANK_FRAGMENT_SCALE
		var/turf/epicenter = get_turf(loc)


		explosion(epicenter, round(range*0.25), round(range*0.5), round(range), round(range*1.5))
		if(istype(src.loc, /obj/item/transfer_valve))
			qdel(src.loc)
		else
			qdel(src)

	else if(pressure > TANK_RUPTURE_PRESSURE || temperature > TANK_MELT_TEMPERATURE)
		if(integrity <= 0)
			var/turf/T = get_turf(src)
			if(!T)
				return
			T.assume_air(air_contents)
			playsound(src.loc, 'sound/effects/spray.ogg', 10, 1, -3)
			qdel(src)
		else
			integrity--

	else if(pressure > TANK_LEAK_PRESSURE)
		if(integrity <= 0)
			var/turf/T = get_turf(src)
			if(!T)
				return
			var/datum/gas_mixture/leaked_gas = air_contents.remove_ratio(0.25)
			T.assume_air(leaked_gas)
		else
			integrity--

	else if(integrity < 3)
		integrity++

// ---------- Procs below are for tanks that are used exclusively in 1-tank bombs ----------

/obj/item/tank/update_overlays()
	. = ..()
	if(tank_assembly)
		. += tank_assembly.icon_state
		. += tank_assembly.overlays
		. += "bomb_assembly"

/obj/item/tank/wrench_act(mob/living/user, obj/item/I)
	if(tank_assembly)
		I.play_tool_sound(src)
		bomb_disassemble(user)
		return TRUE
	return ..()

/obj/item/tank/welder_act(mob/living/user, obj/item/I)
	. = FALSE
	if(bomb_status)
		user.balloon_alert(user, "already welded!")
		return
	if(!I.tool_start_check(user, amount=0))
		return
	if(I.use_tool(src, user, 0, volume=40))
		bomb_status = TRUE
		log_bomber(user, "welded a single tank bomb,", src, "| Temp: [air_contents.return_temperature()-T0C]")
		to_chat(user, span_notice("A pressure hole has been bored to [src]'s valve. \The [src] can now be ignited."))
		add_fingerprint(user)
		return TRUE

/obj/item/tank/receive_signal()	//This is mainly called by the sensor through sense() to the holder, and from the holder to here.
	audible_message("[icon2html(src, hearers(src))] *beep* *beep* *beep*")
	playsound(src, 'sound/machines/triple_beep.ogg', ASSEMBLY_BEEP_VOLUME, TRUE)
	sleep(1 SECONDS)
	if(QDELETED(src))
		return
	if(bomb_status)
		ignite()	//if its not a dud, boom (or not boom if you made shitty mix) the ignite proc is below, in this file
	else
		release()

//Assembly / attached device memes

/obj/item/tank/proc/on_entered(datum/source, atom/movable/AM, ...)
	if(tank_assembly)
		tank_assembly.Crossed(AM)

/obj/item/tank/on_found(mob/finder) //for mousetraps
	..()
	if(tank_assembly)
		tank_assembly.on_found(finder)

/obj/item/tank/attack_hand() //also for mousetraps
	if(..())
		return
	if(tank_assembly)
		tank_assembly.attack_hand()

/obj/item/tank/Move()
	..()
	if(tank_assembly)
		tank_assembly.setDir(dir)
		tank_assembly.Move()

/obj/item/tank/dropped()
	..()
	if(tank_assembly)
		tank_assembly.dropped()

//Bomb assembly proc. This turns assembly+tank into a bomb
/obj/item/tank/proc/bomb_assemble(obj/item/assembly_holder/assembly, mob/living/user)
	//Check if either part of the assembly has an igniter, but if both parts are igniters, then fuck it
	if(isigniter(assembly.a_left) == isigniter(assembly.a_right))
		return

	if((src in user.get_equipped_items(TRUE)) && !user.canUnEquip(src))
		to_chat(user, span_warning("[src] is stuck to you!"))
		return

	if(!user.canUnEquip(assembly))
		to_chat(user, span_warning("[assembly] is stuck to your hand!"))
		return

	user.transferItemToLoc(assembly, src)

	tank_assembly = assembly	//Tell the tank about its assembly part
	assembly.master = src		//Tell the assembly about its new owner

	throw_speed = max(2, throw_speed) //Make it a bit harder to throw

	update_appearance(UPDATE_ICON)
	user.balloon_alert(user, "[assembly.name] attached")
	return

//Bomb disassembly
/obj/item/tank/proc/bomb_disassemble(mob/living/user)
	tank_assembly.forceMove(drop_location())
	tank_assembly.master = null
	tank_assembly = null

	bomb_status = FALSE
	throw_speed = initial(throw_speed)
	user.balloon_alert(user, "disassembled")
	update_appearance(UPDATE_ICON)

/obj/item/tank/proc/ignite()	//This happens when a bomb is told to explode
	var/fuel_moles = air_contents.get_moles(GAS_TRITIUM) + air_contents.get_moles(GAS_H2) + air_contents.get_moles(GAS_PLASMA) + air_contents.get_moles(GAS_O2)/6
	var/datum/gas_mixture/bomb_mixture = air_contents.copy()
	var/strength = 1

	var/turf/ground_zero = get_turf(loc)

	if(master)
		qdel(master)
	qdel(src)

	if(bomb_mixture.return_temperature() > (T0C + 400))
		strength = (fuel_moles/15)

		if(strength >=1)
			explosion(ground_zero, round(strength,1), round(strength*2,1), round(strength*3,1), round(strength*4,1))
		else if(strength >=0.5)
			explosion(ground_zero, 0, 1, 2, 4)
		else if(strength >=0.2)
			explosion(ground_zero, -1, 0, 1, 2)
		else
			ground_zero.assume_air(bomb_mixture)
			ground_zero.hotspot_expose(1000, 125)

	else if(bomb_mixture.return_temperature() > (T0C + 250))
		strength = (fuel_moles/20)

		if(strength >=1)
			explosion(ground_zero, 0, round(strength,1), round(strength*2,1), round(strength*3,1))
		else if (strength >=0.5)
			explosion(ground_zero, -1, 0, 1, 2)
		else
			ground_zero.assume_air(bomb_mixture)
			ground_zero.hotspot_expose(1000, 125)

	else if(bomb_mixture.return_temperature() > (T0C + 100))
		strength = (fuel_moles/25)

		if (strength >=1)
			explosion(ground_zero, -1, 0, round(strength,1), round(strength*3,1))
		else
			ground_zero.assume_air(bomb_mixture)
			ground_zero.hotspot_expose(1000, 125)

	else
		ground_zero.assume_air(bomb_mixture)
		ground_zero.hotspot_expose(1000, 125)

/obj/item/tank/proc/release()	//This happens when the bomb is not welded. Tank contents are just spat out.
	var/datum/gas_mixture/removed = air_contents.remove(air_contents.total_moles())
	var/turf/T = get_turf(src)
	if(!T)
		return
	T.assume_air(removed)
