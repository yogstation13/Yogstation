/obj/item/clothing/suit
	name = "suit"
	icon = 'icons/obj/clothing/suits/suits.dmi'
	lefthand_file = 'icons/mob/inhands/clothing/suits_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing/suits_righthand.dmi'
	var/fire_resist = T0C+100
	allowed = list(/obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman, /obj/item/tank/internals/ipc_coolant)
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 0, ACID = 0)
	drop_sound = 'sound/items/handling/cloth_drop.ogg'
	pickup_sound =  'sound/items/handling/cloth_pickup.ogg'
	slot_flags = ITEM_SLOT_OCLOTHING
	var/blood_overlay_type = "suit"
	var/togglename = null
	var/suittoggled = FALSE
	var/mutantrace_variation = NO_MUTANTRACE_VARIATION
	var/adjusted = NORMAL_STYLE
	limb_integrity = 0 // disabled for most exo-suits
	var/obj/item/badge/attached_badge
	var/mutable_appearance/badge_overlay

/obj/item/clothing/suit/Destroy()
	if(attached_badge)
		QDEL_NULL(attached_badge)
	return ..()

/obj/item/clothing/suit/worn_overlays(mutable_appearance/standing, isinhands = FALSE, icon_file)
	. = ..()
	if(!isinhands)
		if(damaged_clothes)
			. += mutable_appearance('icons/effects/item_damage.dmi', "damageduniform")
		if(HAS_BLOOD_DNA(src))
			var/mutable_appearance/bloody_armor = mutable_appearance('icons/effects/blood.dmi', "[blood_overlay_type]blood")
			bloody_armor.color = get_blood_dna_color(return_blood_DNA())
			. += bloody_armor
		var/mob/living/carbon/human/M = loc
		if(ishuman(M) && M.w_uniform)
			var/obj/item/clothing/under/U = M.w_uniform
			if(istype(U) && U.attached_accessory)
				var/obj/item/clothing/accessory/A = U.attached_accessory
				if(A.above_suit)
					. += U.accessory_overlay
		if(badge_overlay)
			. += badge_overlay

/obj/item/clothing/suit/update_clothes_damaged_state()
	..()
	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_wear_suit()

/obj/item/clothing/suit/equipped(mob/user, slot)
	..()
	if(adjusted)
		adjusted = NORMAL_STYLE

	if(mutantrace_variation && ishuman(user))
		var/mob/living/carbon/human/H = user
		if(DIGITIGRADE in H.dna.species.species_traits)
			adjusted = DIGITIGRADE_STYLE
		H.update_inv_w_uniform()

/obj/item/clothing/suit/attackby(obj/item/I, mob/user, params)
	if(!attach_badge(I, user))
		return ..()

/obj/item/clothing/suit/proc/attach_badge(obj/item/I, mob/user)
	. = FALSE
	if(!istype(I, /obj/item/badge))
		return
	if(user && !user.temporarilyRemoveItemFromInventory(I))
		return
	var/obj/item/badge/B = I
	if(!B.try_attach(src, user))
		return
	if(user)
		to_chat(user, span_notice("You attach [I] to [src]."))
	badge_overlay = mutable_appearance(attached_badge.mob_overlay_icon, "[attached_badge.accessory_state]")
	badge_overlay.alpha = attached_badge.alpha
	badge_overlay.color = attached_badge.color
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		H.update_inv_w_uniform()
		H.update_inv_wear_suit()
	return TRUE

/obj/item/clothing/suit/AltClick(mob/user)
	. = ..()
	if(.)
		return TRUE

	if(!istype(user) || !user.canUseTopic(src, BE_CLOSE, ismonkey(user)))
		return

	if(attached_badge)
		var/obj/item/badge/B = attached_badge
		attached_badge.detach(src, user)
		if(user.put_in_hands(B))
			to_chat(user, span_notice("You detach [B] from [src]."))
		else
			to_chat(user, span_notice("You detach [B] from [src] and it falls on the floor."))
			var/turf/T = get_turf(src)
			if(!T)
				T = get_turf(user)
			if(T)
				B.forceMove(T)

		if(ishuman(loc))
			var/mob/living/carbon/human/H = loc
			H.update_inv_w_uniform()
			H.update_inv_wear_suit()
