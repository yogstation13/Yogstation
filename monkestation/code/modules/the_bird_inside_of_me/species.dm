/// GLOB list of armwings sprites / options
GLOBAL_LIST_EMPTY(arm_wings_list)
GLOBAL_LIST_EMPTY(arm_wingsopen_list)
/// GLOB list of other features (ears, tails)
GLOBAL_LIST_EMPTY(avian_ears_list)
GLOBAL_LIST_EMPTY(tails_list_avian)

/datum/species/ornithid
	// the biggest bird
	name = "\improper Ornithid"
	plural_form = "Ornithids"
	id = SPECIES_ORNITHID

	inherent_traits = list(
		TRAIT_NO_UNDERWEAR,
		TRAIT_FEATHERED,
		TRAIT_USES_SKINTONES,
	)
	mutanttongue = /obj/item/organ/internal/tongue/ornithid
	external_organs = list(
		/obj/item/organ/external/wings/functional/arm_wings = "Monochrome",
		/obj/item/organ/external/plumage = "Hermes",
		/obj/item/organ/external/tail/avian = "Eagle",
	)
	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/ornithid,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/ornithid,
		BODY_ZONE_HEAD = /obj/item/bodypart/head, // just because they are still *partially* human, or otherwise human resembling
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/ornithid,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/ornithid,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/ornithid,
	)
	species_pain_mod = 1.20 // Fuck it, this will fill a niche that isn't implemented yet.
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	digitigrade_customization = DIGITIGRADE_FORCED

	species_cookie = /obj/item/food/semki/healthy // humans get chocolate, lizards get meat. What do birds get? Seed.
	meat = /obj/item/food/meat/slab/chicken
	skinned_type = /obj/item/stack/sheet/animalhide/human
	mutantliver = /obj/item/organ/internal/liver/ornithid

	inert_mutation = /datum/mutation/human/dwarfism
	species_language_holder = /datum/language_holder/yangyu // doing this because yangyu is really just, mostly unused otherwise.
	color_palette = /datum/color_palette/ornithids

/datum/species/ornithid/prepare_human_for_preview(mob/living/carbon/human/human)
	human.skin_tone = "asian1"
	human.hairstyle = "Half-banged Hair"
	human.set_haircolor(COLOR_BROWNER_BROWN)
	human.update_body(TRUE)

// defines limbs/bodyparts.

/obj/item/bodypart/arm/left/ornithid
	limb_id = SPECIES_ORNITHID
	icon_greyscale = 'monkestation/code/modules/the_bird_inside_of_me/icons/ornithid_parts_greyscale.dmi'
	unarmed_attack_verb = "slash"
	unarmed_attack_effect = ATTACK_EFFECT_CLAW
	unarmed_attack_sound = 'sound/weapons/slice.ogg'
	unarmed_miss_sound = 'sound/weapons/slashmiss.ogg'


/obj/item/bodypart/arm/right/ornithid
	limb_id = SPECIES_ORNITHID
	icon_greyscale = 'monkestation/code/modules/the_bird_inside_of_me/icons/ornithid_parts_greyscale.dmi'
	unarmed_attack_verb = "slash"
	unarmed_attack_effect = ATTACK_EFFECT_CLAW
	unarmed_attack_sound = 'sound/weapons/slice.ogg'
	unarmed_miss_sound = 'sound/weapons/slashmiss.ogg'

/obj/item/bodypart/chest/ornithid
	acceptable_bodytype = BODYTYPE_ORGANIC | BODYTYPE_DIGITIGRADE

/obj/item/bodypart/leg/left/ornithid
	limb_id = SPECIES_ORNITHID
	digitigrade_id = SPECIES_ORNITHID
	icon_greyscale = 'monkestation/code/modules/the_bird_inside_of_me/icons/ornithid_parts_greyscale.dmi'
	bodytype = BODYTYPE_ORGANIC | BODYTYPE_DIGITIGRADE
	bodypart_traits = list(TRAIT_HARD_SOLES, TRAIT_NON_IMPORTANT_SHOE_BLOCK)
	step_sounds = list(
		'sound/effects/footstep/hardclaw1.ogg',
		'sound/effects/footstep/hardclaw2.ogg',
		'sound/effects/footstep/hardclaw3.ogg',
		'sound/effects/footstep/hardclaw4.ogg',
		'sound/effects/footstep/hardclaw1.ogg',
	)

