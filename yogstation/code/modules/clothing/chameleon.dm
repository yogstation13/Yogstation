/datum/action/item_action/chameleon/change/update_item(obj/item/picked_item, obj/item/target = target)
	..()
	if(ispath(picked_item, /obj/item/pda) && istype(target, /obj/item/pda))
		target.set_light_color(initial(picked_item.light_color))
