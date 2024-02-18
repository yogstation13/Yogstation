/mob/living/simple_animal/crab/clown
	name = "Bananium Kreb"
	desc = "Its shell seems to be made out of pure bananium. This kreb sure is living the high life!"
	real_name = "Fancy Kreb"
	icon = 'yogstation/icons/mob/clownpets.dmi'
	icon_state = "clown_kreb"
	icon_living = "clown_kreb"
	icon_dead = "clown_kreb_dead"
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "stomps"
	gold_core_spawnable = FRIENDLY_SPAWN
	butcher_results = list(/obj/item/stack/ore/bananium = 3, /obj/item/reagent_containers/food/snacks/meat/slab = 1)