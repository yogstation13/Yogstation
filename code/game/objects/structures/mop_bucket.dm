/obj/structure/mopbucket
	name = "mop bucket"
	desc = "Fill it with water, but don't forget a mop!"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "mopbucket"
	density = TRUE
	var/amount_per_transfer_from_this = 5	//shit I dunno, adding this so syringes stop runtime erroring. --NeoFite
	var/obj/item/mop/ourmop //if there's a mop in the bucket


/obj/structure/mopbucket/Initialize()
	. = ..()
	create_reagents(100, OPENCONTAINER)

/obj/structure/mopbucket/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/mop))
		var/obj/item/mop/m=I
		if(reagents.total_volume < 1 || (m.reagents.total_volume >= m.reagents.maximum_volume && !ourmop))
			if(!user.transferItemToLoc(m, src)
				return
			icon_state = "mopbucket_and_mop"
			ourmop = m
			to_chat(user, "<span class='notice'>You put [m] into [src].</span>")
		else
			reagents.trans_to(M, 5, transfered_by = user)
			to_chat(user, "<span class='notice'>You wet [M] in [src].</span>")
			playsound(loc, 'sound/effects/slosh.ogg', 25, 1)
			update_icon()
	else
		. = ..()
		update_icon()

/obj/structure/mopbucket/attack_hand(mob/user)
	if(mymop)
		user.put_in_hands(ourmop)
		to_chat(user, "<span class='notice'>You take [ourmop] from [src].</span>")
		ourmop = null
		icon_state = "mopbucket"
		return
	return ..()

/obj/structure/mopbucket/update_icon()
	cut_overlays()
	if(reagents.total_volume > 0)
		add_overlay("mopbucket_water")
