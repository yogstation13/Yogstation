/obj/item/toy/heartballoon
	name = "heart balloon"
	desc = "A balloon for that special someone in your life."
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	force = 0
	icon = 'yogstation/icons/obj/toy.dmi'
	icon_state = "heartballoon"
	item_state = "heartballoon"
	lefthand_file = 'yogstation/icons/mob/inhands/antag/balloons_lefthand.dmi'
	righthand_file = 'yogstation/icons/mob/inhands/antag/balloons_righthand.dmi'


/obj/item/toy/toyballoon
	name = "toy balloon"
	desc = "A very colorful balloon, fun for all ages."
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	force = 0
	icon = 'yogstation/icons/obj/toy.dmi'
	icon_state = "toyballoon"
	item_state = "toyballoon"
	lefthand_file = 'yogstation/icons/mob/inhands/antag/balloons_lefthand.dmi'
	righthand_file = 'yogstation/icons/mob/inhands/antag/balloons_righthand.dmi'

/obj/item/toy/toygrenade
	name = "toy grenade"
	desc = "Booooom!"
	icon = 'yogstation/icons/obj/toy.dmi'
	icon_state = "toygrenade"
	w_class = 1

	throw_impact(atom/hit_atom)
		..()
		var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
		s.set_up(3, 1, src)
		s.start()
		new /obj/effect/decal/cleanable/ash(src.loc)
		src.visible_message("\red The [src.name] explodes!","\red You hear a snap!")
		playsound(src, 'sound/effects/snap.ogg', 50, 1)
		qdel(src)

/obj/item/toy/boomerang
	name = "boomerang"
	desc = "Actually comes back."
	icon_state = "boomerang"
	icon = 'yogstation/icons/obj/toy.dmi'
	force = 0
	throw_speed = 0.5
	throw_range = 10
	var/mob/living/carbon/man_down_under
	var/returning = FALSE

/obj/item/toy/boomerang/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(iscarbon(src.loc)) //Did someone catch it?
		return ..()
	if(man_down_under && hit_atom == man_down_under)
		if(man_down_under.put_in_hands(src))
			return
		else
			return ..()
	. = ..()
	if(man_down_under && returning)
		returning = FALSE //only try to return once
		if(get_turf(src) == get_turf(man_down_under))//don't try to return if the tile it hit is literally under the thrower
			return
		addtimer(CALLBACK(src, PROC_REF(comeback)), 1, TIMER_UNIQUE)//delay the return by such a small amount

/obj/item/toy/boomerang/proc/comeback()
	throw_at(man_down_under, throw_range+3, throw_speed)

/obj/item/toy/boomerang/throw_at(atom/target, range, speed, mob/thrower, spin=1, diagonals_first = 0, datum/callback/callback, force, quickstart = TRUE)
	if(thrower && iscarbon(thrower))
		man_down_under = thrower
		returning = TRUE
	. = ..()

/obj/item/toy/boomerang/violent
	throwforce = 10

/obj/item/toy/frisbee
	name = "frisbee"
	desc = "Comes further in life than you."
	icon_state = "frisbee"
	icon = 'yogstation/icons/obj/toy.dmi'
	force = 0
	throw_speed = 0.5
	throw_range = 14

/obj/item/toy/talking/figure/jexp
	name = "JEXP action figure"
	icon_state = "jexp"
	icon = 'yogstation/icons/obj/toy.dmi'
	messages = list(
			"150 rounds as Captain sounds PERFECT!",
			"Brig Officers! Perfect for newbies, but they'll get better costumes than regular officers!",
			"S H I T C O D E",
			"C O P Y P A S T A",
			"Whitelisting is the best listing!",
			"Incompetence can no longer exist! The heads must be PERFECT!")

/obj/item/toy/gun/toyglock
	name = "toy glock"
	desc = "Oh, looks just like the real thing, but it's only a toy."
	icon = 'yogstation/icons/obj/toy.dmi'
	icon_state = "toyglock"
	item_state = "toyglock"
	slot_flags = ITEM_SLOT_BELT
	materials = list(/datum/material/iron=10, /datum/material/glass=10)
	attack_verb = list("struck", "pistol whipped", "hit", "bashed")

/obj/item/toy/gun/toyflaregun
	name = "toy flare gun"
	desc = "For use in make believe emergencies."
	icon = 'yogstation/icons/obj/toy.dmi'
	icon_state = "toyflaregun"
	item_state = "toyflaregun"
	slot_flags = ITEM_SLOT_BELT
	materials = list(/datum/material/iron=10, /datum/material/glass=10)
	attack_verb = list("struck", "pistol whipped", "hit", "bashed")
