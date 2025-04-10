/obj/mecha
	name = "mecha"
	desc = "Exosuit"
	icon = 'icons/mecha/mecha.dmi'
	density = TRUE //Dense. To raise the heat.
	move_resist = MOVE_FORCE_EXTREMELY_STRONG //no pulling around.
	resistance_flags = FIRE_PROOF | ACID_PROOF
	layer = BELOW_MOB_LAYER//icon draw layer
	infra_luminosity = 15 //byond implementation is bugged.
	force = 5
	var/punch_heat_cost = 2
	light_system = MOVABLE_LIGHT_DIRECTIONAL
	light_range = 8
	light_on = FALSE
	flags_1 = HEAR_1
	demolition_mod = 3 // mech punch go brr
	var/weather_protection = WEATHER_STORM
	var/ruin_mecha = FALSE //if the mecha starts on a ruin, don't automatically give it a tracking beacon to prevent metagaming.
	var/can_move = 0 //time of next allowed movement
	var/mob/living/carbon/occupant = null
	var/step_in = 10 //make a step in step_in/10 sec.
	var/dir_in = SOUTH //What direction will the mech face when entered/powered on? Defaults to South.
	var/step_energy_drain = 0
	var/melee_energy_drain = 15
	max_integrity = 600 //max_integrity is base health plus the wreck limit
	integrity_failure = 300 // the point at which this mech becomes a wreck
	var/deflect_chance = 10 //chance to deflect the incoming projectiles, hits, or lesser the effect of ex_act.
	var/super_deflects = FALSE //Redirection of projectiles rather than just L bozoing them
	armor = list(MELEE = 20, BULLET = 10, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 100, ACID = 100)
	var/list/facing_modifiers = list(FRONT_ARMOUR = 1.5, SIDE_ARMOUR = 1, BACK_ARMOUR = 0.5)
	var/equipment_disabled = 0 //disabled due to EMP
	///Keeps track of the mech's cell
	var/obj/item/stock_parts/cell/cell
	///Keeps track of the mech's scanning module
	var/obj/item/stock_parts/scanning_module/scanmod 
	///Keeps track of the mech's capacitor
	var/obj/item/stock_parts/capacitor/capacitor 
	var/state = 0
	var/last_message = 0
	var/add_req_access = 1
	var/maint_access = FALSE
	var/dna_lock //dna-locking the mech
	var/list/proc_res = list() //stores proc owners, like proc_res["functionname"] = owner reference
	var/datum/effect_system/spark_spread/spark_system = new
	var/lights = FALSE
	var/last_user_hud = 1 // used to show/hide the mecha hud while preserving previous preference
	var/omnidirectional_attacks = FALSE //lets mech shoot anywhere, not just in front of it

	var/bumpsmash = 0 //Whether or not the mech destroys walls by running into it.
	//inner atmos
	var/use_internal_tank = FALSE
	var/internal_tank_valve = ONE_ATMOSPHERE
	var/obj/machinery/portable_atmospherics/canister/internal_tank
	var/datum/gas_mixture/cabin_air
	var/obj/machinery/atmospherics/components/unary/portables_connector/connected_port = null

	var/obj/item/radio/mech/radio
	var/list/trackers = list()

	/// Overheating level. This causes damage, slowdown, and eventually complete shutdown.
	var/overheat = 0
	/// Multiplier for overheat gain and loss.
	var/heat_modifier = 1
	/// Multiplier for cooling specifically.
	var/cooling_modifier = 1

	var/max_temperature = 25000
	var/internal_damage_threshold = 50 //health percentage below which internal damage is possible
	var/internal_damage = 0 //contains bitflags

	var/list/operation_req_access = list()//required access level for mecha operation
	var/list/internals_req_access = list(ACCESS_MECH_ENGINE, ACCESS_MECH_SCIENCE)//REQUIRED ACCESS LEVEL TO OPEN CELL COMPARTMENT

	/// Whether the exosuit has been reduced to a wreck.
	var/wrecked = FALSE
	var/repair_state = 0
	var/repair_hint = ""

	var/list/equipment = new
	var/obj/item/mecha_parts/mecha_equipment/selected
	var/max_equip = 3
	var/datum/events/events

	var/stepsound = 'sound/mecha/mechstep.ogg'
	var/turnsound = 'sound/mecha/mechturn.ogg'
	var/meleesound = TRUE //does it play a sound when melee attacking (so mime mech can turn it off)

	var/melee_cooldown = 10
	var/melee_can_hit = TRUE

	var/silicon_pilot = FALSE //set to true if an AI or MMI is piloting.

	///Camera installed into the mech
	var/obj/machinery/camera/exosuit/chassis_camera

	var/enter_delay = 40 //Time taken to enter the mech
	var/exit_delay = 20 //Time to exit mech
	var/destruction_sleep_duration = 20 //Time that mech pilot is put to sleep for if mech is destroyed
	var/enclosed = TRUE //Set to false for open-cockpit mechs
	var/silicon_icon_state = null //if the mech has a different icon when piloted by an AI or MMI
	var/is_currently_ejecting = FALSE //Mech cannot use equiptment when true, set to true if pilot is trying to exit mech

	var/guns_allowed = FALSE	//Whether or not the mech is allowed to mount guns (mecha_equipment/weapon)
	var/melee_allowed = FALSE	//Whether or not the mech is allowed to mount melee weapons (mecha_equipment/melee_weapon)

	//Action datums
	var/datum/action/innate/mecha/mech_eject/eject_action = new
	var/datum/action/innate/mecha/mech_toggle_internals/internals_action = new
	var/datum/action/innate/mecha/mech_cycle_equip/cycle_action = new
	var/datum/action/innate/mecha/mech_toggle_lights/lights_action = new
	var/datum/action/innate/mecha/mech_view_stats/stats_action = new
	var/datum/action/innate/mecha/mech_defence_mode/defence_action = new
	var/datum/action/innate/mecha/mech_overload_mode/overload_action = new
	var/datum/effect_system/fluid_spread/smoke/smoke_system = new //not an action, but trigged by one
	var/datum/action/innate/mecha/mech_smoke/smoke_action = new
	var/datum/action/innate/mecha/mech_zoom/zoom_action = new
	var/datum/action/innate/mecha/mech_switch_damtype/switch_damtype_action = new
	var/datum/action/innate/mecha/mech_toggle_phasing/phasing_action = new
	var/datum/action/innate/mecha/strafe/strafing_action = new

	//Action vars
	var/defence_mode = FALSE
	var/defence_mode_deflect_chance = 15
	var/leg_overload_mode = FALSE
	var/zoom_mode = FALSE
	var/smoke = 5
	var/smoke_ready = 1
	var/smoke_cooldown = 100
	var/phasing = FALSE
	var/phasing_energy_drain = 200
	var/phase_state = "" //icon_state when phasing
	var/strafe = FALSE //If we are strafing
	var/pivot_step = FALSE
	var/nextsmash = 0
	var/smashcooldown = 3	//deciseconds
	var/ejection_distance = 0 //violently ejects the pilot when destroyed
	var/self_destruct = 0

	var/occupant_sight_flags = 0 //sight flags to give to the occupant (e.g. mech mining scanner gives meson-like vision)
	var/mouse_pointer

	hud_possible = list (DIAG_STAT_HUD, DIAG_BATT_HUD, DIAG_MECH_HUD, DIAG_TRACK_HUD, DIAG_OVERHEAT_HUD)

/obj/item/radio/mech //this has to go somewhere

