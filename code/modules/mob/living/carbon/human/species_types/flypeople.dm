/datum/species/fly
	name = "Flyperson"
	plural_form = "Flypeople"
	id = "fly"
	say_mod = "buzzes"
	species_traits = list(NOEYESPRITES, HAS_FLESH, HAS_BONE)
	inherent_biotypes = list(MOB_ORGANIC, MOB_HUMANOID, MOB_BUG)
	mutanttongue = /obj/item/organ/tongue/fly
	mutantliver = /obj/item/organ/liver/fly
	mutantstomach = /obj/item/organ/stomach/fly
	meat = /obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/fly
	disliked_food = null
	liked_food = GROSS | MICE
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT

/datum/species/fly/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.type == /datum/reagent/toxin/pestkiller)
		H.adjustToxLoss(3)
		H.reagents.remove_reagent(chem.type, chem.metabolization_rate)
		return TRUE
	if(istype(chem, /datum/reagent/consumable))
		var/datum/reagent/consumable/nutri_check = chem
		if(nutri_check.nutriment_factor > 0)
			var/turf/pos = get_turf(H)
			H.vomit(0, FALSE, FALSE, 2, TRUE)
			playsound(pos, 'sound/effects/splat.ogg', 50, 1)
			H.visible_message(span_danger("[H] vomits on the floor!"), \
						span_userdanger("You throw up on the floor!"))
	return ..()

/datum/species/fly/check_species_weakness(obj/item/weapon, mob/living/attacker)
	if(istype(weapon, /obj/item/melee/flyswatter))
		return 29 //Flyswatters deal 30x damage to flypeople.
	return 0

/datum/species/fly/get_species_description()
	return "With no official documentation or knowledge of the origin of \
		this species, they remain a mystery to most. Any and all rumours among \
		Nanotrasen staff regarding flypeople are often quickly silenced by high \
		ranking staff or officials."

/datum/species/fly/get_species_lore()
	return list(
		"Flypeople are a curious species with a striking resemblance to the insect order of Diptera, \
		commonly known as flies. With no publically known origin, flypeople are rumored to be a side effect of bluespace travel, \
		despite statements from Nanotrasen officials.",

		"Little is known about the origins of this race, \
		however they posess the ability to communicate with giant spiders, originally discovered in the Australicus sector \
		and now a common occurence in black markets as a result of a breakthrough in syndicate bioweapon research.",

		"Flypeople are often feared or avoided among other species, their appearance often described as unclean or frightening in some cases, \
		and their eating habits even more so with an insufferable accent to top it off.",
	)

/datum/species/fly/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "grin-tongue",
			SPECIES_PERK_NAME = "Uncanny Digestive System",
			SPECIES_PERK_DESC = "Flypeople regurgitate their stomach contents and drink it \
				off the floor to eat and drink with little care for taste, favoring gross foods.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "fist-raised",
			SPECIES_PERK_NAME = "Insectoid Biology",
			SPECIES_PERK_DESC = "Fly swatters will deal significantly higher amounts of damage to a Flyperson.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "briefcase-medical",
			SPECIES_PERK_NAME = "Weird Organs",
			SPECIES_PERK_DESC = "Flypeople take specialized medical knowledge to be \
				treated. Their organs are disfigured and organ manipulation can be interesting...",
		),
	)

	return to_add
