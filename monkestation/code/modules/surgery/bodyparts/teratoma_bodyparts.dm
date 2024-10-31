/obj/item/bodypart/head/teratoma
	icon_static =  'monkestation/icons/mob/species/teratoma/bodyparts.dmi'
	icon_husk = 'icons/mob/species/monkey/bodyparts.dmi'
	husk_type = "monkey"
	limb_id = SPECIES_TERATOMA
	is_dimorphic = FALSE
	bodytype = BODYTYPE_HUMANOID | BODYTYPE_ORGANIC | BODYTYPE_CUSTOM
	should_draw_greyscale = FALSE
	head_flags = HEAD_LIPS | HEAD_DEBRAIN
	composition_effects = list(TRAIT_PASSTABLE = 0.5, TRAIT_VENTCRAWLER_ALWAYS = 0.8)

	dmg_overlay_type = "monkey"

/obj/item/bodypart/chest/teratoma
	icon_static =  'monkestation/icons/mob/species/teratoma/bodyparts.dmi'
	icon_husk = 'icons/mob/species/monkey/bodyparts.dmi'
	husk_type = "monkey"
	limb_id = SPECIES_TERATOMA
	is_dimorphic = FALSE
	bodytype = BODYTYPE_HUMANOID | BODYTYPE_ORGANIC | BODYTYPE_CUSTOM
	acceptable_bodytype = BODYTYPE_CUSTOM
	should_draw_greyscale = FALSE
	composition_effects = list(TRAIT_PASSTABLE = 0.5, TRAIT_VENTCRAWLER_ALWAYS = 0.8)

	dmg_overlay_type = "monkey"

/obj/item/bodypart/arm/left/teratoma
	icon_static =  'monkestation/icons/mob/species/teratoma/bodyparts.dmi'
	icon_husk = 'icons/mob/species/monkey/bodyparts.dmi'
	husk_type = "monkey"
	limb_id = SPECIES_TERATOMA
	bodytype = BODYTYPE_HUMANOID | BODYTYPE_ORGANIC | BODYTYPE_CUSTOM
	should_draw_greyscale = FALSE
	hand_traits = list(TRAIT_CHUNKYFINGERS)
	composition_effects = list(TRAIT_PASSTABLE = 0.5, TRAIT_VENTCRAWLER_ALWAYS = 0.8)

	dmg_overlay_type = "monkey"

/obj/item/bodypart/arm/right/teratoma
	icon_static =  'monkestation/icons/mob/species/teratoma/bodyparts.dmi'
	icon_husk = 'icons/mob/species/monkey/bodyparts.dmi'
	husk_type = "monkey"
	limb_id = SPECIES_TERATOMA
	bodytype = BODYTYPE_HUMANOID | BODYTYPE_ORGANIC | BODYTYPE_CUSTOM
	should_draw_greyscale = FALSE
	hand_traits = list(TRAIT_CHUNKYFINGERS)
	composition_effects = list(TRAIT_PASSTABLE = 0.5, TRAIT_VENTCRAWLER_ALWAYS = 0.8)

	dmg_overlay_type = "monkey"

/obj/item/bodypart/leg/left/teratoma
	icon_static =  'monkestation/icons/mob/species/teratoma/bodyparts.dmi'
	icon_husk = 'icons/mob/species/monkey/bodyparts.dmi'
	husk_type = "monkey"
	limb_id = SPECIES_TERATOMA
	bodytype = BODYTYPE_HUMANOID | BODYTYPE_ORGANIC | BODYTYPE_CUSTOM
	should_draw_greyscale = FALSE
	speed_modifier = -0.075
	footprint_sprite = FOOTPRINT_SPRITE_PAWS
	bodypart_traits = list(TRAIT_VAULTING)
	composition_effects = list(TRAIT_PASSTABLE = 0.5, TRAIT_VENTCRAWLER_ALWAYS = 0.8)

/obj/item/bodypart/leg/right/teratoma
	icon_static =  'monkestation/icons/mob/species/teratoma/bodyparts.dmi'
	icon_husk = 'icons/mob/species/monkey/bodyparts.dmi'
	husk_type = "monkey"
	limb_id = SPECIES_TERATOMA
	bodytype = BODYTYPE_HUMANOID | BODYTYPE_ORGANIC | BODYTYPE_CUSTOM
	should_draw_greyscale = FALSE
	footprint_sprite = FOOTPRINT_SPRITE_PAWS
	speed_modifier = -0.075
	dmg_overlay_type = "monkey"
	bodypart_traits = list(TRAIT_VAULTING)
	composition_effects = list(TRAIT_PASSTABLE = 0.5, TRAIT_VENTCRAWLER_ALWAYS = 0.8)
