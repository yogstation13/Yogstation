/datum/symptom/anime_hair
	name = "Pro-tagonista Syndrome"
	desc = "Causes the infected to believe they are the center of the universe. Outcome may vary depending on symptom strength."
	stage = 3
	max_count = 1
	max_chance = 20
	var/given_katana = FALSE
	max_multiplier = 4
	badness = EFFECT_DANGER_ANNOYING
	var/old_haircolor = ""

/datum/symptom/anime_hair/first_activate(mob/living/carbon/mob)
	RegisterSignal(mob, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/symptom/anime_hair/activate(mob/living/carbon/mob)
	if(ishuman(mob))
		var/mob/living/carbon/human/affected = mob
		var/list/hair_colors = list("pink","red","green","blue","purple")
		var/hair_color = pick(hair_colors)

		old_haircolor = affected.hair_color

		if(!isethereal(affected)) //ethereals have weird custom hair color handling
			switch(hair_color)
				if("pink")
					affected.hair_color = "#e983d8"
				if("red")
					affected.hair_color = "#E01631"
				if("green")
					affected.hair_color = "#008000"
				if("blue")
					affected.hair_color = "#0000FF"
				if("purple")
					affected.hair_color = "#800080"
			affected.update_body()

		if(multiplier)
			if(multiplier >= 1.5)
				//Give them schoolgirl outfits /obj/item/clothing/under/costume/schoolgirl
				var/list/outfits = list(
					/obj/item/clothing/under/costume/schoolgirl,
					/obj/item/clothing/under/costume/schoolgirl/red,
					/obj/item/clothing/under/costume/schoolgirl/green,
					/obj/item/clothing/under/costume/schoolgirl/orange
					)
				var/outfit_path = pick(outfits)
				var/obj/item/clothing/under/costume/schoolgirl/schoolgirl = new outfit_path
				ADD_TRAIT(schoolgirl, TRAIT_NODROP, "disease")
				if(affected.w_uniform && !istype(affected.w_uniform, /obj/item/clothing/under/costume/schoolgirl))
					affected.dropItemToGround(affected.w_uniform,1)
					affected.equip_to_slot(schoolgirl, ITEM_SLOT_ICLOTHING)
				if(!affected.w_uniform)
					affected.equip_to_slot(schoolgirl, ITEM_SLOT_ICLOTHING)
			if(multiplier >= 1.8)
				//Kneesocks /obj/item/clothing/shoes/kneesocks
				var/obj/item/clothing/shoes/kneesocks/kneesock = new /obj/item/clothing/shoes/kneesocks
				ADD_TRAIT(kneesock, TRAIT_NODROP, "disease")
				if(affected.shoes && !istype(affected.shoes, /obj/item/clothing/shoes/kneesocks))
					affected.dropItemToGround(affected.shoes,1)
					affected.equip_to_slot(kneesock, ITEM_SLOT_FEET)
				if(!affected.w_uniform)
					affected.equip_to_slot(kneesock, ITEM_SLOT_FEET)

			if(multiplier >= 2)
				//Regular cat ears /obj/item/clothing/head/kitty
				var /obj/item/clothing/head/costume/kitty/kitty = new  /obj/item/clothing/head/costume/kitty
				if(affected.head && !istype(affected.head,  /obj/item/clothing/head/costume/kitty))
					affected.dropItemToGround(affected.head, TRUE)
					affected.equip_to_slot(kitty, ITEM_SLOT_HEAD)
				if(!affected.head)
					affected.equip_to_slot(kitty, ITEM_SLOT_HEAD)

			if(multiplier >= 2.5 && !given_katana)
				if(multiplier >= 3)
					//REAL katana /obj/item/katana
					var/obj/item/katana/real_katana = new /obj/item/katana
					affected.put_in_hands(real_katana)
				else
					//Toy katana /obj/item/toy/katana
					var/obj/item/toy/katana/fake_katana = new /obj/item/toy/katana
					affected.put_in_hands(fake_katana)
				given_katana = TRUE

/datum/symptom/anime_hair/deactivate(mob/living/carbon/mob)
	UnregisterSignal(mob, COMSIG_MOB_SAY)
	to_chat(mob, "<span class = 'notice'>You no longer feel quite like the main character. </span>")
	if (ishuman(mob))
		var/mob/living/carbon/human/affected = mob
		if(affected.shoes && istype(affected.shoes, /obj/item/clothing/shoes/kneesocks))
			REMOVE_TRAIT(affected.shoes, TRAIT_NODROP, "disease")
		if(affected.w_uniform && istype(affected.w_uniform, /obj/item/clothing/under/costume/schoolgirl))
			REMOVE_TRAIT(affected.w_uniform, TRAIT_NODROP, "disease")

		affected.hair_color = old_haircolor

/datum/symptom/anime_hair/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER

	var/message = speech_args[SPEECH_MESSAGE]
	if(prob(20))
		message += pick(" Nyaa", "  nya", "  Nyaa~", "~")

	speech_args[SPEECH_MESSAGE] = message
