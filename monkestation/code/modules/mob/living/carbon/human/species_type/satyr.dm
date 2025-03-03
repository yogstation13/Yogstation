/datum/species/satyr
	name = "\improper Satyr"
	plural_form = "Satyrs"
	id = SPECIES_SATYR
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN
	sexes = TRUE
	inherent_traits = list(
		TRAIT_NO_UNDERWEAR,
		TRAIT_USES_SKINTONES,
	)
	inherent_biotypes = MOB_ORGANIC | MOB_HUMANOID
	external_organs = list(
		/obj/item/organ/external/satyr_fluff = "normal",
		/obj/item/organ/external/tail/satyr_tail = "short",
		/obj/item/organ/external/horns/satyr_horns = "back",
	)
	meat = /obj/item/food/meat/steak
	mutanttongue = /obj/item/organ/internal/tongue/satyr
	mutantliver = /obj/item/organ/internal/liver/satyr
	maxhealthmod = 1
	stunmod = 1.2
	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/satyr,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/satyr,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/satyr,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/satyr,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/satyr,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/satyr,
	)

/datum/species/satyr/get_species_description()
	return "Mythical goat-people. The clacking of hooves and smell of beer follow them around."

/mob/living/carbon/human/species/satyr
    race = /datum/species/satyr

/datum/species/satyr/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "horse",
			SPECIES_PERK_NAME = "Hooves",
			SPECIES_PERK_DESC = "Cloven feet prevent wearing of shoes, but also protect as a shoe would.",
		)
	)
	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "beer-mug-empty",
			SPECIES_PERK_NAME = "Extreme Alcohol Tolerance",
			SPECIES_PERK_DESC = "Satyr's are immune to toxin damage done by powerful alcohol.",
		)
	)
	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = "beer-mug-empty",
			SPECIES_PERK_NAME = "Drunk",
			SPECIES_PERK_DESC = "Satyr's require a constant supply of booze to not become drunk.",
		)
	)
	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "fa-book-dead",
			SPECIES_PERK_NAME = "Fey Ancenstry",
			SPECIES_PERK_DESC = "Satyr's possess a acute allergy to cold iron.",
		)
	)
	return to_add

/obj/item/organ/internal/tongue/satyr
	name = "satyr tongue"

	liked_foodtypes = GROSS | VEGETABLES | FRUIT
	disliked_foodtypes = MEAT | DAIRY

/obj/item/organ/internal/tongue/satyr/Insert(mob/living/carbon/tongue_owner, special, drop_if_replaced)
	. = ..()
	ADD_TRAIT(tongue_owner, TRAIT_TIN_EATER, ORGAN_TRAIT)

/obj/item/organ/internal/tongue/satyr/Remove(mob/living/carbon/tongue_owner, special)
	. = ..()
	REMOVE_TRAIT(tongue_owner, TRAIT_TIN_EATER, ORGAN_TRAIT)

/obj/item/organ/internal/liver/satyr
	name = "satyr liver"
	organ_traits = list(TRAIT_ALCOHOL_TOLERANCE)


/obj/item/organ/internal/liver/satyr/Insert(mob/living/carbon/receiver, special, drop_if_replaced)
	. = ..()
	receiver.AddComponent(/datum/component/living_drunk)

/obj/item/organ/internal/liver/satyr/Remove(mob/living/carbon/organ_owner, special)
	. = ..()
	var/datum/component/living_drunk/drunk = organ_owner.GetComponent(/datum/component/living_drunk)
	qdel(drunk)

/datum/species/satyr/handle_chemical(datum/reagent/chem, mob/living/carbon/human/H, seconds_per_tick, times_fired)
	if(chem.type == (/datum/reagent/iron))
		H.adjustToxLoss(3 * REM * seconds_per_tick)
		H.reagents.remove_reagent(chem.type, REAGENTS_METABOLISM * seconds_per_tick)
		return TRUE
	if(chem.type == /datum/reagent/medicine/antihol) //Cures alchol, which they need, to live.
		to_chat(H, span_danger("You feel your viens constrict as your heads spin"))
		H.adjustOxyLoss(4 * REM * seconds_per_tick)
		H.reagents.remove_reagent(chem.type, REAGENTS_METABOLISM * seconds_per_tick)
		return TRUE
	return ..()
