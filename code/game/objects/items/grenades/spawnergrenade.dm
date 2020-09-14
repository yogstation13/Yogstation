/obj/item/grenade/spawnergrenade
	desc = "It will unleash an unspecified anomaly into the vicinity."
	name = "delivery grenade"
	icon = 'icons/obj/grenade.dmi'
	icon_state = "delivery"
	item_state = "flashbang"
	var/spawner_type = null // must be an object path
	var/deliveryamt = 1 // amount of type to deliver

/obj/item/grenade/spawnergrenade/prime()			// Prime now just handles the two loops that query for people in lockers and people who can see it.
	update_mob()
	if(spawner_type && deliveryamt)
		// Make a quick flash
		var/turf/T = get_turf(src)
		playsound(T, 'sound/effects/phasein.ogg', 100, 1)
		for(var/mob/living/carbon/C in viewers(T, null))
			C.flash_act()

		// Spawn some hostile syndicate critters and spread them out
		var/list/spawned = spawn_and_random_walk(spawner_type, T, deliveryamt, walk_chance=50, admin_spawn=((flags_1 & ADMIN_SPAWNED_1) ? TRUE : FALSE))
		afterspawn(spawned)

	qdel(src)

/obj/item/grenade/spawnergrenade/proc/afterspawn(list/mob/spawned)
	return

/obj/item/grenade/spawnergrenade/manhacks
	name = "viscerator delivery grenade"
	spawner_type = /mob/living/simple_animal/hostile/viscerator
	deliveryamt = 10

/obj/item/grenade/spawnergrenade/spesscarp
	name = "carp delivery grenade"
	spawner_type = /mob/living/simple_animal/hostile/carp
	deliveryamt = 5

/obj/item/grenade/spawnergrenade/syndiesoap
	name = "Mister Scrubby"
	spawner_type = /obj/item/soap/syndie

/obj/item/grenade/spawnergrenade/buzzkill
	name = "Buzzkill grenade"
	desc = "The label reads: \"WARNING: DEVICE WILL RELEASE LIVE SPECIMENS UPON ACTIVATION. SEAL SUIT BEFORE USE.\" It is warm to the touch and vibrates faintly."
	icon_state = "holy_grenade"
	spawner_type = /mob/living/simple_animal/hostile/poison/bees/toxin
	deliveryamt = 10

/obj/item/grenade/spawnergrenade/clown
	name = "C.L.U.W.N.E."
	desc = "A sleek device often given to clowns on their 10th birthdays for protection. You can hear faint scratching coming from within."
	icon_state = "clown_ball"
	item_state = "clown_ball"
	spawner_type = list(/mob/living/simple_animal/hostile/retaliate/clown/fleshclown, /mob/living/simple_animal/hostile/retaliate/clown/clownhulk, /mob/living/simple_animal/hostile/retaliate/clown/longface, /mob/living/simple_animal/hostile/retaliate/clown/clownhulk/chlown, /mob/living/simple_animal/hostile/retaliate/clown/clownhulk/honcmunculus, /mob/living/simple_animal/hostile/retaliate/clown/mutant/blob, /mob/living/simple_animal/hostile/retaliate/clown/banana, /mob/living/simple_animal/hostile/retaliate/clown/honkling, /mob/living/simple_animal/hostile/retaliate/clown/lube, /mob/living/simple_animal/hostile/retaliate/clown/afro, /mob/living/simple_animal/hostile/retaliate/clown/thin, /mob/living/simple_animal/hostile/retaliate/clown/clownhulk/punisher, /mob/living/simple_animal/hostile/retaliate/clown/mutant/thicc)
	deliveryamt = 1

/obj/item/grenade/spawnergrenade/clown_broken
	name = "stuffed C.L.U.W.N.E."
	desc = "A sleek device often given to clowns on their 10th birthdays for protection. While a typical C.L.U.W.N.E only holds one creature, sometimes foolish young clowns try to cram more in, often to disasterous effect."
	icon_state = "clown_broken"
	item_state = "clown_broken"
	spawner_type = /mob/living/simple_animal/hostile/retaliate/clown/mutant
	deliveryamt = 5
	
/obj/item/grenade/spawnergrenade/clownbugs
	name = "clown bug special"
	spawner_type = /mob/living/simple_animal/cockroach/clownbug
	deliveryamt = 6

/obj/item/grenade/spawnergrenade/feral_cats
	name = "feral cat delivery grenade"
	desc = "This grenade contains 5 dehydrated feral cats in a similar manner to dehydrated monkeys, which, upon detonation, will be rehydrated by a small reservoir of water contained within the grenade. These cats will then attack anything in sight."
	spawner_type = /mob/living/simple_animal/hostile/feral_cat
	deliveryamt = 5

/obj/item/grenade/spawnergrenade/feral_cats/prime()			///Own proc for this because the regular one would flash people which was dumb.
	update_mob()
	if(spawner_type && deliveryamt)
		var/turf/T = get_turf(src)
		playsound(T, 'sound/effects/phasein.ogg', 100, 1)
		for(var/i=1, i<=deliveryamt, i++)
			var/atom/movable/x = new spawner_type
			x.loc = T
			if(prob(50))
				for(var/j = 1, j <= rand(1, 3), j++)
					step(x, pick(NORTH,SOUTH,EAST,WEST))
	qdel(src)
	return
