
// Teleporter, Wormhole generator, Gravitational catapult, Armor booster modules,
// Repair droid, Tesla Energy relay, Generators

////////////////////////////////////////////// TELEPORTER ///////////////////////////////////////////////

/obj/item/mecha_parts/mecha_equipment/teleporter
	name = "mounted teleporter"
	desc = "An exosuit module that allows exosuits to teleport to any position in view."
	icon_state = "mecha_teleport"
	equip_cooldown = 150
	energy_drain = 1000
	range = MECHA_RANGED

/obj/item/mecha_parts/mecha_equipment/teleporter/action_checks(atom/target)
	var/area/start_area = get_area(chassis)
	var/area/end_area = get_area(target)
	if((start_area.area_flags|end_area.area_flags) & NOTELEPORT)
		return FALSE
	return ..()

/obj/item/mecha_parts/mecha_equipment/teleporter/action(atom/target)
	var/turf/T = get_turf(target)
	if(T)
		do_teleport(chassis, T, 4, channel = TELEPORT_CHANNEL_BLUESPACE)
		return 1



////////////////////////////////////////////// WORMHOLE GENERATOR //////////////////////////////////////////

/obj/item/mecha_parts/mecha_equipment/wormhole_generator
	name = "mounted wormhole generator"
	desc = "An exosuit module that allows generating of small quasi-stable wormholes."
	icon_state = "mecha_wholegen"
	equip_cooldown = 50
	energy_drain = 300
	range = MECHA_RANGED

/obj/item/mecha_parts/mecha_equipment/wormhole_generator/action_checks(atom/target)
	var/area/start_area = get_area(chassis)
	var/area/end_area = get_area(target)
	if((start_area.area_flags|end_area.area_flags) & NOTELEPORT)
		return FALSE
	return ..()

/obj/item/mecha_parts/mecha_equipment/wormhole_generator/action(atom/target)
	var/list/theareas = get_areas_in_range(100, chassis)
	if(!theareas.len)
		return
	var/area/thearea = pick(theareas)
	var/list/L = list()
	var/turf/pos = get_turf(src)
	for(var/turf/T in get_area_turfs(thearea.type))
		if(!T.density && pos.z == T.z)
			var/clear = 1
			for(var/obj/O in T)
				if(O.density)
					clear = 0
					break
			if(clear)
				L+=T
	if(!L.len)
		return
	var/turf/target_turf = pick(L)
	if(!target_turf)
		return
	var/list/obj/effect/portal/created = create_portal_pair(get_turf(src), target_turf, src, 300, 1, /obj/effect/portal/anom)
	var/turf/T = get_turf(target)
	message_admins("[ADMIN_LOOKUPFLW(chassis.occupant)] used a Wormhole Generator in [ADMIN_VERBOSEJMP(T)]")
	log_game("[key_name(chassis.occupant)] used a Wormhole Generator in [AREACOORD(T)]")
	src = null
	QDEL_LIST_IN(created, rand(150,300))
	return 1


/////////////////////////////////////// GRAVITATIONAL CATAPULT ///////////////////////////////////////////

/obj/item/mecha_parts/mecha_equipment/gravcatapult
	name = "mounted gravitational catapult"
	desc = "An exosuit mounted Gravitational Catapult."
	icon_state = "mecha_teleport"
	equip_cooldown = 10
	energy_drain = 100
	range = MECHA_MELEE|MECHA_RANGED
	var/atom/movable/locked
	var/datum/beam/gravity_beam

/obj/item/mecha_parts/mecha_equipment/gravcatapult/detach(atom/moveto)
	set_target(null)
	return ..()

