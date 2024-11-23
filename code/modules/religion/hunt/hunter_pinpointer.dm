#define HUNTER_MINIMUM_RANGE 5
#define HUNTER_MAXIMUM_RANGE 200
#define HUNTER_PING_TIME (5 SECONDS)
#define HUNTER_FUZZ_FACTOR 5



/atom/movable/screen/alert/status_effect/agent_pinpointer/hunters_sense
	name = "Hunter's Instincts"
	desc = "Your powerful instincts allow you to easily track your prey"


/datum/status_effect/agent_pinpointer/hunters_sense
	id = "agent_pinpointer"
	alert_type = /atom/movable/screen/alert/status_effect/agent_pinpointer/hunters_sense
	minimum_range = HUNTER_MINIMUM_RANGE
	tick_interval = HUNTER_PING_TIME
	duration = -1
	range_fuzz_factor = HUNTER_FUZZ_FACTOR

///Attempting to locate a nearby target to scan and point towards.
/datum/status_effect/agent_pinpointer/hunters_sense/scan_for_target()

	scan_target = null
	if(!owner && !owner.mind)
		return
	var/dist = 1000
	var/mob/living/basic/deer/prey/chosen_prey
	for(var/mob/living/basic/deer/prey/located as anything in GLOB.sect_of_the_hunt_preys)
		if(get_dist(owner, located) < dist)
			dist = get_dist(owner, located)
			chosen_prey = located
	if(QDELETED(chosen_prey))
		return
	scan_target = chosen_prey


#undef HUNTER_MINIMUM_RANGE
#undef HUNTER_MAXIMUM_RANGE
#undef HUNTER_PING_TIME
#undef HUNTER_FUZZ_FACTOR
