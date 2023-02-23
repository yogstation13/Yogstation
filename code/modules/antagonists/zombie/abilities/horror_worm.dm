/mob/living/simple_animal/hostile/headcrab/horrorworm
	name = "eldritch worm"
	desc = "A severed purple tentacle, it seems to wiggle..?"
	icon_state = "horrorworm"
	icon_living = "horrorworm"
	icon_dead = "horrorworm_dead"
	health = 100
	maxHealth = 100
	obj_damage = 30
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	egg = /obj/item/organ/body_egg/antag_egg/zombie_egg

/mob/living/simple_animal/hostile/headcrab/horrorworm/AltClickOn(atom/A) //aditional way to infect people
	. = ..()
	if(!iscarbon(A))
		return
	var/mob/living/carbon/victim = A
	if(loc == victim)
		to_chat(src, span_notice("You move out of [victim]."))
		forceMove(get_turf(victim))
		return
	visible_message(span_italics("[src] starts crawling into [victim]."), span_italics("You start wiggling inside [victim]...")) //is this weird?
	if(!do_after(src, 3 SECONDS, victim))
		to_chat(src, span_warning("You were interrupted and lost the entryway!"))
		return
	if(!egg_lain && !ismonkey(victim))
		forceMove(victim)
		victim.stomach_contents += src //making space
		egg = new(victim)
		egg.Insert(victim)
		to_chat(src, span_notice("You sucessfully infect [victim] with an egg!")) //infection through outside means kills you, meanwhile this gives the player more agency for being risky
		egg_lain = TRUE

/obj/item/organ/body_egg/antag_egg/zombie_egg
	name = "pulsating ooze"
	desc = "It beats like a heart, spraying black goo when it does."
	incubation_time = 30 //we need this to be faster

/obj/item/organ/body_egg/antag_egg/zombie_egg/Pop()
	owner.adjustBruteLoss(200) //destroyed
	try_to_zombie_infect(owner, /obj/item/organ/zombie_infection/gamemode)
	owner.spawn_gibs()
	var/mob/living/carbon/human/new_human = new(get_turf(owner))
	new_human.set_species(/datum/species/zombie/infectious/gamemode)
	if(fetus_mind && (fetus_mind.current ? (fetus_mind.current.stat == DEAD) : fetus_mind.get_ghost()))
		fetus_mind.transfer_to(new_human)
		new_human.key = fetus_mind.key
