/obj/effect/spawner/mob
	name = "mob spawner"
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "x2"

	var/list/items

/obj/effect/spawner/mob/Initialize(mapload)
	..()
	if(items && items.len)
		var/turf/T = get_turf(src)
		for(var/path in items)
			new path(T)
	return INITIALIZE_HINT_QDEL

/obj/effect/spawner/mob/kitchen_animal
	name = "coldroom animal"
	items = list(/mob/living/simple_animal/hostile/retaliate/goat = 1,
			/mob/living/simple_animal/cow = 1,
			/mob/living/simple_animal/sheep = 1)