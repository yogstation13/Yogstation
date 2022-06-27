/datum/hog_god_interaction/targeted/construction
	name = "construct something"
	description = "construct some building idk lol"
	cost = 0
	cooldown = 0 
	is_targeted = TRUE
	var/time_builded = 10
	var/warp_name = "Sussy baka"
	var/warp_description = "Sussy baka"
	var/obj/structure/destructible/hog_structure/structure_type = /obj/structure/destructible/hog_structure
	var/max_constructible_health = 10
	var/integrity_per_process = 1
	var/icon_name = ""

/datum/hog_god_interaction/targeted/construction/on_targeting(var/mob/camera/hog_god/user, var/atom/target) ///Same as on_use but for targeted ones
	if(!structure_type)
		to_chat(user, span_warning("Not a valid entry."))
		return
	var/turf/open/construction_place = target
	if(!construction_place || !can_be_placed(construction_place, user.cult))
		to_chat(user, span_warning("Not a valid place."))
		return
	if(!time_builded)
		var/obj/structure/destructible/hog_structure/newboy = new structure_type (construction_place)
		newboy.handle_team_change(user.cult)
	else
		var/obj/structure/destructible/warp/warp = new(construction_place)
		warp.structure_type = src.structure_type
		warp.when_started = world.time
		warp.when_ready = world.time + time_builded
		warp.cult = user.cult
		warp.max_integrity = max_constructible_health
		warp.obj_integrity = 1
		warp.integrity_per_process = 1
		warp.icon_state = icon_name
		warp.name = warp_name 
		warp.desc = warp_description
		warp.start()

	. = ..()

/datum/hog_god_interaction/targeted/construction/proc/can_be_placed(var/turf/open/construction_place, var/datum/team/hog_cult/cult)
	if(!construction_place)
		return FALSE
	var/can_we = FALSE
	for(var/obj/structure/destructible/hog_structure/structure in cult.objects)
		if(!structure.constructor_range)
			continue
		if(structure.cult != cult)
			continue
		if(get_dist(get_turf(structure), construction_place) <= structure.constructor_range)
			can_we = TRUE ///Yes we can!!!
	return can_we

/obj/structure/destructible/warp   ///It is like protoss construction in StarCraft 2 but in SS13!
	name = "Warp rift"
	desc = "For Adun!"  
	max_integrity = 1  
	icon = 'icons/obj/hand_of_god_structures.dmi'
	var/obj/structure/destructible/hog_structure/structure_type
	var/when_ready
	var/when_started
	var/datum/team/hog_cult/cult 
	var/integrity_per_process

/obj/structure/destructible/warp/proc/start()
	START_PROCESSING(SSobj, src)

/obj/structure/destructible/warp/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/structure/destructible/warp/process()
	if(world.time >= when_ready)
		var/obj/structure/destructible/hog_structure/newboy = new structure_type (get_turf(src))
		newboy.handle_team_change(cult)
		STOP_PROCESSING(SSobj, src)
		qdel(src)
	var/time1 = when_ready - when_started
	var/time2 = when_ready - world.time 
	var/percentage = time2 / time1
	var/opacility = min(min(percentage * 100, 20), 90)
	alpha = opacility   ///So we are becoming more visible untill we are ready
	take_damage(-integrity_per_process, BRUTE, MELEE, FALSE , 0, 100) ///Basicaly it should gain some percentage of max hp per process, but I don't want to blow my brain up by trying to think how to do that, so i will do it like... this

/turf/open/floor/hog/attack_god(mob/camera/hog_god/god, modifier)
	var/list/buildins = list() ///it is misspeled because YES
	var/list/names = list()
	if(modifier == "ctrl")
		for(var/datum/hog_god_interaction/targeted/construction/buildin in god.cult.possible_buildings)
			buildins[buildin.name] = buildin
			names += buildin.name
		var/datum/hog_god_interaction/targeted/construction/build_action = buildins[input(god,"What do you want to build?","Construction") in names]
		if(!build_action)
			return
		if(!build_action.on_called(god))
			return
		build_action.on_targeting(god, src)

/turf/open/floor/attack_god(mob/camera/hog_god/god, modifier)
	if(modifier == "ctrl")
		var/can_we = FALSE
		for(var/obj/structure/destructible/hog_structure/structure in god.cult.objects)
			if(!structure.constructor_range)
				continue
			if(structure.cult != god.cult)
				continue
			if(get_dist(get_turf(structure), src) <= structure.constructor_range)
				can_we = TRUE ///Yes we can!!!
		if(!can_we)
			to_chat(god, span_warning("You can convert floors only near a shrine or your nexus!"))
			return
		if(!do_after(god, 3 SECONDS, src))
			return
		var/atom/loca = src.loc 
		var/turf/open/floor/hog/H
		H = new(loca)
		if(!istype(src, /turf/open/floor/hog))
			H.name = "divine [name]"
		H.change_hog_team(GOD.CULT)
		qdel(src)

