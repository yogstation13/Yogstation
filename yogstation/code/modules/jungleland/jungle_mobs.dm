/mob/living/simple_animal/hostile/jungle
	icon = 'yogstation/icons/mobs/jungle.dmi'

/mob/living/simple_animal/hostile/jungle/dryad
	name = "Jungle spirit"
	desc = "A spirit of the jungle, protector of the forest, heals the ones in need, and butchers the ones that plauge the forest."
	icon_state = "dryad"
	icon_living = "dryad"
	icon_dead = "dryad_dead"
	mob_biotypes = list(MOB_BEAST,MOB_ORGANIC)
	speak = list("eak!","sheik!","ahik!","keish!")
	speak_emote = list("shimmers", "vibrates")
	emote_hear = list("vibes.","sings.","shimmers.")
	emote_taunt = list("tremors", "shakes")
	speak_chance = 1
	taunt_chance = 1
	turns_per_move = 1
	see_in_dark = 3
	butcher_results = list()
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "hits"
	maxHealth = 60
	health = 60
	spacewalk = TRUE
	ranged = TRUE

/mob/living/simple_animal/hostile/jungle/dryad
