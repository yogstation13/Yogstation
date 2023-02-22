//Foxxy
/mob/living/simple_animal/pet/fox
	name = "fox"
	desc = "It's a fox."
	icon = 'icons/mob/pets.dmi'
	icon_state = "fox"
	icon_living = "fox"
	icon_dead = "fox_dead"
	speak = list("AAAAAAAAAAAAAAAAAAAA","Hehehehehe")
	speak_emote = list("screams","screeches")
	emote_hear = list("yips.","screeches.")
	emote_see = list("shakes its head.", "shivers.")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab = 1) //3 -> 1, foxes aren't Big
	response_help = "pets"
	response_disarm = "gently pushes aside"
	response_harm = "kicks"
	attack_vis_effect = ATTACK_EFFECT_BITE
	gold_core_spawnable = FRIENDLY_SPAWN
	can_be_held = TRUE
	do_footstep = TRUE
	wuv_happy = "screams happily!"
	wuv_angy = "screams angrily!"

//Captain fox
/mob/living/simple_animal/pet/fox/Renault
	name = "Renault"
	desc = "Renault, the Captain's trustworthy fox."
	gender = FEMALE
	gold_core_spawnable = NO_SPAWN
	unique_pet = TRUE
