/mob/living/simple_animal/pet/fox/fennec
	name = "Fennec Fox"
	desc = "It's a fennec fox, fluffy little begger."
	icon = 'yogstation/icons/mob/pets.dmi'
	icon_state = "fennec"
	icon_living = "fennec"
	icon_dead = "fennec_dead"
	speak = list("squeek","Bark!","Meep","Awoo","Squeee!")
	speak_emote = list("squeeks", "barks")
	emote_hear = list("howls.","barks.")
	emote_see = list("dances on all fours.", "shivers.")
	speak_chance = 1
	turns_per_move = 7
	see_in_dark = 6
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab = 3)
	gold_core_spawnable = FRIENDLY_SPAWN