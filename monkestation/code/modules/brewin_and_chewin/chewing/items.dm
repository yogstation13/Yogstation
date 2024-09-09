/obj/item/spatula
	name = "Spatula"
	desc = "A Hydrodynamic Spatula. Port and Starboard attachments not included."
	icon = 'monkestation/code/modules/brewin_and_chewin/icons/kitchen.dmi'
	icon_state = "spat"
	w_class = WEIGHT_CLASS_SMALL

/obj/item
	var/cooking_description_modifier

/obj/item/examine(mob/user)
	. = ..()
	if(cooking_description_modifier)
		. += span_notice(cooking_description_modifier)
