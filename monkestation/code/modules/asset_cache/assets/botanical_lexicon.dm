/datum/asset/spritesheet/botanical_lexicon
	name = "botanical_lexicon"

/datum/asset/spritesheet/botanical_lexicon/create_spritesheets()
	var/list/id_list = list()
	var/list/seeds = (subtypesof(/datum/hydroponics/plant_mutation) - /datum/hydroponics/plant_mutation/spliced_mutation - /datum/hydroponics/plant_mutation/infusion)
	for(var/datum/hydroponics/plant_mutation/mutation as anything in seeds)
		var/obj/item/seed_type = mutation::created_seed
		if(!ispath(seed_type, /obj/item))
			continue
		var/seed_icon_file = seed_type::icon
		var/seed_icon_state = seed_type::icon_state
		if(!seed_icon_file || !seed_icon_state)
			continue
		var/id = sanitize_css_class_name("[seed_icon_file]_[seed_icon_state]")
		if(id_list[id])
			continue
		var/icon/seed_icon = icon(seed_icon_file, seed_icon_state)
		var/icon/resized_icon = resize_icon(seed_icon, 96, 96)
		if(!resized_icon)
			stack_trace("Failed to upscale icon for \"[seed_icon_state]\" @ '[seed_icon]', upscaling using BYOND!")
			seed_icon.Scale(96, 96)
			resized_icon = seed_icon
		id_list[id] = TRUE
		Insert(id, resized_icon)
