#define REGAL_RAT_CHANCE 0
#define PLAGUE_RAT_CHANCE 0
SUBSYSTEM_DEF(minor_mapping)
	name = "Minor Mapping"
	init_order = INIT_ORDER_MINOR_MAPPING
	flags = SS_NO_FIRE

/datum/controller/subsystem/minor_mapping/Initialize(timeofday)
	trigger_migration(CONFIG_GET(number/mice_roundstart), FALSE) //we dont want roundstart special rats
	place_satchels()
	return ..()

/datum/controller/subsystem/minor_mapping/proc/trigger_migration(num_mice = 10, special = TRUE)
	var/list/exposed_wires = find_exposed_wires()

	var/mob/living/simple_animal/M
	var/turf/proposed_turf


	while((num_mice > 0) && exposed_wires.len)
		proposed_turf = pick_n_take(exposed_wires)
		if(!M)
			if(special && prob(REGAL_RAT_CHANCE))
				M = new /mob/living/simple_animal/hostile/regalrat/controlled(proposed_turf)
			else if(special && prob(PLAGUE_RAT_CHANCE))
				M = new /mob/living/simple_animal/hostile/rat/plaguerat(proposed_turf)
				notify_ghosts("A plague \a [M] has migrated into the station!", source = M, action=NOTIFY_ORBIT, header="Something Interesting!")
			else
				M = new /mob/living/simple_animal/mouse(proposed_turf)
		else
			M.forceMove(proposed_turf)
		if(M.environment_is_safe())
			num_mice -= 1
			M = null

/datum/controller/subsystem/minor_mapping/proc/place_satchels(amount=10)
	var/list/turfs = find_satchel_suitable_turfs()

	while(turfs.len && amount > 0)
		var/turf/T = pick_n_take(turfs)
		var/obj/item/storage/backpack/satchel/flat/S = new(T)
		S.hide(intact=TRUE)
		amount--


/proc/find_exposed_wires()
	var/list/exposed_wires = list()

	var/list/all_turfs
	for(var/z in SSmapping.levels_by_trait(ZTRAIT_STATION))
		all_turfs += block(locate(1,1,z), locate(world.maxx,world.maxy,z))
	for(var/turf/open/floor/plating/T in all_turfs)
		if(is_blocked_turf(T))
			continue
		if(locate(/obj/structure/cable) in T)
			exposed_wires += T

	return shuffle(exposed_wires)

/proc/find_satchel_suitable_turfs()
	var/list/suitable = list()

	for(var/z in SSmapping.levels_by_trait(ZTRAIT_STATION))
		for(var/t in block(locate(1,1,z), locate(world.maxx,world.maxy,z)))
			if(isfloorturf(t) && !isplatingturf(t))
				suitable += t

	return shuffle(suitable)

#undef REGAL_RAT_CHANCE 
#undef PLAGUE_RAT_CHANCE
