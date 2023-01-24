//traits with no real impact that can be taken freely
//MAKE SURE THESE DO NOT MAJORLY IMPACT GAMEPLAY. those should be positive or negative traits.

/datum/quirk/vegetarian
	name = "Vegetarian"
	desc = "You find the idea of eating meat morally and physically repulsive."
	icon = "tomato"
	value = 0
	gain_text = span_notice("You feel repulsion at the idea of eating meat.")
	lose_text = span_notice("You feel like eating meat isn't that bad.")
	medical_record_text = "Patient reports a vegetarian diet."

/datum/quirk/vegetarian/add()
	var/mob/living/carbon/human/H = quirk_holder
	var/datum/species/species = H.dna.species
	species.liked_food &= ~MEAT
	species.disliked_food |= MEAT

/datum/quirk/vegetarian/remove()
	var/mob/living/carbon/human/H = quirk_holder
	if(H)
		var/datum/species/species = H.dna.species
		if(initial(species.liked_food) & MEAT)
			species.liked_food |= MEAT
		if(!(initial(species.disliked_food) & MEAT))
			species.disliked_food &= ~MEAT

/datum/quirk/vegetarian/check_quirk(datum/preferences/prefs)
	var/species_type = prefs.read_preference(/datum/preference/choiced/species)
	var/datum/species/species = new species_type

	var/disallowed_trait = (NOMOUTH in species.species_traits) // Cant eat
	qdel(species)

	if(disallowed_trait)
		return "You don't have the ability to eat!"
	return FALSE

/datum/quirk/pineapple_liker
	name = "Ananas Affinity"
	desc = "You find yourself greatly enjoying fruits of the ananas genus. You can't seem to ever get enough of their sweet goodness!"
	icon = "thumbs-up"
	value = 0
	gain_text = span_notice("You feel an intense craving for pineapple.")
	lose_text = span_notice("Your feelings towards pineapples seem to return to a lukewarm state.")
	medical_record_text = "Patient demonstrates a pathological love of pineapple."

/datum/quirk/pineapple_liker/add()
	var/mob/living/carbon/human/H = quirk_holder
	var/datum/species/species = H.dna.species
	species.liked_food |= PINEAPPLE

/datum/quirk/pineapple_liker/remove()
	var/mob/living/carbon/human/H = quirk_holder
	if(H)
		var/datum/species/species = H.dna.species
		species.liked_food &= ~PINEAPPLE

/datum/quirk/pineapple_liker/check_quirk(datum/preferences/prefs)
	var/species_type = prefs.read_preference(/datum/preference/choiced/species)
	var/datum/species/species = new species_type

	var/disallowed_trait = (NOMOUTH in species.species_traits) // Cant eat
	qdel(species)

	if(disallowed_trait)
		return "You don't have the ability to eat!"
	return FALSE

/datum/quirk/pineapple_hater
	name = "Ananas Aversion"
	desc = "You find yourself greatly detesting fruits of the ananas genus. Serious, how the hell can anyone say these things are good? And what kind of madman would even dare putting it on a pizza!?"
	icon = "thumbs-down"
	value = 0
	gain_text = span_notice("You find yourself pondering what kind of idiot actually enjoys pineapples...")
	lose_text = span_notice("Your feelings towards pineapples seem to return to a lukewarm state.")
	medical_record_text = "Patient is correct to think that pineapple is disgusting."

/datum/quirk/pineapple_hater/add()
	var/mob/living/carbon/human/H = quirk_holder
	var/datum/species/species = H.dna.species
	species.disliked_food |= PINEAPPLE

/datum/quirk/pineapple_hater/remove()
	var/mob/living/carbon/human/H = quirk_holder
	if(H)
		var/datum/species/species = H.dna.species
		species.disliked_food &= ~PINEAPPLE

/datum/quirk/pineapple_hater/check_quirk(datum/preferences/prefs)
	var/species_type = prefs.read_preference(/datum/preference/choiced/species)
	var/datum/species/species = new species_type

	var/disallowed_trait = (NOMOUTH in species.species_traits) // Cant eat
	qdel(species)

	if(disallowed_trait)
		return "You don't have the ability to eat!"
	return FALSE

/datum/quirk/deviant_tastes
	name = "Deviant Tastes"
	desc = "You dislike food that most people enjoy, and find delicious what they don't."
	icon = "grin-tongue-squint"
	value = 0
	gain_text = span_notice("You start craving something that tastes strange.")
	lose_text = span_notice("You feel like eating normal food again.")
	medical_record_text = "Patient demonstrates irregular nutrition preferences."

/datum/quirk/deviant_tastes/add()
	var/mob/living/carbon/human/H = quirk_holder
	var/datum/species/species = H.dna.species
	var/liked = species.liked_food
	species.liked_food = species.disliked_food
	species.disliked_food = liked

/datum/quirk/deviant_tastes/remove()
	var/mob/living/carbon/human/H = quirk_holder
	if(H)
		var/datum/species/species = H.dna.species
		species.liked_food = initial(species.liked_food)
		species.disliked_food = initial(species.disliked_food)

