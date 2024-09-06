/obj/effect/spawner/bundle
	name = "bundle spawner"
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "x2"
	color = "#00FF00"

	var/list/items

/obj/effect/spawner/bundle/Initialize(mapload)
	..()
	if(items && items.len)
		var/turf/T = get_turf(src)
		for(var/path in items)
			new path(T)
	return INITIALIZE_HINT_QDEL

/obj/effect/spawner/bundle/costume/chicken
	name = "chicken costume spawner"
	items = list(
		/obj/item/clothing/suit/chickensuit,
		/obj/item/clothing/head/chicken,
		/obj/item/reagent_containers/food/snacks/egg)

/obj/effect/spawner/bundle/costume/gladiator
	name = "gladiator costume spawner"
	items = list(
		/obj/item/clothing/under/costume/gladiator,
		/obj/item/clothing/head/helmet/gladiator)
