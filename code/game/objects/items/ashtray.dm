/obj/item/ashtray
	name = "ashtray"
	desc = "A thing to keep your butts in."
	icon = 'icons/obj/objects.dmi'
	icon_state = "ashtray"
	var/max_butts = 10

/obj/item/ashtray/update_icon()
	..()
	overlays.Cut()
	if(contents.len == max_butts)
		add_overlay(image('icons/obj/objects.dmi',"ashtray_full"))
	else if(contents.len >= max_butts * 0.5)
		add_overlay(image('icons/obj/objects.dmi',"ashtray_half"))

/obj/item/ashtray/attackby(obj/item/W, mob/user)
	if (user.a_intent == INTENT_HARM)
		..()
		return

	if(istype(W, /obj/item/cigbutt) || istype(W, /obj/item/clothing/mask/cigarette) || istype(W, /obj/item/match))
		if(contents.len >= max_butts)
			to_chat(user, span_notice("\The [src] is full."))
			return

		if(istype(W,/obj/item/clothing/mask/cigarette))
			var/obj/item/clothing/mask/cigarette/cig = W
			if (cig.lit == TRUE)
				visible_message(span_notice("[user] crushes [cig] in [src][cig.lit == TRUE ? ", putting it out" : ""]."))
				W = cig.extinguish()

		if(user.transferItemToLoc(W, src))
			visible_message(span_notice("[user] places [W] in [src]."))
			update_icon()
		return

	..()

/obj/item/ashtray/throw_impact(atom/hit_atom)
	if(contents.len)
		visible_message(span_danger("\The [src] slams into [hit_atom], spilling its contents!"))
		for(var/obj/O in contents)
			O.forceMove(drop_location())
	update_icon()
	return ..()
