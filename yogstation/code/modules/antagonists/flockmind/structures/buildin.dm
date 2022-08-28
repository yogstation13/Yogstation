/obj/structure/destructible/flock/construction
	name = "Weird building"
	desc = "It's some weird looking ghost building. Seems like its under construction, You can see faint strands of material floating in it."
	flock_desc = "A Flock structure not yet realised. Provide it resources to bring it into existence."
	icon_state = "egg"
	var/resource_cost = 0
	var/resources_we_have = 0 
	var/obj/structure/destructible/flock/s_type
	flock_id = "Construction Tealprint"
	density = FALSE

/obj/structure/destructible/flock/construction/flock_act(mob/living/simple_animal/hostile/flockdrone/drone)
	if(drone)
		var/money_to_get = min(10, resource_cost - resources_we_have)
		if(drone.resources < min(money_to_get))
			to_chat(drone, span_warning("Not enough resources!"))
			return
		drone.change_resources(-money_to_get)
		resources_we_have += money_to_get
		if(resources_we_have >= resource_cost)
			new s_type (get_turf(src))
			qdel(src)

/obj/structure/destructible/flock/construction/Initialize()
	. = ..()
	if(istype(s_type, /obj/structure/destructible/flock/the_relay))
		var/datum/team/flock/flock = get_flock_team()
		flock.relay_builded = TRUE

/obj/structure/destructible/flock/construction/Destroy()
	. = ..()
	if(istype(s_type, /obj/structure/destructible/flock/the_relay) && resources_we_have >= resource_cost)
		var/datum/team/flock/flock = get_flock_team()
		flock.relay_builded = FALSE

/obj/structure/destructible/flock/construction/get_special_description(mob/user)
	. = ..()
	. += span_swarmer("<span class='bold'>Construction Progress:</span> [resources_we_have]/[resource_cost]")

/obj/structure/destructible/flock/construction/New(loc, cost = 0, struc_type)
	. = ..()
	resource_cost = cost
	s_type = struc_type

/datum/construction_datum
	var/obj/structure/destructible/flock/s_type = /obj/structure/destructible/flock
	var/resource_cost
	var/name = "Nothing."
	var/required_compute = 0
	var/total = FALSE
	var/icon_icon = 'goon/icons/obj/flockobjects.dmi'
	var/icon_state

/datum/construction_datum/proc/can_build(var/turf/T, mob/user, silent = FALSE)
	if(!istype(T) || !T)
		if(!silent)
			user.balloon_alert(user, "Not a valid location")
		return FALSE
	if(!isopenturf(T))
		if(!silent)
			user.balloon_alert(user, "Not a valid location")
		return FALSE
	var/datum/team/flock/flock = get_flock_team()
	if(flock.get_compute(!total) < required_compute && required_compute)
		if(!silent)
			user.balloon_alert(user, "Not enough compute")
		return FALSE
	if(!is_station_level(T.z) || !flock.winner)
		if(!silent)
			to_chat(user, span_warning("You are not enough powerfull to build on not station z-levels."))
		return FALSE
	return TRUE

/datum/construction_datum/proc/build(var/turf/T)
	if(!can_build(T, silent = TRUE))
		return
	new s_type (T, resource_cost, s_type)
	qdel(src)
	
/datum/construction_datum/collector
	name = "Collector"
	resource_cost = 200
	s_type = /obj/structure/destructible/flock/collector
	icon_state = "collector"
	
/datum/construction_datum/sentinel
	name = "Sentinel"
	resource_cost = 150
	required_compute = 20
	s_type = /obj/structure/destructible/flock/sentinel
	icon_state = "sentinelon"

/datum/construction_datum/relay
	name = "The Relay"
	resource_cost = 1000
	required_compute = 20
	total = TRUE
	s_type = /obj/structure/destructible/flock/the_relay
	icon_state = "compute"

/datum/construction_datum/relay/can_build(var/turf/T, mob/user, silent = FALSE)
	if(user)
		var/order = input(user,"Do you REALLY want to build The Relay? It will alert all the station about it's position, and if it will be destroyed you will die.") in list("Hell Yeah", "No")
		if(order == "No")
			return FALSE
	var/datum/team/flock/flock = get_flock_team(user.mind)
	if(flock.relay_builded)
		return FALSE
	. = ..()
