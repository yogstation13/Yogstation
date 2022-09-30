/mob/living/simple_animal/friendly/axolotl
	name = "axolotl"
	desc = "Quite the colorful amphibian!"
	icon_state = "axolotl"
	icon_living = "axolotl"
	icon_dead = "axolotl_dead"
	maxHealth = 10
	health = 10
	attacktext = "nibbles" //their teeth are just for gripping food, not used for self defense nor even chewing
	butcher_results = list(/obj/item/food/nugget = 1)
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
