/datum/job/cyborg
	title = JOB_CYBORG
	description = "Assist the crew, follow your laws, obey your AI."
	auto_deadmin_role_flags = DEADMIN_POSITION_SILICON
	faction = FACTION_STATION
	total_positions = 3 //Monkestation edit - makes cyborgs joinable in join menu
	spawn_positions = 3 //Monkestation edit - makes cyborgs joinable in join menu
	supervisors = "your laws and the AI" //Nodrak
	spawn_type = /mob/living/silicon/robot
	minimal_player_age = 21
	exp_requirements = 300
	exp_required_type = EXP_TYPE_CREW
	exp_granted_type = EXP_TYPE_CREW
	config_tag = "CYBORG"

	display_order = JOB_DISPLAY_ORDER_CYBORG

	departments_list = list(
		/datum/job_department/silicon,
		)
	random_spawns_possible = FALSE
	job_flags = JOB_NEW_PLAYER_JOINABLE | JOB_EQUIP_RANK | JOB_CANNOT_OPEN_SLOTS

/datum/job/cyborg/get_latejoin_spawn_point()
	var/turf/open/picked_turf = get_random_open_turf_in_area()
	return picked_turf

/datum/job/cyborg/after_latejoin_spawn(mob/living/spawning)
	. = ..()
	var/obj/structure/closet/supplypod/podspawn/podspawn = new(null)
	podspawn.explosionSize = list(0,0,0,0)
	podspawn.bluespace = TRUE
	var/turf/granter_turf = get_turf(spawning)
	spawning.forceMove(podspawn)
	new /obj/effect/pod_landingzone(granter_turf, podspawn)

/datum/job/cyborg/proc/get_random_open_turf_in_area()
	var/list/turfs = get_area_turfs(/area/station/ai_monitored/turret_protected/ai_upload)
	while(length(turfs))
		var/turf/turf = pick_n_take(turfs)
		if(!isfloorturf(turf) || turf.is_blocked_turf(exclude_mobs = TRUE))
			continue
		return turf
	stack_trace("Failed to find eligible spawn turf for a cyborg, using observer start landmark instead.")
	var/obj/effect/landmark/observer_start/target = locate(/obj/effect/landmark/observer_start) in GLOB.landmarks_list
	return get_turf(target)

/datum/job/cyborg/after_spawn(mob/living/spawned, client/player_client)
	. = ..()
	if(!iscyborg(spawned))
		return
	spawned.gender = NEUTER
	var/mob/living/silicon/robot/robot_spawn = spawned
	robot_spawn.notify_ai(AI_NOTIFICATION_NEW_BORG)
	if(!robot_spawn.connected_ai) // Only log if there's no Master AI
		robot_spawn.log_current_laws()
	return TRUE

/datum/job/cyborg/get_radio_information()
	return "<b>Prefix your message with :b to speak with other cyborgs and AI.</b>"
