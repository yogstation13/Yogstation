/datum/symptom/elvis
	name = "Elvisism"
	desc = "Makes the infected the king of rock and roll."
	stage = 3
	badness = EFFECT_DANGER_HINDRANCE
	severity = 2

/datum/symptom/elvis/first_activate(mob/living/carbon/mob)
	if(ismouse(mob))
		var/mob/living/basic/mouse/mouse = mob
		mouse.icon_state = "mouse_elvis"
		mouse.base_icon_state = "mouse_elvis"
		mouse.icon_living = "mouse_elvis"
		mouse.icon_dead = "mouse_brown_dead"
		return
	mob.dna.add_mutation(/datum/mutation/human/elvis, MUT_EXTRA)

/datum/symptom/elvis/activate(mob/living/carbon/mob)
	if(!ishuman(mob))
		return

	var/mob/living/carbon/human/victim = mob

	/*
	var/obj/item/clothing/glasses/H_glasses = H.get_item_by_slot(slot_glasses)
	if(!istype(H_glasses, /obj/item/clothing/glasses/sunglasses/virus))
		var/obj/item/clothing/glasses/sunglasses/virus/virussunglasses = new
		mob.u_equip(H_glasses,1)
		mob.equip_to_slot(virussunglasses, slot_glasses)
	*/

	mob.adjust_confusion(1 SECONDS)

	if(prob(50))
		mob.say(pick("Uh HUH!", "Thank you, Thank you very much...", "I ain't nothin' but a hound dog!", "Swing low, sweet chariot!"))
	else
		mob.emote("me",1,pick("curls his lip!", "gyrates his hips!", "thrusts his hips!"))

	if(istype(victim))

		if(!(victim.hairstyle == "Pompadour (Big)"))
			spawn(50)
				victim.hairstyle = "Pompadour (Big)"
				victim.hair_color = "#242424"
				victim.update_body()

		if(!(victim.facial_hairstyle == "Sideburns (Elvis)"))
			spawn(50)
				victim.facial_hairstyle = "Sideburns (Elvis)"
				victim.facial_hair_color = "#242424"
				victim.update_body()

/datum/symptom/elvis/deactivate(mob/living/carbon/mob)
	if(ismouse(mob))
		return
	/*
	if(ishuman(mob))
		var/mob/living/carbon/human/dude = mob
		if(istype(dude.glasses, /obj/item/clothing/glasses/sunglasses/virus))
			dude.glasses.canremove = 1
			dude.u_equip(dude.glasses,1)
	*/
	mob.dna.remove_mutation(/datum/mutation/human/elvis)
