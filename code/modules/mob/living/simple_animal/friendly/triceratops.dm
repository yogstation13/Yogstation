/mob/living/simple_animal/triceratops
	name = "Bismuth"
	desc = "Ancient, Reliable, Good at Pathfinding."
	icon = 'icons/mob/pets.dmi'
	icon_state = "bismuth"
	icon_living = "bismuth"
	icon_dead = "bis_dead"
	speak_emote = list("grumbles")
	emote_hear = list("grunts.","grumbles.")
	emote_see = list("wags their tail.", "sniffs at the ground.")
	speak_chance = 1
	turns_per_move = 5
	butcher_results = list(/obj/item/dice/d20 = 1)
	response_help = "pets"
	response_disarm = "gently pushes aside"
	response_harm = "rams"
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	gold_core_spawnable = FRIENDLY_SPAWN
	melee_damage_lower = 18
	melee_damage_upper = 18
	health = 350
	maxHealth = 350
	speed = 5
	glide_size = 2
	can_be_held = FALSE
	footstep_type = FOOTSTEP_MOB_SHOE

/mob/living/simple_animal/triceratops/Initialize(mapload)
	var/cap = CONFIG_GET(number/bismuthcap)
	if (LAZYLEN(SSmobs.bismuth) > cap)
		if(prob(30))
			new /mob/living/simple_animal/triceratops(loc)
			SSmobs.bismuth += src
	. = ..()

/mob/living/simple_animal/triceratops/handle_automated_movement()
	if(!isturf(src.loc) || !(mobility_flags & MOBILITY_MOVE) || buckled)
		return //If it can't move, dont let it move.

//-----WANDERING - Time to mosey around
	else
		walk(src, 0)

		if(prob(10))
			step(src, pick(GLOB.cardinals))
			return

