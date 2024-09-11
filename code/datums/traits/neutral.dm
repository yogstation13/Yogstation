//traits with no real impact that can be taken freely
//MAKE SURE THESE DO NOT MAJORLY IMPACT GAMEPLAY. those should be positive or negative traits.

/datum/quirk/vegetarian
	name = "Vegetarian"
	desc = "You find the idea of eating meat morally and physically repulsive."
	icon = "carrot"
	value = -1
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
