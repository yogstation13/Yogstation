/obj/machinery/papershredder
	name = "Paper Shredder"
	desc = "Disposes of papers you don't want seen, as well as IDs that are no longer needed."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "papershredder0"
	density = 1
	anchored = 1
	var/max_paper = 10
	var/paperamount = 0

/obj/machinery/papershredder/proc/try_insert(mob/user, insert_size = 0)
	if(paperamount <= max_paper - insert_size)
		paperamount += insert_size
		update_icon()
		playsound(src.loc, 'sound/items/pshred.ogg', 75, 1)
		return TRUE
	else
		if(prob(5))
			var/i
			var/curpaper = paperamount
			for(i=1; i<=curpaper; i++)
				var/obj/item/shreddedpaper/SP = new /obj/item/shreddedpaper(usr.loc)
				SP.pixel_x = rand(-5,5)
				SP.pixel_y = rand(-5,5)
				var/ran = rand(1,3)
				if(ran == 1)
					SP.color = "#BABABA"
				if(ran == 2)
					SP.color = "#7F7F7F"
				if(ran == 3)
					SP.color = null
				paperamount -=1
			update_icon()
			to_chat(user, span_warning("The [src] was too full and shredded paper goes everywhere!"))
		else
			to_chat(user, span_warning("The [src] is full please empty it before you continue."))
		return FALSE

/obj/machinery/papershredder/attackby(obj/item/W, mob/user)
	if(default_unfasten_wrench(user, W))
		return
	var/shred_amount = 0
	if (istype(W, /obj/item/paper))
		shred_amount = 1
	else if(istype(W, /obj/item/photo))
		shred_amount = 1
	else if(istype(W, /obj/item/newspaper))
		shred_amount = 3
	else if(istype(W, /obj/item/card/id))
		shred_amount = 3
	else if(istype(W, /obj/item/station_charter))
		shred_amount = 3
	else if(istype(W, /obj/item/card/emag))
		qdel(W)
		explosion(src, -1, 0, 1,)
		visible_message(("<span class='danger'>The [src] short-circuits and explodes! </span>"))
	else if(istype(W, /obj/item/paper_bundle))
		shred_amount = 3
	else if(istype(W, /obj/item/book))
		shred_amount = 5
	else if(istype(W, /obj/item/storage/bag/trash))
		var/datum/component/storage/STR = W.GetComponent(/datum/component/storage)
		var/curpaper = paperamount
		var/i
		for(i=1; i<=curpaper; i++)
			if(W.contents.len < 21)
				var/obj/item/shreddedpaper/SP = new /obj/item/shreddedpaper
				var/ran = rand(1,3)
				if(ran == 1)
					SP.color = "#BABABA"
				if(ran == 2)
					SP.color = "#7F7F7F"
				if(ran == 3)
					SP.color = null
				STR.handle_item_insertion(SP)
				paperamount -=1
				update_icon()
			else
				to_chat(user, span_warning("The [W] is full."))
				return
	else if(istype(W, /obj/item/shreddedpaper))
		if(paperamount == max_paper)
			to_chat(user, span_warning("The [src] is full please empty it before you continue."))
			return
		if(paperamount < max_paper)
			qdel(W)
			paperamount += 1
			update_icon()
			return
	
	if(shred_amount && try_insert(user, shred_amount))
		qdel(W)

/obj/machinery/papershredder/verb/empty()
	set name = "Empty bin"
	set category = "Object"
	emptypaper()

/obj/machinery/papershredder/proc/emptypaper()
	set src in oview(1)
	if(paperamount != 0)
		var/i
		var/curpaper = paperamount
		for(i=1; i<=curpaper; i++)
			var/obj/item/shreddedpaper/SP = new /obj/item/shreddedpaper(usr.loc)
			SP.pixel_x = rand(-5,5)
			SP.pixel_y = rand(-5,5)
			var/ran = rand(1,3)
			if(ran == 1)
				SP.color = "#BABABA"
			if(ran == 2)
				SP.color = "#7F7F7F"
			if(ran == 3)
				SP.color = null
			paperamount -=1
		update_icon()

/obj/machinery/papershredder/AltClick(mob/living/user)
	emptypaper()

/obj/machinery/papershredder/update_icon()
	if(paperamount == 0)
		icon_state = "papershredder0"
	if(paperamount == 1||paperamount == 2)
		icon_state = "papershredder1"
	if(paperamount == 3||paperamount == 4)
		icon_state = "papershredder2"
	if(paperamount == 5||paperamount == 6)
		icon_state = "papershredder3"
	if(paperamount == 7||paperamount == 8)
		icon_state = "papershredder4"
	if(paperamount == 9||paperamount == 10)
		icon_state = "papershredder5"
	return

/obj/item/shreddedpaper
	name = "shredded paper"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "shredp"
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_range = 3
	throw_speed = 1
	layer = 4
	pressure_resistance = 1

/obj/item/shreddedpaper/attackby(obj/item/W as obj, mob/user as mob)
	if(W.is_hot())
		burnpaper(W, user)
	else
		..()

/obj/item/shreddedpaper/proc/burnpaper(obj/item/P, mob/user)
	var/class = "<span class='warning'>"

	if(P.is_hot() && !user.restrained())
		if(istype(P, /obj/item/lighter))
			class = "<span class='rose'>"

		user.visible_message("[class][user] holds \the [P] up to \the [src], it looks like \he's trying to burn it!</span>", \
		"[class]You hold \the [P] up to \the [src], burning it slowly.</span>")

		if(do_after(user, 2 SECONDS, src))
			user.visible_message("[class][user] burns right through \the [src], turning it to ash. It flutters through the air before settling on the floor in a heap.</span>", \
			"[class]You burn right through \the [src], turning it to ash. It flutters through the air before settling on the floor in a heap.</span>")

			if(user.get_inactive_hand_index() == src)
				user.dropItemToGround(src)

			new /obj/effect/decal/cleanable/ash(src.loc)
			qdel(src)

		else
			to_chat(user, span_warning("You must hold \the [P] steady to burn \the [src]."))