/obj/item/mecha_parts/mecha_equipment/gravcatapult/action(atom/movable/target, mob/living/user, params)
	var/list/modifiers = params2list(params)
	if(modifiers[RIGHT_CLICK])
		if(locked)
			set_target(null)
			return
		if(get_dist(chassis, target) > 7)
			balloon_alert(chassis.occupant, "too far!")
			return
		if(!ismovable(target) || target.anchored || target.move_resist >= INFINITY)
			return
		if(ismob(target))
			var/mob/M = target
			if(M.mob_negates_gravity())
				occupant_message("Unable to lock on [target]")
				return
		set_target(target)
		return
	else if(locked)
		var/turf/targ = get_turf(target)
		var/turf/orig = get_turf(locked)
		locked.throw_at(target, 14, 1.5)
		set_target(null)
		send_byjax(chassis.occupant,"exosuit.browser","[REF(src)]",src.get_equip_info())
		log_game("[key_name(chassis.occupant)] used a Gravitational Catapult to throw [locked] (From [AREACOORD(orig)]) at [target] ([AREACOORD(targ)]).")
		return TRUE
	else
		var/turf/center
		if(user.client) //try to get the precise angle to the user's mouse rather than just the tile clicked on
			center = get_turf_in_angle(mouse_angle_from_client(user.client), get_turf(chassis))
		if(!center) //if no fancy targeting has happened, default to something alright
			center = get_turf_in_angle(get_angle(chassis, target), get_turf(chassis))
		to_chat(chassis.occupant, "Repulse Epicenter: [center] ([center?.x],[center?.y])")
		new /obj/effect/temp_visual/kinetic_blast(center)

		INVOKE_ASYNC(src, PROC_REF(do_repulse), center, user)
		return TRUE

/obj/item/mecha_parts/mecha_equipment/gravcatapult/proc/do_repulse(turf/center, mob/user)
	playsound(center, 'sound/weapons/resonator_blast.ogg', 50, 1)
	var/atom/movable/gravity_lens/shockwave = new(get_turf(center))
	shockwave.transform *= 0.1 //basically invisible
	shockwave.pixel_x = -240
	shockwave.pixel_y = -240
	shockwave.alpha = 200 //slightly weaker looking
	animate(shockwave, alpha = 0, transform = matrix().Scale(0.24), time = 3)//the scale of this is VERY finely tuned to range
	QDEL_IN(shockwave, 4)

	chassis.visible_message(span_warning("[chassis] repels everything in front of it!"))

	var/throw_dir = get_dir(chassis, center)
	for(var/atom/movable/hit_atom in range(1, center))
		if(hit_atom == chassis)
			continue
		if(!hit_atom.anchored)
			hit_atom.throw_at(get_edge_target_turf(hit_atom, throw_dir), 5, 2, user, TRUE)
		if(isitem(hit_atom))
			return
		if(hit_atom.uses_integrity) // damages structures
			var/damage = 15
			if(get_turf(hit_atom) == center)
				damage *= 2 //anything in the center takes more
			hit_atom.take_damage(damage, sound_effect = FALSE)

	log_game("[key_name(chassis.occupant)] used a Gravitational Catapult repulse wave on [AREACOORD(center)]")

/obj/item/mecha_parts/mecha_equipment/gravcatapult/proc/set_target(atom/movable/target)
	if(target == locked)
		return
	if(gravity_beam)
		QDEL_NULL(gravity_beam)
	if(locked)
		UnregisterSignal(locked, COMSIG_MOVABLE_MOVED, PROC_REF(target_check))
		UnregisterSignal(chassis, COMSIG_MOVABLE_MOVED, PROC_REF(target_check))
	if(!target)
		locked = null
		send_byjax(chassis.occupant, "exosuit.browser", "[REF(src)]", src.get_equip_info())
		return
	locked = target
	gravity_beam = chassis.Beam(target, "rped_upgrade", time = INFINITY)
	send_byjax(chassis.occupant,"exosuit.browser", "[REF(src)]", src.get_equip_info())
	RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(target_check))
	RegisterSignal(chassis, COMSIG_MOVABLE_MOVED, PROC_REF(target_check))

