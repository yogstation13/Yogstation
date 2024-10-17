/datum/asset/spritesheet/loadout_store
	name = "loadout_store"

/datum/asset/spritesheet/loadout_store/create_spritesheets()
	var/list/id_list = list()
	for(var/datum/store_item/store_item as anything in subtypesof(/datum/store_item))
		if(!store_item::name || !store_item::item_path)
			continue
		var/obj/item_type = store_item::item_path
		if(!should_generate_icon(item_type))
			continue
		var/id = sanitize_css_class_name("[item_type]")
		if(id_list[id])
			continue
		var/icon/item_icon = icon(SSgreyscale.GetColoredIconByType(item_type::greyscale_config, item_type::greyscale_colors), item_type::icon_state)
		if(!item_icon)
			stack_trace("Failed to generate icon for [item_type]")
			continue
		else if(item_icon.Width() != 32 || item_icon.Height() != 32)
			stack_trace("[item_type] icon had invalid width/height ([item_icon.Width()]x[item_icon.Height()])")
			continue
		Insert(id, item_icon)
		id_list[id] = TRUE

/datum/asset/spritesheet/loadout_store/proc/should_generate_icon(obj/item/item)
	if(item::icon_preview && item::icon_state_preview)
		return FALSE
	if(item::greyscale_config && item::greyscale_colors)
		return TRUE
	return FALSE
