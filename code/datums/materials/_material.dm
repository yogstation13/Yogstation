/*! Material datum

Simple datum which is instanced once per type and is used for every object of said material. It has a variety of variables that define behavior. Subtyping from this makes it easier to create your own materials.

*/


/datum/material
	var/name = "material"
	var/desc = "It's...stuff." // I'm stuff :stuff:
	///Var that's mostly used by science machines to identify specific materials, should most likely be phased out at some point
	var/id = "mat"
	///Base color of the material, is used for greyscale. Item isn't changed in color if this is null.
	///Deprecated, use greyscale_color instead.
	var/color
	///Determines the color palette of the material. Formatted the same as atom/var/greyscale_colors
	var/greyscale_colors
	///Base alpha of the material, is used for greyscale icons.
	var/alpha
	///Materials "Traits". its a map of key = category | Value = Bool. Used to define what it can be used for.gold
	var/list/categories = list()
	///The type of sheet this material creates. This should be replaced as soon as possible by greyscale sheets.
	var/sheet_type
	///The type of coin this material spawns. This should be replaced as soon as possible by greyscale coins.
	var/coin_type
	///This is a modifier for force, and resembles the strength of the material
	var/strength_modifier = 1
	///This is a modifier for integrity, and resembles the strength of the material
	var/integrity_modifier = 1
	///what texture icon state to overlay
	var/texture_layer_icon_state
	///a cached icon for the texture filter
	var/cached_texture_filter_icon

/** Handles initializing the material.
 *
 * Arugments:
 * - _id: The ID the material should use. Overrides the existing ID.
 */
/datum/material/proc/Initialize(_id, ...)
	if(_id)
		id = _id
	else if(isnull(id))
		id = type

	if(texture_layer_icon_state)
		cached_texture_filter_icon = icon('icons/materials/composite.dmi', texture_layer_icon_state)

	return TRUE

///This proc is called when the material is added to an object.
/datum/material/proc/on_applied(atom/source, amount, material_flags)
	if(material_flags & MATERIAL_COLOR) //Prevent changing things with pre-set colors, to keep colored toolboxes their looks for example
		if(color) //Do we have a custom color?
			source.add_atom_colour(color, FIXED_COLOUR_PRIORITY)
		if(alpha)
			source.alpha = alpha
		if(texture_layer_icon_state)
			ADD_KEEP_TOGETHER(source, MATERIAL_SOURCE(src))
			source.add_filter("material_texture_[name]",1,layering_filter(icon=cached_texture_filter_icon,blend_mode=BLEND_INSET_OVERLAY))

	if(material_flags & MATERIAL_GREYSCALE)
		var/config_path = get_greyscale_config_for(source.greyscale_config)
		source.set_greyscale(greyscale_colors, config_path)

	if(alpha < 255)
		source.opacity = FALSE
	if(material_flags & MATERIAL_ADD_PREFIX)
		source.name = "[name] [source.name]"

	if(isobj(source)) //objs
		on_applied_obj(source, amount, material_flags)
	
	source.mat_update_desc(src)

///This proc is called when a material updates an object's description
/atom/proc/mat_update_desc(datum/material/mat)
	return

///This proc is called when the material is added to an object specifically.
/datum/material/proc/on_applied_obj(obj/o, amount, material_flags)
	if(material_flags & MATERIAL_AFFECT_STATISTICS)
		var/new_max_integrity = CEILING(o.max_integrity * integrity_modifier, 1)
		// This is to keep the same damage relative to the max integrity of the object
		o.modify_max_integrity(new_max_integrity, FALSE)
		o.force *= strength_modifier
		o.throwforce *= strength_modifier

	if(!isitem(o))
		return
	var/obj/item/item = o

	if(material_flags & MATERIAL_GREYSCALE)
		var/worn_path = get_greyscale_config_for(item.greyscale_config_worn)
		var/lefthand_path = get_greyscale_config_for(item.greyscale_config_inhand_left)
		var/righthand_path = get_greyscale_config_for(item.greyscale_config_inhand_right)
		item.set_greyscale(
			new_worn_config = worn_path,
			new_inhand_left = lefthand_path,
			new_inhand_right = righthand_path
		)

/datum/material/proc/on_applied_turf(turf/T, amount, material_flags)
	return

/datum/material/proc/get_greyscale_config_for(datum/greyscale_config/config_path)
	if(!config_path)
		return
	for(var/datum/greyscale_config/path as anything in subtypesof(config_path))
		if(type != initial(path.material_skin))
			continue
		return path

///This proc is called when the material is removed from an object.
/datum/material/proc/on_removed(atom/source, amount, material_flags)
	if(material_flags & MATERIAL_COLOR) //Prevent changing things with pre-set colors, to keep colored toolboxes their looks for example
		if(color)
			source.remove_atom_colour(FIXED_COLOUR_PRIORITY, color)
		if(texture_layer_icon_state)
			source.remove_filter("material_texture_[name]")
			REMOVE_KEEP_TOGETHER(source, MATERIAL_SOURCE(src))
		source.alpha = initial(source.alpha)

	if(material_flags & MATERIAL_GREYSCALE)
		source.set_greyscale(initial(source.greyscale_colors), initial(source.greyscale_config))

	if(material_flags & MATERIAL_ADD_PREFIX)
		source.name = initial(source.name)

	if(isobj(source)) //objs
		on_removed_obj(source, amount, material_flags)

	if(istype(source, /turf)) //turfs
		on_removed_turf(source, amount, material_flags)

///This proc is called when the material is removed from an object specifically.
/datum/material/proc/on_removed_obj(obj/o, amount, material_flags)
	if(material_flags & MATERIAL_AFFECT_STATISTICS)
		o.modify_max_integrity(initial(o.max_integrity), FALSE)
		o.force = initial(o.force)
		o.throwforce = initial(o.throwforce)
	
	if(isitem(o) && (material_flags & MATERIAL_GREYSCALE))
		var/obj/item/item = o
		item.set_greyscale(
			new_worn_config = initial(item.greyscale_config_worn),
			new_inhand_left = initial(item.greyscale_config_inhand_left),
			new_inhand_right = initial(item.greyscale_config_inhand_right)
		)

/datum/material/proc/on_removed_turf(turf/T, amount, material_flags)
	return

/**
 * This proc is called when the mat is found in an item that's consumed by accident. see /obj/item/proc/on_accidental_consumption.
 * Arguments
 * * M - person consuming the mat
 * * S - (optional) item the mat is contained in (NOT the item with the mat itself)
 */
/datum/material/proc/on_accidental_mat_consumption(mob/living/carbon/M, obj/item/S)
	return FALSE

/** Returns the composition of this material.
 *
 * Mostly used for alloys when breaking down materials.
 *
 * Arguments:
 * - amount: The amount of the material to break down.
 * - breakdown_flags: Some flags dictating how exactly this material is being broken down.
 */
/datum/material/proc/return_composition(amount=1, breakdown_flags=NONE)
	return list((src) = amount) // Yes we need the parenthesis, without them BYOND stringifies src into "src" and things break.

