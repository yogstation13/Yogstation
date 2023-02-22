/mob/living/simple_animal/pet/snail
	name = "snail"
	desc = "Snails are mollusks, putting them in the same category as oysters, clams, and mussels."
	icon = 'icons/mob/pets.dmi'
	icon_state = "snail"
	icon_living = "snail"
	icon_dead = "snail_dead"
	speak_emote = list("gurgles")
	emote_hear = list("gurgles.")
	emote_see = list("gurgles.")
	speak_chance = 1
	turns_per_move = 7
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab = 1)
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "stomps"
	friendly = "bops"
	melee_damage_lower = 2
	melee_damage_upper = 2
	health = 50
	maxHealth = 50
	gold_core_spawnable = FRIENDLY_SPAWN

/mob/living/simple_animal/pet/snail/gary
	name = "Gary the snail"
	desc = "Gary come home"
