/mob/living/simple_animal/pet/axolotl
	name = "axolotl"
	desc = "Quite the colorful amphibian!"
	icon_state = "axolotl"
	icon_living = "axolotl"
	icon_dead = "axolotl_dead"
	held_state = "axolotl"
	maxHealth = 10
	health = 10
	attacktext = "nibbles" //their teeth are just for gripping food, not used for self defense nor even chewing
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/raw_cutlet/axolotl = 1)
	response_help = "pets"
	response_disarm = "gently pushes aside"
	response_harm = "splats"
	density = FALSE
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	ventcrawler = VENTCRAWLER_ALWAYS
	gold_core_spawnable = FRIENDLY_SPAWN
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	mob_size = MOB_SIZE_TINY
	can_be_held = TRUE
	worn_slot_flags = ITEM_SLOT_HEAD
	wuv_happy = "looks happy"
	wuv_angy = "makes a noise"

/mob/living/simple_animal/pet/axolotl/Life()
	. = ..()
	if(!stat && !buckled && !client)
		if(prob(1))
			emote("me", 1, pick("stretches out.", "lies down."), TRUE)
			set_resting(TRUE)
		else if (prob(1))
			if (resting)
				emote("me", 1, pick("gets up.", "walks around.", "stops resting."), TRUE)
				set_resting(FALSE)
		else if (prob(1))
			emote("me", 1, pick("rests for a bit."), TRUE)
			set_resting(TRUE)