/datum/quirk/deviant_tastes/check_quirk(datum/preferences/prefs)
	var/species_type = prefs.read_preference(/datum/preference/choiced/species)
	var/datum/species/species = new species_type

	var/disallowed_trait = (NOMOUTH in species.species_traits) // Cant eat
	qdel(species)

	if(disallowed_trait)
		return "You don't have the ability to eat!"
	return FALSE

/datum/quirk/shifty_eyes
	name = "Shifty Eyes"
	desc = "Your eyes tend to wander all over the place, whether you mean to or not, causing people to sometimes think you're looking directly at them when you aren't."
	icon = "face-spiral-eyes"
	value = 0
	medical_record_text = "Fucking creep kept staring at me the whole damn checkup. I'm only diagnosing this because it's less awkward than thinking it was on purpose."
	mob_trait = TRAIT_SHIFTY_EYES

/datum/quirk/random_accent
	name = "Randomized Accent"
	desc = "You have developed a random accent."
	icon = "message-dots"
	value = 0
	mob_trait = TRAIT_RANDOM_ACCENT
	gain_text = span_danger("You have developed an accent.")
	lose_text = span_notice("You have better control of how you pronounce your words.")
	medical_record_text = "Patient is difficult to understand."

/datum/quirk/random_accent/post_add()
	var/mob/living/carbon/human/H = quirk_holder
	if(!H.mind.accent_name)
		H.mind.RegisterSignal(H, COMSIG_MOB_SAY, /datum/mind/.proc/handle_speech)
	H.mind.accent_name = pick(assoc_to_keys(GLOB.accents_name2file))// Right now this pick just picks a straight random one from all implemented.

/datum/quirk/colorist
	name = "Colorist"
	desc = "You like carrying around a hair dye spray to quickly apply color patterns to your hair."
	icon = "spray-can-sparkles"
	value = 0
	medical_record_text = "Patient enjoys dyeing their hair with pretty colors."
	var/where

/datum/quirk/colorist/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	var/obj/item/dyespray/spraycan = new(get_turf(H))
	var/list/slots = list(
		"in your left pocket" = SLOT_L_STORE,
		"in your right pocket" = SLOT_R_STORE,
		"in your backpack" = SLOT_IN_BACKPACK
	)
	where = H.equip_in_one_of_slots(spraycan, slots, FALSE) || "at your feet"

/datum/quirk/colorist/post_add()
	if(where == "in your backpack")
		var/mob/living/carbon/human/H = quirk_holder
		SEND_SIGNAL(H.back, COMSIG_TRY_STORAGE_SHOW, H)

	to_chat(quirk_holder, span_boldnotice("Your bottle of hair dye spray is [where]."))

/datum/quirk/colorist/check_quirk(datum/preferences/prefs)
	var/species_type = prefs.read_preference(/datum/preference/choiced/species)
	var/datum/species/species = new species_type

	var/disallowed_trait = (HAIR in species.species_traits) // No Hair
	qdel(species)

	if(!disallowed_trait)
		return "You don't have hair!"
	return FALSE

/datum/quirk/family_heirloom
	name = "Family Heirloom"
	desc = "You are the current owner of an heirloom, passed down for generations. You have to keep it safe!"
	icon = "toolbox"
	value = 0
	mood_quirk = FALSE
	var/obj/item/heirloom
	var/where
	medical_record_text = "Patient demonstrates an unnatural attachment to a family heirloom."