/obj/item/mecha_parts/mecha_equipment/gravcatapult/proc/target_check()
	if(!locked)
		return
	if(get_dist(chassis, locked) > 7)
		set_target(null)


////////////////////////////////// REPAIR DROID //////////////////////////////////////////////////


/obj/item/mecha_parts/mecha_equipment/repair_droid
	name = "exosuit repair droid"
	desc = "An automated repair droid for exosuits. Scans for damage and repairs it. Can fix almost all types of external or internal damage."
	icon_state = "repair_droid"
	energy_drain = 25
	heat_cost = 5
	range = 0
	var/health_boost = 2
	var/icon/droid_overlay
	var/list/repairable_damage = list(MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH)
	equip_actions = list(/datum/action/innate/mecha/equipment/toggle_repair)
	selectable = 0

/obj/item/mecha_parts/mecha_equipment/repair_droid/Destroy()
	if(chassis)
		chassis.cut_overlay(droid_overlay)
	return ..()

/obj/item/mecha_parts/mecha_equipment/repair_droid/attach(obj/mecha/M as obj)
	. = ..()
	droid_overlay = new(src.icon, icon_state = "repair_droid")
	M.add_overlay(droid_overlay)
	RegisterSignal(chassis, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(update_chassis_overlays))

/obj/item/mecha_parts/mecha_equipment/repair_droid/detach()
	chassis.cut_overlay(droid_overlay)
	UnregisterSignal(chassis, COMSIG_ATOM_UPDATE_OVERLAYS)
	return ..()

/obj/item/mecha_parts/mecha_equipment/repair_droid/proc/update_chassis_overlays(atom/source, list/overlays)
	overlays += droid_overlay

/obj/item/mecha_parts/mecha_equipment/repair_droid/on_process(delta_time)
	if(!chassis || chassis.wrecked)
		return PROCESS_KILL
	var/h_boost = health_boost * delta_time
	var/repaired = FALSE
	if(chassis.internal_damage & MECHA_INT_SHORT_CIRCUIT)
		h_boost *= -1
	else if(chassis.internal_damage && prob(15))
		for(var/int_dam_flag in repairable_damage)
			if(chassis.internal_damage & int_dam_flag)
				chassis.clearInternalDamage(int_dam_flag)
				repaired = 1
				break
	if(h_boost < 0)
		chassis.take_damage(-h_boost)
		repaired = TRUE
	if(chassis.get_integrity() < chassis.max_integrity && h_boost > 0)
		chassis.repair_damage(h_boost)
		repaired = TRUE
	if(repaired)
		chassis.adjust_overheat(heat_cost * delta_time)
		if(!chassis.use_power(energy_drain * delta_time))
			chassis.update_appearance(UPDATE_OVERLAYS)
			return PROCESS_KILL

/datum/action/innate/mecha/equipment/toggle_repair
	name = "Toggle Repairs"
	button_icon_state = "mech_repair_off"

/datum/action/innate/mecha/equipment/toggle_repair/Activate()
	var/obj/item/mecha_parts/mecha_equipment/repair_droid/repair_droid = equipment
	repair_droid.active = !repair_droid.active
	repair_droid.log_message(repair_droid.active ? "Activated." : "Deactivated.", LOG_MECHA)
	repair_droid.droid_overlay = new(repair_droid.icon, icon_state = "repair_droid[repair_droid.active ? "_a" : ""]")
	chassis.update_appearance(UPDATE_OVERLAYS)
	build_all_button_icons()

/datum/action/innate/mecha/equipment/toggle_repair/apply_button_icon(atom/movable/screen/movable/action_button/current_button, force)
	button_icon_state = "mech_repair_[equipment.active ? "on" : "off"]"
	return ..()

/////////////////////////////////// TESLA ENERGY RELAY ////////////////////////////////////////////////

