/obj/item/mecha_parts/mecha_equipment/afterburner
	name = "\improper CL-56 \"Hardlight\" Afterburner"
	desc = "A powerful thruster designed for small shuttles, retrofitted for exosuits despite better judgement. Redirects power from all other equipment during use. It has a warning label against mounting to anything not secured."
	icon_state = "mecha_afterburner" 
	selectable = FALSE // your mech IS the weapon
	var/minimum_damage = 10
	var/structure_damage_mult = 4
	equip_actions = list(/datum/action/cooldown/mecha_afterburner)

/obj/item/mecha_parts/mecha_equipment/afterburner/can_attach(obj/mecha/new_mecha)
	if(!(new_mecha.melee_allowed || istype(new_mecha, /obj/mecha/working/clarke))) // clarke because it's fucking COOL
		return FALSE
	return ..()

/obj/item/mecha_parts/mecha_equipment/afterburner/attach(obj/mecha/new_mecha)
	. = ..()
	RegisterSignal(new_mecha, COMSIG_MOVABLE_PRE_ENTER, PROC_REF(headstomp))
	RegisterSignal(new_mecha, COMSIG_MOVABLE_MOVED, PROC_REF(after_move))

/obj/item/mecha_parts/mecha_equipment/afterburner/detach(atom/moveto)
	UnregisterSignal(chassis, list(COMSIG_MOVABLE_PRE_ENTER, COMSIG_MOVABLE_MOVED))
	return ..()

/obj/item/mecha_parts/mecha_equipment/afterburner/proc/headstomp(atom/movable/source, atom/entering_loc)
	if(!chassis.throwing)
		return FALSE
	var/hit_something = FALSE

	if(ismineralturf(entering_loc)) // crush through rocks
		var/turf/closed/mineral/ore_turf = entering_loc
		ore_turf.gets_drilled(chassis.occupant, FALSE)
		hit_something = TRUE
	if(isgroundlessturf(entering_loc)) // we are literally FLYING!! no ground friction to hold us back!!
		chassis.throwing.maxrange += (chassis.throwing.maxrange - chassis.throwing.dist_travelled < 2 ? 1 : 0.5)

	var/kinetic_damage = max(chassis.force * (initial(chassis.step_in) / 2), minimum_damage) // heavier mechs have more kinetic energy
	if(istype(chassis, /obj/mecha/working/clarke) && lavaland_equipment_pressure_check(get_turf(entering_loc))) // less air resistance means MORE SPEED!!!!
		kinetic_damage *= 2
	if(entering_loc.uses_integrity && entering_loc.density)
		entering_loc.take_damage(kinetic_damage * structure_damage_mult, BRUTE, MELEE, FALSE, null, 50)
		hit_something = TRUE

	for(var/atom/movable/hit_atom in entering_loc)
		if(QDELETED(hit_atom))
			continue
		if(hit_atom.uses_integrity && (hit_atom.density || hit_atom.buckled_mobs?.len))
			hit_atom.take_damage(kinetic_damage * structure_damage_mult, BRUTE, MELEE, FALSE, null, 50)
			if(istype(hit_atom, /obj/structure/flora))
				hit_atom.atom_destruction(BRUTE)
			if(!hit_atom.anchored)
				hit_atom.throw_at(get_step(hit_atom, get_dir(chassis, hit_atom)), 1, 5, chassis.occupant, TRUE)
			hit_something = TRUE
		else if(isliving(hit_atom))
			var/mob/living/stomped = hit_atom
			if(!stomped.check_shields(chassis, kinetic_damage * structure_damage_mult, "[chassis]", MELEE_ATTACK, 50)) // i mean, you can TRY to block it
				stomped.apply_damage(kinetic_damage * (isanimal(stomped) ? 4 : 1), BRUTE, BODY_ZONE_CHEST) // bonus damage to simple mobs
				stomped.Knockdown(0.5 SECONDS) // just long enough for the mech to pass over
			if(stomped.mobility_flags & MOBILITY_STAND) // still standing? knock them back!
				stomped.throw_at(get_step(stomped, get_dir(chassis, stomped)), 1, 5, chassis.occupant, TRUE)
			hit_something = TRUE

	if(hit_something)
		chassis.throwing.maxrange -= 1 // transfer of kinetic energy
		playsound(entering_loc, 'sound/effects/meteorimpact.ogg', 25, TRUE)

/obj/item/mecha_parts/mecha_equipment/afterburner/proc/after_move()
	var/turf/chassis_turf = get_turf(chassis)
	if(!chassis.throwing || !chassis.has_gravity() || isgroundlessturf(chassis_turf))
		return
	playsound(chassis.loc, chassis.stepsound, 50, TRUE)

/datum/action/cooldown/mecha_afterburner
	name = "Fire Afterburner"
	cooldown_time = 10 SECONDS
	check_flags = AB_CHECK_HANDS_BLOCKED |  AB_CHECK_IMMOBILE | AB_CHECK_CONSCIOUS
	button_icon = 'icons/mob/actions/actions_mecha.dmi'
	button_icon_state = "mech_afterburner"
	/// The exosuit linked to this action.
	var/obj/mecha/chassis
	/// Whether the linked exosuit has received bonus armor from charging.
	var/bonus_lavaland_armor = FALSE

/datum/action/cooldown/mecha_afterburner/Grant(mob/living/L, obj/mecha/M)
	if(M)
		chassis = M
	return ..()

/datum/action/cooldown/mecha_afterburner/Activate()
	if(chassis.completely_disabled)
		return
	chassis.movement_type |= FLYING // for doing sick jumps over chasms
	chassis.completely_disabled = TRUE
	chassis.AddComponent(/datum/component/after_image, 0.7 SECONDS, 0.5, FALSE)
	if(istype(chassis, /obj/mecha/working/clarke) && lavaland_equipment_pressure_check(get_turf(chassis))) // clarke gets bonus armor when charging on lavaland
		chassis.armor.modifyRating(melee = 50)
		bonus_lavaland_armor = TRUE
	playsound(chassis, 'sound/vehicles/rocketlaunch.ogg', 100, TRUE) // sound effect has a short time before it gets going, so it plays before the wind up
	if(do_after(chassis.occupant, 0.5 SECONDS, chassis, IGNORE_ALL))
		var/delta_v = 4 / (1 + chassis.step_in) // using mech base step time to estimate mass
		chassis.throw_at(
			get_edge_target_turf(get_turf(chassis), chassis.dir),
			10 * delta_v,
			delta_v,
			chassis.occupant,
			FALSE,
			callback = CALLBACK(src, PROC_REF(charge_end))
		)
	else // if this somehow fails then something has gone terribly wrong
		charge_end()
		CRASH("[type] failed to complete wind-up!")
	return ..()

/datum/action/cooldown/mecha_afterburner/proc/charge_end()
	var/datum/component/after_image/chassis_after_image = chassis.GetComponent(/datum/component/after_image)
	if(chassis_after_image)
		qdel(chassis_after_image)
	if(bonus_lavaland_armor)
		chassis.armor.modifyRating(melee = -50)
		bonus_lavaland_armor = FALSE
	chassis.completely_disabled = FALSE
	chassis.movement_type &= ~FLYING
