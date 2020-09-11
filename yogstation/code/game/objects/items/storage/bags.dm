/obj/item/storage/bag/trash
	component_type = /datum/component/storage/concrete/trashbag

/obj/item/storage/bag/trash/proc/snap(mob/user) // Handles whenever the trash bag breaks
	to_chat(user,"<span class='danger'>The [src] rips! Oh no!</span>")
	emptyStorage()
	icon_state = "[initial(icon_state)]_broken"
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 0

/obj/item/storage/bag/trash/bluespace/snap(mob/user)
	return // Bluespace don't crack, as the old saying goes

/obj/item/storage/bag/trash/cyborg/snap(mob/user)
	return // TODO: Make this work for borgs, maybe, I guess