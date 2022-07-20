/obj/effect/randomfood /// Spawns a random food item, then deletes
/obj/effect/randomfood/Initialize(mapload, mob/living/source_mob, list/datum/disease/diseases)
	. = ..()
	var/obj/spawned = get_random_food()
	new spawned(loc)
	return INITIALIZE_HINT_QDEL

/obj/effect/randomdrink /// Spawns a random drink item, then deletes
/obj/effect/randomdrink/Initialize(mapload, mob/living/source_mob, list/datum/disease/diseases)
	. = ..()
	var/obj/spawned = get_random_drink()
	new spawned(loc)
	return INITIALIZE_HINT_QDEL
