/datum/species/lizard
	// Reptilian humanoids with scaled skin and tails.
	name = "\improper Lizardperson"
	plural_form = "Lizardfolk"
	id = SPECIES_LIZARD
	visual_gender = TRUE	//MONKESTATION EDIT - Dimorphic Lizards
	inherent_traits = list(
		TRAIT_MUTANT_COLORS,
		TRAIT_MUTANT_COLORS_SECONDARY,
		TRAIT_NO_UNDERWEAR,
		TRAIT_CAN_USE_FLIGHT_POTION,
		TRAIT_TACKLING_TAILED_DEFENDER,
	)
	inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID|MOB_REPTILE
	mutant_bodyparts = list("body_markings" = "None", "legs" = "Normal Legs")
	external_organs = list(
		/obj/item/organ/external/horns = "None",
		/obj/item/organ/external/frills = "None",
		/obj/item/organ/external/snout = "Round",
		/obj/item/organ/external/spines = "None",
		/obj/item/organ/external/tail/lizard = "Smooth",
	)
	mutanttongue = /obj/item/organ/internal/tongue/lizard
	mutantstomach = /obj/item/organ/internal/stomach/lizard
	mutantheart = /obj/item/organ/internal/heart/lizard
	coldmod = 1.5
	heatmod = 0.67
	payday_modifier = 0.75
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	species_cookie = /obj/item/food/meat/slab
	meat = /obj/item/food/meat/slab/human/mutant/lizard
	skinned_type = /obj/item/stack/sheet/animalhide/lizard
	exotic_bloodtype = /datum/blood_type/crew/lizard
	inert_mutation = /datum/mutation/human/firebreath
	death_sound = 'sound/voice/lizard/deathsound.ogg'
	species_language_holder = /datum/language_holder/lizard
	digitigrade_customization = DIGITIGRADE_FORCED //Monkestation Edit: OPTIONAL > FORCED

	mutanteyes = /obj/item/organ/internal/eyes/lizard
	// Lizards are coldblooded and can stand a greater temperature range than humans
	bodytemp_normal = (BODYTEMP_NORMAL - 7.5)
	bodytemp_heat_damage_limit = BODYTEMP_HEAT_LAVALAND_SAFE + 5 KELVIN // This puts lizards 10 above lavaland max heat for ash lizards.
	bodytemp_cold_damage_limit = (BODYTEMP_COLD_DAMAGE_LIMIT - 10)

	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/lizard,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/lizard,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/lizard,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/lizard,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/lizard,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/lizard,
	)

/datum/species/lizard/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	. = ..()
	// melbert todo : temp / integrate this into the coldblooded trait
	// if you spawn on station is is expected you have already acclimated to the room temp (20c) (but give a little bit of leeway)
	if(is_station_level(C.z))
		C.bodytemperature = CELCIUS_TO_KELVIN(22.5 CELCIUS)

/datum/species/lizard/random_name(gender,unique,lastname)
	if(unique)
		return random_unique_lizard_name(gender)

	var/randname = lizard_name(gender)

	if(lastname)
		randname += " [lastname]"

	return randname

/datum/species/lizard/randomize_features(mob/living/carbon/human/human_mob)
	human_mob.dna.features["body_markings"] = pick(GLOB.body_markings_list)
	randomize_external_organs(human_mob)

/datum/species/lizard/get_species_description()
	return "The militaristic Lizardpeople hail originally from Tizira, but have grown \
		throughout their centuries in the stars to possess a large spacefaring \
		empire: though now they must contend with their younger, more \
		technologically advanced Human neighbours."

// Override for the default temperature perks, so we can give our specific "cold blooded" perk.
/datum/species/lizard/create_pref_temperature_perks()
	var/list/to_add = list()

	to_add += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
		SPECIES_PERK_ICON = "thermometer-empty",
		SPECIES_PERK_NAME = "Cold-blooded",
		SPECIES_PERK_DESC = "Lizardpeople have higher tolerance for hot temperatures, but lower \
			tolerance for cold temperatures. Additionally, they cannot self-regulate their body temperature - \
			they are as cold or as warm as the environment around them is. Stay warm!",
	))

	return to_add

/*
Lizard subspecies: ASHWALKERS
*/
/datum/species/lizard/ashwalker
	name = "Ash Walker"
	id = SPECIES_LIZARD_ASH
	mutantlungs = /obj/item/organ/internal/lungs/lavaland
	mutantbrain = /obj/item/organ/internal/brain/primitive
	inherent_traits = list(
		TRAIT_MUTANT_COLORS,
		TRAIT_MUTANT_COLORS_SECONDARY,
		TRAIT_NO_UNDERWEAR,
		//TRAIT_LITERATE,
		TRAIT_VIRUSIMMUNE,
		TRAIT_CAN_USE_FLIGHT_POTION,
	)
	species_language_holder = /datum/language_holder/lizard/ash
	/*digitigrade_customization = DIGITIGRADE_FORCED*/ //MONKESTATION REMOVAL: not needed
	examine_limb_id = SPECIES_LIZARD
	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/lizard,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/lizard,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/lizard/ashwalker,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/lizard/ashwalker,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/lizard/ashwalker,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/lizard/ashwalker,
	)

/*
Lizard subspecies: SILVER SCALED
*/
/datum/species/lizard/silverscale
	name = "Silver Scale"
	id = SPECIES_LIZARD_SILVER
	inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID|MOB_REPTILE
	inherent_traits = list(
		TRAIT_HOLY,
		TRAIT_NOBREATH,
		TRAIT_PIERCEIMMUNE,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_VIRUSIMMUNE,
		TRAIT_WINE_TASTER,
	)
	mutantlungs = null
	species_language_holder = /datum/language_holder/lizard/silver
	mutanttongue = /obj/item/organ/internal/tongue/lizard/silver
	exotic_bloodtype = /datum/blood_type/crew/lizard/silver
	armor = 10 //very light silvery scales soften blows
	changesource_flags = MIRROR_BADMIN | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN
	examine_limb_id = SPECIES_LIZARD
	///stored mutcolor for when we turn back off of a silverscale.
	var/old_mutcolor
	///stored eye color for when we turn back off of a silverscale.
	var/old_eye_color_left
	///See above
	var/old_eye_color_right

/datum/species/lizard/silverscale/on_species_gain(mob/living/carbon/new_silverscale, datum/species/old_species, pref_load)
	var/mob/living/carbon/human/silverscale = new_silverscale
	var/datum/color_palette/generic_colors/palette = new_silverscale.dna.color_palettes[/datum/color_palette/generic_colors]
	old_mutcolor = palette.return_color(MUTANT_COLOR)
	old_eye_color_left = silverscale.eye_color_left
	old_eye_color_right = silverscale.eye_color_right
	palette.mutant_color = "#eeeeee"
	silverscale.eye_color_left = "#0000a0"
	silverscale.eye_color_right = "#0000a0"
	..()
	silverscale.add_filter("silver_glint", 2, list("type" = "outline", "color" = "#ffffff63", "size" = 2))

/datum/species/lizard/silverscale/on_species_loss(mob/living/carbon/old_silverscale, datum/species/new_species, pref_load)
	var/mob/living/carbon/human/was_silverscale = old_silverscale
	var/datum/color_palette/generic_colors/palette = was_silverscale.dna.color_palettes[/datum/color_palette/generic_colors]
	palette.mutant_color = old_mutcolor
	was_silverscale.eye_color_left = old_eye_color_left
	was_silverscale.eye_color_right = old_eye_color_right

	was_silverscale.remove_filter("silver_glint")
	..()