/obj/mecha/Initialize(mapload)
	. = ..()
	events = new
	update_appearance(UPDATE_ICON)
	add_radio()
	add_cabin()
	if (enclosed)
		add_airtank()
	spark_system.set_up(2, 0, src)
	spark_system.attach(src)
	smoke_system.set_up(3, location = src)
	smoke_system.attach(src)
	add_cell()
	add_scanmod()
	add_capacitor()
	START_PROCESSING(SSmecha, src)
	GLOB.poi_list |= src
	log_message("[src.name] created.", LOG_MECHA)
	GLOB.mechas_list += src //global mech list
	prepare_huds()
	for(var/datum/atom_hud/data/diagnostic/diag_hud in GLOB.huds)
		diag_hud.add_atom_to_hud(src)
	diag_hud_set_mechhealth()
	diag_hud_set_mechcell()
	diag_hud_set_mechstat()
	diag_hud_set_mechoverheat()
	RegisterSignal(src, COMSIG_LIGHT_EATER_ACT, PROC_REF(on_light_eater))
	ADD_TRAIT(src, TRAIT_SHIELDBUSTER, INNATE_TRAIT) // previously it didn't even check shields at all, now it still doesn't but does some fun stuff in the process

/// Special light eater handling
/obj/mecha/proc/on_light_eater(obj/vehicle/sealed/source, datum/light_eater)
	SIGNAL_HANDLER
	visible_message(span_danger("[src]'s lights burn out!"))
	set_light_on(FALSE)
	lights_action.Remove(occupant)
	return COMPONENT_BLOCK_LIGHT_EATER
	
/obj/mecha/update_icon_state()
	. = ..()
	if(wrecked)
		icon_state = "[initial(icon_state)]-broken"
	else if(silicon_pilot && silicon_icon_state)
		icon_state = silicon_icon_state
	else if(!occupant)
		icon_state = "[initial(icon_state)]-open"
	else
		icon_state = initial(icon_state)

/obj/mecha/get_cell()
	return cell

/obj/mecha/Destroy()
	var/mob/living/silicon/ai/AI
	for(var/mob/M in src) //Let's just be ultra sure
		if(isAI(M))
			occupant = null
			AI = M //AIs are loaded into the mech computer itself. When the mech dies, so does the AI. They can be recovered with an AI card from the wreck.
		else
			M.forceMove(loc)
	force_eject_occupant()
	for(var/obj/item/mecha_parts/mecha_equipment/E in equipment)
		E.detach(loc)
		qdel(E)
	if(cell)
		qdel(cell)
	if(scanmod)
		qdel(scanmod)
	if(capacitor)
		qdel(capacitor)
	if(internal_tank)
		qdel(internal_tank)
	if(AI)
		AI.gib() //No wreck, no AI to recover
	STOP_PROCESSING(SSmecha, src)
	GLOB.poi_list.Remove(src)
	equipment.Cut()
	cell = null
	scanmod = null
	capacitor = null
	internal_tank = null
	assume_air(cabin_air)
	cabin_air = null
	qdel(spark_system)
	spark_system = null
	qdel(smoke_system)
	smoke_system = null

	if(self_destruct && !QDELETED(src))
		detonate(self_destruct)

	GLOB.mechas_list -= src //global mech list
	return ..()

/obj/mecha/proc/force_eject_occupant()
	if(!occupant)
		return
	var/mob/living/carbon/previous_occupant = occupant
	go_out()
	if(ejection_distance)
		var/turf/target = get_edge_target_turf(previous_occupant, dir)
		previous_occupant.throw_at(target, 10, 1)
	else if(!ejection_distance)
		previous_occupant.SetSleeping(destruction_sleep_duration)

/obj/mecha/proc/restore_equipment()
	equipment_disabled = FALSE
	if(occupant)
		SEND_SOUND(occupant, sound('sound/items/timer.ogg', volume=50))
		to_chat(occupant, "<span=notice>Equipment control unit has been rebooted successfully.</span>")
		occupant.update_mouse_pointer()

/obj/mecha/CheckParts(list/parts_list)
	..()
	cell = locate(/obj/item/stock_parts/cell) in contents
	scanmod = locate(/obj/item/stock_parts/scanning_module) in contents
	capacitor = locate(/obj/item/stock_parts/capacitor) in contents

////////////////////////
////// Helpers /////////
////////////////////////

/obj/mecha/proc/add_airtank()
	internal_tank = new /obj/machinery/portable_atmospherics/canister/air(src)
	return internal_tank

/obj/mecha/proc/add_cell(obj/item/stock_parts/cell/C=null) ///Adds a cell, for use in Map-spawned mechs, Nuke Ops mechs, and admin-spawned mechs. Mechs built by hand will replace this.
	QDEL_NULL(cell)
	if(C)
		C.forceMove(src)
		cell = C
		return
	cell = new /obj/item/stock_parts/cell/high/plus(src)

/obj/mecha/proc/add_scanmod(obj/item/stock_parts/scanning_module/sm=null) ///Adds a scanning module, for use in Map-spawned mechs, Nuke Ops mechs, and admin-spawned mechs. Mechs built by hand will replace this.
	QDEL_NULL(scanmod)
	if(sm)
		sm.forceMove(src)
		scanmod = sm
		return
	scanmod = new /obj/item/stock_parts/scanning_module(src)

/obj/mecha/proc/add_capacitor(obj/item/stock_parts/capacitor/cap=null) ///Adds a capacitor, for use in Map-spawned mechs, Nuke Ops mechs, and admin-spawned mechs. Mechs built by hand will replace this.
	QDEL_NULL(capacitor)
	if(cap)
		cap.forceMove(src)
		capacitor = cap
		return
	capacitor = new /obj/item/stock_parts/capacitor(src)

/obj/mecha/proc/add_cabin()
	cabin_air = new
	cabin_air.set_temperature(T20C)
	cabin_air.set_volume(200)
	cabin_air.set_moles(GAS_O2, O2STANDARD*cabin_air.return_volume()/(R_IDEAL_GAS_EQUATION*cabin_air.return_temperature()))
	cabin_air.set_moles(GAS_N2, N2STANDARD*cabin_air.return_volume()/(R_IDEAL_GAS_EQUATION*cabin_air.return_temperature()))
	return cabin_air

/obj/mecha/proc/add_radio()
	radio = new(src)
	radio.name = "[src] radio"
	radio.icon = icon
	radio.icon_state = icon_state
	radio.subspace_transmission = TRUE

/obj/mecha/proc/can_use(mob/user)
	if(user != occupant)
		return FALSE
	if(user && ismob(user))
		if(!user.incapacitated())
			return TRUE
	return FALSE

/obj/mecha/proc/adjust_overheat(amount = 0)
	if(amount > 0)
		amount *= 1.2 - (scanmod.rating * 0.1) // 1.1x to 0.8x heat generation based on scanner module rating
	overheat = round(clamp(overheat + (amount * heat_modifier), 0, OVERHEAT_MAXIMUM), 0.1)
	if(overheat >= OVERHEAT_MAXIMUM && amount > 0)
		if(overload_action)
			overload_action.Activate(FALSE) // turn it off
		occupant.throw_alert("mech_overheat", /atom/movable/screen/alert/overheating, 3)
		ADD_TRAIT(src, TRAIT_MECH_DISABLED, OVERHEAT_TRAIT)
		if(world.time > last_message + 2 SECONDS)
			SEND_SOUND(occupant, sound('sound/machines/warning-buzzer.ogg',volume=50))
			occupant_message("Warning: overheating critical. Shutdown imminent.")
	else if(overheat < OVERHEAT_THRESHOLD)
		REMOVE_TRAIT(src, TRAIT_MECH_DISABLED, OVERHEAT_TRAIT)
	infra_luminosity = initial(infra_luminosity) * (1 + overheat / OVERHEAT_THRESHOLD) // hotter mechs are more visible on infrared
	diag_hud_set_mechoverheat()

