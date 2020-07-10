/datum/round_event_control/time_traveler
	name = "Time Traveler"
	typepath = /datum/round_event/ghost_role/time_traveler
	weight = 15
	max_occurrences = 1

/datum/round_event/ghost_role/time_traveler
	minimum_required = 1
	role_name = "time traveler"
	fakeable = TRUE

/datum/outfit/time_traveler
	uniform = /obj/item/clothing/under/pants/youngfolksjeans
	suit = /obj/item/clothing/suit/jacket/letterman
	belt = /obj/item/storage/belt/fannypack/blue
	gloves = /obj/item/clothing/gloves/fingerless
	shoes = /obj/item/clothing/shoes/wheelys
	mask = /obj/item/clothing/mask/cigarette
	glasses = /obj/item/clothing/glasses/orange
	r_hand = /obj/item/computer_mouse

/datum/round_event/ghost_role/time_traveler/proc/createEffects(var/turf/T)
	playsound(T, 'sound/magic/lightningbolt.ogg', 50, 0)
	var/obj/effect/portal/P = new /obj/effect/portal(T)
	P.color = "#00ff00"
	sleep(100)
	qdel(P)

/datum/round_event/ghost_role/time_traveler/announce(fake)
	priority_announce("Bluespace-time distortions have been detected aboard the station.")
/datum/round_event/ghost_role/time_traveler/spawn_role()
	var/list/candidates = get_candidates(ROLE_ALIEN, null, ROLE_ALIEN)
	if(!candidates.len)
		return NOT_ENOUGH_PLAYERS

	var/mob/dead/selected = pick(candidates)

	var/datum/mind/player_mind = new /datum/mind(selected.key)
	player_mind.active = TRUE

	var/list/spawn_locs = list()
	var/area = pick(1,3)
	switch(area)
		if(1)
			for(var/area/crew_quarters/dorms/A in world)
				for(var/turf/F in A)
					if(isfloorturf(F))
						spawn_locs += F
		if(2)
			for(var/area/crew_quarters/bar/A in world)
				for(var/turf/F in A)
					if(isfloorturf(F))
						spawn_locs += F
		if(3)
			for(var/area/medical/A in world)
				for(var/turf/F in A)
					if(isfloorturf(F))
						spawn_locs += F
	if(!spawn_locs.len)
		return MAP_ERROR
	var/loc = pick(spawn_locs)
	var/mob/living/carbon/human/T = new(loc)
	player_mind.transfer_to(T)
	player_mind.assigned_role = "Time Traveler"
	player_mind.special_role = "Time Traveler"
	T.equipOutfit(/datum/outfit/time_traveler)
	to_chat(T,"<span class='warning'>Woah, poggers. You were playing league when all of a sudden, a rift in time-space opened up and dropped you into the future! You hail from the year of 2015, make sure to spread your old-timey knowledge.</span>")
	createEffects(loc)
	spawned_mobs += T
	return SUCCESSFUL_SPAWN