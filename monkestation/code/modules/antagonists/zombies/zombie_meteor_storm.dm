//this is its own event type due to having a bunch of unique logic
/datum/round_event_control/zombie_meteor_wave
	name = "Meteor Wave: Zombies"
	typepath = /datum/round_event/zombie_meteor_wave
	weight = 2
	max_occurrences = 1
	earliest_start = 60 MINUTES
	category = EVENT_CATEGORY_SPACE
	description = "Spawn a wave of meteors containing zombies."
	min_players = 50
	admin_setup = list(/datum/event_admin_setup/input_number/zombie_meteor_count)
	checks_antag_cap = TRUE
	track = EVENT_TRACK_ROLESET
	tags = list(TAG_COMBAT, TAG_DESTRUCTIVE, TAG_EXTERNAL, TAG_OUTSIDER_ANTAG, TAG_SPOOKY)
	enemy_roles = list(
		JOB_CAPTAIN,
		JOB_DETECTIVE,
		JOB_HEAD_OF_SECURITY,
		JOB_SECURITY_OFFICER,
		JOB_SECURITY_ASSISTANT,
		JOB_WARDEN,
	)
	required_enemies = 5

/datum/round_event/zombie_meteor_wave
	start_when = 1
	end_when = 3
	var/meteor_count = 3

/datum/round_event/zombie_meteor_wave/start()
	. = ..()
	generate_meteors(meteor_count)

/datum/round_event/zombie_meteor_wave/proc/generate_meteors(count = 1)
	if(!count)
		return

	var/list/candidates = SSpolling.poll_ghost_candidates("Would you like to be considered for a zombie meteor?", poll_time = 30 SECONDS)
	if(!length(candidates))
		return

	for(var/i in 1 to count)
		var/mob/dead/selected = pick_n_take(candidates)
		var/datum/mind/player_mind = new(selected.key)
		player_mind.active = TRUE

		var/turf/picked_start
		if (SSmapping.is_planetary())
			var/list/possible_start = list()
			for(var/obj/effect/landmark/carpspawn/spawn_point in GLOB.landmarks_list)
				possible_start += get_turf(spawn_point)
			picked_start = pick(possible_start)
		else
			var/start_z = pick(SSmapping.levels_by_trait(ZTRAIT_STATION))
			var/start_side = pick(GLOB.cardinals)
			picked_start = spaceDebrisStartLoc(start_side, start_z)

		if (!picked_start)
			stack_trace("No valid spawn location for zombie meteor")

		var/mob/living/carbon/human/new_mob = new
		var/obj/effect/meteor/meaty/zombie/zombie_meteor = new(picked_start, get_random_station_turf())
		new_mob.set_species(/datum/species/zombie/infectious)
		new_mob.forceMove(zombie_meteor)
		player_mind.transfer_to(new_mob, TRUE)
		SEND_SOUND(new_mob, 'sound/magic/mutate.ogg')
		message_admins("[ADMIN_LOOKUPFLW(new_mob)] has been made into a zombie by an event.")
		new_mob.log_message("was spawned as a zombie by an event.", LOG_GAME)
		if(!length(candidates))
			break

/datum/event_admin_setup/input_number/zombie_meteor_count
	input_text = "How many meteors would you like?"
	default_value = 3

/datum/event_admin_setup/input_number/zombie_meteor_count/apply_to_event(datum/round_event/zombie_meteor_wave/event)
	event.meteor_count = chosen_value

/obj/effect/meteor/meaty/zombie
	name = "rotting meaty meteor"
	desc = "A loosely packed knit of flesh and skin, pulsating with unlife."
	color = "#5EFF00"
	heavy = FALSE
	hits = 1 //Instantly splatters apart when it hits anything.
	hitpwr = EXPLODE_LIGHT
	threat = 100
	signature = "rotting lifesign" //In the extremely unlikely one-in-a-million chance that one of these gets reported by the stray meteor event
	///Where we want our zombie to, by whatever means, end up at.
	var/atom/landing_target

/obj/effect/meteor/meaty/zombie/Initialize(mapload, turf/target)
	. = ..()
	landing_target = target

/obj/effect/meteor/meaty/zombie/meteor_effect()
	..()
	for(var/atom/movable/child in contents)
		child.forceMove(get_turf(src))

/obj/effect/meteor/meaty/zombie/ram_turf()
	return //So we don't instantly smash into our occupant upon unloading them.

/obj/effect/meteor/meaty/zombie/shield_defense(obj/machinery/satellite/meteor_shield/defender)
	landing_target = defender
	return TRUE

//If the meteor misses the station and deletes itself, we make absolutely sure the changeling reaches the station.
/obj/effect/meteor/meaty/zombie/handle_stopping()
	if(!landing_target)
		//If our destination turf is gone for some reason, we chuck them at the observer_start landmark (usually at the center of the station) as a last resort.
		landing_target = locate(/obj/effect/landmark/observer_start) in GLOB.landmarks_list

	for(var/atom/movable/zombie in contents)
		zombie.forceMove(get_turf(src))
		zombie.throw_at(landing_target, 2, 2)
		zombie.visible_message(span_warning("[zombie] is launched out from inside of the [name]"), \
								span_warning("Sensing that something is terribly wrong, we forcibly eject ourselves from the [name]!"))
		playsound(zombie, 'sound/effects/splat.ogg', 50, pressure_affected = FALSE)

	return ..()

/obj/effect/meteor/meaty/zombie/check_examine_award(mob/user) //We don't want this to be a free achievement that comes with the role.
	return