/obj/mecha/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..() // if something can go through machines it can go through mechs
	if(istype(mover) && (mover.pass_flags & PASSMECH))
		return TRUE

////////////////////////////////////////////////////////////////////////////////

/obj/mecha/examine(mob/user)
	. = ..()
	var/hide_weapon = locate(/obj/item/mecha_parts/concealed_weapon_bay) in contents
	var/obj/item/mecha_parts/mecha_equipment/melee_weapon/hidden_melee_weapon = locate(/obj/item/mecha_parts/mecha_equipment/melee_weapon) in equipment
	if(hidden_melee_weapon && !(hidden_melee_weapon.mech_flags & EXOSUIT_MODULE_COMBAT))
		hidden_melee_weapon = null
	var/hidden_weapon = hide_weapon ? (locate(/obj/item/mecha_parts/mecha_equipment/weapon) in equipment)||hidden_melee_weapon : null
	var/list/visible_equipment = equipment - hidden_weapon
	if(visible_equipment.len)
		. += "It's equipped with:"
		for(var/obj/item/mecha_parts/mecha_equipment/ME in visible_equipment)
			. += "[icon2html(ME, user)] \A [ME]."
	if(occupant && occupant == user)
		if(armor.bio || armor.bomb || armor.bullet || armor.energy || armor.laser || armor.melee || armor.fire || armor.acid || deflect_chance || max_temperature)
			. += "<span class='notice'>It has a <a href='byond://?src=[REF(src)];list_armor=1'>tag</a> listing its protection classes.</span>"
	if(!enclosed)
		if(silicon_pilot)
			. += "[src] appears to be piloting itself..."
		else if(occupant && occupant != user) //!silicon_pilot implied
			. += "You can see [occupant] inside."
			if(ishuman(user))
				var/mob/living/carbon/human/H = user
				for(var/O in H.held_items)
					if(istype(O, /obj/item/gun))
						. += span_warning("It looks like you can hit the pilot directly if you target the center or above.")
						break //in case user is holding two guns
	if(wrecked)
		switch(capacitor?.rating)
			if(0)
				. += span_danger("There was no capacitor to save this poor mecha from its doomed fate! It cannot be repaired!")
			if(1)
				. += span_danger("The weak capacitor did what little it could in preventing total destruction of this mecha. It is barely recoverable.")
			if(2)
				. += span_danger("The capacitor barely held the parts together upon its destruction. Repair will be difficult.")
			if(3)
				. += span_danger("The capacitor did well in preventing too much damage. Repair will be manageable.")
			if(4)
				. += span_danger("The capacitor did such a good job in preserving the chassis that you could almost call it functional. But it isn't. Repair should be easy though.")
		if(repair_hint && (capacitor?.rating || user.skill_check(SKILL_TECHNICAL, EXP_GENIUS) || user.skill_check(SKILL_MECHANICAL, EXP_GENIUS)))
			. += repair_hint

//Armor tag
/obj/mecha/Topic(href, href_list)
	. = ..()
	if(href_list["list_armor"])
		to_chat(usr, "[armor.show_protection_classes()]")

//processing equipment, internal damage, temperature, air regulation, alert updates, lights power use.
/obj/mecha/process(delta_time)
	for(var/obj/item/mecha_parts/mecha_equipment/equip as anything in equipment)
		if(!equip.active)
			continue
		if(equip.on_process(delta_time) == PROCESS_KILL)
			equip.active = FALSE

	var/internal_temp_regulation = TRUE

	if(internal_damage)
		if(internal_damage & MECHA_INT_FIRE)
			if(!(internal_damage & MECHA_INT_TEMP_CONTROL) && prob(5))
				clearInternalDamage(MECHA_INT_FIRE)
			if(internal_tank)
				var/datum/gas_mixture/int_tank_air = internal_tank.return_air()
				if(int_tank_air.return_pressure() > internal_tank.maximum_pressure && !(internal_damage & MECHA_INT_TANK_BREACH))
					setInternalDamage(MECHA_INT_TANK_BREACH)
				if(int_tank_air && int_tank_air.return_volume() > 0) //heat the air_contents
					int_tank_air.set_temperature(min(6000+T0C, int_tank_air.return_temperature() + rand(5, 7) * delta_time))
			if(cabin_air && cabin_air.return_volume()>0)
				cabin_air.set_temperature(min(6000+T0C, cabin_air.return_temperature() + rand(5, 7) * delta_time))
				if(cabin_air.return_temperature() > max_temperature/2)
					take_damage(4/round(max_temperature/cabin_air.return_temperature(),0.1), BURN, 0, 0)

		if(internal_damage & MECHA_INT_TEMP_CONTROL)
			internal_temp_regulation = FALSE

		if(internal_damage & MECHA_INT_TANK_BREACH) //remove some air from internal tank
			if(internal_tank)
				assume_air_ratio(internal_tank.return_air(), 0.1)

		if(internal_damage & MECHA_INT_SHORT_CIRCUIT)
			if(get_charge())
				spark_system.start()
				cell.charge -= min(delta_time SECONDS, cell.charge)
				cell.maxcharge -= min(delta_time SECONDS, cell.maxcharge)

	if(world.time > can_move)
		adjust_overheat(max((world.time - can_move) * STATIONARY_COOLING * delta_time, STATIONARY_COOLING_MAXIMUM))

	if(internal_temp_regulation)
		adjust_overheat(PASSIVE_COOLING * delta_time)
		var/datum/gas_mixture/environment = loc.return_air()
		if(environment?.return_temperature() > max_temperature)
			adjust_overheat(min((environment.return_temperature() - max_temperature) / max_temperature, -PASSIVE_COOLING))
		if(cabin_air && cabin_air.return_volume() > 0)
			var/delta = cabin_air.return_temperature() - T20C
			cabin_air.set_temperature(cabin_air.return_temperature() - max(-0.5 * delta_time SECONDS, min(10, round(delta/4,0.1))))

	if(overheat >= OVERHEAT_THRESHOLD)
		take_damage(delta_time * (1 + 2 * (overheat - OVERHEAT_THRESHOLD) / OVERHEAT_THRESHOLD), BURN, null, FALSE) // 1 to 3 damage per second

	if(internal_tank)
		var/datum/gas_mixture/tank_air = internal_tank.return_air()

		var/release_pressure = internal_tank_valve
		var/cabin_pressure = cabin_air.return_pressure()
		var/pressure_delta = min(release_pressure - cabin_pressure, (tank_air.return_pressure() - cabin_pressure)/2)
		var/transfer_moles = 0
		if(pressure_delta > 0) //cabin pressure lower than release pressure
			if(tank_air.return_temperature() > 0)
				transfer_moles = pressure_delta*cabin_air.return_volume()/(cabin_air.return_temperature() * R_IDEAL_GAS_EQUATION)
				tank_air.transfer_to(cabin_air,transfer_moles)
		else if(pressure_delta < 0) //cabin pressure higher than release pressure
			var/datum/gas_mixture/t_air = return_air()
			pressure_delta = cabin_pressure - release_pressure
			if(t_air)
				pressure_delta = min(cabin_pressure - t_air.return_pressure(), pressure_delta)
			if(pressure_delta > 0) //if location pressure is lower than cabin pressure
				transfer_moles = pressure_delta*cabin_air.return_volume()/(cabin_air.return_temperature() * R_IDEAL_GAS_EQUATION)
				cabin_air.transfer_to(t_air, transfer_moles)

	if(occupant)
		if(cell)
			var/cellcharge = cell.charge/cell.maxcharge
			switch(cellcharge)
				if(0.75 to INFINITY)
					occupant.clear_alert("charge")
				if(0.5 to 0.75)
					occupant.throw_alert("charge", /atom/movable/screen/alert/lowcell, 1)
				if(0.25 to 0.5)
					occupant.throw_alert("charge", /atom/movable/screen/alert/lowcell, 2)
				if(0.01 to 0.25)
					occupant.throw_alert("charge", /atom/movable/screen/alert/lowcell, 3)
				else
					occupant.throw_alert("charge", /atom/movable/screen/alert/emptycell)

		var/integrity = 100 * (atom_integrity - integrity_failure) / (max_integrity - integrity_failure) 
		switch(integrity)
			if(30 to 45)
				occupant.throw_alert("mech damage", /atom/movable/screen/alert/low_mech_integrity, 1)
			if(15 to 35)
				occupant.throw_alert("mech damage", /atom/movable/screen/alert/low_mech_integrity, 2)
			if(-INFINITY to 15)
				occupant.throw_alert("mech damage", /atom/movable/screen/alert/low_mech_integrity, 3)
			else
				occupant.clear_alert("mech damage")

		if(HAS_TRAIT_FROM(src, TRAIT_MECH_DISABLED, OVERHEAT_TRAIT))
			occupant.throw_alert("mech_overheat", /atom/movable/screen/alert/overheating, 3)
		else if(overheat >= OVERHEAT_WARNING)
			occupant.throw_alert("mech_overheat", /atom/movable/screen/alert/overheating, round(3 * (overheat - OVERHEAT_WARNING) / (OVERHEAT_MAXIMUM - OVERHEAT_WARNING)))
		else
			occupant.clear_alert("mech_overheat")

		var/atom/checking = occupant.loc
		// recursive check to handle all cases regarding very nested occupants,
		// such as brainmob inside brainitem inside MMI inside mecha
		while (!isnull(checking))
			if (isturf(checking))
				// hit a turf before hitting the mecha, seems like they have
				// been moved out
				occupant.clear_alert("charge")
				occupant.clear_alert("mech damage")
				RemoveActions(occupant, human_occupant=1)
				occupant = null
				break
			else if (checking == src)
				break  // all good
			checking = checking.loc

	if(lights)
		var/lights_energy_drain = 2
		use_power(lights_energy_drain)

	if(!enclosed && occupant?.incapacitated()) //no sides mean it's easy to just sorta fall out if you're incapacitated.
		visible_message(span_warning("[occupant] tumbles out of the cockpit!"))
		go_out() //Maybe we should install seat belts?

	//Diagnostic HUD updates
	diag_hud_set_mechhealth()
	diag_hud_set_mechcell()
	diag_hud_set_mechstat()
	diag_hud_set_mechoverheat()

