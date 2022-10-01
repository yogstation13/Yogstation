GLOBAL_LIST_INIT(mouse_comestible, typecacheof(list(
		/obj/effect/decal/cleanable/food,
		/obj/effect/decal/cleanable/greenglow,
		/obj/effect/decal/cleanable/insectguts,
		/obj/effect/decal/cleanable/vomit,
		/obj/item/trash,
		/obj/item/grown/bananapeel,
		/obj/item/grown/corncob,
		/obj/item/grown/sunflower,
		/obj/item/cigbutt
	)))
GLOBAL_VAR_INIT(food_for_next_mouse, 0)

GLOBAL_VAR_INIT(mouse_food_eaten, 0)
GLOBAL_VAR_INIT(mouse_spawned, 0)
GLOBAL_VAR_INIT(mouse_killed, 0)

#define FOODPERMOUSE 35

/mob/living/simple_animal/mouse
	name = "mouse"
	desc = "This cute little guy just loves the taste of uninsulated electrical cables. Isn't he adorable?"
	icon_state = "mouse_gray"
	icon_living = "mouse_gray"
	icon_dead = "mouse_gray_dead"
	speak = list("Squeak!","SQUEAK!","Squeak?")
	speak_emote = list("squeaks")
	emote_hear = list("squeaks.")
	emote_see = list("runs in a circle.", "shakes.")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 8
	maxHealth = 5
	health = 5
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab/mouse = 1)
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "splats"
	density = FALSE
	ventcrawler = VENTCRAWLER_ALWAYS
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	mob_size = MOB_SIZE_TINY
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	can_be_held = TRUE //mouse gaming
	worn_slot_flags = ITEM_SLOT_HEAD
	var/body_color //brown, gray and white, leave blank for random
	gold_core_spawnable = FRIENDLY_SPAWN
	move_force = MOVE_FORCE_EXTREMELY_WEAK
	var/chew_probability = 1
	var/full = FALSE
	var/eating = FALSE
	var/cheesed = FALSE
	var/cheese_time = 0

/mob/living/simple_animal/mouse/Initialize()
	. = ..()
	AddComponent(/datum/component/squeak, list('sound/effects/mousesqueek.ogg'=1), 100)
	if(!body_color)
		body_color = pick( list("brown","gray","white") )
	icon_state = "mouse_[body_color]"
	icon_living = "mouse_[body_color]"
	icon_dead = "mouse_[body_color]_dead"

/mob/living/simple_animal/mouse/handle_stomach()
	if(cheesed && cheese_time < world.time)
		cheese_down()

/mob/living/simple_animal/mouse/proc/splat()
	if(key)
		adjustHealth(rand(7,12))
		if(health <= 0)
			src.icon_dead = "mouse_[body_color]_splat"
	else
		src.health = 0
		src.icon_dead = "mouse_[body_color]_splat"
		death()

/mob/living/simple_animal/mouse/death(gibbed, toast)
	GLOB.mouse_killed++
	if(!ckey)
		..(1)
		if(!gibbed)
			var/obj/item/reagent_containers/food/snacks/deadmouse/M = new(loc)
			M.icon_state = icon_dead
			M.name = name
			if(toast)
				M.add_atom_colour("#3A3A3A", FIXED_COLOUR_PRIORITY)
				M.desc = "It's toast."
		qdel(src)
	else
		SSmobs.cheeserats -= src
		..(gibbed)

/mob/living/simple_animal/mouse/Crossed(AM as mob|obj)
	if( ishuman(AM) )
		if(!stat)
			var/mob/M = AM
			to_chat(M, span_notice("[icon2html(src, M)] Squeak!"))
	if(istype(AM, /obj/item/reagent_containers/food/snacks/royalcheese))
		evolve()
		qdel(AM)
	..()

/mob/living/simple_animal/mouse/handle_automated_action()
	if(prob(chew_probability))
		var/turf/open/floor/F = get_turf(src)
		if(istype(F) && !F.intact)
			var/obj/structure/cable/C = locate() in F
			if(C && prob(15))
				if(C.avail())
					visible_message(span_warning("[src] chews through the [C]. It's toast!"))
					playsound(src, 'sound/effects/sparks2.ogg', 100, TRUE)
					C.deconstruct()
					death(toast=1)
				else
					C.deconstruct()
					visible_message(span_warning("[src] chews through the [C]."))
	for(var/obj/item/reagent_containers/food/snacks/cheesewedge/cheese in range(1, src))
		if(prob(10))
			be_fruitful()
			qdel(cheese)
			return
	for(var/obj/item/reagent_containers/food/snacks/royalcheese/bigcheese in range(1, src))
		qdel(bigcheese)
		evolve()
		return


