/datum/round_event_control/floor_cluwne
	name = "Floor Cluwne"
	typepath = /datum/round_event/floor_cluwne
	max_occurrences = 1
	min_players = 20


/datum/round_event/floor_cluwne/start()
	var/list/vents = list()
	for(var/obj/machinery/atmospherics/components/unary/vent_pump/temp_vent in GLOB.machines)
		if(QDELETED(temp_vent))
			continue
		if(is_station_level(temp_vent.loc.z) && !temp_vent.welded)
			var/datum/pipeline/temp_vent_parent = temp_vent.parents[1]
			if(temp_vent_parent.other_atmosmch.len > 20)
				vents += temp_vent

	if(!vents.len)
		message_admins("No valid spawn locations found, aborting...")
		return MAP_ERROR

	var/turf/T = get_turf(pick(vents.len))
	var/mob/living/simple_animal/hostile/floor_cluwne/S = new(T)
	playsound(S, 'yogstation/sound/misc/bikehorn_creepy.ogg', 50, 1, -1)
	message_admins("A floor cluwne has been spawned at [COORD(T)][ADMIN_JMP(T)]")
	log_game("A floor cluwne has been spawned at [COORD(T)]")
	return SUCCESSFUL_SPAWN