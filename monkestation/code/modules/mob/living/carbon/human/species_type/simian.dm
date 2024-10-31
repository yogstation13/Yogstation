/datum/species/monkey/simian
	name = "Simian"
	id = SPECIES_SIMIAN
	inherent_traits = list(
		TRAIT_NO_UNDERWEAR,
		TRAIT_NO_AUGMENTS, //Their bodytype doesn't allow augments, this prevents the futile effort.
		TRAIT_MUTANT_COLORS,
		TRAIT_FUR_COLORS,
		//Simian unique traits
		TRAIT_VAULTING,
		TRAIT_MONKEYFRIEND,
		/*Monkey traits that Simians don't have, and why.
		TRAIT_NO_BLOOD_OVERLAY, //let's them have a blood overlay, why not?
		TRAIT_NO_TRANSFORMATION_STING, //Simians are a roundstart species and can equip all, unlike monkeys.
		TRAIT_GUN_NATURAL, //Simians are Advanced tool users, this lets monkeys use guns without being smart.
		TRAIT_VENTCRAWLER_NUDE, //We don't want a roundstart species that can ventcrawl.
		TRAIT_WEAK_SOUL, //Crew innately giving less to Revenants for no real reason sucks for the rev.
		*/
	)

	//they get a normal brain instead of a monkey one,
	//which removes the tripping stuff and gives them literacy/advancedtooluser and removes primitive (unable to use mechs)
	mutantbrain = /obj/item/organ/internal/brain
	no_equip_flags = NONE
	changesource_flags = parent_type::changesource_flags & ~(WABBAJACK | SLIME_EXTRACT)
	maxhealthmod = 0.85 //small = weak
	stunmod = 1.3
	payday_modifier = 1

	give_monkey_species_effects = FALSE

/datum/species/monkey/simian/get_species_description()
	return "Monke."

/datum/species/monkey/simian/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "skull",
			SPECIES_PERK_NAME = "Little Monke",
			SPECIES_PERK_DESC = "You are a weak being, and have less health than most.", // 0.85% health
		)
		,list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "hand",
			SPECIES_PERK_NAME = "Thief",
			SPECIES_PERK_DESC = "Your monkey instincts force you to steal objects at random.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "bolt",
			SPECIES_PERK_NAME = "Agile",
			SPECIES_PERK_DESC = "Simians run slightly faster than other species, but are still outpaced by Goblins.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = "running",
			SPECIES_PERK_NAME = "Vaulting",
			SPECIES_PERK_DESC = "Simians vault over tables instead of climbing them.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "fist-raised",
			SPECIES_PERK_NAME = "Easy to Keep Down",
			SPECIES_PERK_DESC = "You get back up slower from stuns.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "heart",
			SPECIES_PERK_NAME = "Ape Not Kill Ape",
			SPECIES_PERK_DESC = "Monkeys like you more.",
		),
	)

	return to_add

/datum/species/monkey/simian/on_species_gain(mob/living/carbon/human/human_who_gained_species, datum/species/old_species, pref_load)
	. = ..()
	human_who_gained_species.gain_trauma(/datum/brain_trauma/mild/kleptomania, TRAUMA_RESILIENCE_ABSOLUTE)

/datum/species/monkey/simian/random_name(gender,unique,lastname)
	if(unique)
		return random_unique_simian_name(gender)

	var/randname = simian_name(gender)
	if(lastname)
		randname += " [lastname]"
	return randname

/datum/species/monkey/simian/pre_equip_species_outfit(datum/job/job, mob/living/carbon/human/equipping, visuals_only = FALSE)
	var/obj/item/clothing/mask/translator/simian_translator = new /obj/item/clothing/mask/translator(equipping.loc)
	equipping.equip_to_slot(simian_translator, ITEM_SLOT_NECK)
