//This is for the mini-game golf.
/obj/machinery/golfhole
	desc = "A hole for the game of golf. Try to score a hole in one."
	name = "golf hole"
	icon = 'yogstation/icons/code/game/golf/golfstuff.dmi'
	icon_state = "redgolfhole"
	anchored = 0


/obj/machinery/golfhole/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/wrench))
		switch(anchored)
			if(0)
				anchored = 1
				icon_state = icon_state + "_w"
				playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)
				user.visible_message("[user.name] secures [src] to the floor.", \
				"<span class='notice'>You secure [src] to the floor.</span>", \
			"	<span class='italics'>You hear a ratchet</span>")
				src.anchored = 1
			if(1)
				anchored = 0
				icon_state = initial(icon_state)
				playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)
				user.visible_message("[user.name] unsecures [src]  from the floor.", \
				"<span class='notice'>You unwrench [src] from the floor.</span>", \
				"<span class='italics'>You hear a ratchet.</span>")
				src.anchored = 0

/obj/machinery/golfhole/Cross(atom/movable/mover, turf/target)
	. = ..()
	if (istype(mover,/obj/item/golfball) && mover.throwing  && anchored)
		if (contents.len >= 3)
			visible_message("<span class='notice'>The golf hole is full! Try removing golfballs from the hole.</span>")
			return FALSE

		var/obj/item/golfball = mover
		if(prob(75))
			golfball.loc = src
			visible_message("<span class='notice'>The golfball lands in [src].</span>")

			update_icon()
		else
			visible_message("<span class='notice'>The golfball bounces out of [src]!</span>")
		return FALSE
	else
		return ..()


/obj/machinery/golfhole/attack_hand(atom, mob/user)
	var/obj/item/golfball/ball = locate(/obj/item/golfball) in contents
	if (ball)
		visible_message("<span class='notice'>The golfball is removed from the hole.</span>")
		ball.loc = get_turf(src.loc)


/obj/machinery/golfhole/proc/hole_place_item_in(obj/item/golfball, mob/user)
	golfball.loc = src
	user.visible_message("[user.name] knocks the golfball into [src].", \
						"<span class='notice'>You knock the golfball into [src].</span>")

/obj/machinery/golfhole/blue
	icon = 'yogstation/icons/code/game/golf/golfstuff.dmi'
	icon_state = "bluegolfhole"


/obj/machinery/golfhole/puttinggreen
	desc = "The captain's putting green for the game of golf. Try to score a hole in one."
	icon = 'yogstation/icons/code/game/golf/golfstuff.dmi'
	icon_state = "puttinggreen"
	anchored = 1


/obj/item/golfball
	desc = "A ball for the game of golf."
	name = "golfball"
	icon = 'yogstation/icons/code/game/golf/golfstuff.dmi'
	icon_state ="golfball"
	throwforce = 12
	attack_verb = list("hit")

/obj/item/golfball/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/golfclub))
		var/turf/throw_at = get_ranged_target_turf(src, get_dir(user, src), 3 )
		throw_at(throw_at, 3 , 2)
		user.changeNext_move(CLICK_CD_RANGE)

/obj/item/golfclub
	desc = "A club for the game of golf."
	name = "golfclub"
	lefthand_file = 'yogstation/icons/mob/inhands/weapons/golfclub_lefthand.dmi'
	righthand_file = 'yogstation/icons/mob/inhands/weapons/golfclub_righthand.dmi'
	icon = 'yogstation/icons/code/game/golf/golfstuff.dmi'
	icon_state ="golfclub"
	force = 8
	damtype = BRUTE
	attack_verb = list("smacked", "struck")

/obj/structure/closet/golf
	name = "golf supplies closet"
	desc = "This unit contains all the supplies for golf."
	icon = 'yogstation/icons/obj/closet.dmi'
	icon_state = "golf"

/obj/structure/closet/golf/New()
	..()
	new /obj/item/golfball(src)
	new /obj/item/golfball(src)
	new /obj/item/golfball(src)
	new /obj/item/golfball(src)
	new /obj/item/golfball(src)
	new /obj/item/golfball(src)
	new /obj/item/golfball(src)
	new /obj/item/golfball(src)
	new /obj/item/golfball(src)
	new /obj/item/golfball(src)
	new /obj/item/golfball(src)
	new /obj/item/golfclub(src)
	new /obj/item/golfclub(src)
	new /obj/item/golfclub(src)
	new /obj/item/golfclub(src)
	new /obj/machinery/golfhole(src)
	new /obj/machinery/golfhole(src)
	new /obj/machinery/golfhole/blue(src)
	new /obj/machinery/golfhole/blue(src)
