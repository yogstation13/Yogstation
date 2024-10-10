/datum/species/lizard
	payday_modifier = 1

/datum/species/lizard/get_custom_worn_config_fallback(item_slot, obj/item/item)

	return item.greyscale_config_worn_lizard_fallback

/datum/species/lizard/generate_custom_worn_icon(item_slot, obj/item/item)
	. = ..()
	if(.)
		return

	// Use the fancy fallback sprites.
	. = generate_custom_worn_icon_fallback(item_slot, item)
	if(.)
		return
