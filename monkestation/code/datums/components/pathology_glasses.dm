// This is a component for glasses that makes them able to see pathogens and also toggle viewing them.
// Mainly used by "viral analyzer goggles", "viral analyzer glasses" and "night vision viral analyzer goggles", but works with any type of glasses.

/datum/component/pathology_glasses
	var/icon_state_on = null
	var/icon_state_off = null

	var/worn_icon_state_on = null
	var/worn_icon_state_off = null

	var/glass_color_type_on = /datum/client_colour/glass_colour/lightgreen
	var/glass_color_type_off = /datum/client_colour/glass_colour/lightpurple
	var/use_glass_color = FALSE

	var/color_cutoffs_on = null
	var/color_cutoffs_off = null
	var/use_color_cutoffs = FALSE

	var/enabled = TRUE

	var/action = /datum/action/item_action/toggle_virus_view

/datum/component/pathology_glasses/Initialize(icon_state_on, icon_state_off, worn_icon_state_on = icon_state_on, worn_icon_state_off = icon_state_off, glass_color_type_on, glass_color_type_off, use_glass_color = FALSE, color_cutoffs_on, color_cutoffs_off, use_color_cutoffs = FALSE)
	var/obj/item/clothing/glasses/glasses = parent

	if(!istype(glasses))
		return COMPONENT_INCOMPATIBLE

	src.icon_state_on = icon_state_on
	src.icon_state_off = icon_state_off
	src.worn_icon_state_on = worn_icon_state_on
	src.worn_icon_state_off = worn_icon_state_off
	src.use_glass_color = use_glass_color
	src.use_color_cutoffs = use_color_cutoffs

	if(use_glass_color)
		src.glass_color_type_on ||= glass_color_type_on
		src.glass_color_type_off ||= glass_color_type_off
		glasses.glass_colour_type = glass_color_type_on

	if(use_color_cutoffs)
		src.color_cutoffs_on = color_cutoffs_on
		src.color_cutoffs_off = color_cutoffs_off
		glasses.color_cutoffs = color_cutoffs_on

	action = glasses.add_item_action(action) // Doing it after setting the icon state vars makes sure the item action has the correct sprite.

/datum/component/pathology_glasses/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_UI_ACTION_CLICK, PROC_REF(on_action_click))
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equipped))

/datum/component/pathology_glasses/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ITEM_UI_ACTION_CLICK, COMSIG_ITEM_EQUIPPED))

/datum/component/pathology_glasses/proc/on_action_click(datum/source, mob/living/user, datum/action/action)
	SIGNAL_HANDLER

	if(src.action != action)
		return

	if(enabled)
		disable(user)
	else
		enable(user)

/datum/component/pathology_glasses/proc/on_equipped(datum/source, mob/living/user, slot)
	SIGNAL_HANDLER

	if(!(slot & ITEM_SLOT_EYES))
		return

	if(enabled)
		ADD_CLOTHING_TRAIT(user, TRAIT_VIRUS_SCANNER)

	RegisterSignal(user, COMSIG_MOB_UNEQUIPPED_ITEM, PROC_REF(on_item_unequipped))

/datum/component/pathology_glasses/proc/on_item_unequipped(mob/living/user, obj/item/item)
	SIGNAL_HANDLER

	if(item != parent)
		return

	if(enabled)
		REMOVE_CLOTHING_TRAIT(user, TRAIT_VIRUS_SCANNER)

	UnregisterSignal(user, COMSIG_MOB_UNEQUIPPED_ITEM)

/datum/component/pathology_glasses/proc/enable(mob/living/user)
	enabled = TRUE
	update_icon_states(user)

	ADD_CLOTHING_TRAIT(user, TRAIT_VIRUS_SCANNER)

	playsound(get_turf(parent), 'sound/machines/click.ogg', vol = 30, vary = TRUE)

/datum/component/pathology_glasses/proc/disable(mob/living/user)
	enabled = FALSE
	update_icon_states(user)

	REMOVE_CLOTHING_TRAIT(user, TRAIT_VIRUS_SCANNER)

	playsound(get_turf(parent), 'sound/machines/click.ogg', vol = 30, vary = TRUE)

/datum/component/pathology_glasses/proc/update_icon_states(mob/living/user)
	var/obj/item/clothing/glasses/glasses = parent

	glasses.icon_state = enabled ? icon_state_on : icon_state_off
	glasses.worn_icon_state = enabled ? worn_icon_state_on : worn_icon_state_off

	if(use_glass_color)
		glasses.change_glass_color(user, enabled ? glass_color_type_on : glass_color_type_off)

	if(use_color_cutoffs)
		glasses.color_cutoffs = enabled ? color_cutoffs_on : color_cutoffs_off
		user.update_sight()

	user.update_worn_glasses()
	glasses.update_item_action_buttons()
