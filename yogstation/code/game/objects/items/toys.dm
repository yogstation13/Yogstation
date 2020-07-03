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

/obj/item/toy/boomerang/throw_impact(atom/hit_atom,)
	if(iscarbon(src.loc)) //Did someone catch it?
		return ..()
	throw_at(thrownby, throw_range+3, throw_speed, null)
	..()

/obj/item/toy/boomerang/throw_at(atom/target, range, speed, mob/thrower, spin=1, diagonals_first = 0, datum/callback/callback, force)
	if(iscarbon(thrower))
		var/mob/living/carbon/C = thrower
		C.throw_mode_on()
	..()

/obj/item/toy/frisbee
	name = "frisbee"
	desc = "Comes further in life then you."
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
	materials = list(MAT_METAL=10, MAT_GLASS=10)
	attack_verb = list("struck", "pistol whipped", "hit", "bashed")

/obj/item/toy/gun/toyflaregun
	name = "toy flare gun"
	desc = "For use in make believe emergencies."
	icon = 'yogstation/icons/obj/toy.dmi'
	icon_state = "toyflaregun"
	item_state = "toyflaregun"
	slot_flags = ITEM_SLOT_BELT
	materials = list(MAT_METAL=10, MAT_GLASS=10)
	attack_verb = list("struck", "pistol whipped", "hit", "bashed")
