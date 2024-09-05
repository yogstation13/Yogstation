//traits with no real impact that can be taken freely
//MAKE SURE THESE DO NOT MAJORLY IMPACT GAMEPLAY. those should be positive or negative traits.

/datum/quirk/vegetarian
	name = "Vegetarian"
	desc = "You find the idea of eating meat morally and physically repulsive."
	icon = "carrot"
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
	var/datum/species/species_type = prefs.read_preference(/datum/preference/choiced/species)
	species_type = new species_type()
	var/disallowed_trait = (NOMOUTH in species_type.species_traits) // Cant eat
	qdel(species_type)

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
	var/datum/species/species_type = prefs.read_preference(/datum/preference/choiced/species)
	species_type = new species_type()
	var/disallowed_trait = (NOMOUTH in species_type.species_traits) // Cant eat
	qdel(species_type)

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
	var/datum/species/species_type = prefs.read_preference(/datum/preference/choiced/species)
	species_type = new species_type()
	var/disallowed_trait = (NOMOUTH in species_type.species_traits) // Cant eat
	qdel(species_type)

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
	var/datum/species/species_type = prefs.read_preference(/datum/preference/choiced/species)
	species_type = new species_type()
	var/disallowed_trait = (NOMOUTH in species_type.species_traits) // Cant eat
	qdel(species_type)

	if(disallowed_trait)
		return "You don't have the ability to eat!"
	return FALSE

/datum/quirk/shifty_eyes
	name = "Shifty Eyes"
	desc = "Your eyes tend to wander all over the place, whether you mean to or not, causing people to sometimes think you're looking directly at them when you aren't."
	icon = "face-dizzy"
	value = 0
	medical_record_text = "Fucking creep kept staring at me the whole damn checkup. I'm only diagnosing this because it's less awkward than thinking it was on purpose."
	mob_trait = TRAIT_SHIFTY_EYES

/datum/quirk/random_accent
	name = "Randomized Accent"
	desc = "You have developed a random accent."
	icon = "comment-dollar"
	value = 0
	mob_trait = TRAIT_RANDOM_ACCENT
	gain_text = span_danger("You have developed an accent.")
	lose_text = span_notice("You have better control of how you pronounce your words.")
	medical_record_text = "Patient is difficult to understand."

/datum/quirk/random_accent/post_add()
	var/mob/living/carbon/human/H = quirk_holder
	if(!H.mind.accent_name)
		H.mind.RegisterSignal(H, COMSIG_MOB_SAY, TYPE_PROC_REF(/datum/mind, handle_speech))
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
		"in your left pocket" = ITEM_SLOT_LPOCKET,
		"in your right pocket" = ITEM_SLOT_RPOCKET,
		"in your backpack" = ITEM_SLOT_BACKPACK
	)
	where = H.equip_in_one_of_slots(spraycan, slots, FALSE) || "at your feet"

/datum/quirk/colorist/post_add()
	if(where == "in your backpack")
		var/mob/living/carbon/human/H = quirk_holder
		SEND_SIGNAL(H.back, COMSIG_TRY_STORAGE_SHOW, H)

	to_chat(quirk_holder, span_boldnotice("Your bottle of hair dye spray is [where]."))

/datum/quirk/colorist/check_quirk(datum/preferences/prefs)
	var/datum/species/species_type = prefs.read_preference(/datum/preference/choiced/species)
	species_type = new species_type()
	var/disallowed_trait = (HAIR in species_type.species_traits) //no hair
	qdel(species_type)

	if(!disallowed_trait)
		return "You don't have hair!"
	return FALSE

/datum/quirk/bald
	name = "Smooth-Headed"
	desc = "You have no hair and are quite insecure about it! Keep your head covered."
	value = 0
	icon = "fa-egg"
	mob_trait = TRAIT_BALD
	gain_text = span_notice("Your head is as smooth as can be, it's terrible.")
	lose_text = span_notice("Your head itches, could it be... growing hair?!")
	medical_record_text = "Patient starkly refused to take off headwear during examination."
	/// Their original hairstyle before becoming bald
	var/old_hair

/datum/quirk/bald/add()
	var/mob/living/carbon/human/H = quirk_holder
	old_hair = H.hair_style
	H.hair_style = "Bald"
	H.update_body_parts()
	H.update_hair()
	RegisterSignal(H, COMSIG_CARBON_EQUIP_HAT, PROC_REF(equip_hat))
	RegisterSignal(H, COMSIG_CARBON_UNEQUIP_HAT, PROC_REF(unequip_hat))

