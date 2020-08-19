/obj/item/melee/fryingpan
	name = "frying pan"
	desc = "A cast-iron frying pan designed for cooking food."
	lefthand_file = 'yogstation/icons/mob/inhands/weapons/pan_lefthand.dmi'
	righthand_file = 'yogstation/icons/mob/inhands/weapons/pan_righthand.dmi'
	icon = 'yogstation/icons/obj/pan.dmi'
	icon_state = "frying_pan"
	w_class = 3
	force = 12
	throwforce = 10
	throw_range = 5
	var/bonkpower = 15
	var/pantrify = FALSE
	block_chance = 10
	materials = list(MAT_METAL=75)
	attack_verb = list("BONKED", "panned")
	hitsound = 'yogstation/sound/weapons/pan.ogg'

/obj/item/melee/fryingpan/get_clamped_volume()
	return 100 // BONK!

/obj/item/melee/fryingpan/bananium
	name = "bananium frying pan"
	desc = "A cast-bananium frying pan imbued with an ancient power."
	color = "#ffd700"
	force = 25
	throwforce = 15
	bonkpower = 50
	pantrify = TRUE
	block_chance = 25
	materials = list(MAT_BANANIUM=75)
	attack_verb = list("BONKED", "panned", "flexes on")
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 100, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 100) //honkzo bananium frying pan folded over 1000 times, your mime explosives are no match.

/obj/item/melee/fryingpan/bananium/Initialize()
	. = ..()
	AddComponent(/datum/component/randomcrits, force)

/obj/item/melee/fryingpan/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(!proximity || !isliving(target) || !iscarbon(user))
		return
	var/mob/living/M = target
	if(ishuman(M))
		M.adjustEarDamage(bonkpower)
	if(pantrify == TRUE && M.stat == DEAD)
		playsound(M, 'sound/effects/supermatter.ogg', 100)
		var/S = M.petrify(600, TRUE)
		if(S)
			var/obj/structure/statue/petrified/statue = S
			statue.name = "bananium plated [statue.name]"
			statue.desc = "An incredibly lifelike bananium carving."
			statue.add_atom_colour("#ffd700", FIXED_COLOUR_PRIORITY)
			statue.max_integrity = 9999
			statue.obj_integrity = 9999
	return ..()
