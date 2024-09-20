///Chameleon - lets the suit disguise as any item that would fit on that slot.
/obj/item/mod/module/chameleon
	name = "MOD chameleon module"
	desc = "A module using chameleon technology to disguise the suit as another object."
	icon_state = "chameleon"
	module_type = MODULE_USABLE
	complexity = 2
	incompatible_modules = list(/obj/item/mod/module/chameleon)
	cooldown_time = 0.5 SECONDS
	allow_flags = MODULE_ALLOW_INACTIVE
	/// A list of all the items the suit can disguise as.
	var/list/possible_disguises = list()
	/// The path of the item we're disguised as.
	var/obj/item/current_disguise
	/// The last (valid) slot the suit was equipped to, so we don't lose it if we just temporarily put it in our hands or something
	var/last_equipped_slot = NONE
	/// Cached possible disguises for individual slots
	var/static/list/cached_disguises = list()

/obj/item/mod/module/chameleon/on_install()
	undo_disguise()
	current_disguise = null

/obj/item/mod/module/chameleon/on_uninstall(deleting = FALSE)
	if(deleting)
		return
	undo_disguise()
	if(current_disguise)
		current_disguise = null
		mod.wearer?.balloon_alert(mod.wearer, "MOD disguise cleared")

/obj/item/mod/module/chameleon/on_use()
	. = ..()
	if(!.)
		return
	if(current_disguise)
		undo_disguise()
		current_disguise = null
		mod.wearer.balloon_alert(mod.wearer, "MOD disguise cleared")
		return
	var/picked_name = tgui_input_list(mod.wearer, "Select look to change into", "Chameleon Settings", possible_disguises)
	if(!possible_disguises[picked_name])
		return
	if(mod.active || mod.activating)
		mod.wearer.balloon_alert(mod.wearer, "can't disguise MOD while active!")
		return
	current_disguise = possible_disguises[picked_name]
	mod.wearer?.balloon_alert(mod.wearer, "MOD disguise set")
	disguise()

/obj/item/mod/module/chameleon/on_equip()
	if(QDELETED(mod) || QDELETED(mod.wearer))
		return
	var/mob/living/carbon/human/wearer = mod.wearer
	var/current_slot = wearer.get_slot_by_item(mod)
	if(mod.slot_flags & current_slot)
		last_equipped_slot = current_slot
	else
		// if we're holding it or something, just use either the last equipped slot or the default one
		current_slot = last_equipped_slot || mod.slot_flags
	possible_disguises = get_slot_disguises(current_slot)
	if(current_disguise && !(current_disguise::slot_flags & current_slot))
		undo_disguise()
		current_disguise = null
		mod.wearer?.balloon_alert(mod.wearer, "MOD undisguised")

/obj/item/mod/module/chameleon/on_unequip()
	if(QDELETED(mod) || QDELETED(mod.wearer))
		return
	var/mob/living/carbon/human/wearer = mod.wearer
	var/current_slot = wearer.get_slot_by_item(mod)
	if(mod.slot_flags & current_slot)
		current_slot = last_equipped_slot || mod.slot_flags

/obj/item/mod/module/chameleon/on_suit_activation()
	undo_disguise()
	if(current_disguise)
		mod.wearer?.balloon_alert(mod.wearer, "MOD undisguised")

/obj/item/mod/module/chameleon/on_suit_deactivation(deleting = FALSE)
	if(deleting)
		return
	disguise()
	if(current_disguise)
		mod.wearer?.balloon_alert(mod.wearer, "MOD disguised")

/obj/item/mod/module/chameleon/proc/disguise()
	if(!current_disguise)
		undo_disguise()
		return
	mod.name = initial(current_disguise.name)
	mod.desc = initial(current_disguise.desc)
	mod.icon_state = initial(current_disguise.icon_state)
	mod.icon = initial(current_disguise.icon)
	mod.worn_icon = initial(current_disguise.worn_icon)
	mod.alternate_worn_layer = initial(current_disguise.alternate_worn_layer)
	mod.lefthand_file = initial(current_disguise.lefthand_file)
	mod.righthand_file = initial(current_disguise.righthand_file)
	mod.worn_icon_state = initial(current_disguise.worn_icon_state)
	mod.inhand_icon_state = initial(current_disguise.inhand_icon_state)
	mod.wearer?.update_clothing(mod.slot_flags)

/obj/item/mod/module/chameleon/proc/undo_disguise()
	mod.name = "[mod.theme.name] [initial(mod.name)]"
	mod.desc = "[initial(mod.desc)] [mod.theme.desc]"
	mod.icon_state = "[mod.skin]-[initial(mod.icon_state)]"
	var/list/mod_skin = mod.theme.skins[mod.skin]
	mod.icon = mod_skin[MOD_ICON_OVERRIDE] || 'icons/obj/clothing/modsuit/mod_clothing.dmi'
	mod.worn_icon = mod_skin[MOD_WORN_ICON_OVERRIDE] || 'icons/mob/clothing/modsuit/mod_clothing.dmi'
	mod.alternate_worn_layer = mod_skin[CONTROL_LAYER]
	mod.lefthand_file = initial(mod.lefthand_file)
	mod.righthand_file = initial(mod.righthand_file)
	mod.worn_icon_state = initial(mod.worn_icon_state)
	mod.inhand_icon_state = initial(mod.inhand_icon_state)
	mod.update_icon_state()
	mod.wearer?.update_clothing(mod.slot_flags)

/obj/item/mod/module/chameleon/proc/get_slot_disguises(slot) as /list
	if(cached_disguises["[slot]"]) // let's avoid repeated sorts on a list that'll always be the same for the same input
		return cached_disguises["[slot]"]
	var/list/all_disguises = sort_list(subtypesof(get_path_by_slot(slot)), GLOBAL_PROC_REF(cmp_typepaths_asc))
	var/list/disguises = list()
	for(var/obj/item/clothing as anything in all_disguises)
		if(!clothing::icon_state)
			continue
		var/chameleon_item_name = "[clothing::name] ([clothing::icon_state])"
		disguises[chameleon_item_name] = clothing
	cached_disguises["[slot]"] = disguises
	return disguises