/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay
	name = "exosuit energy relay"
	desc = "An exosuit module that wirelessly drains energy from any available power channel in area. The performance index is quite low."
	icon_state = "tesla"
	energy_drain = 0
	range = 0
	var/coeff = 100
	var/list/use_channels = list(AREA_USAGE_EQUIP,AREA_USAGE_ENVIRON,AREA_USAGE_LIGHT)
	selectable = 0

/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay/detach()
	active = FALSE
	return ..()

/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay/proc/get_charge()
	if(equip_ready) //disabled
		return
	var/area/A = get_area(chassis)
	var/pow_chan = get_mutation_power_channel(A)
	if(pow_chan)
		return 1000 //making magic


/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay/proc/get_mutation_power_channel(area/A)
	var/pow_chan
	if(A)
		for(var/c in use_channels)
			if(A.powered(c))
				pow_chan = c
				break
	return pow_chan

/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay/Topic(href, href_list)
	..()
	if(href_list["toggle_relay"])
		active = !active
		log_message(active ? "Activated." : "Deactivated.", LOG_MECHA)

/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay/get_equip_info()
	if(!chassis)
		return
	return "<span style=\"color:[equip_ready?"#0f0":"#f00"];\">*</span>&nbsp; [src.name] - <a href='byond://?src=[REF(src)];toggle_relay=1'>[equip_ready?"A":"Dea"]ctivate</a>"


/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay/on_process(delta_time)
	if(!chassis || chassis.internal_damage & MECHA_INT_SHORT_CIRCUIT)
		return PROCESS_KILL
	var/cur_charge = chassis.get_charge()
	if(isnull(cur_charge) || !chassis.cell)
		occupant_message("No powercell detected.")
		return PROCESS_KILL
	if(cur_charge < chassis.cell.maxcharge)
		var/area/A = get_area(chassis)
		if(A)
			var/pow_chan
			for(var/c in list(AREA_USAGE_EQUIP,AREA_USAGE_ENVIRON,AREA_USAGE_LIGHT))
				if(A.powered(c))
					pow_chan = c
					break
			if(pow_chan)
				var/delta = min(20, chassis.cell.maxcharge-cur_charge) * delta_time
				chassis.give_power(delta)
				A.use_power(delta*coeff, pow_chan)




/////////////////////////////////////////// GENERATOR /////////////////////////////////////////////


/obj/item/mecha_parts/mecha_equipment/generator
	name = "exosuit plasma converter"
	desc = "An exosuit module that generates power using solid plasma as fuel. Pollutes the environment."
	icon_state = "tesla"
	range = MECHA_MELEE
	var/coeff = 100
	var/obj/item/stack/sheet/fuel
	var/max_fuel = 150000
	var/fuel_per_cycle_idle = 25
	var/fuel_per_cycle_active = 200
	var/power_per_cycle = 20

/obj/item/mecha_parts/mecha_equipment/generator/Initialize(mapload)
	. = ..()
	generator_init()

/obj/item/mecha_parts/mecha_equipment/generator/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/mecha_parts/mecha_equipment/generator/proc/generator_init()
	fuel = new /obj/item/stack/sheet/mineral/plasma(src, 0)

/obj/item/mecha_parts/mecha_equipment/generator/detach()
	STOP_PROCESSING(SSobj, src)
	..()

/obj/item/mecha_parts/mecha_equipment/generator/Topic(href, href_list)
	..()
	if(href_list["toggle"])
		if(equip_ready) //inactive
			set_ready_state(0)
			START_PROCESSING(SSobj, src)
			log_message("Activated.", LOG_MECHA)
		else
			set_ready_state(1)
			STOP_PROCESSING(SSobj, src)
			log_message("Deactivated.", LOG_MECHA)

/obj/item/mecha_parts/mecha_equipment/generator/get_equip_info()
	var/output = ..()
	if(output)
		return "[output] \[[fuel]: [round(fuel.amount*fuel.mats_per_stack,0.1)] cm<sup>3</sup>\] - <a href='byond://?src=[REF(src)];toggle=1'>[equip_ready?"A":"Dea"]ctivate</a>"