/**
  *Checks the mouse cap, if it's above the cap, doesn't spawn a mouse. If below, spawns a mouse and adds it to cheeserats.
  */
/mob/living/simple_animal/mouse/proc/be_fruitful()
	var/cap = CONFIG_GET(number/ratcap)
	if(LAZYLEN(SSmobs.cheeserats) >= cap)
		visible_message(span_warning("[src] carefully eats the cheese, hiding it from the [cap] mice on the station!"))
		return
	var/mob/living/newmouse = new /mob/living/simple_animal/mouse(loc)
	SSmobs.cheeserats += newmouse
	visible_message(span_notice("[src] nibbles through the cheese, attracting another mouse!"))

/**
  *Spawns a new regal rat, says some good jazz, and if sentient, transfers the relivant mind.
  */
/mob/living/simple_animal/mouse/proc/evolve()
	var/mob/living/simple_animal/hostile/regalrat = new /mob/living/simple_animal/hostile/regalrat(loc)
	visible_message(span_warning("[src] devours the cheese! He morphs into something... greater!"))
	regalrat.say("RISE, MY SUBJECTS! SCREEEEEEE!")
	if(mind)
		mind.transfer_to(regalrat)
	qdel(src)

/mob/living/simple_animal/mouse/Move()
	. = ..()
	if(stat != CONSCIOUS)
		return .

	if(!key)
		eat_cheese()
	else
		if(!(locate(/obj/structure/table) in get_turf(src)))
			for(var/obj/item/reagent_containers/glass/G in get_turf(src))
				G.throw_at(get_turf(G), 0, 1, src)
			for(var/obj/item/reagent_containers/food/drinks/D in get_turf(src))
				D.throw_at(get_turf(D), 0, 1, src)


/mob/living/simple_animal/mouse/proc/eat_cheese()
	var/obj/item/reagent_containers/food/snacks/cheesewedge/CW = locate(/obj/item/reagent_containers/food/snacks/cheesewedge) in loc
	if(!QDELETED(CW) && full == FALSE)
		say("Burp!")
		visible_message(span_warning("[src] gobbles up the [CW]."))
		qdel(CW)
		full = TRUE
		addtimer(VARSET_CALLBACK(src, full, FALSE), 3 MINUTES)

/mob/living/simple_animal/mouse/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/reagent_containers/food/snacks/cheesewedge))
		to_chat(user, span_notice("You feed [O] to [src]."))
		visible_message("[src] squeaks happily!")
		qdel(O)
	else
		return ..()

/mob/living/simple_animal/mouse/attack_ghost(mob/dead/observer/user)
	if(client)
		return ..()
	if(stat == DEAD)
		return ..()
	user.possess_mouse(src)

/mob/living/simple_animal/mouse/start_pulling(atom/movable/AM, state, force, supress_message)
	return FALSE

/mob/living/simple_animal/mouse/CtrlClickOn(atom/A)
	face_atom(A)
	if(!isturf(loc))
		return
	if(next_move > world.time)
		return
	if(!A.Adjacent(src))
		return

	if(!can_eat(A))
		return FALSE

	eating = TRUE
	layer = MOB_LAYER
	visible_message(span_danger("[src] starts eating away [A]..."),span_notice("You start eating the [A]..."))
	if(do_after(src, 3 SECONDS, A, FALSE))
		if(QDELETED(A))
			return
		visible_message(span_danger("[src] finishes eating up [A]!"),span_notice("You finish up eating [A]."))
		mouse_eat(A)
		playsound(A.loc,'sound/effects/mousesqueek.ogg', 100) // i have no idea how loud this is, 100 seems to be used for the squeak component
		GLOB.mouse_food_eaten++

	eating = FALSE
	layer = BELOW_OPEN_DOOR_LAYER

/mob/living/simple_animal/mouse/proc/can_eat(atom/A)
	. = FALSE

	if(eating)
		return FALSE
	if(is_type_in_list(A, GLOB.mouse_comestible))
		return TRUE
	if(istype(A, /obj/item/reagent_containers/food) && !(locate(/obj/structure/table) in get_turf(A)))
		return TRUE

/mob/living/simple_animal/mouse/proc/regen_health(amt = 5)
	var/overheal = max(health + amt - maxHealth, 0)
	adjustHealth(-amt)
	GLOB.food_for_next_mouse += overheal
	var/mice = FLOOR(GLOB.food_for_next_mouse / FOODPERMOUSE, 1)
	if(!mice)
		return

	GLOB.mouse_spawned += mice
	GLOB.food_for_next_mouse = max(GLOB.food_for_next_mouse - FOODPERMOUSE * mice, 0)
	SSminor_mapping.trigger_migration(mice, TRUE)