/datum/quirk/bald/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	var/obj/item/clothing/head/wig/natural/W = new(get_turf(H))
	if(old_hair == "Bald")
		W.hair_style = pick(GLOB.hair_styles_list - "Bald")
	else
		W.hair_style = old_hair
	W.update_icon()
	var/list/slots = list(
		"head" = ITEM_SLOT_HEAD,
		"backpack" = ITEM_SLOT_BACKPACK,
		"hands" = ITEM_SLOT_HANDS
	)
	H.equip_in_one_of_slots(W, slots, qdel_on_fail = TRUE)

/datum/quirk/bald/remove()
	. = ..()
	var/mob/living/carbon/human/H = quirk_holder
	if(QDELETED(H)) // uh oh
		return
	H.hair_style = old_hair
	H.update_body_parts()
	H.update_hair()
	UnregisterSignal(H, COMSIG_CARBON_EQUIP_HAT)
	UnregisterSignal(H, COMSIG_CARBON_UNEQUIP_HAT)
	SEND_SIGNAL(H, COMSIG_CLEAR_MOOD_EVENT, "bad_hair_day")

/datum/quirk/bald/proc/equip_hat(mob/user, obj/item/hat)
	if(istype(hat, /obj/item/clothing/head/wig))
		SEND_SIGNAL(quirk_holder, COMSIG_ADD_MOOD_EVENT, "bad_hair_day", /datum/mood_event/confident_mane)
	else
		SEND_SIGNAL(quirk_holder, COMSIG_CLEAR_MOOD_EVENT, "bad_hair_day")

/datum/quirk/bald/proc/unequip_hat(mob/user, obj/item/hat)
	SEND_SIGNAL(quirk_holder, COMSIG_ADD_MOOD_EVENT, "bad_hair_day", /datum/mood_event/bald)

/datum/quirk/sheltered
	name = "Sheltered"
	desc = "You never learned to speak galactic common."
	icon = "comment-dots"
	value = 0
	mob_trait = TRAIT_SHELTERED
	gain_text = span_danger("You do not speak galactic common.")
	lose_text = span_notice("You start to put together how to speak galactic common.")
	medical_record_text = "Patient looks perplexed when questioned in galactic common."
	job_blacklist = list("Captain", "Head of Personnel", "Research Director", "Chief Medical Officer", "Chief Engineer", "Head of Security", "Civil Protection Officer", "Warden")

/datum/quirk/sheltered/on_clone(data)
	var/mob/living/carbon/human/H = quirk_holder
	H.remove_language(/datum/language/common, FALSE, TRUE)
	if(!H.get_selected_language())
		H.grant_language(/datum/language/japanese)

/datum/quirk/sheltered/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	H.remove_language(/datum/language/common, FALSE, TRUE)
	if(!H.get_selected_language())
		H.grant_language(/datum/language/japanese)

//regular cybernetic organs
/datum/quirk/cyberorgan/lungs
	name = "Cybernetic Organ (Lungs)"
	desc = "Due to a past incident you lost function of your lungs, but now have cybernetic lungs!"
	organ_list = list(ORGAN_SLOT_LUNGS = /obj/item/organ/lungs/cybernetic)
	medical_record_text = "During physical examination, patient was found to have cybernetic lungs."
	value = 0
	quality = "regular cybernetic"

/datum/quirk/cyberorgan/lungs/check_quirk(datum/preferences/prefs)
	var/datum/species/species_type = prefs.read_preference(/datum/preference/choiced/species)
	var/datum/species/species = new species_type
	if(TRAIT_NOBREATH in species.inherent_traits) // species with TRAIT_NOBREATH don't have lungs
		return "You don't have lungs!"
	return ..()

/datum/quirk/cyberorgan/heart
	name = "Cybernetic Organ (Heart)"
	desc = "Due to a past incident you lost function of your heart, but now have a cybernetic heart!"
	organ_list = list(ORGAN_SLOT_HEART = /obj/item/organ/heart/cybernetic)
	medical_record_text = "During physical examination, patient was found to have a cybernetic heart."
	value = 0
	quality = "regular cybernetic"

/datum/quirk/cyberorgan/heart/check_quirk(datum/preferences/prefs)
	var/datum/species/species_type = prefs.read_preference(/datum/preference/choiced/species)
	var/datum/species/species = new species_type
	var/disallowed_trait = ((NOBLOOD in species.species_traits) || (STABLEBLOOD in species.species_traits)) // species with NOBLOOD don't have a heart
	qdel(species)
	if(disallowed_trait)
		return "You don't have a heart!"
	return ..()

/datum/quirk/cyberorgan/liver
	name = "Cybernetic Organ (Liver)"
	desc = "Due to a past incident you lost function of your liver, but now have a cybernetic liver!"
	organ_list = list(ORGAN_SLOT_LIVER = /obj/item/organ/liver/cybernetic)
	medical_record_text = "During physical examination, patient was found to have a cybernetic liver."
	value = 0
	quality = "regular cybernetic"
