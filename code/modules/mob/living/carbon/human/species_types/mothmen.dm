/datum/species/moth
	name = "Mothperson"
	plural_form = "Mothpeople"
	id = "moth"
	say_mod = "flutters"
	default_color = "00FF00"
	species_traits = list(LIPS, NOEYESPRITES,HAS_FLESH,HAS_BONE)
	payday_modifier = 0.8 //Useful to NT for biomedical advancements
	inherent_biotypes = list(MOB_ORGANIC, MOB_HUMANOID, MOB_BUG)
	mutant_bodyparts = list("moth_wings")
	default_features = list("moth_wings" = "Plain")
	attack_verb = "slash"
	attack_sound = 'sound/weapons/slash.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	meat = /obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/moth
	liked_food = VEGETABLES | SUGAR
	disliked_food = DAIRY | GROSS
	toxic_food = MEAT | RAW | SEAFOOD | MICE
	burnmod = 1.25 //Fluffy and flammable
	brutemod = 0.9 //Evasive buggers
	punchdamagehigh = 9 //Weird fluffy bug fist
	punchstunthreshold = 10 //No stun punches
	mutanteyes = /obj/item/organ/eyes/moth
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT
	species_language_holder = /datum/language_holder/mothmen

	screamsound = 'sound/voice/moth/scream_moth.ogg'

	smells_like = "dusty dryness"

/datum/species/moth/regenerate_organs(mob/living/carbon/C, datum/species/old_species, replace_current = TRUE, visual_only = FALSE)
	. = ..()
	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		handle_mutant_bodyparts(H)

/datum/species/moth/random_name(gender,unique,lastname)
	if(unique)
		return random_unique_moth_name()

	var/randname = moth_name()

	if(lastname)
		randname += " [lastname]"

	return randname

/datum/species/moth/handle_fire(mob/living/carbon/human/H, no_protection = FALSE)
	. = ..()
	if(.) //if the mob is immune to fire, don't burn wings off.
		return
	if(H.dna.features["moth_wings"] != "Burnt Off" && H.bodytemperature >= 800 && H.fire_stacks > 0) //do not go into the extremely hot light. you will not survive
		to_chat(H, span_danger("Your precious wings burn to a crisp!"))
		H.dna.features["moth_wings"] = "Burnt Off"
		handle_mutant_bodyparts(H)

/datum/species/moth/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.type == /datum/reagent/toxin/pestkiller)
		H.adjustToxLoss(3)
		H.reagents.remove_reagent(chem.type, chem.metabolization_rate)
		return FALSE
	return ..()

/datum/species/moth/check_species_weakness(obj/item/weapon, mob/living/attacker)
	if(istype(weapon, /obj/item/melee/flyswatter))
		return 9 //flyswatters deal 10x damage to moths
	return 0

/datum/species/moth/space_move(mob/living/carbon/human/H)
	. = ..()
	if(H.loc && !isspaceturf(H.loc) && H.dna.features["moth_wings"] != "Burnt Off")
		var/datum/gas_mixture/current = H.loc.return_air()
		if(current && (current.return_pressure() >= ONE_ATMOSPHERE*0.85)) //as long as there's reasonable pressure and no gravity, flight is possible
			return TRUE

/datum/species/moth/get_species_description()
	return /*"Hailing from a planet that was lost long ago, the moths travel \
		the galaxy as a nomadic people aboard a colossal fleet of ships, seeking a new homeland."*/

/datum/species/moth/get_species_lore()
	return list(/*
		"Their homeworld lost to the ages, the moths live aboard the Grand Nomad Fleet. \
		Made up of what could be found, bartered, repaired, or stolen the armada is a colossal patchwork \
		built on a history of politely flagging travelers down and taking their things. Occasionally a moth \
		will decide to leave the fleet, usually to strike out for fortunes to send back home.",

		"Nomadic life produces a tight-knit culture, with moths valuing their friends, family, and vessels highly. \
		Moths are gregarious by nature and do best in communal spaces. This has served them well on the galactic stage, \
		maintaining a friendly and personable reputation even in the face of hostile encounters. \
		It seems that the galaxy has come to accept these former pirates.",

		"Surprisingly, living together in a giant fleet hasn't flattened variance in dialect and culture. \
		These differences are welcomed and encouraged within the fleet for the variety that they bring.",
	*/)

/datum/species/moth/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "feather-alt",
			SPECIES_PERK_NAME = "Precious Wings",
			SPECIES_PERK_DESC = "Moths can fly in pressurized, zero-g environments and safely land short falls using their wings.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "tshirt",
			SPECIES_PERK_NAME = "Meal Plan",
			SPECIES_PERK_DESC = "Moths can eat clothes for nourishment.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "fire",
			SPECIES_PERK_NAME = "Ablazed Wings",
			SPECIES_PERK_DESC = "Moth wings are fragile, and can be easily burnt off.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "sun",
			SPECIES_PERK_NAME = "Bright Lights",
			SPECIES_PERK_DESC = "Moths need an extra layer of flash protection to protect \
				themselves, such as against security officers or when welding. Welding \
				masks will work.",
		),
	)

	return to_add
