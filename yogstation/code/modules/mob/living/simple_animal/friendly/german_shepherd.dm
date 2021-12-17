/mob/living/simple_animal/pet/dog/gshepherd
	name = "german shepherd"
	real_name = "german shepherd"
	icon = 'yogstation/icons/mob/pets.dmi'
	icon_state = "g_shepherd"
	icon_living = "g_shepherd"
	icon_dead = "g_shepherd_dead"
	gender = FEMALE
	speak = list("YAP", "Woof!", "Bark!", "AUUUUUU")
	speak_emote = list("barks", "woofs")
	emote_hear = list("barks", "woofs", "yaps","pants")
	emote_see = list("shakes its head", "shivers")
	speak_chance = 1
	turns_per_move = 8
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab = 4)
	response_help  = "pets"
	response_disarm = "bops"
	response_harm   = "kicks"

/mob/living/simple_animal/pet/dog/gshepherd/roxie
	name = "Roxie"
	real_name = "Roxie"
	desc = "How old is this dog?"