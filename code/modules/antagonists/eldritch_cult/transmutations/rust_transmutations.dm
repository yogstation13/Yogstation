/datum/eldritch_transmutation/rust_blade
	name = "Rusty Blade"
	required_atoms = list(/obj/item/kitchen/knife,/obj/item/trash)
	result_atoms = list(/obj/item/melee/sickly_blade/rust)
	required_shit_list = "A piece of trash and a knife."

/datum/eldritch_transmutation/armor
	name = "Create Eldritch Armor"
	required_atoms = list(/obj/structure/table,/obj/item/clothing/mask/gas)
	result_atoms = list(/obj/item/clothing/suit/hooded/cultrobes/eldritch)
	required_shit_list = "A table and a gas mask."

/datum/eldritch_transmutation/water
	name = "Create Eldritch Essence"
	required_atoms = list(/obj/structure/reagent_dispensers/watertank)
	result_atoms = list(/obj/item/reagent_containers/glass/beaker/eldritch)
	required_shit_list = "A tank of water."

/datum/eldritch_transmutation/final/rust_final
	name = "Rustbringer's Oath"
	required_atoms = list(/mob/living/carbon/human)
	required_shit_list = "Three dead bodies."

/datum/eldritch_transmutation/final/rust_final/on_finished_recipe(mob/living/user, list/atoms, loc)
	var/mob/living/carbon/human/H = user
	H.physiology.brute_mod *= 0.5
	H.physiology.burn_mod *= 0.5
	H.physiology.stamina_mod = 0
	H.physiology.stun_mod = 0
	priority_announce("$^@&#*$^@(#&$(@&#^$&#^@# Fear the decay, for Rustbringer [user.real_name] has come! $^@&#*$^@(#&$(@&#^$&#^@#","#$^@&#*$^@(#&$(@&#^$&#^@#", 'sound/ai/spanomalies.ogg')
	new /datum/rust_spread(loc)
	var/datum/antagonist/heretic/ascension = H.mind.has_antag_datum(/datum/antagonist/heretic)
	ascension.ascended = TRUE
	return ..()

/datum/eldritch_transmutation/final/rust_final/on_life(mob/user)
	. = ..()
	if(!finished)
		return
	var/mob/living/carbon/human/human_user = user
	human_user.adjustBruteLoss(-3, FALSE)
	human_user.adjustFireLoss(-3, FALSE)
	human_user.adjustToxLoss(-3, FALSE)
	human_user.adjustOxyLoss(-1, FALSE)
	human_user.adjustStaminaLoss(-10)


/**
  * #Rust spread datum
  *
  * Simple datum that automatically spreads rust around it
  *
  * Simple implementation of automatically growing entity
  */
/datum/rust_spread
	var/list/edge_turfs = list()
	var/list/turfs = list()
	var/static/list/blacklisted_turfs = typecacheof(list(/turf/open/indestructible,/turf/closed/indestructible,/turf/open/space,/turf/open/lava,/turf/open/chasm))
	var/spread_per_tick = 6


/datum/rust_spread/New(loc)
	. = ..()
	var/turf/turf_loc = get_turf(loc)
	turf_loc.rust_heretic_act()
	turfs += turf_loc
	START_PROCESSING(SSprocessing,src)


/datum/rust_spread/Destroy(force, ...)
	STOP_PROCESSING(SSprocessing,src)
	return ..()

/datum/rust_spread/process()
	compile_turfs()
	var/turf/T
	for(var/i in 0 to spread_per_tick)
		T = pick(edge_turfs)
		T.rust_heretic_act()
		turfs += get_turf(T)

/**
  * Compile turfs
  *
  * Recreates all edge_turfs as well as normal turfs.
  */
/datum/rust_spread/proc/compile_turfs()
	edge_turfs = list()
	for(var/X in turfs)
		if(!istype(X,/turf/closed/wall/rust) && !istype(X,/turf/closed/wall/r_wall/rust) && !istype(X,/turf/open/floor/plating/rust))
			turfs -=X
			continue
		for(var/turf/T in range(1,X))
			if(T in turfs)
				continue
			if(is_type_in_typecache(T,blacklisted_turfs))
				continue
			edge_turfs += T
