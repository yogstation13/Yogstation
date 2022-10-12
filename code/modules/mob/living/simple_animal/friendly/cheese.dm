/mob/living/simple_animal/cheese
	name = "sentient cheese"
	icon = 'icons/mob/animal.dmi'
	icon_state = "parmesan"
	icon_living = "parmesan"
	icon_dead = "parmesan_dead"
	ventcrawler = VENTCRAWLER_ALWAYS
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_SMALL
	mob_biotypes = list(MOB_ORGANIC)
	butcher_results = list(/obj/item/reagent_containers/food/snacks/cheesewedge/parmesan = 2)
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	health = 50
	maxHealth = 50
	wander = 0
	response_harm = "takes a bite out of"
	attacked_sound = 'sound/items/eatfood.ogg'
	deathmessage = "dies from the pain of existence!"
	deathsound = "bodyfall"
	speed = 5
	can_be_held = TRUE
	density = FALSE
	var/mob/living/stored_mob

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
	if(ishuman(L) && L.a_intent == INTENT_GRAB)
		if(stat == DEAD || status_flags & GODMODE || !can_be_held)
			..()
			return
		if(L.get_active_held_item())
			to_chat(L, span_warning("Your hands are full!"))
			return
		visible_message(span_warning("[L] starts picking up [src]."), \
						span_userdanger("[L] starts picking you up!"))
		if(!do_after(L, 2 SECONDS, src))
			return
		visible_message(span_warning("[L] picks up [src]!"), \
						span_userdanger("[L] picks you up!"))
		if(buckled)
			to_chat(L, span_warning("[src] is buckled to [buckled] and cannot be picked up!"))
			return
		to_chat(L, span_notice("You pick [src] up."))
		drop_all_held_items()
		var/obj/item/clothing/mob_holder/cheese/P = new(get_turf(src), src, null, null, null, ITEM_SLOT_HEAD, mob_size, null)
		L.put_in_hands(P)

/mob/living/simple_animal/cheese/death(gibbed)
	for(var/i = 0; i < 4; i++)
		new /obj/item/reagent_containers/food/snacks/cheesewedge/parmesan(loc)
	if(stored_mob)
		uncheeseify(src)
	. = ..()
	
