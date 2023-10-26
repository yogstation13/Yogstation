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

/obj/structure/mopbucket/update_overlays()
	. = ..()
	if(reagents.total_volume > 0)
		. += "mopbucket_water"
	if(ourmop)
		. += "mopbucket_mop"
