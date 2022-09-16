//murder fish reptile
/mob/living/simple_animal/hostile/retaliate/gator
	name = "alligator"
	desc = "Sharp teeth, stronger bite force."
	icon = 'icons/mob/pets.dmi'
	icon_state = "gator"
	icon_living = "gator"
	icon_dead ="gator_dead"
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	environment_smash = ENVIRONMENT_SMASH_NONE
	speak_emote = list("snaps")
	emote_hear = list("snaps.","hisses.")
	emote_see = list("waits apprehensively.", "shuffles.")
	speak_chance = 1
	turns_per_move = 5
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/lizard = 4, /obj/item/organ/tail/lizard = 1)
	response_help = "pets"
	response_disarm = "rolls over"
	response_harm = "kicks"
	gold_core_spawnable = HOSTILE_SPAWN
	faction = list("hostile")
	melee_damage_lower = 20
	melee_damage_upper = 24
	attacktext = "bites"
	attack_sound = 'sound/weapons/bite.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE
	health = 125
	maxHealth = 125
	speed = 8

/mob/living/simple_animal/hostile/retaliate/gator/Life()
	. = ..()
	if(. && sentience_type != SENTIENCE_BOSS)
		//stolen from goats so alligators can eat you without intervention
		if(!enemies.len && prob(1))
			Retaliate()

		if(enemies.len && prob(10))
			enemies = list()
			LoseTarget()
			src.visible_message(span_notice("[src] calms down."))

/mob/living/simple_animal/hostile/retaliate/gator/Retaliate()
	. = ..()
	src.visible_message(span_danger("[src] starts snapping [p_their()] jaws."))

/mob/living/simple_animal/hostile/retaliate/gator/steppy
	name = "Steppy"
	desc = "Cargo's pet gator. Is he being detained!?"
	icon_state = "steppy"
	icon_living = "steppy"
	icon_dead ="steppy_dead"
	speak_emote = list("snaps")
	emote_hear = list("snaps.","hisses.")
	emote_see = list("waits apprehensively.", "shuffles.")
	speak_chance = 1
	turns_per_move = 5
	response_help = "pets"
	response_disarm = "rolls over"
	response_harm = "kicks"
	gold_core_spawnable = NO_SPAWN
	faction = list("neutral")
	melee_damage_lower = 20
	melee_damage_upper = 24
	health = 125
	maxHealth = 125
	speed = 8

/mob/living/simple_animal/hostile/retaliate/gator/steppy/iguana
	name = "Izzy"
	desc = "A master of looking at pipes, she's a favorite among the GEC for her GECK-like nature."
	gender = FEMALE
	icon_state = "iguana"
	icon_living = "iguana"
	icon_dead ="iguana_dead"
	speak_chance = 1
	turns_per_move = 5
	response_help = "pets"
	response_disarm = "rolls over"
	response_harm = "kicks"
	gold_core_spawnable = NO_SPAWN
	speak_emote = list("sneezes")
	emote_hear = list("snaps.","hisses.", "sneezes.")
	emote_see = list("waits apprehensively.", "shuffles.")
	attacktext = "whipped"
	attack_sound = 'sound/weapons/slap.ogg'
	attack_vis_effect = ATTACK_EFFECT_KICK
