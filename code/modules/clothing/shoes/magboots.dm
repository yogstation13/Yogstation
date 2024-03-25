/obj/item/clothing/shoes/magboots
	desc = "Magnetic boots, often used during extravehicular activity to ensure the user remains safely attached to the vehicle."
	name = "magboots"
	icon_state = "magboots0"
	var/magboot_state = "magboots"
	var/magpulse = 0
	var/slowdown_active = 2
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 60, RAD = 0, FIRE = 0, ACID = 0, ELECTRIC = 100)
	actions_types = list(/datum/action/item_action/toggle)
	strip_delay = 70
	equip_delay_other = 70
	resistance_flags = FIRE_PROOF
	cryo_preserve = TRUE

/obj/item/clothing/shoes/magboots/verb/toggle()
	set name = "Toggle Magboots"
	set category = "Object"
	set src in usr
	if(!can_use(usr))
		return
	attack_self(usr)


/obj/item/clothing/shoes/magboots/attack_self(mob/user)
	if(magpulse)
		clothing_flags &= ~NOSLIP
		slowdown = SHOES_SLOWDOWN
	else
		clothing_flags |= NOSLIP
		slowdown = slowdown_active
	magpulse = !magpulse
	icon_state = "[magboot_state][magpulse]"
	to_chat(user, span_notice("You [magpulse ? "enable" : "disable"] the mag-pulse traction system."))
	user.update_inv_shoes()	//so our mob-overlays update
	user.update_gravity(user.has_gravity())
	for(var/X in actions)
		var/datum/action/A = X
		A.build_all_button_icons()

/obj/item/clothing/shoes/magboots/negates_gravity()
	return clothing_flags & NOSLIP

/obj/item/clothing/shoes/magboots/examine(mob/user)
	. = ..()
	. += "Its mag-pulse traction system appears to be [magpulse ? "enabled" : "disabled"]."


/obj/item/clothing/shoes/magboots/advance
	desc = "Advanced magnetic boots that have a lighter magnetic pull, placing less burden on the wearer."
	name = "advanced magboots"
	icon_state = "advmag0"
	magboot_state = "advmag"
	slowdown_active = SHOES_SLOWDOWN
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/item/clothing/shoes/magboots/advance/attack_self(mob/user)
	. = ..()
	if(magpulse)
		clothing_flags &= ~NOSLIP | ~NOSLIP_ICE

/obj/item/clothing/shoes/magboots/syndie
	desc = "Reverse-engineered magnetic boots that have a heavy magnetic pull. Property of Gorlex Marauders."
	name = "blood-red magboots"
	icon_state = "syndiemag0"
	magboot_state = "syndiemag"

/obj/item/clothing/shoes/magboots/syndie/attack_self(mob/user)
	. = ..()
	if(magpulse)
		clothing_flags &= ~NOSLIP | ~NOSLIP_ICE

/obj/item/clothing/shoes/magboots/security
	name = "combat magboots"
	desc = "Combat-edition magboots issued by Nanotrasen Security for extravehicular missions."
	icon_state = "cmagboots0"
	magboot_state = "cmagboots"
	slowdown_active = 1

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
