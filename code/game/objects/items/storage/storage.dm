/obj/item/storage
	name = "storage"
	icon = 'icons/obj/storage.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	var/rummage_if_nodrop = TRUE
	var/component_type = /datum/component/storage/concrete
	/// Should we preload the contents of this type?
	/// BE CAREFUL, THERE'S SOME REALLY NASTY SHIT IN THIS TYPEPATH
	/// SANTA IS EVIL
	var/preload = FALSE

/obj/item/storage/get_dumping_location(obj/item/storage/source,mob/user)
	return src

/obj/item/storage/Initialize(mapload)
	. = ..()
	AddComponent(component_type)
	PopulateContents()

/obj/item/storage/AllowDrop()
	return FALSE

/obj/item/storage/contents_explosion(severity, target)
	for(var/thing in contents)
		switch(severity)
			if(EXPLODE_DEVASTATE)
				SSexplosions.high_mov_atom += thing
			if(EXPLODE_HEAVY)
				SSexplosions.med_mov_atom += thing
			if(EXPLODE_LIGHT)
				SSexplosions.low_mov_atom += thing

/obj/item/storage/canStrip(mob/who)
	. = ..()
	if(!. && rummage_if_nodrop)
		return TRUE

/obj/item/storage/doStrip(mob/who)
	if(HAS_TRAIT(src, TRAIT_NODROP) && rummage_if_nodrop)
		var/datum/component/storage/CP = GetComponent(/datum/component/storage)
		CP.do_quick_empty()
		return TRUE
	return ..()

/obj/item/storage/contents_explosion(severity, target)
//Cyberboss says: "USE THIS TO FILL IT, NOT INITIALIZE OR NEW"

/obj/item/storage/proc/PopulateContents()

/obj/item/storage/proc/emptyStorage()
	var/datum/component/storage/ST = GetComponent(/datum/component/storage)
	ST.do_quick_empty()

/// Returns a list of object types to be preloaded by our code
/// I'll say it again, be very careful with this. We only need it for a few things
/// Don't do anything stupid, please
/obj/item/storage/proc/get_types_to_preload()
	return

/obj/item/storage/vv_get_dropdown()
	. = ..()
	VV_DROPDOWN_SEPERATOR
	VV_DROPDOWN_OPTION(VV_HK_SPAWN_ITEM_INSIDE, "Spawn Item Inside")

/obj/item/storage/vv_do_topic(list/href_list)
	. = ..()
	if(href_list[VV_HK_SPAWN_ITEM_INSIDE] && check_rights(R_SPAWN))
		var/valid_id = FALSE
		var/chosen_id
		while(!valid_id)
			chosen_id = input(usr, "Enter the typepath of the item you want to add.", "Search items") as null|text
			if(isnull(chosen_id)) //Get me out of here!
				break
			if (!ispath(text2path(chosen_id)))
				chosen_id = pick_closest_path(chosen_id, make_types_fancy(subtypesof(/obj/item)))
				if (ispath(chosen_id))
					valid_id = TRUE
			else
				valid_id = TRUE
			if(!valid_id)
				to_chat(usr, span_warning("A reagent with that ID doesn't exist!"))
		
		if(valid_id)
			var/obj/item/item = new chosen_id(src)
			item.forceMove(src)

