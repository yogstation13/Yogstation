/obj/item/clothing/head/helmet/space/space_ninja
	mob_overlay_icon = 'yogstation/icons/mob/clothing/head/head.dmi'
	icon_state = "s-ninja"

/obj/item/clothing/mask/gas/space_ninja
	mob_overlay_icon = 'yogstation/icons/mob/clothing/mask/mask.dmi'
	icon = 'yogstation/icons/obj/clothing/masks.dmi'
	icon_state = "s-ninja"
	var/lights_on = FALSE
	var/lights_colour = "16be00"

/obj/item/clothing/shoes/space_ninja
	mob_overlay_icon = 'yogstation/icons/mob/clothing/feet/feet.dmi'
	icon_state = "s-ninja"
	var/lights_on = FALSE
	var/lights_colour = "16be00"

/obj/item/clothing/suit/space/space_ninja
	mob_overlay_icon = 'yogstation/icons/mob/clothing/suit/suit.dmi'
	icon = 'yogstation/icons/obj/clothing/suits.dmi'
	icon_state = "s-ninja"
	var/lights_on = FALSE
	var/lights_colour = "#16be00"
	var/obj/item/clothing/mask/gas/space_ninja/n_mask

/obj/item/clothing/gloves/space_ninja
	var/lights_on = FALSE
	var/lights_colour = "16be00"

/obj/item/clothing/suit/space/space_ninja/worn_overlays(isinhands = FALSE)
	.=..()
	if(!isinhands && lights_on)
		var/mutable_appearance/M = mutable_appearance(mob_overlay_icon, "s-ninja-overlay")
		M.color = lights_colour
		. += M

/obj/item/clothing/mask/gas/space_ninja/worn_overlays(isinhands = FALSE)
	.=..()
	if(!isinhands && lights_on)
		var/mutable_appearance/M = mutable_appearance(mob_overlay_icon, "s-ninja-overlay")
		M.color = lights_colour
		. += M


/obj/item/clothing/shoes/space_ninja/worn_overlays(isinhands = FALSE)
	.=..()
	if(!isinhands && lights_on)
		var/mutable_appearance/M = mutable_appearance(mob_overlay_icon, "s-ninja-overlay")
		M.color = lights_colour
		. += M

/obj/item/clothing/gloves/space_ninja/worn_overlays(isinhands = FALSE)
	.=..()
	if(!isinhands && lights_on)
		var/mutable_appearance/M = mutable_appearance(mob_overlay_icon, "s-ninja-overlay")
		M.color = lights_colour
		. += M

/obj/item/clothing/suit/space/space_ninja/lock_suit(mob/living/carbon/human/H)
	if(!istype(H) || !is_ninja(H))
		return ..()

	if(!istype(H.wear_mask, /obj/item/clothing/mask/gas/space_ninja))
		to_chat(H, "[span_userdanger("ERROR")]: 10453 UNABLE TO LOCATE FACE MASK\nABORTING...")
		return FALSE

	.=..()
	if(.)
		n_mask = H.wear_mask
		ADD_TRAIT(n_mask, TRAIT_NODROP, NINJA_SUIT_TRAIT)
		n_mask.lights_on = TRUE
		n_shoes.lights_on = TRUE
		n_gloves.lights_on = TRUE
		lights_on = TRUE
		H.regenerate_icons()

/obj/item/clothing/suit/space/space_ninja/unlock_suit()
	.=..()
	if(n_mask)
		REMOVE_TRAIT(n_mask, TRAIT_NODROP, NINJA_SUIT_TRAIT)
		n_mask.lights_on = FALSE

	if(n_shoes)
		n_shoes.lights_on = FALSE

	if(n_gloves)
		n_gloves.lights_on = FALSE

	lights_on = FALSE
	affecting.regenerate_icons()

/obj/item/clothing/suit/space/space_ninja/lockIcons(mob/living/carbon/human/H)
	return

/obj/item/clothing/suit/space/space_ninja/Initialize()
	actions_types += /datum/action/item_action/ninjacolour
	.=..()

/obj/item/clothing/suit/space/space_ninja/ui_action_click(mob/user, action)
	.=..()
	if(.)
		return .

	if(!s_initialized)
		to_chat(user, span_warning("<b>ERROR</b>: suit offline.  Please activate suit."))
		return FALSE

	if(istype(action, /datum/action/item_action/ninjacolour))
		ninjacolour()
		return TRUE


/obj/item/clothing/suit/space/space_ninja/proc/ninjacolour()
	var/pickedNinjaColor = input(affecting, "Choose your suit light color.", "Suit light colour",lights_colour) as color|null
	if(pickedNinjaColor)
		lights_colour = pickedNinjaColor
		if(n_mask)
			n_mask.lights_colour = pickedNinjaColor
		if(n_shoes)
			n_shoes.lights_colour = pickedNinjaColor
		if(n_gloves)
			n_gloves.lights_colour = pickedNinjaColor
		affecting.regenerate_icons()

/obj/item/clothing/suit/space/space_ninja/lavaland
	do_gib = FALSE
