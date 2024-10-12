/datum/asset/spritesheet/loadout_store
	name = "loadout_store"

/datum/asset/spritesheet/loadout_store/create_spritesheets()
	var/list/id_list = list()
	for(var/datum/store_item/store_item as anything in subtypesof(/datum/store_item))
		if(!store_item::name || !store_item::item_path)
			continue
		var/obj/item_type = store_item::item_path
		var/id = sanitize_css_class_name("[item_type]")
		if(id_list[id])
			continue
		var/icon/item_icon = generate_icon_for_item(item_type)
		if(!item_icon)
			stack_trace("Failed to generate icon for [item_type]")
			continue
		else if(item_icon.Width() != 32 || item_icon.Height() != 32)
			stack_trace("[item_type] icon had invalid width/height ([item_icon.Width()]x[item_icon.Height()])")
			continue
		Insert(id, item_icon)
		id_list[id] = TRUE

/datum/asset/spritesheet/loadout_store/proc/generate_icon_for_item(obj/item/item) as /icon
	RETURN_TYPE(/icon)
	var/icon_file = item::icon_preview || item::icon
	var/icon_state = item::icon_state_preview || item::icon_state
	var/has_gags_config = item::greyscale_config && item::greyscale_colors
	var/has_preview_icon = item::icon_preview && item::icon_state_preview
	if(has_gags_config && !has_preview_icon) // preview icons take priority over GAGS
		var/icon/gags_icon = SSgreyscale.GetColoredIconByType(item::greyscale_config, item::greyscale_colors)
		return icon(gags_icon, item::icon_state)
	else if(icon_exists(icon_file, icon_state))
		var/icon/item_icon = icon(
			icon_file,
			icon_state,
			dir = SOUTH,
			frame = 1,
			moving = FALSE,
		)
		return icon(fcopy_rsc(item_icon))
	else
		var/obj/item/dummy_item = new item
		var/icon/flat_icon = getFlatIcon(dummy_item)
		if(!flat_icon)
			CRASH("Failed to generate any icon for [item]")
		var/icon/cached_icon = icon(fcopy_rsc(flat_icon))
		qdel(dummy_item)
		return cached_icon
