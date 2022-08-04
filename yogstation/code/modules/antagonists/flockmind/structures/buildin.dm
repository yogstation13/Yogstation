/obj/structure/destructible/flock/construction
	name = "Weird building"
	desc = "It's some weird looking ghost building. Seems like its under construction, You can see faint strands of material floating in it."
	flock_desc = "A Flock structure not yet realised. Provide it resources to bring it into existence."
	icon_state = "egg"
	var/resource_cost = 0
	var/resources_we_have = 0 
	flock_id = "Construction Tealprint"
	density = FALSE

/obj/structure/destructible/flock/construction/New(loc, cost = 0)
	. = ..()
	resource_cost = cost

/datum/construction_datum
	var/obj/structure/destructible/flock/s_type = /obj/structure/destructible/flock
	var/resource_cost
	var/name = "Nothing."
	var/required_compute = 0
	var/total = FALSE

/datum/construction_datum/proc/can_build(var/turf/T, mob/user, silent = FALSE)
	if(istype(!T) || !T)
		if(!silent)
			to_chat(user, span_warning("Not a valid location."))
		return FALSE
	if(!isopenturf(T))
		if(!silent)
			to_chat(user, span_warning("Not a valid location."))
		return FALSE
	var/datum/team/flock/flock = get_flock_team()
	if(flock.get_compute(total) < required_compute && required_compute)
		if(!silent)
			to_chat(user, span_warning("Not enough compute."))
		return FALSE
	if(!is_station_level(T.z) || !flock.winer)
		if(!silent)
			to_chat(user, span_warning("You are not enough powerfull to build on not station z-levels."))
		return FALSE
	return TRUE

/datum/construction_datum/proc/build(var/turf/T)
	if(!can_build(T, silent = TRUE))
		return
	new s_type (T, resource_cost)
	qdel(src)
	
/datum/construction_datum/collector
	name = "Collector"
	resource_cost = 200
	s_type = /obj/structure/destructible/flock/collector
	
/datum/construction_datum/sentinel
	name = "Sentinel"
	resource_cost = 150
	s_type = /obj/structure/destructible/flock/sentinel

/datum/construction_datum/relay
	name = "The Relay"
	resource_cost = 1000
	s_type = /obj/structure/destructible/flock/the_relay