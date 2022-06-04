/mob/living/simple_animal/pet/dog/eggdog //E G G R P
	name = "Egg Dog"
	desc = "It's a egg that is also a dog."
	icon = 'yogstation/icons/mob/pets.dmi'
	icon_state = "eggdog"
	icon_living = "eggdog"
	icon_dead = "eggdog_dead"
	health = 50
	maxHealth = 50
	harm_intent_damage = 10
	response_harm = "takes a bite out of"
	attacked_sound = 'sound/items/eatfood.ogg'
	deathmessage = "loses its false life and collapses back into a egg!"
	deathsound = "bodyfall"
	del_on_death = TRUE
	loot = list(/obj/item/reagent_containers/food/snacks/egg)

/mob/living/simple_animal/pet/dog/eggdog/CheckParts(list/parts)
	..()
	var/obj/item/organ/brain/B = locate(/obj/item/organ/brain) in contents
	if(!B || !B.brainmob || !B.brainmob.mind)
		return
	B.brainmob.mind.transfer_to(src)
	to_chat(src, "<span class='big bold'>You are a egg dog!</span><b> You're a harmless egg/dog hybrid that most people love. People can take bites out of you if they're hungry, but you regenerate health \
	so quickly that it generally doesn't matter. You're remarkably resilient to any damage besides this and it's hard for you to really die at all. Your mission is to go around and spread egg role play \
	across the station so have fun!</b>")
	var/new_name = stripped_input(src, "Enter your name, or press \"Cancel\" to stick with Egg Dog.", "Name Change")
	if(new_name)
		to_chat(src, span_notice("Your name is now <b>\"new_name\"</b>!"))
		name = new_name

/mob/living/simple_animal/pet/dog/eggdog/Life()
	..()
	if(stat)
		return
	if(health < maxHealth)
		adjustBruteLoss(-8) //Fast life regen

/mob/living/simple_animal/pet/dog/eggdog/attack_hand(mob/living/L)
	..()
	if(L.a_intent == INTENT_HARM && L.reagents && !stat)
		L.reagents.add_reagent(/datum/reagent/consumable/eggyolk, 0.4)
		L.reagents.add_reagent(/datum/reagent/consumable/nutriment/vitamin, 0.4)
		L.reagents.add_reagent(/datum/reagent/growthserum, 0.4)
