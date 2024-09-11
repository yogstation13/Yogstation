/datum/asset/spritesheet/chicken_book
	name = "chicken_book"

/datum/asset/spritesheet/chicken_book/create_spritesheets()
	var/list/id_list = list()
	for(var/datum/mutation/ranching/chicken/chicken_mutation as anything in subtypesof(/datum/mutation/ranching/chicken))
		var/chicken_type = chicken_mutation::chicken_type
		if(!ispath(chicken_type, /mob/living/basic/chicken))
			continue
		var/id = sanitize_css_class_name("[chicken_type]")
		if(id_list[id])
			continue
		var/mob/living/basic/chicken/chicken = new chicken_type
		var/icon/chicken_icon = getFlatIcon(chicken, EAST, no_anim = TRUE)
		var/icon/resized_icon = resize_icon(chicken_icon, 96, 96)
		if(!resized_icon)
			stack_trace("Failed to upscale icon for [chicken_type], upscaling using BYOND!")
			chicken_icon.Scale(96, 96)
			resized_icon = chicken_icon
		id_list[id] = TRUE
		Insert(id, resized_icon)
		QDEL_NULL(chicken)
