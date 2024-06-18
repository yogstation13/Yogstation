/obj/item/clothing/shoes/magboots/vox
	name = "vox magclaws"
	desc = "A pair of heavy, jagged armoured foot pieces, seemingly suitable for a velociraptor."
	item_state = "boots-vox"
	icon_state = "boots-vox"
	icon = 'icons/obj/clothing/species/vox/shoes.dmi'
	species_restricted = list(SPECIES_VOX)

/obj/item/clothing/shoes/magboots/vox/attack_self(mob/user)
	if(magpulse)
		clothing_flags &= ~NOSLIP
		REMOVE_TRAIT(src, TRAIT_NODROP, "vox_magclaws")
		to_chat(user, "You relax your deathgrip on the flooring.")
	else
		//make sure these can only be used when equipped.
		if(!ishuman(user))
			return
		var/mob/living/carbon/human/H = user
		if(H.shoes != src)
			to_chat(user, span_warning("You will have to put on [src] before you can do that."))
			return
		clothing_flags |= NOSLIP	//kinda hard to take off magclaws when you are gripping them tightly.
		ADD_TRAIT(src, TRAIT_NODROP, "vox_magclaws")
		to_chat(user, "You dig your claws deeply into the flooring, bracing yourself.")
		to_chat(user, "It would be hard to take off [src] without relaxing your grip first.")
	magpulse = !magpulse
	user.update_inv_shoes()	//so our mob-overlays update
	user.update_gravity(user.has_gravity())
	for(var/X in actions)
		var/datum/action/A = X
		A.build_all_button_icons()

//In case they somehow come off while enabled.
/obj/item/clothing/shoes/magboots/vox/dropped(mob/user)
	..()
	if(magpulse)
		user.visible_message("[src] go limp as they are removed from [usr]'s feet.", "[src] go limp as they are removed from your feet.")
		magpulse = FALSE
		clothing_flags &= ~NOSLIP
		REMOVE_TRAIT(src, TRAIT_NODROP, "vox_magclaws")

/obj/item/clothing/shoes/magboots/vox/examine(mob/user)
	. = ..()
	if(magpulse)
		. += "It would be hard to take these off without relaxing your grip first."//theoretically this message should only be seen by the wearer when the claws are equipped.