/datum/quirk/family_heirloom/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	var/obj/item/heirloom_type

	if(is_species(H, /datum/species/moth) && prob(50))
		heirloom_type = /obj/item/flashlight/lantern/heirloom_moth
	else if(iscatperson(H) && prob(50))
		heirloom_type = /obj/item/toy/cattoy
	else
		switch(quirk_holder.mind.assigned_role)
			//Service jobs
			if("Clown")
				heirloom_type = /obj/item/bikehorn/golden
			if("Mime")
				heirloom_type = /obj/item/reagent_containers/food/snacks/baguette
			if("Janitor")
				heirloom_type = pick(/obj/item/mop, /obj/item/clothing/suit/caution, /obj/item/reagent_containers/glass/bucket/wooden)
			if("Cook")
				heirloom_type = pick(/obj/item/reagent_containers/food/condiment/saltshaker, /obj/item/kitchen/rollingpin, /obj/item/clothing/head/chefhat)
			if("Clerk")
				heirloom_type = pick(/obj/item/coin, /obj/item/coin/gold, /obj/item/coin/iron, /obj/item/coin/silver)
			if("Botanist")
				if(is_species(H, /datum/species/plasmaman))
					heirloom_type = pick(/obj/item/cultivator, /obj/item/shovel/spade, /obj/item/reagent_containers/glass/bucket/wooden, /obj/item/toy/plush/beeplushie)
				else
					heirloom_type = pick(/obj/item/cultivator, /obj/item/shovel/spade, /obj/item/reagent_containers/glass/bucket/wooden, /obj/item/toy/plush/beeplushie, /obj/item/clothing/mask/cigarette/pipe, /obj/item/clothing/mask/cigarette/pipe/cobpipe)
			if("Bartender")
				heirloom_type = pick(/obj/item/reagent_containers/glass/rag, /obj/item/clothing/head/that, /obj/item/reagent_containers/food/drinks/shaker)
			if("Curator")
				heirloom_type = pick(/obj/item/pen/fountain, /obj/item/storage/pill_bottle/dice)
			if("Assistant")
				heirloom_type = /obj/item/storage/toolbox/mechanical/old/heirloom
			//Security/Command
			if("Captain")
				heirloom_type = /obj/item/reagent_containers/food/drinks/flask/gold
			if("Head of Security")
				heirloom_type = /obj/item/book/manual/wiki/security_space_law
			if("Warden")
				heirloom_type = /obj/item/book/manual/wiki/security_space_law
			if("Security Officer")
				heirloom_type = pick(/obj/item/book/manual/wiki/security_space_law, /obj/item/clothing/head/beret/sec)
			if("Detective")
				heirloom_type = pick(/obj/item/reagent_containers/food/drinks/bottle/whiskey, /obj/item/taperecorder/empty)
			if("Lawyer")
				heirloom_type = pick(/obj/item/gavelhammer, /obj/item/book/manual/wiki/security_space_law)
			//RnD
			if("Research Director")
				heirloom_type = /obj/item/toy/plush/slimeplushie
			if("Scientist")
				heirloom_type = /obj/item/toy/plush/slimeplushie
			if("Roboticist")
				heirloom_type = pick(subtypesof(/obj/item/toy/prize)) //look at this nerd
			//Medical
			if("Chief Medical Officer")
				heirloom_type = pick(/obj/item/clothing/neck/stethoscope, /obj/item/bodybag)
			if("Medical Doctor")
				heirloom_type = pick(/obj/item/clothing/neck/stethoscope, /obj/item/bodybag)
			if("Chemist")
				heirloom_type = pick(/obj/item/book/manual/wiki/chemistry, /obj/item/clothing/mask/vape)
			if("Virologist")
				heirloom_type = /obj/item/reagent_containers/syringe
			//Engineering
			if("Chief Engineer")
				heirloom_type = pick(/obj/item/clothing/head/hardhat/white, /obj/item/screwdriver, /obj/item/wrench, /obj/item/weldingtool, /obj/item/crowbar, /obj/item/wirecutters)
			if("Station Engineer")
				heirloom_type = pick(/obj/item/clothing/head/hardhat, /obj/item/screwdriver, /obj/item/wrench, /obj/item/weldingtool, /obj/item/crowbar, /obj/item/wirecutters)
			if("Atmospheric Technician")
				heirloom_type = pick(/obj/item/lighter, /obj/item/lighter/greyscale, /obj/item/storage/box/matches)
			//Supply
			if("Quartermaster")
				heirloom_type = pick(/obj/item/stamp, /obj/item/stamp/denied)
			if("Cargo Technician")
				heirloom_type = /obj/item/clipboard
			if("Shaft Miner")
				heirloom_type = pick(/obj/item/pickaxe/mini, /obj/item/shovel)

	if(!heirloom_type)
		heirloom_type = pick(
		/obj/item/toy/cards/deck,
		/obj/item/lighter,
		/obj/item/dice/d20)
	heirloom = new heirloom_type(get_turf(quirk_holder))
	var/list/slots = list(
		"in your left pocket" = SLOT_L_STORE,
		"in your right pocket" = SLOT_R_STORE,
		"in your backpack" = SLOT_IN_BACKPACK
	)
	where = H.equip_in_one_of_slots(heirloom, slots, FALSE) || "at your feet"

/datum/quirk/family_heirloom/post_add()
	if(where == "in your backpack")
		var/mob/living/carbon/human/H = quirk_holder
		SEND_SIGNAL(H.back, COMSIG_TRY_STORAGE_SHOW, H)

	to_chat(quirk_holder, span_boldnotice("There is a precious family [heirloom.name] [where], passed down from generation to generation. Keep it safe!"))

	var/list/names = splittext(quirk_holder.real_name, " ")
	var/family_name = names[names.len]

	heirloom.AddComponent(/datum/component/heirloom, quirk_holder.mind, family_name)

/datum/quirk/family_heirloom/on_process()
	if(heirloom in quirk_holder.GetAllContents())
		SEND_SIGNAL(quirk_holder, COMSIG_CLEAR_MOOD_EVENT, "family_heirloom_missing")
		SEND_SIGNAL(quirk_holder, COMSIG_ADD_MOOD_EVENT, "family_heirloom", /datum/mood_event/family_heirloom)
	else
		SEND_SIGNAL(quirk_holder, COMSIG_CLEAR_MOOD_EVENT, "family_heirloom")
		SEND_SIGNAL(quirk_holder, COMSIG_ADD_MOOD_EVENT, "family_heirloom_missing", /datum/mood_event/family_heirloom_missing)

/datum/quirk/family_heirloom/clone_data()
	return heirloom

/datum/quirk/family_heirloom/on_clone(data)
	heirloom = data

