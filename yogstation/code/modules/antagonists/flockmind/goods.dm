/obj/item/flockcache
	name = "weird cube"
	desc = "A weird looking cube. Seems to be raw material"
	icon_state = "cube"
	var/resources = 10

/obj/item/flockcache/New(loc, initial_goods)
	. = ..()
	resources = initial_goods

/obj/item/flockcache/flock_act(mob/living/simple_animal/hostile/flockdrone/drone)
	if(!drone)
		return
	if(drone.resources >= drone.max_resources)
		to_chat(drone, span_notice("You already have more then enough resources in your storage!"))
		return
	var/extraction_amount = min(drone.max_resources - drone.resources, resources)
	resources -= extraction_amount
	drone.change_resources(extraction_amount, TRUE)
	if(resources)
		to_chat(drone, span_notice("You extract [extraction_amount] of resources from [src]."))
		return
	else
		to_chat(drone, span_notice("You put [src] in your storage."))
		qdel(src)
		return