/obj/mecha/fire_act() //Check if we should ignite the pilot of an open-canopy mech
	. = ..()
	if (occupant && !enclosed && !silicon_pilot)
		if (occupant.fire_stacks < 5)
			occupant.adjust_fire_stacks(1)
		occupant.ignite_mob()

/obj/mecha/extinguish() // can be ignited, so should be extinguished as well
	. = ..()
	if(occupant && !enclosed && !silicon_pilot)
		occupant.extinguish_mob()

/obj/mecha/proc/drop_item()//Derpfix, but may be useful in future for engineering exosuits.
	return

/obj/mecha/Hear(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, list/message_mods = list())
	. = ..()
	if(speaker == occupant)
		if(radio?.broadcasting)
			radio.talk_into(speaker, text, , spans, message_language, message_mods)
		//flick speech bubble
		var/list/speech_bubble_recipients = list()
		for(var/mob/M in get_hearers_in_view(7,src))
			if(M.client)
				speech_bubble_recipients.Add(M.client)
		INVOKE_ASYNC(GLOBAL_PROC, /proc/flick_overlay_global, image('icons/mob/talk.dmi', src, "machine[say_test(raw_message)]",MOB_LAYER+1), speech_bubble_recipients, 30)

////////////////////////////
///// Action processing ////
////////////////////////////


/obj/mecha/proc/click_action(atom/target, mob/user, params)
	if(!occupant || occupant != user || wrecked)
		return
	if(!locate(/turf) in list(target,target.loc)) // Prevents inventory from being drilled
		return
	if(HAS_TRAIT(src, TRAIT_MECH_DISABLED))
		return
	if(is_currently_ejecting)
		return
	if(phasing)
		occupant_message("Unable to interact with objects while phasing")
		return
	if(user.incapacitated())
		return
	if(state)
		occupant_message(span_warning("Maintenance protocols in effect."))
		return
	if(!get_charge())
		return
	if(src == target)
		return
	var/dir_to_target = get_dir(src,target)
	if(!omnidirectional_attacks && dir_to_target && !(dir_to_target & dir))//wrong direction
		return
	if(internal_damage & MECHA_INT_CONTROL_LOST)
		target = pick(view(3,target))
		if(!target)
			return

	// No shotgun swapping
	for(var/obj/item/mecha_parts/mecha_equipment/weapon/W in equipment)
		if(!W.equip_ready && (W.equip_cooldown < MECHA_MAX_COOLDOWN))
			return
	
	if(!selected)
		default_melee_attack(target)
	else if(selected.action_checks(target) && selected.action(target, user, params))
		selected.start_cooldown()

/obj/mecha/proc/default_melee_attack(atom/target, cooldown_override = 0)
	if(internal_damage & MECHA_INT_CONTROL_LOST)
		target = pick(oview(1,src))
	if(!melee_can_hit || !isatom(target))
		return FALSE
	if(equipment_disabled)
		return FALSE
	if(!Adjacent(target))
		return FALSE
	target.mech_melee_attack(src, force, TRUE)
	melee_can_hit = FALSE
	adjust_overheat(punch_heat_cost)
	addtimer(VARSET_CALLBACK(src, melee_can_hit, TRUE), cooldown_override ? cooldown_override : melee_cooldown)
	return TRUE

/obj/mecha/proc/range_action(atom/target)
	return


//////////////////////////////////
////////  Movement procs  ////////
//////////////////////////////////

/obj/mecha/Move(atom/newloc, direct)
	. = ..()
	if(.)
		events.fireEvent("onMove",get_turf(src))
	if (internal_tank?.disconnect()) // Something moved us and broke connection
		occupant_message(span_warning("Air port connection teared off!"))
		log_message("Lost connection to gas port.", LOG_MECHA)

/obj/mecha/Process_Spacemove(movement_dir = 0)
	. = ..()
	if(.)
		return TRUE

	var/atom/movable/backup = get_spacemove_backup()
	if(backup)
		if(istype(backup) && movement_dir && !backup.anchored)
			if(backup.newtonian_move(turn(movement_dir, 180)))
				if(occupant)
					to_chat(occupant, span_info("You push off of [backup] to propel yourself."))
		return TRUE

/obj/mecha/relaymove(mob/user,direction)
	if(wrecked) // for any AIs still stuck inside
		return
	if(HAS_TRAIT(src, TRAIT_MECH_DISABLED))
		return
	if(!direction)
		return
	if(user != occupant) //While not "realistic", this piece is player friendly.
		user.forceMove(get_turf(src))
		to_chat(user, span_notice("You climb out from [src]."))
		return FALSE
	if(internal_tank?.connected_port)
		if(world.time - last_message > 20)
			occupant_message(span_warning("Unable to move while connected to the air system port!"))
			last_message = world.time
		return FALSE
	if(state)
		if(world.time - last_message > 20)
			occupant_message(span_danger("Maintenance protocols in effect."))
			last_message = world.time
		return
	return domove(direction)