/obj/item/mecha_parts/mecha_equipment/generator/action(target)
	if(chassis)
		var/result = load_fuel(target)
		if(result)
			send_byjax(chassis.occupant,"exosuit.browser","[REF(src)]",src.get_equip_info())

/obj/item/mecha_parts/mecha_equipment/generator/proc/load_fuel(obj/item/stack/sheet/P)
	if(P.type == fuel.type && P.amount > 0)
		var/to_load = max(max_fuel - fuel.amount*fuel.mats_per_stack,0)
		if(to_load)
			var/units = min(max(round(to_load / P.mats_per_stack),1),P.amount)
			fuel.amount += units
			P.use(units)
			occupant_message("[units] unit\s of [fuel] successfully loaded.")
			return units
		else
			occupant_message("Unit is full.")
			return 0
	else
		occupant_message(span_warning("[fuel] traces in target minimal! [P] cannot be used as fuel."))
		return

/obj/item/mecha_parts/mecha_equipment/generator/attackby(weapon,mob/user, params)
	load_fuel(weapon)

/obj/item/mecha_parts/mecha_equipment/generator/process()
	if(!chassis)
		STOP_PROCESSING(SSobj, src)
		set_ready_state(1)
		return
	if(fuel.amount<=0)
		STOP_PROCESSING(SSobj, src)
		log_message("Deactivated - no fuel.", LOG_MECHA)
		set_ready_state(1)
		return
	var/cur_charge = chassis.get_charge()
	if(isnull(cur_charge))
		set_ready_state(1)
		occupant_message("No powercell detected.")
		log_message("Deactivated.", LOG_MECHA)
		STOP_PROCESSING(SSobj, src)
		return
	var/use_fuel = fuel_per_cycle_idle
	if(cur_charge < chassis.cell.maxcharge)
		use_fuel = fuel_per_cycle_active
		chassis.give_power(power_per_cycle)
	fuel.amount -= min(use_fuel/fuel.mats_per_stack,fuel.amount)
	update_equip_info()
	return 1


/obj/item/mecha_parts/mecha_equipment/generator/nuclear
	name = "exonuclear reactor"
	desc = "An exosuit module that generates power using uranium as fuel. Pollutes the environment."
	icon_state = "tesla"
	max_fuel = 50000
	fuel_per_cycle_idle = 10
	fuel_per_cycle_active = 30
	power_per_cycle = 50
	var/rad_per_cycle = 30

/obj/item/mecha_parts/mecha_equipment/generator/nuclear/generator_init()
	fuel = new /obj/item/stack/sheet/mineral/uranium(src, 0)

/obj/item/mecha_parts/mecha_equipment/generator/nuclear/process()
	if(..())
		radiation_pulse(get_turf(src), rad_per_cycle)

/////////////////////////////////////////// THRUSTERS /////////////////////////////////////////////

/obj/item/mecha_parts/mecha_equipment/thrusters
	name = "generic exosuit thrusters" //parent object, in-game sources will be a child object
	desc = "A generic set of thrusters, from an unknown source. Uses not-understood methods to propel exosuits seemingly for free."
	icon_state = "thrusters"
	equip_actions = list(/datum/action/innate/mecha/equipment/toggle_thrusters)
	selectable = FALSE
	var/thrusters_active = FALSE
	var/datum/effect_system/trail_follow/thrust_trail = /datum/effect_system/trail_follow/sparks

/obj/item/mecha_parts/mecha_equipment/thrusters/Initialize(mapload)
	. = ..()
	thrust_trail = new thrust_trail
	thrust_trail.set_up(src)

/obj/item/mecha_parts/mecha_equipment/thrusters/try_attach_part(mob/user, obj/mecha/M)
	for(var/obj/item/mecha_parts/mecha_equipment/equip as anything in M.equipment)
		if(istype(equip, type))
			to_chat(user, span_warning("[src] already has thrusters!"))
			return FALSE
	return ..()

