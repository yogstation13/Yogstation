/datum/asset/spritesheet/loadout_store
	name = "loadout_store"

/datum/asset/spritesheet/loadout_store/create_spritesheets()
	var/list/id_list = list()
	for(var/datum/store_item/store_item as anything in subtypesof(/datum/store_item))
		if(!store_item::name || !store_item::item_path)
			continue
		var/atom/item_type = store_item::item_path
		if(!item_type::icon || !item_type::icon_state)
			continue
		var/id = sanitize_css_class_name("[item_type]")
		if(id_list[id])
			continue
		var/icon/item_icon
		if(item_type::greyscale_config || item_type::greyscale_colors)
			var/atom/loadout_item = new item_type
			item_icon = getFlatIcon(loadout_item)
			QDEL_NULL(loadout_item)
		else
			item_icon = icon(item_type::icon, item_type::icon_state)
		if(!item_icon || item_icon.Width() != 32 || item_icon.Height() != 32)
			continue
		Insert(id, item_icon)
		id_list[id] = TRUE
