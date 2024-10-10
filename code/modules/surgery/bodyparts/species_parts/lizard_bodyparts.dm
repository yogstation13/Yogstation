/obj/item/bodypart/head/lizard
	icon_greyscale = 'icons/mob/species/lizard/bodyparts.dmi'
	limb_id = SPECIES_LIZARD
	is_dimorphic = FALSE
	head_flags = HEAD_HAIR| HEAD_EYESPRITES | HEAD_EYEHOLES | HEAD_DEBRAIN | HEAD_EYECOLOR
	composition_effects = list(TRAIT_COLD_BLOODED = 0.5)
	palette = /datum/color_palette/generic_colors
	palette_key = MUTANT_COLOR

/obj/item/bodypart/chest/lizard
	icon_greyscale = 'icons/mob/species/lizard/bodyparts.dmi'
	limb_id = SPECIES_LIZARD
	is_dimorphic = FALSE
	ass_image = 'icons/ass/asslizard.png'
	composition_effects = list(TRAIT_COLD_BLOODED = 0.5)
	wing_types = list(/obj/item/organ/external/wings/functional/dragon)
	palette = /datum/color_palette/generic_colors
	palette_key = MUTANT_COLOR

/obj/item/bodypart/arm/left/lizard
	icon_greyscale = 'icons/mob/species/lizard/bodyparts.dmi'
	limb_id = SPECIES_LIZARD
	unarmed_attack_verb = "slash"
	unarmed_attack_effect = ATTACK_EFFECT_CLAW
	unarmed_attack_sound = 'sound/weapons/slash.ogg'
	unarmed_miss_sound = 'sound/weapons/slashmiss.ogg'
	composition_effects = list(TRAIT_COLD_BLOODED = 0.5)
	palette = /datum/color_palette/generic_colors
	palette_key = MUTANT_COLOR

/obj/item/bodypart/arm/right/lizard
	icon_greyscale = 'icons/mob/species/lizard/bodyparts.dmi'
	limb_id = SPECIES_LIZARD
	unarmed_attack_verb = "slash"
	unarmed_attack_effect = ATTACK_EFFECT_CLAW
	unarmed_attack_sound = 'sound/weapons/slash.ogg'
	unarmed_miss_sound = 'sound/weapons/slashmiss.ogg'
	composition_effects = list(TRAIT_COLD_BLOODED = 0.5)
	palette = /datum/color_palette/generic_colors
	palette_key = MUTANT_COLOR

/obj/item/bodypart/arm/left/lizard/ashwalker
	hand_traits = list(TRAIT_CHUNKYFINGERS)

/obj/item/bodypart/arm/right/lizard/ashwalker
	hand_traits = list(TRAIT_CHUNKYFINGERS)

/obj/item/bodypart/leg/left/lizard
	icon_greyscale = 'icons/mob/species/lizard/bodyparts.dmi'
	limb_id = SPECIES_LIZARD
	can_be_digitigrade = TRUE
	digitigrade_id = "digitigrade"
	footprint_sprite = FOOTPRINT_SPRITE_CLAWS
	composition_effects = list(TRAIT_COLD_BLOODED = 0.5)
	palette = /datum/color_palette/generic_colors
	palette_key = MUTANT_COLOR
	step_sounds = list(
		'sound/effects/footstep/hardclaw1.ogg',
		'sound/effects/footstep/hardclaw2.ogg',
		'sound/effects/footstep/hardclaw3.ogg',
		'sound/effects/footstep/hardclaw4.ogg',
	)

/obj/item/bodypart/leg/right/lizard
	icon_greyscale = 'icons/mob/species/lizard/bodyparts.dmi'
	limb_id = SPECIES_LIZARD
	can_be_digitigrade = TRUE
	digitigrade_id = "digitigrade"
	footprint_sprite = FOOTPRINT_SPRITE_CLAWS
	composition_effects = list(TRAIT_COLD_BLOODED = 0.5)
	palette = /datum/color_palette/generic_colors
	palette_key = MUTANT_COLOR
	step_sounds = list(
		'sound/effects/footstep/hardclaw1.ogg',
		'sound/effects/footstep/hardclaw2.ogg',
		'sound/effects/footstep/hardclaw3.ogg',
		'sound/effects/footstep/hardclaw4.ogg',
	)

/obj/item/bodypart/leg/right/lizard/ashwalker
	bodypart_traits = list(TRAIT_HARD_SOLES)

/obj/item/bodypart/leg/left/lizard/ashwalker
	bodypart_traits = list(TRAIT_HARD_SOLES)
