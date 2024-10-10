/datum/species/werewolf
	name = "werewolf"
	id = SPECIES_WEREWOLF
	inherent_traits = list(
		TRAIT_NO_UNDERWEAR,
		TRAIT_USES_SKINTONES,
		TRAIT_NO_AUGMENTS,
		TRAIT_IGNOREDAMAGESLOWDOWN,
		TRAIT_PUSHIMMUNE,
		TRAIT_STUNIMMUNE,
		TRAIT_PRIMITIVE,
		TRAIT_CAN_STRIP,
		TRAIT_CHUNKYFINGERS,

	)
	mutanttongue = /obj/item/organ/internal/tongue/werewolf
	mutantears = /obj/item/organ/internal/ears/werewolf
	mutanteyes = /obj/item/organ/internal/eyes/werewolf
	mutantbrain = /obj/item/organ/internal/brain/werewolf
	mutantliver = /obj/item/organ/internal/liver/werewolf
	external_organs = list(
		/obj/item/organ/external/tail/cat = "Cat",
	)
	skinned_type = /obj/item/stack/sheet/animalhide/human
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT
	no_equip_flags = ITEM_SLOT_MASK | ITEM_SLOT_OCLOTHING | ITEM_SLOT_GLOVES | ITEM_SLOT_FEET | ITEM_SLOT_ICLOTHING | ITEM_SLOT_SUITSTORE

	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/werewolf,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/werewolf,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/werewolf,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/werewolf,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/werewolf,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/werewolf,
	)

/obj/item/organ/internal/brain/werewolf/get_attacking_limb(mob/living/carbon/human/target)
	name = "werewolf brain"
	desc = "a strange mixture of a human and wolf brain"
	organ_traits = list(TRAIT_PRIMITIVE, TRAIT_CAN_STRIP)

	if(target.body_position == LYING_DOWN)
		return owner.get_bodypart(BODY_ZONE_HEAD)
	return ..()

/datum/species/werewolf/prepare_human_for_preview(mob/living/carbon/human/human)
	human.hair_color = "#bb9966" // brown
	human.hairstyle = "Business Hair"

/datum/species/werewolf/get_species_description()
	return "N/A"

/datum/species/werewolf/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "paw",
			SPECIES_PERK_NAME = "Primal Primate",
			SPECIES_PERK_DESC = "Werewolves are monstrous humans, and can't do most things a human can do. Computers are impossible, \
				complex machines are right out, and most clothes don't fit your larger form.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "assistive-listening-systems",
			SPECIES_PERK_NAME = "Sensitive Hearing",
			SPECIES_PERK_DESC = "Werewolves are more sensitive to loud sounds, such as flashbangs.",
		))

	return to_add