/obj/mecha/proc/domove(direction)
	if(can_move >= world.time)
		return FALSE
	if((direction & (DOWN|UP)) && !get_step_multiz(get_turf(src), direction))
		direction &= ~(DOWN|UP) // remove vertical component
	if(!direction) // don't bother moving without a direction
		return FALSE
	if(!Process_Spacemove(direction))
		return FALSE
	if(!has_charge(step_energy_drain))
		return FALSE

	if(defence_mode)
		if(world.time - last_message > 20)
			occupant_message(span_danger("Unable to move while in defense mode"))
			last_message = world.time
		return FALSE
	if(zoom_mode)
		if(world.time - last_message > 20)
			occupant_message("Unable to move while in zoom mode.")
			last_message = world.time
		return FALSE
	if(!cell)
		if(world.time - last_message > 20)
			occupant_message(span_warning("Missing power cell."))
			last_message = world.time
		return FALSE
	if(!scanmod || !capacitor)
		if(world.time - last_message > 20)
			occupant_message(span_warning("Missing [scanmod? "capacitor" : "scanning module"]."))
			last_message = world.time
		return FALSE

	var/move_result = 0
	var/oldloc = loc
	var/step_time = step_in
	if(overheat > OVERHEAT_THRESHOLD)
		step_time += (min(overheat, OVERHEAT_MAXIMUM) - OVERHEAT_THRESHOLD) / OVERHEAT_THRESHOLD // up to 0.5 slower based on overheating
	if(leg_overload_mode)
		step_time = min(1, step_in / 2)
	step_time *= check_eva()

	if(internal_damage & MECHA_INT_CONTROL_LOST)
		set_glide_size(DELAY_TO_GLIDE_SIZE(step_time))
		move_result = mechsteprand()
	else if(dir != direction && (!strafe || occupant?.client?.keys_held["Alt"]))
		move_result = mechturn(direction)
	else
		set_glide_size(DELAY_TO_GLIDE_SIZE(step_time))
		move_result = mechstep(direction)
	if(move_result || loc != oldloc)// halfway done diagonal move still returns false
		use_power(step_energy_drain)
		if(leg_overload_mode)
			adjust_overheat(OVERLOAD_HEAT_COST * step_time)
		can_move = world.time + step_time
		return TRUE
	return FALSE

/obj/mecha/proc/mechturn(direction)
	setDir(direction)
	if(turnsound && has_gravity())
		playsound(src,turnsound,40,1)
	return TRUE

/obj/mecha/proc/mechstep(direction)
	var/current_dir = dir
	var/result = step(src,direction)
	if(strafe && !pivot_step)
		setDir(current_dir)
	if(result && stepsound && has_gravity())
		playsound(src,stepsound,40,1)
	return result

/obj/mecha/proc/mechsteprand()
	var/result = step_rand(src)
	if(result && stepsound && has_gravity())
		playsound(src,stepsound,40,1)
	return result

/obj/mecha/setDir()
	. = ..()
	if(occupant)
		occupant.setDir(dir) // keep the pilot facing the direction of the mech or bad things happen

/obj/mecha/Bump(atom/obstacle)
	var/turf/newloc = get_step(src,dir)
	var/area/newarea = newloc.loc

	if(phasing && ((newloc.turf_flags & NOJAUNT) || (newarea.area_flags & NOTELEPORT) || SSmapping.level_trait(newloc.z, ZTRAIT_NOPHASE)))
		to_chat(occupant, span_warning("Some strange aura is blocking the way."))
		return	//If we're trying to phase and it's NOT ALLOWED, don't bump

	if(istype(newloc, /turf/closed/indestructible))
		return	//If the turf is indestructible don't bother trying

	if(phasing && get_charge() >= phasing_energy_drain && !throwing)
		spawn()
			if(can_move)
				can_move = 0
				if(phase_state)
					flick(phase_state, src)
				forceMove(newloc)
				use_power(phasing_energy_drain)
				sleep(step_in * check_eva()*3)
				can_move = TRUE
	else
		if(..()) //mech was thrown
			return
		if(bumpsmash && occupant && !equipment_disabled && melee_can_hit) //Need a pilot to push the PUNCH button.
			default_melee_attack(obstacle, smashcooldown) //Non-equipment melee attack
			if(!obstacle || obstacle.CanPass(src,newloc))
				step(src,dir)
		if(isobj(obstacle))
			var/obj/O = obstacle
			if(!O.anchored)
				step(obstacle, dir)
		else if(ismob(obstacle))
			var/mob/M = obstacle
			if(!M.anchored)
				step(obstacle, dir)





///////////////////////////////////
////////  Internal damage  ////////
///////////////////////////////////

/obj/mecha/proc/check_for_internal_damage(list/possible_int_damage,ignore_threshold=null)
	if(!islist(possible_int_damage) || !length(possible_int_damage))
		return
	if(prob(20))
		if(ignore_threshold || atom_integrity*100/max_integrity < internal_damage_threshold)
			for(var/T in possible_int_damage)
				if(internal_damage & T)
					possible_int_damage -= T
			var/int_dam_flag = pick(possible_int_damage)
			if(int_dam_flag)
				setInternalDamage(int_dam_flag)
	if(prob(5))
		if(ignore_threshold || atom_integrity*100/max_integrity < internal_damage_threshold)
			var/obj/item/mecha_parts/mecha_equipment/ME = pick(equipment)
			if(ME)
				qdel(ME)
	return

/obj/mecha/proc/setInternalDamage(int_dam_flag)
	internal_damage |= int_dam_flag
	log_message("Internal damage of type [int_dam_flag].", LOG_MECHA)
	SEND_SOUND(occupant, sound('sound/machines/warning-buzzer.ogg',wait=0))
	diag_hud_set_mechstat()
	return

/obj/mecha/proc/clearInternalDamage(int_dam_flag)
	if(internal_damage & int_dam_flag)
		switch(int_dam_flag)
			if(MECHA_INT_TEMP_CONTROL)
				occupant_message(span_boldnotice("Life support system reactivated."))
			if(MECHA_INT_FIRE)
				occupant_message(span_boldnotice("Internal fire extinquished."))
			if(MECHA_INT_TANK_BREACH)
				occupant_message(span_boldnotice("Damaged internal tank has been sealed."))
	internal_damage &= ~int_dam_flag
	diag_hud_set_mechstat()

/////////////////////////////////////
//////////// AI piloting ////////////
/////////////////////////////////////

/obj/mecha/attack_ai(mob/living/silicon/ai/user)
	if(!isAI(user))
		return
	//Allows the Malf to scan a mech's status and loadout, helping it to decide if it is a worthy chariot.
	if(user.can_dominate_mechs)
		examine(user) //Get diagnostic information!
		if(user.nuking)
			to_chat(user, span_warning("Unable to assume control of mech while attempting to self-destruct the station."))
			return
		for(var/obj/item/mecha_parts/mecha_tracking/B in trackers)
			to_chat(user, span_danger("Warning: Tracking Beacon detected. Enter at your own risk. Beacon Data:"))
			to_chat(user, "[B.get_mecha_info()]")
			break
		//Nothing like a big, red link to make the player feel powerful!
		to_chat(user, "<a href='byond://?src=[REF(user)];ai_take_control=[REF(src)]'>[span_userdanger("ASSUME DIRECT CONTROL?")]</a><br>")
	else
		examine(user)
		if(occupant)
			to_chat(user, span_warning("This exosuit has a pilot and cannot be controlled."))
			return
		var/can_control_mech = FALSE
		for(var/obj/item/mecha_parts/mecha_tracking/ai_control/A in trackers)
			can_control_mech = TRUE
			to_chat(user, "[span_notice("[icon2html(src, user)] Status of [name]:")]\n[A.get_mecha_info()]")
			break
		if(!can_control_mech)
			to_chat(user, span_warning("You cannot control exosuits without AI control beacons installed."))
			return
		to_chat(user, "<a href='byond://?src=[REF(user)];ai_take_control=[REF(src)]'>[span_boldnotice("Take control of exosuit?")]</a><br>")

