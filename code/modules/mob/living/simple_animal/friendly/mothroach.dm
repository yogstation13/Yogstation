/mob/living/simple_animal/friendly/mothroach
	name = "mothroach"
	desc = "This is the adorable by-product of multiple attempts at genetically mixing mothpeople with cockroaches."
	icon_state = "mothroach"
	icon_living = "mothroach"
	icon_dead = "mothroach_dead"
	held_state = "mothroach"
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab/mothroach = 3, /obj/item/stack/sheet/animalhide/mothroach = 1)
	speak_emote = list("flutters.")
	mob_size = MOB_SIZE_SMALL
	health = 25
	maxHealth = 25
	speed = 1.25
	mob_biotypes = list(MOB_ORGANIC, MOB_BUG)
	gold_core_spawnable = FRIENDLY_SPAWN
	can_be_held = TRUE
	worn_slot_flags = ITEM_SLOT_HEAD
	ventcrawler = VENTCRAWLER_ALWAYS

	verb_say = "flutters"
	verb_ask = "flutters inquisitively"
	verb_exclaim = "flutters loudly"
	verb_yell = "flutters loudly"

	faction = list("neutral")

/mob/living/simple_animal/friendly/mothroach/attack_hand(mob/living/carbon/human/user, list/modifiers)
	. = ..()
	if(src.stat == DEAD)
		return
	else
		playsound(loc, 'sound/voice/moth/scream_moth.ogg', 50, TRUE)

/mob/living/simple_animal/friendly/mothroach/attackby(obj/item/attacking_item, mob/living/user, params)
	. = ..()
	if(src.stat == DEAD)
		return
	else
		playsound(loc, 'sound/voice/moth/scream_moth.ogg', 50, TRUE)

/mob/living/simple_animal/friendly/mothroach/Life()
	. = ..()
	if(!stat && !buckled && !client)
		if(prob(1))
			emote("me", 1, pick("stretches out.", "lies down."), TRUE)
			icon_state = "[icon_living]_rest"
			set_resting(TRUE)
		else if (prob(1))
			if (resting)
				emote("me", 1, pick("gets up.", "walks around.", "stops resting."), TRUE)
				icon_state = "[icon_living]"
				set_resting(FALSE)
		else if (prob(1))
			emote("me", 1, pick("rests for a bit."), TRUE)
			icon_state = "[icon_living]_sleep"
			set_resting(TRUE)