/obj/item/mecha_parts/mecha_equipment/thrusters/attach(obj/mecha/M)
	. = ..()
	if(thrusters_active)
		thrust_trail.start()
	RegisterSignal(M, COMSIG_MOVABLE_SPACEMOVE, PROC_REF(thrust))

/obj/item/mecha_parts/mecha_equipment/thrusters/detach(atom/moveto)
	UnregisterSignal(chassis, COMSIG_MOVABLE_SPACEMOVE)
	if(thrusters_active)
		thrust_trail.stop()
	return ..()

/obj/item/mecha_parts/mecha_equipment/thrusters/proc/thrust(obj/mecha/exo, movement_dir)
	if(!thrusters_active)
		return
	if(!chassis)
		return
	return COMSIG_MOVABLE_ALLOW_SPACEMOVE //This parent should never exist in-game outside admeme use, so why not let it be a creative thruster?

/obj/item/mecha_parts/mecha_equipment/thrusters/get_equip_info()
	return "[..()] \[<b>Thrusters: </b> [thrusters_active ? "Enabled" : "Disabled"]\]"

/obj/item/mecha_parts/mecha_equipment/thrusters/gas
	name = "RCS thruster package"
	desc = "A set of thrusters that allow for exosuit movement in zero-gravity environments, by expelling gas from the internal life support tank."
	thrust_trail = /datum/effect_system/trail_follow/smoke
	var/move_cost = 0.05 // moles per step (5 times more than human jetpacks)

/obj/item/mecha_parts/mecha_equipment/thrusters/gas/thrust(obj/mecha/exo, movement_dir)
	if(!thrusters_active)
		return
	if(!movement_dir)
		return
	var/obj/machinery/portable_atmospherics/canister/internal_tank = chassis.internal_tank
	if(!internal_tank)
		return
	var/datum/gas_mixture/our_mix = internal_tank.return_air()
	var/moles = our_mix.total_moles()
	if(moles < move_cost)
		thrusters_active = FALSE
		thrust_trail.stop()
		our_mix.remove(moles)
		return
	our_mix.remove(move_cost)
	return COMSIG_MOVABLE_ALLOW_SPACEMOVE

/obj/item/mecha_parts/mecha_equipment/thrusters/ion //for mechs with built-in thrusters, should never really exist un-attached to a mech
	name = "ion thruster package"
	desc = "A set of thrusters that allow for exosuit movement in zero-gravity environments."
	thrust_trail = /datum/effect_system/trail_follow/ion
	salvageable = FALSE

/obj/item/mecha_parts/mecha_equipment/thrusters/ion/thrust(obj/mecha/exo, movement_dir)
	if(!thrusters_active)
		return
	if(!chassis.use_power(chassis.step_energy_drain))
		thrusters_active = FALSE
		thrust_trail.stop()
		return
	return COMSIG_MOVABLE_ALLOW_SPACEMOVE

/obj/item/mecha_parts/mecha_equipment/thrusters/alien
	name = "anti-gravity engine"
	desc = "A set of thrusters from an unknown source. Uses not-understood methods to propel exosuits seemingly for free."

/obj/item/mecha_parts/mecha_equipment/thrusters/alien/attach(obj/mecha/new_mecha)
	. = ..()
	RegisterSignal(new_mecha, COMSIG_ATOM_HAS_GRAVITY, PROC_REF(grav_check))

/obj/item/mecha_parts/mecha_equipment/thrusters/alien/detach(atom/moveto)
	UnregisterSignal(chassis, COMSIG_ATOM_HAS_GRAVITY)
	return ..()

/obj/item/mecha_parts/mecha_equipment/thrusters/alien/proc/grav_check(obj/mecha/attached_mech, turf/location, list/gravs)
	if(!thrusters_active)
		return
	gravs.Add(0) // screw gravity!

