/mob/living/simple_animal/hostile/rat
	name = "rat"
	desc = "It's a nasty, ugly, evil, disease-ridden rodent with anger issues."
	icon_state = "mouse_gray"
	icon_living = "mouse_gray"
	icon_dead = "mouse_gray_dead"
	speak = list("Skree!","SKREEE!","Squeak?")
	speak_emote = list("squeaks")
	emote_hear = list("Hisses.")
	emote_see = list("runs in a circle.", "stands on its hind legs.")
	melee_damage_lower = 3
	melee_damage_upper = 5
	obj_damage = 5
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	maxHealth = 15
	health = 15
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab/mouse = 1)
	density = FALSE
	ventcrawler = VENTCRAWLER_ALWAYS
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	mob_size = MOB_SIZE_TINY
	mob_biotypes = list(MOB_ORGANIC,MOB_BEAST)
	faction = list("rat")
	var/body_color

/mob/living/simple_animal/hostile/rat/loan
	faction = list("hostile")

/mob/living/simple_animal/hostile/rat/Initialize()
	. = ..()
	if(mind)
		language_holder += new /datum/language_holder/mouse(src)
	AddComponent(/datum/component/squeak, list('sound/effects/mousesqueek.ogg'=1), 100)
	if(!body_color)
		body_color = pick( list("brown","gray","white") )
	icon_state = "mouse_[body_color]"
	icon_living = "mouse_[body_color]"
	icon_dead = "mouse_[body_color]_dead"
	SSmobs.cheeserats += src

/mob/living/simple_animal/hostile/rat/Destroy()
	SSmobs.cheeserats -= src
	return ..()

/mob/living/simple_animal/hostile/rat/examine(mob/user)
	. = ..()
	if(istype(user,/mob/living/simple_animal/hostile/rat))
		var/mob/living/simple_animal/hostile/rat/ratself = user
		if(ratself.faction_check_mob(src, TRUE))
			. += span_notice("You both serve the same king.")
		else
			. += span_warning("This fool serves a different king!")
	else if(istype(user,/mob/living/simple_animal/hostile/regalrat))
		var/mob/living/simple_animal/hostile/regalrat/ratking = user
		if(ratking.faction_check_mob(src, TRUE))
			. += span_notice("This rat serves under you.")
		else
			. += span_warning("This peasant serves a different king! Strike him down!")

/mob/living/simple_animal/hostile/rat/CanAttack(atom/the_target)
	if(istype(the_target,/mob/living/simple_animal))
		var/mob/living/A = the_target
		if(istype(the_target, /mob/living/simple_animal/hostile/regalrat) && A.stat == CONSCIOUS)
			var/mob/living/simple_animal/hostile/regalrat/ratking = the_target
			if(ratking.faction_check_mob(src, TRUE))
				return FALSE
			else
				return TRUE
		if(istype(the_target, /mob/living/simple_animal/hostile/rat) && A.stat == CONSCIOUS)
			var/mob/living/simple_animal/hostile/rat/R = the_target
			if(R.faction_check_mob(src, TRUE))
				return FALSE
			else
				return TRUE
	return ..()

/mob/living/simple_animal/hostile/rat/handle_automated_action()
	. = ..()
	if (!mind)
		if(prob(40))
			var/turf/open/floor/F = get_turf(src)
			if(istype(F) && !F.intact)
				var/obj/structure/cable/C = locate() in F
				if(C && prob(15))
					if(C.avail())
						visible_message(span_warning("[src] chews through the [C]. It's toast!"))
						playsound(src, 'sound/effects/sparks2.ogg', 100, TRUE)
						C.deconstruct()
						death()
				else if(C && C.avail())
					visible_message(span_warning("[src] chews through the [C]. It looks unharmed!"))
					playsound(src, 'sound/effects/sparks2.ogg', 100, TRUE)
					C.deconstruct()