/obj/mecha/transfer_ai(interaction, mob/user, mob/living/silicon/ai/AI, obj/item/aicard/card)
	if(!..())
		return

 //Transfer from core or card to mech. Proc is called by mech.
	switch(interaction)
		if(AI_TRANS_TO_CARD) //Upload AI from mech to AI card.
			if(!state && !wrecked) //Mech must be in maint mode to allow carding, unless it's been completely wrecked.
				to_chat(user, span_warning("[name] must have maintenance protocols active in order to allow a transfer."))
				return
			AI = occupant
			if(!AI || !isAI(occupant)) //Mech does not have an AI for a pilot
				to_chat(user, span_warning("No AI detected in the [name] onboard computer."))
				return
			AI.ai_restore_power()//So the AI initially has power.
			AI.control_disabled = TRUE
			AI.radio_enabled = FALSE
			AI.disconnect_shell()
			RemoveActions(AI, TRUE)
			occupant = null
			silicon_pilot = FALSE
			AI.forceMove(card)
			card.AI = AI
			AI.controlled_mech = null
			AI.remote_control = null
			update_appearance(UPDATE_ICON)
			to_chat(AI, "You have been downloaded to a mobile storage device. Wireless connection offline.")
			to_chat(user, "[span_boldnotice("Transfer successful")]: [AI.name] ([rand(1000,9999)].exe) removed from [name] and stored within local memory.")

		if(AI_MECH_HACK) //Called by AIs on the mech
			if(wrecked)
				to_chat(AI, span_warning("Exosuit not responding. Aborting."))
				return
			if(AI.can_dominate_mechs)
				if(occupant) //Oh, I am sorry, were you using that?
					to_chat(AI, span_warning("Pilot detected! Forced ejection initiated!"))
					to_chat(occupant, span_danger("You have been forcibly ejected!"))
					go_out(1) //IT IS MINE, NOW. SUCK IT, RD!
			ai_enter_mech(AI, interaction)

		if(AI_TRANS_FROM_CARD) //Using an AI card to upload to a mech.
			if(wrecked)
				to_chat(user, span_warning("This mech is too damaged!"))
				return
			AI = card.AI
			if(!AI)
				to_chat(user, span_warning("There is no AI currently installed on this device."))
				return
			if(AI.deployed_shell) //Recall AI if shelled so it can be checked for a client
				AI.disconnect_shell()
			if(AI.stat || !AI.client)
				to_chat(user, span_warning("[AI.name] is currently unresponsive, and cannot be uploaded."))
				return
			if(occupant || dna_lock) //Normal AIs cannot steal mechs!
				to_chat(user, span_warning("Access denied. [name] is [occupant ? "currently occupied" : "secured with a DNA lock"]."))
				return
			AI.control_disabled = FALSE
			AI.radio_enabled = TRUE
			to_chat(user, "[span_boldnotice("Transfer successful")]: [AI.name] ([rand(1000,9999)].exe) installed and executed successfully. Local copy has been removed.")
			card.AI = null
			ai_enter_mech(AI, interaction)

//Hack and From Card interactions share some code, so leave that here for both to use.
/obj/mecha/proc/ai_enter_mech(mob/living/silicon/ai/AI, interaction)
	AI.ai_restore_power()
	AI.forceMove(src)
	occupant = AI
	silicon_pilot = TRUE
	icon_state = initial(icon_state)
	update_appearance()
	playsound(src, 'sound/machines/windowdoor.ogg', 50, 1)
	if(!internal_damage)
		SEND_SOUND(occupant, sound('sound/mecha/nominal.ogg',volume=50))
	AI.eyeobj?.forceMove(src)
	AI.eyeobj?.RegisterSignal(src, COMSIG_MOVABLE_MOVED, TYPE_PROC_REF(/mob/camera/ai_eye, update_visibility))
	AI.controlled_mech = src
	AI.remote_control = src
	AI.mobility_flags = ALL //Much easier than adding AI checks! Be sure to set this back to 0 if you decide to allow an AI to leave a mech somehow.
	AI.can_shunt = FALSE //ONE AI ENTERS. NO AI LEAVES.
	to_chat(AI, AI.can_dominate_mechs ? span_announce("Takeover of [name] complete! You are now loaded onto the onboard computer. Do not attempt to leave the station sector!") :\
		span_notice("You have been uploaded to a mech's onboard computer."))
	to_chat(AI, "<span class='reallybig boldnotice'>Use Middle-Mouse to activate mech functions and equipment. Click normally for AI interactions.</span>")
	register_occupant(AI)
	if(interaction == AI_TRANS_FROM_CARD)
		GrantActions(AI, FALSE) //No eject/return to core action for AI uploaded by card
	else
		GrantActions(AI, !AI.can_dominate_mechs)


//An actual AI (simple_animal mecha pilot) entering the mech
/obj/mecha/proc/aimob_enter_mech(mob/living/simple_animal/hostile/syndicate/mecha_pilot/pilot_mob)
	if(pilot_mob && pilot_mob.Adjacent(src))
		if(occupant)
			return
		icon_state = initial(icon_state)
		occupant = pilot_mob
		pilot_mob.mecha = src
		pilot_mob.forceMove(src)
		register_occupant(pilot_mob)
		GrantActions(pilot_mob)//needed for checks, and incase a badmin puts somebody in the mob

/obj/mecha/proc/aimob_exit_mech(mob/living/simple_animal/hostile/syndicate/mecha_pilot/pilot_mob)
	if(occupant == pilot_mob)
		occupant = null
	if(pilot_mob.mecha == src)
		pilot_mob.mecha = null
	pilot_mob.forceMove(get_turf(src))
	update_appearance(UPDATE_ICON)
	register_occupant(pilot_mob)
	RemoveActions(pilot_mob)


/////////////////////////////////////
////////  Atmospheric stuff  ////////
/////////////////////////////////////

/obj/mecha/remove_air(amount)
	if(use_internal_tank)
		return cabin_air.remove(amount)
	return ..()

/obj/mecha/remove_air_ratio(ratio)
	if(use_internal_tank)
		return cabin_air.remove_ratio(ratio)
	return ..()

/obj/mecha/return_air()
	if(use_internal_tank)
		return cabin_air
	return ..()

/obj/mecha/return_analyzable_air()
	return cabin_air

/obj/mecha/proc/return_pressure()
	var/datum/gas_mixture/t_air = return_air()
	if(t_air)
		. = t_air.return_pressure()
	return

/obj/mecha/return_temperature()
	var/datum/gas_mixture/t_air = return_air()
	if(t_air)
		. = t_air.return_temperature()
	return

