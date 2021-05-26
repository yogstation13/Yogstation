/mob/living/simple_animal/cheese
	name = "sentient cheese"
	icon = 'icons/obj/food/cheese.dmi'
	icon_state = "parmesan_wheel"
	ventcrawler = VENTCRAWLER_ALWAYS
	pass_flags = PASSTABLE
	mob_size = MOB_SIZE_SMALL
	mob_biotypes = list(MOB_ORGANIC)
	butcher_results = list(/obj/item/reagent_containers/food/snacks/cheesewedge/parmesan = 2)
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	health = 50
	maxHealth = 50
	response_harm = "takes a bite out of"
	attacked_sound = 'sound/items/eatfood.ogg'
	deathmessage = "dies from the pain of existence!"
	deathsound = "bodyfall"

/mob/living/simple_animal/cheese/Life()
	..()
	if(stat)
		return
	if(health < maxHealth)
		adjustBruteLoss(-1)

/mob/living/simple_animal/cheese/attack_hand(mob/living/L)
	..()
	if(L.a_intent == INTENT_HARM && L.reagents && !stat)
		L.reagents.add_reagent(/datum/reagent/consumable/nutriment, 0.4)
		L.reagents.add_reagent(/datum/reagent/consumable/nutriment/vitamin, 0.4)
		L.adjustBruteLoss(-0.1, 0)
		L.adjustFireLoss(-0.1, 0)
		L.adjustToxLoss(-0.1, 0)
		L.adjustOxyLoss(-0.1, 0)
