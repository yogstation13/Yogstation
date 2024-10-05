/mob/living/simple_animal/pet/hamster
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	response_help_continuous  = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "bops"
	response_disarm_simple = "bop"
	response_harm_continuous = "bites"
	response_harm_simple = "bite"
	speak = list("Squeak", "SQUEAK!")
	speak_emote = list("squeak", "hisses", "squeals")
	emote_hear = list("squeaks.", "hisses.", "squeals.")
	emote_see = list("skitters", "examines it's claws", "rolls around")
	see_in_dark = 5
	speak_chance = 1
	turns_per_move = 3
	footstep_type = FOOTSTEP_MOB_CLAW
	density = FALSE
	pass_flags = PASSMOB
	mob_size = MOB_SIZE_SMALL
	name = "\improper hamster"
	real_name = "hamster"
	desc = "It's a hamster."
	icon = 'monkestation/icons/mob/pets.dmi'
	icon_state = "hamster"
	icon_living = "hamster"
	held_state = "hamster"
	icon_dead = "hamster_dead"
	butcher_results = list(/obj/item/food/meat/slab = 1)
	childtype = list(/mob/living/simple_animal/pet/hamster = 1)
	animal_species = /mob/living/simple_animal/pet/hamster
	gold_core_spawnable = FRIENDLY_SPAWN
	can_be_held = TRUE
	worn_slot_flags = ITEM_SLOT_HEAD
	head_icon = 'monkestation/icons/mob/pets_held.dmi'
	held_lh = 'monkestation/icons/mob/pets_held_lh.dmi'
	held_rh = 'monkestation/icons/mob/pets_held_rh.dmi'

/mob/living/simple_animal/pet/hamster/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)
