/obj/structure/table_frame/bananium
	name = "bananium table frame"
	desc = "A table frame made out of bananium very squeaky. You could easily pass through this."
	icon_state = "bananium_frame"
	framestack = /obj/item/stack/sheet/mineral/bananium
	framestackamount = 2
	resistance_flags = FIRE_PROOF | ACID_PROOF

/obj/structure/table_frame/wood/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/stack/sheet/mineral/bananium))
		var/obj/item/stack/sheet/mineral/bananium/W = I
		if(W.get_amount() < 1)
			to_chat(user, "<span class='warning'>You need one bananium sheet to do this!</span>")
			return
		to_chat(user, "<span class='notice'>You start adding [W] to [src]...</span>")
		if(do_after(user, 20, target = src) && W.use(1))
			make_new_table(/obj/structure/table/bananium)
	else
		return ..()