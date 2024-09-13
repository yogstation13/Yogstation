/datum/species/human
	name = "Human"
	id = SPECIES_HUMAN
	default_color = "FFFFFF"
	species_traits = list(EYECOLOR,HAIR,FACEHAIR,LIPS,HAS_FLESH,HAS_BONE)
	default_features = list("mcolor" = "#FFFFFF", "wings" = "None")
	use_skintones = 1
	skinned_type = /obj/item/stack/sheet/animalhide/human
	disliked_food = GROSS | RAW | MICE
	liked_food = JUNKFOOD | FRIED | GRILLED
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT
	species_language_holder = /datum/language_holder/english

	smells_like = "soap and superiority"

/datum/species/human/qualifies_for_rank(rank, list/features)
	return TRUE	//Pure humans are always allowed in all roles.

/datum/species/human/has_toes()
	return TRUE

/datum/species/human/get_butt_sprite(mob/living/carbon/human/human)
	var/butt_sprite = human.gender == FEMALE ? BUTT_SPRITE_HUMAN_FEMALE : BUTT_SPRITE_HUMAN_MALE
	return butt_sprite

/datum/species/human/get_scream_sound(mob/living/carbon/human/human)
	if(human.gender == MALE)
		if(prob(1))
			return 'sound/voice/human/wilhelm_scream.ogg'
		return pick(
			'sound/voice/human/malescream_1.ogg',
			'sound/voice/human/malescream_2.ogg',
			'sound/voice/human/malescream_3.ogg',
			'sound/voice/human/malescream_4.ogg',
			'sound/voice/human/malescream_5.ogg',
			'sound/voice/human/malescream_6.ogg',
		)

	return pick(
		'sound/voice/human/femalescream_1.ogg',
		'sound/voice/human/femalescream_2.ogg',
		'sound/voice/human/femalescream_3.ogg',
		'sound/voice/human/femalescream_4.ogg',
		'sound/voice/human/femalescream_5.ogg',
	)

/datum/species/human/get_cough_sound(mob/living/carbon/human/human)
	if(human.gender == FEMALE)
		return pick(
			'sound/voice/human/female_cough1.ogg',
			'sound/voice/human/female_cough2.ogg',
			'sound/voice/human/female_cough3.ogg',
			'sound/voice/human/female_cough4.ogg',
			'sound/voice/human/female_cough5.ogg',
			'sound/voice/human/female_cough6.ogg',
		)
	return pick(
		'sound/voice/human/male_cough1.ogg',
		'sound/voice/human/male_cough2.ogg',
		'sound/voice/human/male_cough3.ogg',
		'sound/voice/human/male_cough4.ogg',
		'sound/voice/human/male_cough5.ogg',
		'sound/voice/human/male_cough6.ogg',
	)

/datum/species/human/get_cry_sound(mob/living/carbon/human/human)
	if(human.gender == FEMALE)
		return pick(
			'sound/voice/human/female_cry1.ogg',
			'sound/voice/human/female_cry2.ogg',
		)
	return pick(
		'sound/voice/human/male_cry1.ogg',
		'sound/voice/human/male_cry2.ogg',
		'sound/voice/human/male_cry3.ogg',
	)


/datum/species/human/get_sneeze_sound(mob/living/carbon/human/human)
	if(human.gender == FEMALE)
		return 'sound/voice/human/female_sneeze1.ogg'
	return 'sound/voice/human/male_sneeze1.ogg'

/datum/species/human/get_laugh_sound(mob/living/carbon/human/human)
	if(!ishuman(human))
		return
	if(human.gender == FEMALE)
		return 'sound/voice/human/womanlaugh.ogg'
	return pick(
		'sound/voice/human/manlaugh1.ogg',
		'sound/voice/human/manlaugh2.ogg',
	)

/datum/species/human/prepare_human_for_preview(mob/living/carbon/human/human)
	human.hair_style = "Business Hair"
	human.hair_color = "b96" // brown
	human.update_hair()

/datum/species/human/get_species_description()
	return "Humans are the dominant intelligent species inside Earth."

/datum/species/human/get_species_lore()
	return list(
		"It has been about 16 years since the Seven Hour war. \
		The Combine have taken over the world, and in that time set up cities, mined much of the natural resources of the world, and put remaining people into urban centers. \
		Alyx has only just released the G-Man, and the Combine have only now started to increase their oppression. \
		Citizens have just begun to be forced into their iconic blue jumpsuits, and are having other privledges removed. \
		Will you help the Benefactors and hope for a better life, try to make it on your own, or side with the resistance to try to get your world back?",
	)

/datum/species/human/create_pref_unique_perks()
	var/list/to_add = list()

	if(CONFIG_GET(flag/enforce_human_authority))
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "star-half-alt",
			SPECIES_PERK_NAME = "Benefactor's Favored",
			SPECIES_PERK_DESC = "Humans are far better treated by the combine compared to Vortigaunts",
		))

	return to_add