/obj/mecha/MouseDrop_T(mob/M, mob/user)
	if (!user.canUseTopic(src) || (user != M))
		return
	if(!ishuman(user)) // no silicons or drones in mechas.
		return
	log_message("[user] tries to move in.", LOG_MECHA)
	if (occupant)
		to_chat(usr, span_warning("The [name] is already occupied!"))
		log_message("Permission denied (Occupied).", LOG_MECHA)
		return
	if(dna_lock)
		var/passed = FALSE
		if(user.has_dna())
			var/mob/living/carbon/C = user
			if(C.dna.unique_enzymes==dna_lock)
				passed = TRUE
		if (!passed)
			to_chat(user, span_warning("Access denied. [name] is secured with a DNA lock."))
			log_message("Permission denied (DNA LOCK).", LOG_MECHA)
			return
	if(!operation_allowed(user))
		to_chat(user, span_warning("Access denied. Insufficient operation keycodes."))
		log_message("Permission denied (No keycode).", LOG_MECHA)
		return
	if(user.buckled)
		to_chat(user, span_warning("You are currently buckled and cannot move."))
		log_message("Permission denied (Buckled).", LOG_MECHA)
		return
	if(user.has_buckled_mobs()) //mob attached to us
		to_chat(user, span_warning("You can't enter the exosuit with other creatures attached to you!"))
		log_message("Permission denied (Attached mobs).", LOG_MECHA)
		return

	visible_message("[user] starts to climb into [name].")

	if(do_after(user, round(enter_delay * (check_eva(user)**2)), src, IGNORE_SKILL_DELAY, skill_check = SKILL_TECHNICAL))
		if(atom_integrity <= 0)
			to_chat(user, span_warning("You cannot get in the [name], it has been destroyed!"))
		else if(occupant)
			to_chat(user, span_danger("[occupant] was faster! Try better next time, loser."))
		else if(user.buckled)
			to_chat(user, span_warning("You can't enter the exosuit while buckled."))
		else if(user.has_buckled_mobs())
			to_chat(user, span_warning("You can't enter the exosuit with other creatures attached to you!"))
		else
			moved_inside(user)
	else
		to_chat(user, span_warning("You stop entering the exosuit!"))
	return

/obj/mecha/proc/register_occupant(mob/living/new_occupant)
	RegisterSignal(new_occupant, COMSIG_MOVABLE_KEYBIND_FACE_DIR, PROC_REF(on_turn))

/obj/mecha/proc/unregister_occupant(mob/living/old_occupant)
	UnregisterSignal(old_occupant, COMSIG_MOVABLE_KEYBIND_FACE_DIR)

/obj/mecha/proc/on_turn()
	SIGNAL_HANDLER
	return COMSIG_IGNORE_MOVEMENT_LOCK

/obj/mecha/proc/moved_inside(mob/living/carbon/human/H)
	if(H && H.client && (H in range(1)))
		occupant = H
		H.forceMove(src)
		H.update_mouse_pointer()
		add_fingerprint(H)
		GrantActions(H, human_occupant=1)
		forceMove(loc)
		log_message("[H] moved in as pilot.", LOG_MECHA)
		icon_state = initial(icon_state)
		setDir(dir_in)
		playsound(src, 'sound/machines/windowdoor.ogg', 50, 1)
		register_occupant(H)
		if(!internal_damage)
			SEND_SOUND(occupant, sound('sound/mecha/nominal.ogg',volume=50))
		return 1
	else
		return 0

/obj/mecha/proc/mmi_move_inside(obj/item/mmi/mmi_as_oc, mob/user)
	if(!mmi_as_oc.brainmob || !mmi_as_oc.brainmob.client)
		to_chat(user, span_warning("Consciousness matrix not detected!"))
		return FALSE
	else if(mmi_as_oc.brainmob.stat)
		to_chat(user, span_warning("Beta-rhythm below acceptable level!"))
		return FALSE
	else if(occupant)
		to_chat(user, span_warning("Occupant detected!"))
		return FALSE
	else if(dna_lock && (!mmi_as_oc.brainmob.stored_dna || (dna_lock != mmi_as_oc.brainmob.stored_dna.unique_enzymes)))
		to_chat(user, span_warning("Access denied. [name] is secured with a DNA lock."))
		return FALSE

	visible_message(span_notice("[user] starts to insert an MMI into [name]."))

	if(do_after(user, 4 SECONDS, src))
		if(!occupant)
			return mmi_moved_inside(mmi_as_oc, user)
		else
			to_chat(user, span_warning("Occupant detected!"))
	else
		to_chat(user, span_notice("You stop inserting the MMI."))
	return FALSE

/obj/mecha/proc/mmi_moved_inside(obj/item/mmi/mmi_as_oc, mob/user)
	if(!(Adjacent(mmi_as_oc) && Adjacent(user)))
		return FALSE
	if(!mmi_as_oc.brainmob || !mmi_as_oc.brainmob.client)
		to_chat(user, span_notice("Consciousness matrix not detected!"))
		return FALSE
	else if(mmi_as_oc.brainmob.stat)
		to_chat(user, span_warning("Beta-rhythm below acceptable level!"))
		return FALSE
	if(!user.transferItemToLoc(mmi_as_oc, src))
		to_chat(user, span_warning("\the [mmi_as_oc] is stuck to your hand, you cannot put it in \the [src]!"))
		return FALSE
	var/mob/living/brainmob = mmi_as_oc.brainmob
	mmi_as_oc.mecha = src
	occupant = brainmob
	silicon_pilot = TRUE
	brainmob.forceMove(src) //should allow relaymove
	brainmob.reset_perspective(src)
	brainmob.remote_control = src
	brainmob.update_mobility()
	brainmob.update_mouse_pointer()
	icon_state = initial(icon_state)
	update_appearance(UPDATE_ICON)
	setDir(dir_in)
	register_occupant(mmi_as_oc)
	log_message("[mmi_as_oc] moved in as pilot.", LOG_MECHA)
	if(istype(mmi_as_oc, /obj/item/mmi/posibrain))											//yogs start reminder to posibrain to not be shitlers
		to_chat(brainmob, "<b>As a synthetic intelligence, you answer to all crewmembers and the AI.\n\
		Remember, the purpose of your existence is to serve the crew and the station. Above all else, do no harm.</b>")
	else
		to_chat(brainmob, "<b>If you were a member of the crew, you still are! Do not use this new form as an excuse to break rules. Similarly, if you were an antagonist, you still are!</b>")//yogs end
	if(!internal_damage)
		SEND_SOUND(occupant, sound('sound/mecha/nominal.ogg',volume=50))
	GrantActions(brainmob)
	return TRUE

/obj/mecha/proc/remove_mmi(mob/user)
	if(!silicon_pilot) // this should be impossible unless someone is messing with the client to do unintended things
		CRASH("[type] called remove_mmi() without having a silicon pilot!")
	var/mob/living/brain/brainmob = occupant
	go_out(FALSE, get_turf(src)) // eject any silicon pilot, including AIs
	if(!istype(brainmob)) // if there wasn't a brain inside, no need to continue
		return
	var/obj/item/mmi/mmi = brainmob.container
	if(user && !user.put_in_hands(mmi))
		mmi.forceMove(get_turf(user))

/obj/mecha/container_resist(mob/living/user)
	is_currently_ejecting = TRUE
	to_chat(occupant, "<span class='notice'>You begin the ejection procedure. Equipment is disabled during this process. Hold still to finish ejecting.<span>")
	if(do_after(occupant, round(exit_delay * (check_eva(user)**2)), src, IGNORE_SKILL_DELAY, skill_check = SKILL_TECHNICAL))
		to_chat(occupant, "<span class='notice'>You exit the mech.<span>")
		go_out()
	else
		to_chat(occupant, "<span class='notice'>You stop exiting the mech. Weapons are enabled again.<span>")
	is_currently_ejecting = FALSE

