//No relation to slugcat

/mob/living/simple_animal/pet/catslug
	name = "catslug"
	desc = "It seems to be both a cat and a slug!"
	icon = 'icons/mob/pets.dmi'
	icon_state = "catslug"
	icon_living = "catslug"
	icon_dead = "catslug_dead"
	gender = MALE
	emote_see = list("stares at the ceiling.", "shivers.")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	response_help  = "hugs"
	response_disarm = "rudely paps"
	response_harm   = "kicks"
	gold_core_spawnable = FRIENDLY_SPAWN
