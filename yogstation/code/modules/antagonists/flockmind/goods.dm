/obj/item/flockcache
	name = "weird cube"
	desc = "A weird looking cube. Seems to be raw material"
	icon = 'icons/obj/flockobjects.dmi'
	icon_state = "cube"
	var/resources = 10

/obj/item/flockcache/New(loc, initial_goods)
	. = ..()
	resources = initial_goods

/obj/item/flockcache/flock_act(mob/living/simple_animal/hostile/flockdrone/drone)
	if(!drone)
		return
	if(drone.resources >= drone.max_resources)
		balloon_alert(drone, "Storage is full, aborting")
		return
	var/extraction_amount = min(drone.max_resources - drone.resources, resources)
	resources -= extraction_amount
	drone.change_resources(extraction_amount, TRUE)
	if(resources)
		balloon_alert(drone, "[extraction_amount] resources extracted")
		return
	else
		to_chat(drone, span_notice("You put [src] in your storage."))
		qdel(src)
		return

/obj/item/flockcache/examine(mob/user)
	. = ..()
	if(isflockdrone(user) || isflocktrace(user))
		. = span_swarmer("<span class='bold'>###=-</span> Ident confirmed. data packet received.>")
		. += span_swarmer("<span class='bold'>ID:</span> [icon2html(src, user)] Resource Cache")
		. += span_swarmer("<span class='bold'>Resources:</span> [resources]")
		. += span_swarmer("<span class='bold'>###=-</span>")