/obj/mecha/Exited(atom/movable/M, atom/newloc)
	if(occupant && occupant == M) // The occupant exited the mech without calling go_out()
		go_out(FALSE, newloc) // Voice of god breaks things (such as gibbing AI)

	if(cell && cell == M)
		cell = null
		return
	if(scanmod && scanmod == M)
		scanmod = null
		return
	if(capacitor && capacitor == M)
		capacitor = null
		return

/obj/mecha/proc/go_out(forced, atom/newloc = loc)
	if(!occupant)
		return
	var/atom/movable/mob_container
	var/is_ai_user = FALSE
	occupant.clear_alert("charge")
	occupant.clear_alert("mech damage")
	occupant.clear_alert("mech_overheat")
	if(ishuman(occupant))
		mob_container = occupant
		RemoveActions(occupant, human_occupant=1)
		unregister_occupant(occupant)
	else if(isbrain(occupant))
		var/mob/living/brain/brain = occupant
		RemoveActions(brain)
		unregister_occupant(occupant)
		mob_container = brain.container
	else if(isAI(occupant))
		var/mob/living/silicon/ai/AI = occupant
		if(forced)//This should only happen if there are multiple AIs in a round, and at least one is Malf.
			RemoveActions(occupant)
			unregister_occupant(occupant)
			occupant.gib()  //If one Malf decides to steal a mech from another AI (even other Malfs!), they are destroyed, as they have nowhere to go when replaced.
			occupant = null
			silicon_pilot = FALSE
			return
		else
			to_chat(AI, span_notice("Attempting to return to core..."))
			AI.controlled_mech = null
			AI.remote_control = null
			RemoveActions(occupant, 1)
			unregister_occupant(occupant)
			mob_container = AI
			newloc = null
			if(GLOB.primary_data_core)
				newloc = GLOB.primary_data_core
			else if(LAZYLEN(GLOB.data_cores))
				newloc = GLOB.data_cores[1]

			if(!istype(newloc, /obj/machinery/ai/data_core))
				to_chat(AI, span_userdanger("No cores available. Core code corrupted."))

			is_ai_user = TRUE
	else
		return
	var/mob/living/L = occupant
	occupant = null //we need it null when forceMove calls Exited().
	silicon_pilot = FALSE
	if(mob_container.forceMove(newloc))//ejecting mob container
		log_message("[mob_container] moved out.", LOG_MECHA)
		L << browse(null, "window=exosuit")

		if(istype(mob_container, /obj/item/mmi))
			var/obj/item/mmi/mmi = mob_container
			if(mmi.brainmob)
				L.forceMove(mmi)
				L.reset_perspective()
				L.remote_control = null
			mmi.mecha = null
			mmi.update_appearance(UPDATE_ICON)
			L.mobility_flags = NONE
		update_appearance(UPDATE_ICON)
		setDir(dir_in)
		if(is_ai_user)
			var/mob/living/silicon/ai/AI = occupant
			AI.relocate(TRUE)


	if(L && L.client)
		L.update_mouse_pointer()
		L.client.view_size.resetToDefault()
		zoom_mode = 0

/////////////////////////
////// Access stuff /////
/////////////////////////

/obj/mecha/proc/operation_allowed(mob/M)
	req_access = operation_req_access
	req_one_access = list()
	return allowed(M)

/obj/mecha/proc/internals_access_allowed(mob/M)
	req_one_access = internals_req_access
	req_access = list()
	return allowed(M)



////////////////////////////////
/////// Messages and Log ///////
////////////////////////////////

/obj/mecha/proc/occupant_message(message as text)
	if(message)
		if(occupant && occupant.client)
			to_chat(occupant, "[icon2html(src, occupant)] [message]")
	return

GLOBAL_VAR_INIT(year, time2text(world.realtime,"YYYY"))
GLOBAL_VAR_INIT(year_integer, text2num(year)) // = 2013???

///////////////////////
///// Power stuff /////
///////////////////////

/obj/mecha/proc/has_charge(amount)
	return (get_charge()>=amount)

/obj/mecha/proc/get_charge()
	for(var/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay/R in equipment)
		var/relay_charge = R.get_charge()
		if(relay_charge)
			return relay_charge
	if(cell)
		return max(0, cell.charge)

/obj/mecha/proc/use_power(amount)
	amount *= (2.5 - (scanmod.rating / 2)) // 0-5: 2.5x, 2x, 1.5x, 1x, 0.5x
	if(get_charge())
		cell.use(amount)
		diag_hud_set_mechcell(amount)
		return TRUE
	return FALSE

/obj/mecha/proc/give_power(amount)
	if(!isnull(get_charge()))
		cell.give(amount)
		diag_hud_set_mechcell(amount)
		return TRUE
	return FALSE

/obj/mecha/update_remote_sight(mob/living/user)
	if(occupant_sight_flags)
		if(user == occupant)
			user.sight |= occupant_sight_flags

///////////////////////
////// Ammo stuff /////
///////////////////////

/obj/mecha/proc/ammo_resupply(obj/item/mecha_ammo/A, mob/user, fail_chat_override = FALSE)
	if(!A.rounds)
		if(!fail_chat_override)
			to_chat(user, span_warning("This box of ammo is empty!"))
		return FALSE
	var/ammo_needed
	var/found_gun
	for(var/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/gun in equipment)
		ammo_needed = 0

		if(istype(gun, /obj/item/mecha_parts/mecha_equipment/weapon/ballistic) && gun.ammo_type == A.ammo_type)
			found_gun = TRUE
			if(A.direct_load)
				ammo_needed = initial(gun.projectiles) - gun.projectiles
			else
				ammo_needed = gun.projectiles_cache_max - gun.projectiles_cache

			if(ammo_needed)
				if(ammo_needed < A.rounds)
					if(A.direct_load)
						gun.projectiles = gun.projectiles + ammo_needed
					else
						gun.projectiles_cache = gun.projectiles_cache + ammo_needed
					playsound(get_turf(user),A.load_audio,50,1)
					to_chat(user, span_notice("You add [ammo_needed] [A.round_term][ammo_needed > 1?"s":""] to the [gun.name]"))
					A.rounds = A.rounds - ammo_needed
					A.update_appearance(UPDATE_NAME)
					return TRUE

				else
					if(A.direct_load)
						gun.projectiles = gun.projectiles + A.rounds
					else
						gun.projectiles_cache = gun.projectiles_cache + A.rounds
					playsound(get_turf(user),A.load_audio,50,1)
					to_chat(user, span_notice("You add [A.rounds] [A.round_term][A.rounds > 1?"s":""] to the [gun.name]"))
					A.rounds = 0
					A.update_appearance(UPDATE_NAME)
					return TRUE
	if(!fail_chat_override)
		if(found_gun)
			to_chat(user, span_notice("You can't fit any more ammo of this type!"))
		else
			to_chat(user, span_notice("None of the equipment on this exosuit can use this ammo!"))
	return FALSE

// Matter resupply and upgrades for mounted RCDs
/obj/mecha/proc/matter_resupply(obj/item/I, mob/user)
	for(var/obj/item/mecha_parts/mecha_equipment/rcd/R in equipment)
		. = R.internal_rcd.attackby(I, user)
		if(QDELETED(I))
			return

// Check the pilot for mech piloting skill
/obj/mecha/proc/check_eva(mob/pilot)
	if(!pilot)
		pilot = occupant
	var/effective_skill = pilot.get_skill(SKILL_TECHNICAL)
	if(HAS_TRAIT(pilot, TRAIT_SKILLED_PILOT) || HAS_MIND_TRAIT(pilot, TRAIT_SKILLED_PILOT))
		effective_skill += EXP_LOW
	return 1 + (2 - effective_skill) * 0.075
