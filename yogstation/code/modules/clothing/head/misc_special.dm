/obj/item/clothing/head/hardhat/pumpkinhead/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/card/emag))
		new /obj/item/card/emag/halloween(get_turf(src.loc))
		qdel(W)
		qdel(src)
		to_chat(user, "<span class='notice'>You shove the [W.name] into the [src.name], creating something beautiful.")
	else
		return