/obj/item/bodypart/leg/right/ornithid
	limb_id = SPECIES_ORNITHID
	digitigrade_id = SPECIES_ORNITHID
	icon_greyscale = 'monkestation/code/modules/the_bird_inside_of_me/icons/ornithid_parts_greyscale.dmi'
	bodytype = BODYTYPE_ORGANIC | BODYTYPE_DIGITIGRADE
	bodypart_traits = list(TRAIT_HARD_SOLES, TRAIT_NON_IMPORTANT_SHOE_BLOCK)
	step_sounds = list(
		'sound/effects/footstep/hardclaw1.ogg',
		'sound/effects/footstep/hardclaw2.ogg',
		'sound/effects/footstep/hardclaw3.ogg',
		'sound/effects/footstep/hardclaw4.ogg',
		'sound/effects/footstep/hardclaw1.ogg',
	)

// section for lore/perk descs
/datum/species/ornithid/get_species_lore()
	return list(
		"Much to the chagrin of the collective, the term \"Ornithid\" is in effect, a dumping ground of the various human-derived avian animalids, making it the second most populous animalid group. \
		Several cultural and geneological groups can fall under this banner, with sometimes only those directly related to eachother baring any resemblance physically.",

		"while countless other groups exist, the three most common ornithid groups known to Nanotrasen are the conniving Izulukin, The wandering Vagrants, and The traditionalist Tengu.",

		"the Izulukin are an infamous bunch, being heavily overrepresented in privateer populations, always hungering for blood and gold. \
		above all else, however, the Izulukin are obsessed with \"Genetic Perfection\", always finding ways to eliminate maladaptive or \"non-beneficial\" genes. \
		this behavior is prevalent in their culture, with many izulukin activating latent genes to given themselves \"Super Powers\" so as to earn an edge in combat, and in culture.",

		"of all the Izulukin's activities, they are most known for their contracts with witches, warlocks, and other dark-mages, binding a living member to a mage, \
		until the bound member perishes, passing on to a chosen descendant should the contract owner perish themself. \
		In addition, another activity they are infamous for is their almost vampiric obsession with the blood of biological organisms, \
		harvesting it to be used in the production of various synthetic proteins, which form the core of their diet.",

		"The third most populous groups are the simply named Vagrants, a typical group of wanderers who have no true home accross the stars, \
		often working as traders, bounty hunters, and other nomadic professions. They are well known for a very effecient style of living, \
		mixing efficient equipment and armor with casual wear, leaving little scraps left to waste.",

		"The most populous of the three groups, the culture of the Tengu bares a striking resemblance to Edo Period Japan on earth, with their primary language, \
		Yangyu, appearing to be based upon Japanese. They have a rigid, class-based society, with one's cultural importance and percieved morality holding more importance than wealth; \
		which unsurprisingly, ends up funneled to the top regardless.",

		"While there are many \"Born\" Tengu, many are cultural immigrants from various portions of the galaxy, most notably those who have fled or been exiled from the Izulukin."

	)

/datum/species/ornithid/get_species_description()
	return list(
		"Ornithids are a collective group of various human descendant, or otherwise resembling, sentient avian beings.",
		"Their most well known physical trait are their reduced weight, and feathery \"wings\" protuding from their arms, which they can use to fly.",
		"There are countless various types and groups of Ornithids, with a variety of backgrounds both known and unknown by NT. "
	)

/datum/species/ornithid/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "dove",
			SPECIES_PERK_NAME = "Airborne",
			SPECIES_PERK_DESC = "Is it a bird? is it a plane? Of course its a bird you dumbass, \
				Ornithids are lightweight winged avians, and can, as a result, fly.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "music",
			SPECIES_PERK_NAME = "Musical",
			SPECIES_PERK_DESC = "Thanks to their avian tongues, Ornithids can mimic a \
				variety of instruments, conventional or not.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = "feather",
			SPECIES_PERK_NAME = "Winged",
			SPECIES_PERK_DESC = "Ornithids have wings that are not concealed by hardsuits \
				or MODsuits, making it easier to identify them.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = "shoe-prints",
			SPECIES_PERK_NAME = "Talon-Footed",
			SPECIES_PERK_DESC = "Avians have talons instead of regular feet, which prevent them from wearing shoes \
			but protect as a shoe would.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "feather",
			SPECIES_PERK_NAME = "Lightweights",
			SPECIES_PERK_DESC = "As a result of their reduced average weight, \
				Ornithids have a lower alcohol tolerance. Pansies.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "brain",
			SPECIES_PERK_NAME = "Hyper-Sensitive Nerves",
			SPECIES_PERK_DESC = "Ornithids have incredibly sensistive nerves compared to their human counterparts, \
				Taking 1.2x pain, 1.5x damage to their ears, and get stunned for 2x longer when flying.", // the 2x stun length only applies when flying, and is inherited from functional wings.
		),
	)
	return to_add

/obj/item/organ/internal/liver/ornithid
	name = "bird liver"
	organ_traits = list(TRAIT_LIGHT_DRINKER)
