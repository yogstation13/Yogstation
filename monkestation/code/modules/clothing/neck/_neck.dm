/obj/item/clothing/neck
	var/cover_accessories = TRUE

/obj/item/clothing/neck/Initialize(mapload)
	. = ..()
	register_context()

/obj/item/clothing/neck/alt_click_secondary(mob/user)
	. = ..()
	if(.)
		return
	if(!can_use(user))
		return
	cover_accessories = !cover_accessories
	if(cover_accessories)
		to_chat(usr, span_notice("You adjust [src] to cover accessories."))
	else
		to_chat(usr, span_notice("You adjust [src] to show accessories."))

	user.update_clothing(ITEM_SLOT_NECK)
	update_appearance()

/obj/item/clothing/neck/add_context(atom/source, list/context, obj/item/held_item, mob/living/user)
	. = ..()
	context[SCREENTIP_CONTEXT_ALT_RMB] =  "[cover_accessories ? "Uncover" : "Cover"] accessories"
	return CONTEXTUAL_SCREENTIP_SET

/obj/item/clothing/neck/worn_overlays(mutable_appearance/standing, isinhands = FALSE)
	. = ..()
	if(isinhands)
		return
	if(cover_accessories)
		return
	var/mob/living/carbon/human/wearer = loc
	if(!ishuman(wearer) || !wearer.w_uniform)
		return
	var/obj/item/clothing/under/undershirt = wearer.w_uniform
	if(!istype(undershirt) || !LAZYLEN(undershirt.attached_accessories))
		return

	var/obj/item/clothing/accessory/displayed = undershirt.attached_accessories[1]
	if(displayed.above_suit)
		. += undershirt.accessory_overlay
