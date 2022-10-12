
/mob/living/carbon/monkey/regenerate_icons()
	if(!..())
		update_body_parts()
		update_hair()
		update_inv_wear_mask()
		update_inv_head()
		update_inv_back()
		update_transform()


////////


/mob/living/carbon/monkey/update_hair()
	remove_overlay(HAIR_LAYER)

	var/obj/item/bodypart/head/HD = get_bodypart(BODY_ZONE_HEAD)
	if(!HD) //Decapitated
		return

	if(HAS_TRAIT(src, TRAIT_HUSK))
		return

	var/hair_hidden = 0

	if(head)
		var/obj/item/I = head
		if(I.flags_inv & HIDEHAIR)
			hair_hidden = 1
	if(wear_mask)
		var/obj/item/clothing/mask/M = wear_mask
		if(M.flags_inv & HIDEHAIR)
			hair_hidden = 1
	if(!hair_hidden)
		if(!getorgan(/obj/item/organ/brain)) //Applies the debrained overlay if there is no brain
			overlays_standing[HAIR_LAYER] = mutable_appearance('icons/mob/human_face.dmi', "debrained", -HAIR_LAYER)
			apply_overlay(HAIR_LAYER)


/mob/living/carbon/monkey/update_fire()
	..("Monkey_burning")

/mob/living/carbon/monkey/update_inv_legcuffed()
	remove_overlay(LEGCUFF_LAYER)
	clear_alert("legcuffed")
	if(legcuffed)
		var/mutable_appearance/legcuffs = mutable_appearance('icons/mob/restraints.dmi', legcuffed.item_state, -LEGCUFF_LAYER)
		legcuffs.color = handcuffed.color
		legcuffs.pixel_y = 8

		overlays_standing[HANDCUFF_LAYER] = legcuffs
		apply_overlay(LEGCUFF_LAYER)
		throw_alert("legcuffed", /obj/screen/alert/restrained/legcuffed, new_master = legcuffed)
	apply_overlay(LEGCUFF_LAYER)


//monkey HUD updates for items in our inventory

//update whether our head item appears on our hud.
/mob/living/carbon/monkey/update_hud_head(obj/item/I)
	if(client && hud_used && hud_used.hud_shown)
		I.screen_loc = ui_monkey_head
		client.screen += I

//update whether our mask item appears on our hud.
/mob/living/carbon/monkey/update_hud_wear_mask(obj/item/I)
	if(client && hud_used && hud_used.hud_shown)
		I.screen_loc = ui_monkey_mask
		client.screen += I

//update whether our neck item appears on our hud.
/mob/living/carbon/monkey/update_hud_neck(obj/item/I)
	if(client && hud_used && hud_used.hud_shown)
		I.screen_loc = ui_monkey_neck
		client.screen += I

//update whether our back item appears on our hud.
/mob/living/carbon/monkey/update_hud_back(obj/item/I)
	if(client && hud_used && hud_used.hud_shown)
		I.screen_loc = ui_monkey_back
		client.screen += I
