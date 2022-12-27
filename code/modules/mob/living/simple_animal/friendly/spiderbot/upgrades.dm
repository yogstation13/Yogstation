// Contains all the interaction procs for spiderbots, also contains upgrade stuff
/mob/living/simple_animal/spiderbot/proc/update_upgrades()
	if("/obj/item/bot_assembly/cleanbot" in spiderbot_upgrades)
		add_verb(src, list(/mob/living/simple_animal/spiderbot/proc/cleaning_mode))
//Hiding under tables
/mob/living/simple_animal/spiderbot/proc/hide()
	set name = "Hide"
	set desc = "Allows to hide beneath tables or certain items. Toggled on or off."
	set category = "Spiderbot"

	if(stat != CONSCIOUS)
		return

	if (layer != ABOVE_NORMAL_TURF_LAYER)
		layer = ABOVE_NORMAL_TURF_LAYER
		to_chat(src, span_notice("You are now hiding."))
	else
		layer = MOB_LAYER
		to_chat(src, span_notice("You have stopped hiding."))

//Dropping items
/mob/living/simple_animal/spiderbot/proc/drop_held_item()
	set name = "Drop held item"
	set category = "Spiderbot"
	set desc = "Drop the item you're holding."
	if(stat != CONSCIOUS)
		return
	if(!held_item)
		to_chat(usr, span_warning(">You have nothing to drop!"))
		return 0

	visible_message(span_notice("[src] drops \the [held_item]!"), span_notice("You drop \the [held_item]!"), span_hear("You hear a skittering noise and a soft thump."))
	held_item.forceMove(loc)
	held_item = null
	return

// Kleptomania simulator 23xx
/mob/living/simple_animal/spiderbot/proc/get_item()
	set name = "Pick up item"
	set category = "Spiderbot"
	set desc = "Allows you to take a nearby small item."

	if(stat != CONSCIOUS)
		return
	if(held_item)
		to_chat(src, span_warning("You are already holding \the [held_item]"))
		return

	var/list/items = list()
	for(var/obj/item/I in view(1,src))
		//Make sure we're not already holding it and it's small enough
		if(I.loc != src && I.w_class <= WEIGHT_CLASS_SMALL)
			items |= I
	var/obj/selection = input("Select an item.", "Pickup") in items

	if(selection)
		for(var/obj/item/I in view(1, src))
			if(selection == I)
				held_item = selection
				selection.loc = src
				visible_message(span_notice("[src] scoops up \the [held_item]!"), span_notice("You grab \the [held_item]!"), span_hear("You hear a skittering noise and a clink."))
				return held_item
		to_chat(src, span_warning("\The [selection] is too far away."))
		return 0

	to_chat(src, span_warning("There is nothing of interest to take."))
	return 0

mob/living/simple_animal/spiderbot/proc/cleaning_mode()
	set name = "Switch cleaning protocols"
	set category = "Spiderbot"
	set desc = "Allows you to clean when moving, but slows you down"

	if(clean_on_move == FALSE)
		clean_on_move = TRUE
		AddComponent(/datum/component/cleaning)
		speed = slowed_speed
		to_chat(src, span_warning("You turn on your cleaning protocols."))
	else
		clean_on_move = FALSE
		qdel(GetComponent(/datum/component/cleaning))
		speed = default_speed
		to_chat(src, span_warning("You disable your cleaning protocols."))
	
	return 0
