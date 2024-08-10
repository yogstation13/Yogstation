/obj/structure/mopbucket
	name = "mop bucket"
	desc = "Fill it with water, but don't forget a mop!"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "mopbucket"
	density = TRUE
	var/amount_per_transfer_from_this = 5	//shit I dunno, adding this so syringes stop runtime erroring. --NeoFite
	var/obj/item/mop/ourmop //if there's a mop in the bucket


/obj/structure/mopbucket/Initialize(mapload)
	. = ..()
	create_reagents(100, OPENCONTAINER)

/obj/structure/mopbucket/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/mop))
		var/obj/item/mop/M=I
		if((reagents.total_volume < 1) || (M.reagents.total_volume >= M.reagents.maximum_volume && !ourmop))
			if(!user.transferItemToLoc(M, src))
				return
			ourmop = M
			update_appearance(UPDATE_ICON)
			to_chat(user, span_notice("You put [M] into [src]."))
		else
			reagents.trans_to(M, 5, transfered_by = user)
			to_chat(user, span_notice("You wet [M] in [src]."))
			playsound(loc, 'sound/effects/slosh.ogg', 25, 1)
			update_appearance(UPDATE_ICON)
	else
		. = ..()
		update_appearance(UPDATE_ICON)

/obj/structure/mopbucket/attack_hand(mob/user)
	if(ourmop)
		user.put_in_hands(ourmop)
		to_chat(user, span_notice("You take [ourmop] from [src]."))
		ourmop = null
		update_appearance(UPDATE_ICON)
		return
	return ..()

/obj/structure/mop_bucket/attackby_secondary(obj/item/weapon, mob/user, params)
	if(istype(weapon, /obj/item/mop))
		if(!weapon.reagents.total_volume)
			if(weapon.reagents.total_volume >= weapon.reagents.maximum_volume)
				balloon_alert(user, "mop is already soaked!")
				return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
			if(!reagents.total_volume < 1)
				balloon_alert(user, "mop bucket is empty!")
				return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
			reagents.trans_to(weapon, weapon.reagents.maximum_volume, transfered_by = user)
			balloon_alert(user, "wet mop")
			playsound(src, 'sound/effects/slosh.ogg', 25, vary = TRUE)
		else
			var/obj/item/mop/attacked_mop = weapon
			to_chat(user, "You completly wring out the [attacked_mop.name] into the waste bucket of the cart.")
			attacked_mop.reagents.remove_all(attacked_mop.mopcap)

	if(istype(weapon, /obj/item/reagent_containers) || istype(weapon, /obj/item/mop))
		update_appearance(UPDATE_OVERLAYS)
		return SECONDARY_ATTACK_CONTINUE_CHAIN // skip attack animations when refilling cart

	return SECONDARY_ATTACK_CONTINUE_CHAIN


/obj/structure/mopbucket/update_overlays()
	. = ..()
	if(reagents.total_volume > 0)
		. += "mopbucket_water"
	if(ourmop)
		. += "mopbucket_mop"
