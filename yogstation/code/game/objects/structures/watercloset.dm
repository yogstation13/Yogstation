/obj/structure/toilet/attackby(obj/item/I, mob/living/user, params)
	if (istype(I, /obj/item/flamethrower))
		if (!user.is_holding_item_of_type(/obj/item/crowbar))
			to_chat(user, span_warning("You need a crowbar to retrofit this toilet into a bong!"))
			return
		playsound(loc, 'sound/effects/stonedoor_openclose.ogg', 50, 1)
		user.visible_message(span_notice("[user] begins to attach [I] to [src]..."), span_notice("You begin attaching [I] to [src]..."))
		if (!do_after(user, 5 SECONDS, src))
			return
		for (var/obj/item/cistern_item in contents)
			cistern_item.forceMove(loc)
			visible_message(span_warning("[cistern_item] falls out of [src]!"))
		var/obj/structure/toilet_bong/bong = new(loc)
		bong.dir = dir
		qdel(I)
		qdel(src)
	else
		return ..()