/mob/living/simple_animal/hostile/rat/attack_ghost(mob/dead/observer/user)
	if(key)
		return ..()

	if(is_banned_from(user.key, ROLE_MOUSE))
		to_chat(user, span_warning("You are banned from being a mouse!"))
		return FALSE

	if(alert("Are you sure you want to become a rat? (Warning, you can no longer be cloned!)",,"Yes","No") != "Yes")
		return FALSE

	src.key = user.key
	src.faction = list("rat")
	src.layer = BELOW_OPEN_DOOR_LAYER
	src.language_holder = new /datum/language_holder/mouse(src)
	src.pass_flags |= PASSDOOR
	src.sentience_act()
	src.health = src.maxHealth

/mob/living/simple_animal/hostile/rat/CtrlClickOn(atom/A)
	face_atom(A)
	if(!isturf(loc))
		return

	if(next_move > world.time)
		return

	if(!A.Adjacent(src))
		return

	if(!can_eat(A))
		return FALSE
	layer = MOB_LAYER
	visible_message(span_danger("[src] starts eating away [A]..."),span_notice("You start eating the [A]..."))
	if(do_after(src, 3 SECONDS, A, FALSE))
		if(QDELETED(A))
			return
		visible_message(span_danger("[src] finishes eating up [A]!"),span_notice("You finish up eating [A]."))
		heal_bodypart_damage(5)
		qdel(A)
	layer = BELOW_OPEN_DOOR_LAYER

/mob/living/simple_animal/hostile/rat/proc/can_eat(atom/A)
	. = FALSE
	if(is_type_in_list(A, GLOB.mouse_comestible))
		return TRUE
	if(istype(A, /obj/item/reagent_containers/food) && !(locate(/obj/structure/table) in get_turf(A)))
		return TRUE

/*
	Plague Rat
*/

/mob/living/simple_animal/hostile/rat/plaguerat
	desc = "It's a large rodent, afflicted with both anger issues and a terrible disease."
	icon_state = "mouse_black"
	icon_living = "mouse_black"
	icon_dead = "mouse_black_dead"
	melee_damage_lower = 5 //stronk
	melee_damage_upper = 7
	turns_per_move = 5
	see_in_dark = 8
	maxHealth = 40
	health = 40
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab/plagued = 1)
	body_color = "black"

/mob/living/simple_animal/hostile/rat/plaguerat/AttackingTarget()
	. = ..()
	if(iscarbon(target)) //It is for injecting plague reagent into people via biting them.
		var/mob/living/carbon/C = target
		if(C.stat != DEAD)
			if(C.reagents)
				var/obj/item/I = C.get_item_by_slot(ITEM_SLOT_OCLOTHING)
				if(!istype(I, /obj/item/clothing/suit/space/hardsuit) && !istype(I, /obj/item/clothing/suit/armor) && !istype(I, /obj/item/clothing/suit/bio_suit/plaguedoctorsuit))
					var/datum/reagent/plaguebacteria/plague = new /datum/reagent/plaguebacteria
					C.reagents.add_reagent(/datum/reagent/plaguebacteria, 3) //gets caught up in blood transfers
					plague.reaction_mob(C, INJECT) //making sure we stay winning

		else //It is for biting dead bodies to heal.
			if(C.getBruteLoss_nonProsthetic() >= 100)
				return
			src.visible_message(span_warning("[src] starts biting into [C]!"),span_notice("You start eating [C]..."))
			if(!do_after(src, 3 SECONDS, FALSE, target))
				return
			to_chat(src, span_notice ("You finish eating [C]."))
			heal_bodypart_damage(5)
			C.adjustBruteLoss(15)

	if(!isliving(target))
		if(!isitem(target))
			return
		if(target.reagents && target.is_injectable(src, allowmobs = TRUE)) //It is for injecting plague reagent into reagent containers by licking them. Not to be confused with biting people.
			if(target.reagents.has_reagent(/datum/reagent/plaguebacteria))
				to_chat(src, span_warning("[target] is already infected!"))
				return
			if(INTERACTING_WITH(src, target))
				return
			src.visible_message(span_warning("[src] starts licking [target]!"),span_notice("You start licking [target]..."))
			if(!do_after(src, 2 SECONDS, FALSE, target))
				to_chat(src, span_warning("You stop licking [target]."))
				return
			target.reagents.add_reagent(/datum/reagent/plaguebacteria, rand(1,2), no_react = TRUE)
			to_chat(src, span_notice("You finish licking [target]."))