/datum/action/innate/mecha/equipment/toggle_thrusters
	name = "Toggle Thrusters"
	button_icon_state = "mech_thrusters_off"

/datum/action/innate/mecha/equipment/toggle_thrusters/Activate()
	var/obj/item/mecha_parts/mecha_equipment/thrusters/thruster = equipment
	thruster.thrusters_active = !thruster.thrusters_active
	if(thruster.thrusters_active)
		thruster.thrust_trail.start()
	else
		thruster.thrust_trail.stop()
	chassis.log_message("Toggled thrusters.", LOG_MECHA)
	chassis.occupant_message("<font color='[thruster.thrusters_active ?"blue":"red"]'>Thrusters [thruster.thrusters_active ?"en":"dis"]abled.")
	button_icon_state = "mech_thrusters_[thruster.thrusters_active ? "on" : "off"]"
	build_all_button_icons()

/////////////////////////////////////////// EJECTION /////////////////////////////////////////////

/obj/item/mecha_parts/mecha_equipment/emergency_eject
	name = "emergency ejection system"
	desc = "An emergency quick-eject system designed to protect the pilot from injury if the exosuit suffers catastrophic damage."
	icon_state = "mecha_eject"
	var/ejection_distance = 8

/obj/item/mecha_parts/mecha_equipment/emergency_eject/attach(obj/mecha/M)
	. = ..()
	M.ejection_distance += ejection_distance

/obj/item/mecha_parts/mecha_equipment/emergency_eject/detach(atom/moveto)
	if(chassis)
		chassis.ejection_distance -= ejection_distance
	. = ..()

///// Coral Generator /////

/obj/item/mecha_parts/mecha_equipment/coral_generator
	name = "IA-C01G AORTA"
	desc = "A highly classified emergent technology, burns raw redspace crystal to enhance mech movement, as a side effect the mech will emit a red glow, greatly increasing energy usage."
	icon_state = "coral_engine" 
	selectable = FALSE // your mech IS the weapon
	var/minimum_damage = 10
	var/structure_damage_mult = 4
	var/list/hit_list = list()
	equip_actions = list(/datum/action/innate/mecha/coral_overload_mode)

/obj/item/mecha_parts/mecha_equipment/coral_generator/can_attach(obj/mecha/new_mecha)
	if(istype(new_mecha, /obj/mecha/combat/gygax)) // no gygax stacking sorry
		return FALSE
	if(locate(type) in new_mecha.equipment)
		return FALSE // no stacking multiple
	return ..()

/datum/action/innate/mecha/coral_overload_mode
	name = "Coral Engine Overload"
	button_icon_state = "mech_coral_overload_off"

/datum/action/innate/mecha/coral_overload_mode/Activate(forced_state = null)
	if(chassis?.equipment_disabled) // If a EMP or something has messed a mech up return instead of activating -- Moogle
		return
	if(!owner || !chassis || chassis.occupant != owner)
		return
	if(!isnull(forced_state))
		chassis.leg_overload_mode = forced_state
	else
		chassis.leg_overload_mode = !chassis.leg_overload_mode
	button_icon_state = "mech_coral_overload_[chassis.leg_overload_mode ? "on" : "off"]"
	chassis.log_message("Toggled coral engine overload.", LOG_MECHA)
	if(chassis.leg_overload_mode)
		chassis.AddComponent(/datum/component/after_image, 0.5 SECONDS, 0.5, TRUE)
		chassis.bumpsmash = TRUE
		chassis.leg_overload_mode = TRUE
		chassis.occupant_message(span_danger("You enable coral engine overload."))
	else
		var/datum/component/after_image/chassis_after_image = chassis.GetComponent(/datum/component/after_image)
		if(chassis_after_image)
			qdel(chassis_after_image)
		chassis.bumpsmash = FALSE
		chassis.leg_overload_mode = FALSE
		chassis.occupant_message(span_notice("You disable coral engine overload."))
	build_all_button_icons()
