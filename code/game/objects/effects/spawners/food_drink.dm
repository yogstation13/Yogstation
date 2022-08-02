/obj/effect/randomfood /// Spawns a random food item, then deletes
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "random_food"

/obj/effect/randomfood/Initialize(mapload, mob/living/source_mob, list/datum/disease/diseases)
	. = ..()
	var/obj/spawned = get_random_food()
	new spawned(loc)
	return INITIALIZE_HINT_QDEL

/obj/effect/randomdrink /// Spawns a random drink item, then deletes
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "random_drink"

/obj/effect/randomdrink/Initialize(mapload, mob/living/source_mob, list/datum/disease/diseases)
	. = ..()
	var/obj/spawned = get_random_drink()
	new spawned(loc)
	return INITIALIZE_HINT_QDEL
