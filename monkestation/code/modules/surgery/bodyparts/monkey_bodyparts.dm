/obj/item/bodypart/head/monkey
	icon = 'monkestation/icons/mob/species/monkey/bodyparts.dmi'
	icon_greyscale = 'monkestation/icons/mob/species/monkey/bodyparts.dmi'
	icon_static = 'icons/mob/species/monkey/bodyparts.dmi'
	icon_husk = 'monkestation/icons/mob/species/monkey/bodyparts.dmi'
	husk_type = "monkey"
	icon_state = "default_monkey_head"
	limb_id = SPECIES_MONKEY
	bodytype = BODYTYPE_MONKEY | BODYTYPE_ORGANIC
	dmg_overlay_type = SPECIES_MONKEY
	is_dimorphic = FALSE
	should_draw_greyscale = TRUE
	head_flags = HEAD_EYESPRITES | HEAD_EYEHOLES | HEAD_DEBRAIN | HEAD_EYECOLOR
	palette = /datum/color_palette/generic_colors
	palette_key = "fur_color"

/obj/item/bodypart/chest/monkey
	icon = 'monkestation/icons/mob/species/monkey/bodyparts.dmi'
	icon_greyscale = 'monkestation/icons/mob/species/monkey/bodyparts.dmi'
	icon_static = 'icons/mob/species/monkey/bodyparts.dmi'
	icon_husk = 'monkestation/icons/mob/species/monkey/bodyparts.dmi'
	husk_type = "monkey"
	icon_state = "default_monkey_chest"
	limb_id = SPECIES_MONKEY
	should_draw_greyscale = TRUE
	is_dimorphic = FALSE
	wound_resistance = -10
	bodytype = BODYTYPE_MONKEY | BODYTYPE_ORGANIC
	acceptable_bodytype = BODYTYPE_MONKEY
	dmg_overlay_type = SPECIES_MONKEY
	palette = /datum/color_palette/generic_colors
	palette_key = "fur_color"

/obj/item/bodypart/arm/left/monkey
	icon = 'monkestation/icons/mob/species/monkey/bodyparts.dmi'
	icon_greyscale = 'monkestation/icons/mob/species/monkey/bodyparts.dmi'
	icon_static = 'icons/mob/species/monkey/bodyparts.dmi'
	icon_husk = 'monkestation/icons/mob/species/monkey/bodyparts.dmi'
	husk_type = "monkey"
	icon_state = "default_monkey_l_arm"
	limb_id = SPECIES_MONKEY
	should_draw_greyscale = TRUE
	bodytype = BODYTYPE_MONKEY | BODYTYPE_ORGANIC
	wound_resistance = -10
	px_x = -5
	px_y = -3
	dmg_overlay_type = SPECIES_MONKEY
	unarmed_damage_low = 2 // monkey punches must be really weak, considering they bite people instead and their bites are weak as hell.
	unarmed_damage_high = 2
	unarmed_stun_threshold = 3
	palette = /datum/color_palette/generic_colors
	palette_key = "fur_color"

/obj/item/bodypart/arm/right/monkey
	icon = 'monkestation/icons/mob/species/monkey/bodyparts.dmi'
	icon_greyscale = 'monkestation/icons/mob/species/monkey/bodyparts.dmi'
	icon_static = 'icons/mob/species/monkey/bodyparts.dmi'
	icon_husk = 'monkestation/icons/mob/species/monkey/bodyparts.dmi'
	husk_type = "monkey"
	icon_state = "default_monkey_r_arm"
	limb_id = SPECIES_MONKEY
	bodytype = BODYTYPE_MONKEY | BODYTYPE_ORGANIC
	should_draw_greyscale = TRUE
	wound_resistance = -10
	px_x = 5
	px_y = -3
	dmg_overlay_type = SPECIES_MONKEY
	unarmed_damage_low = 2
	unarmed_damage_high = 2
	unarmed_stun_threshold = 3
	palette = /datum/color_palette/generic_colors
	palette_key = "fur_color"

/obj/item/bodypart/leg/left/monkey
	icon = 'monkestation/icons/mob/species/monkey/bodyparts.dmi'
	icon_greyscale = 'monkestation/icons/mob/species/monkey/bodyparts.dmi'
	icon_static = 'icons/mob/species/monkey/bodyparts.dmi'
	icon_husk = 'monkestation/icons/mob/species/monkey/bodyparts.dmi'
	husk_type = "monkey"
	icon_state = "default_monkey_l_leg"
	limb_id = SPECIES_MONKEY
	should_draw_greyscale = TRUE
	bodytype = BODYTYPE_MONKEY | BODYTYPE_ORGANIC
	wound_resistance = -10
	px_y = 4
	dmg_overlay_type = SPECIES_MONKEY
	unarmed_damage_low = 3
	unarmed_damage_high = 3
	unarmed_stun_threshold = 4
	footprint_sprite = FOOTPRINT_SPRITE_PAWS
	speed_modifier = -0.05
	palette = /datum/color_palette/generic_colors
	palette_key = "fur_color"

/obj/item/bodypart/leg/right/monkey
	icon = 'monkestation/icons/mob/species/monkey/bodyparts.dmi'
	icon_greyscale = 'monkestation/icons/mob/species/monkey/bodyparts.dmi'
	icon_static = 'icons/mob/species/monkey/bodyparts.dmi'
	icon_husk = 'monkestation/icons/mob/species/monkey/bodyparts.dmi'
	husk_type = "monkey"
	icon_state = "default_monkey_r_leg"
	limb_id = SPECIES_MONKEY
	should_draw_greyscale = TRUE
	bodytype = BODYTYPE_MONKEY | BODYTYPE_ORGANIC
	wound_resistance = -10
	px_y = 4
	dmg_overlay_type = SPECIES_MONKEY
	unarmed_damage_low = 3
	unarmed_damage_high = 3
	unarmed_stun_threshold = 4
	footprint_sprite = FOOTPRINT_SPRITE_PAWS
	speed_modifier = -0.05
	palette = /datum/color_palette/generic_colors
	palette_key = "fur_color"
