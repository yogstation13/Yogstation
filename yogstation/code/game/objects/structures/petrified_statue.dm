/obj/structure/statue/petrified/New(loc, mob/living/L, statue_timer, pan)
	if(statue_timer)
		timer = statue_timer
	if(L)
		petrified_mob = L
		if(L.buckled)
			L.buckled.unbuckle_mob(L,force=1)
		if(pan == TRUE)
			L.visible_message("<span class='warning'>[L]'s skin rapidly turns to bananium!</span>", "<span_class='ratvar'>BONK!</span>")
		else
			L.visible_message("<span class='warning'>[L]'s skin rapidly turns to marble!</span>", "<span class='userdanger'>Your body freezes up! Can't... move... can't...  think...</span>")
		L.forceMove(src)
		L.add_trait(TRAIT_MUTE, STATUE_MUTE)
		L.faction += "mimic" //Stops mimics from instaqdeling people in statues
		L.status_flags |= GODMODE
		obj_integrity = L.health + 100 //stoning damaged mobs will result in easier to shatter statues
		max_integrity = obj_integrity
		START_PROCESSING(SSobj, src)
	..()

yogstation/mob/proc/petrify(statue_timer, pan = FALSE)

/mob/living/carbon/human/petrify(statue_timer, pan)
	if(!isturf(loc))
		return 0
	var/obj/structure/statue/petrified/S = new(loc, src, statue_timer, pan)
	S.name = "statue of [name]"
	bleedsuppress = 1
	S.copy_overlays(src)
	var/newcolor = list(rgb(77,77,77), rgb(150,150,150), rgb(28,28,28), rgb(0,0,0))
	if(pan == TRUE)
		S.name = "bananium plated statue of [name]"
		S.desc = "an incredibly lifelike bananium carving."
		S.add_atom_colour("#ffd700", FIXED_COLOUR_PRIORITY)
		S.max_integrity = 9999
		S.obj_integrity = 9999
	else
		S.add_atom_colour(newcolor, FIXED_COLOUR_PRIORITY)
	return 1

/mob/living/carbon/monkey/petrify(statue_timer, pan)
	if(!isturf(loc))
		return 0
	var/obj/structure/statue/petrified/S = new(loc, src, statue_timer, pan)
	S.name = "statue of a monkey"
	S.icon_state = "monkey"
	if(pan == TRUE)
		S.name = "bananium plated statue of a monkey"
		S.desc = "an incredibly lifelike bananium carving."
		S.add_atom_colour("#ffd700", FIXED_COLOUR_PRIORITY)
		S.max_integrity = 9999
		S.obj_integrity = 9999
	return 1

/mob/living/simple_animal/pet/dog/corgi/petrify(statue_timer, pan)
	if(!isturf(loc))
		return 0
	var/obj/structure/statue/petrified/S = new (loc, src, statue_timer, pan)
	S.name = "statue of a corgi"
	S.icon_state = "corgi"
	S.desc = "If it takes forever, I will wait for you..."
	if(pan == TRUE)
		S.name = "bananium plated statue of a corgi"
		S.add_atom_colour("#ffd700", FIXED_COLOUR_PRIORITY)
		S.max_integrity = 9999
		S.obj_integrity = 9999
	return 1