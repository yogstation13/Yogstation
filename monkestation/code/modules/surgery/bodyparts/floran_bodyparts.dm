/obj/item/bodypart/head/floran
	icon_greyscale = 'monkestation/icons/mob/species/floran/bodyparts.dmi'
	limb_id = SPECIES_FLORAN
	is_dimorphic = FALSE
	head_flags = HEAD_EYESPRITES | HEAD_EYEHOLES | HEAD_DEBRAIN
	palette = /datum/color_palette/generic_colors
	palette_key = MUTANT_COLOR

/obj/item/bodypart/chest/floran
	icon_greyscale = 'monkestation/icons/mob/species/floran/bodyparts.dmi'
	limb_id = SPECIES_FLORAN
	is_dimorphic = TRUE
	ass_image = 'icons/ass/asspodperson.png'
	bodypart_traits = list(TRAIT_LIMBATTACHMENT)
	palette = /datum/color_palette/generic_colors
	palette_key = MUTANT_COLOR

/obj/item/bodypart/arm/left/floran
	icon_greyscale = 'monkestation/icons/mob/species/floran/bodyparts.dmi'
	limb_id = SPECIES_FLORAN
	unarmed_attack_verb = "slash"
	unarmed_damage_high = 4
	unarmed_damage_low = 4
	unarmed_attack_effect = ATTACK_EFFECT_CLAW
	unarmed_attack_sound = 'sound/weapons/slice.ogg'
	unarmed_miss_sound = 'sound/weapons/slashmiss.ogg'
	hand_traits = list(TRAIT_PLANT_SAFE)
	palette = /datum/color_palette/generic_colors
	palette_key = MUTANT_COLOR

/obj/item/bodypart/arm/right/floran
	icon_greyscale = 'monkestation/icons/mob/species/floran/bodyparts.dmi'
	limb_id = SPECIES_FLORAN
	unarmed_attack_verb = "slash"
	unarmed_damage_high = 4
	unarmed_damage_low = 4
	unarmed_attack_effect = ATTACK_EFFECT_CLAW
	unarmed_attack_sound = 'sound/weapons/slice.ogg'
	unarmed_miss_sound = 'sound/weapons/slashmiss.ogg'
	hand_traits = list(TRAIT_PLANT_SAFE)
	palette = /datum/color_palette/generic_colors
	palette_key = MUTANT_COLOR

/obj/item/bodypart/leg/left/floran
	icon_greyscale = 'monkestation/icons/mob/species/floran/bodyparts.dmi'
	limb_id = SPECIES_FLORAN
	speed_modifier = -0.05
	palette = /datum/color_palette/generic_colors
	palette_key = MUTANT_COLOR

/obj/item/bodypart/leg/right/floran
	icon_greyscale = 'monkestation/icons/mob/species/floran/bodyparts.dmi'
	limb_id = SPECIES_FLORAN
	speed_modifier = -0.05
	palette = /datum/color_palette/generic_colors
	palette_key = MUTANT_COLOR
