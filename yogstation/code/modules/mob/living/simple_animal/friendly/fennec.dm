/mob/living/simple_animal/pet/fox/fennec
	name = "Fennec Fox"
	desc = "It's a fennec fox, fluffy little begger."
	icon = 'yogstation/icons/mob/pets.dmi'
	icon_state = "fennec"
	icon_living = "fennec"
	icon_dead = "fennec_dead"
	speak = list("squeek","Squeee!")
	speak_emote = list("squeeks", "screams")
	emote_hear = list("squeeks.","screams.")
	emote_see = list("dances on all fours.", "shivers.")
	speak_chance = 1
	turns_per_move = 7
	see_in_dark = 6
	gold_core_spawnable = FRIENDLY_SPAWN

/mob/living/simple_animal/pet/fox/fennec/Autumn
	name = "Autumn"
	gender = FEMALE
	gold_core_spawnable = NO_SPAWN
	unique_pet = TRUE
