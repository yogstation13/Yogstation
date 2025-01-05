/*
Immovable rod random event.
The rod will spawn at some location outside the station, and travel in a straight line to the opposite side of the station
Everything solid in the way will be ex_act()'d
In my current plan for it, 'solid' will be defined as anything with density == 1

--NEOFite
*/

/datum/round_event_control/immovable_rod
	name = "Immovable Rod"
	typepath = /datum/round_event/immovable_rod
	min_players = 18
	max_occurrences = 3
	earliest_start = 20 MINUTES
	description = "The station passes through an immovable rod."
	min_wizard_trigger_potency = 6
	max_wizard_trigger_potency = 7
	admin_setup = list(/datum/event_admin_setup/set_location/immovable_rod)
	track = EVENT_TRACK_MODERATE
	tags = list(TAG_DESTRUCTIVE, TAG_EXTERNAL, TAG_MAGICAL)
	event_group = /datum/event_group/meteors

/// Admins can pick a spot the rod will aim for
/datum/event_admin_setup/set_location/immovable_rod
	input_text = "Aimed at current location?"

/datum/event_admin_setup/set_location/immovable_rod/apply_to_event(datum/round_event/immovable_rod/event)
	event.special_target = chosen_turf

/datum/round_event/immovable_rod
	announce_when = 5
	/// Admins can pick a spot the rod will aim for.
	var/atom/special_target

/datum/round_event/immovable_rod/announce(fake)
	priority_announce("What the fuck was that?!", "General Alert")

/datum/round_event/immovable_rod/start()
	var/startside = pick(GLOB.cardinals)
	var/turf/end_turf = get_edge_target_turf(get_random_station_turf(), turn(startside, 180))
	var/turf/start_turf = spaceDebrisStartLoc(startside, end_turf.z)
	var/atom/rod = new /obj/effect/immovablerod(start_turf, end_turf, special_target)
	announce_to_ghosts(rod)

/obj/effect/immovablerod
	name = "immovable rod"
	desc = "What the fuck is that?"
	icon = 'icons/obj/objects.dmi'
	icon_state = "immrod"
	throwforce = 100
	move_force = INFINITY
	move_resist = INFINITY
	pull_force = INFINITY
	density = TRUE
	anchored = TRUE
	flags_1 = PREVENT_CONTENTS_EXPLOSION_1
	var/z_original = 0
	var/destination
	var/notify = TRUE
	var/atom/special_target
	var/notdebris = FALSE

/obj/effect/immovablerod/New(atom/start, atom/end, aimed_at)
	..()
	SSaugury.register_doom(src, 2000)
	z_original = z
	destination = end
	special_target = aimed_at
	GLOB.poi_list += src
	if(notdebris)
		SSaugury.unregister_doom(src)

	var/special_target_valid = FALSE
	if(special_target)
		var/turf/T = get_turf(special_target)
		if(T.z == z_original)
			special_target_valid = TRUE
	if(special_target_valid)
		walk_towards(src, special_target, 1)
	else if(end && end.z==z_original)
		walk_towards(src, destination, 1)

/obj/effect/immovablerod/Topic(href, href_list)
	if(href_list["orbit"])
		var/mob/dead/observer/ghost = usr
		if(istype(ghost))
			ghost.ManualFollow(src)

/obj/effect/immovablerod/Destroy()
	GLOB.poi_list -= src
	. = ..()

/obj/effect/immovablerod/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	if((z != z_original) || (loc == destination))
		qdel(src)
	if(special_target && loc == get_turf(special_target))
		complete_trajectory()
	return ..()

/obj/effect/immovablerod/proc/complete_trajectory()
	//We hit what we wanted to hit, time to go
	special_target = null
	destination = get_edge_target_turf(src, dir)
	walk(src,0)
	walk_towards(src, destination, 1)

/obj/effect/immovablerod/ex_act(severity, target)
	return 0

/obj/effect/immovablerod/singularity_act()
	return

/obj/effect/immovablerod/singularity_pull()
	return

/obj/effect/immovablerod/Bump(atom/clong)
	if(prob(10))
		playsound(src, 'sound/effects/bang.ogg', 50, 1)
		audible_message(span_danger("You hear a CLANG!"))

	if(clong && prob(25))
		x = clong.x
		y = clong.y

	if(special_target && clong == special_target)
		complete_trajectory()

	if(isturf(clong) || isobj(clong))
		if(clong.density)
			if(isturf(clong))
				SSexplosions.medturf += clong
			if(isobj(clong))
				SSexplosions.med_mov_atom += clong

	else if(isliving(clong))
		penetrate(clong)
	else if(istype(clong, type))
		var/obj/effect/immovablerod/other = clong
		visible_message(span_danger("[src] collides with [other]!"))
		var/datum/effect_system/fluid_spread/smoke/smoke = new
		smoke.set_up(2, location = get_turf(src))
		smoke.start()
		qdel(src)
		qdel(other)

/obj/effect/immovablerod/proc/penetrate(mob/living/L)
	L.visible_message(span_danger("[L] is penetrated by an immovable rod!") , span_userdanger("The rod penetrates you!") , span_danger("You hear a CLANG!"))
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		H.adjustBruteLoss(160)
	if(L && (L.density || prob(10)))
		L.ex_act(EXPLODE_HEAVY)

/obj/effect/immovablerod/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return

	var/mob/living/carbon/human/U = user
	if(!(U.job in list("Research Director")))
		return
	playsound(src, 'sound/effects/meteorimpact.ogg', 100, TRUE)
	for(var/mob/living/nearby_mob in urange(8, src))
		if(nearby_mob.stat != CONSCIOUS)
			continue
		shake_camera(nearby_mob, 2, 3)

	return suplex_rod(user)

/**
 * Called when someone manages to suplex the rod.
 *
 * Arguments
 * * strongman - the suplexer of the rod.
 */
/obj/effect/immovablerod/proc/suplex_rod(mob/living/strongman)
//	strongman.client?.give_award(/datum/award/achievement/misc/feat_of_strength, strongman)
	strongman.visible_message(
		span_boldwarning("[strongman] suplexes [src] into the ground!"),
		span_warning("You suplex [src] into the ground!")
		)
	new /obj/structure/festivus/anchored(drop_location())
	new /obj/effect/anomaly/flux(drop_location())
	qdel(src)
	return TRUE