/mob/living/simple_animal/mouse/proc/cheese_up()
	regen_health(15)
	if(cheesed)
		cheese_time = cheese_time + 3 MINUTES
		return
	cheesed = TRUE
	resize = 2
	update_transform()
	add_movespeed_modifier(MOVESPEED_ID_MOUSE_CHEESE, TRUE, 100, multiplicative_slowdown = -1)
	maxHealth = 30
	health = maxHealth
	to_chat(src, span_userdanger("You ate cheese! You are now stronger, bigger and faster!"))
	cheese_time = cheese_time + 3 MINUTES

/mob/living/simple_animal/mouse/proc/cheese_down()
	cheesed = FALSE
	maxHealth = 15
	health = maxHealth
	resize = 0.5
	update_transform()
	remove_movespeed_modifier(MOVESPEED_ID_MOUSE_CHEESE, TRUE)
	to_chat(src, span_userdanger("A feeling of sadness comes over you as the effects of the cheese wears off. You. Must. Get. More."))

/mob/living/simple_animal/mouse/proc/mouse_eat(obj/item/reagent_containers/food/snacks/F)
	var/list/cheeses = list(/obj/item/reagent_containers/food/snacks/cheesewedge, /obj/item/reagent_containers/food/snacks/cheesewheel,
							/obj/item/reagent_containers/food/snacks/store/cheesewheel, /obj/item/reagent_containers/food/snacks/customizable/cheesewheel,
							/obj/item/reagent_containers/food/snacks/cheesiehonkers) //all cheeses - royal
	if(istype(F, /obj/item/reagent_containers/food/snacks/royalcheese))
		evolve()
		return
	if(istype(F, /obj/item/grown/bananapeel/bluespace))
		var/obj/item/grown/bananapeel/bluespace/B
		var/teleport_radius = max(round(B.seed.potency / 10), 1)
		var/turf/T = get_turf(src)
		do_teleport(src, T, teleport_radius, channel = TELEPORT_CHANNEL_BLUESPACE)
	if(is_type_in_list(F, cheeses))
		cheese_up()
	regen_health()
	qdel(F)

/*
 * Mouse types
 */

/mob/living/simple_animal/mouse/white
	body_color = "white"
	icon_state = "mouse_white"

/mob/living/simple_animal/mouse/gray
	body_color = "gray"
	icon_state = "mouse_gray"

/mob/living/simple_animal/mouse/brown
	body_color = "brown"
	icon_state = "mouse_brown"

//TOM IS ALIVE! SQUEEEEEEEE~K :)
/mob/living/simple_animal/mouse/brown/Tom
	name = "Tom"
	desc = "Jerry the cat is not amused."
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "splats"
	gold_core_spawnable = NO_SPAWN

/obj/item/reagent_containers/food/snacks/deadmouse
	name = "dead mouse"
	desc = "It looks like somebody dropped the bass on it. A Lizard's favorite meal."
	icon = 'icons/mob/animal.dmi'
	icon_state = "mouse_gray_dead"
	bitesize = 3
	eatverb = "devour"
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/nutriment/vitamin = 2)
	foodtype = MICE
	grind_results = list(/datum/reagent/blood = 20, /datum/reagent/liquidgibs = 5)

/obj/item/reagent_containers/food/snacks/deadmouse/attackby(obj/item/I, mob/user, params)
	if(I.is_sharp() && user.a_intent == INTENT_HARM)
		if(isturf(loc))
			new /obj/item/reagent_containers/food/snacks/meat/slab/mouse(loc)
			to_chat(user, span_notice("You butcher [src]."))
			qdel(src)
		else
			to_chat(user, span_warning("You need to put [src] on a surface to butcher it!"))
	else
		return ..()

/obj/item/reagent_containers/food/snacks/deadmouse/on_grind()
	reagents.clear_reagents()


/mob/living/simple_animal/mouse/Destroy()
	SSmobs.cheeserats -= src
	return ..()

/mob/living/simple_animal/mouse/revive(full_heal = FALSE, admin_revive = FALSE)
	var/cap = CONFIG_GET(number/ratcap)
	if(!admin_revive && !ckey && LAZYLEN(SSmobs.cheeserats) >= cap)
		visible_message(span_warning("[src] twitched but does not continue moving due to the overwhelming rodent population on the station!"))
		return FALSE
	. = ..()
	if(.)
		SSmobs.cheeserats += src
