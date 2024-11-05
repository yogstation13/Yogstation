/datum/species/moth/tundra
	name = "\improper Tundra Moth"
	plural_form = "Tundra Moths"
	id = SPECIES_TUNDRA
	mutanteyes = /obj/item/organ/internal/eyes/moth/tundra
	external_organs = list(/obj/item/organ/external/wings/moth = "Tundra", /obj/item/organ/external/antennae = "Tundra")

	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/tundramoth,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/tundramoth,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/tundramoth,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/tundramoth,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/tundramoth,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/tundramoth,
	)

	coldmod = 0.67
	heatmod = 1.5


//Body parts
/obj/item/bodypart/head/tundramoth
	name = "Tundra Head"
	desc = "It looks just like a moths, but its covered in black fur. Is that a bald sp-"
	icon = 'monkestation/icons/mob/species/tundramoths/bodyparts.dmi'
	icon_state = "tundra_moth_head"
	icon_static = 'monkestation/icons/mob/species/tundramoths/bodyparts.dmi'
	limb_id = SPECIES_TUNDRA
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	head_flags = /obj/item/bodypart/head/moth::head_flags

/obj/item/bodypart/chest/tundramoth
	name = "Tundra chest"
	desc = "It looks just like a moths, but its covered in black fur."
	icon = 'monkestation/icons/mob/species/tundramoths/bodyparts.dmi'
	icon_state = "tundra_moth_chest_m"
	icon_static = 'monkestation/icons/mob/species/tundramoths/bodyparts.dmi'
	limb_id = SPECIES_TUNDRA
	is_dimorphic = TRUE
	should_draw_greyscale = FALSE
	wing_types = list(/obj/item/organ/external/wings/functional/moth/megamoth, /obj/item/organ/external/wings/functional/moth/mothra)

/obj/item/bodypart/arm/left/tundramoth
	name = "Tundra left arm"
	desc = "It looks just like a moths, but its covered in black fur."
	icon = 'monkestation/icons/mob/species/tundramoths/bodyparts.dmi'
	icon_state = "tundra_moth_l_arm"
	icon_static = 'monkestation/icons/mob/species/tundramoths/bodyparts.dmi'
	limb_id = SPECIES_TUNDRA
	should_draw_greyscale = FALSE
	unarmed_attack_verb = "slash"
	unarmed_attack_effect = ATTACK_EFFECT_CLAW
	unarmed_attack_sound = 'sound/weapons/slash.ogg'
	unarmed_miss_sound = 'sound/weapons/slashmiss.ogg'

/obj/item/bodypart/arm/right/tundramoth
	name = "Tundra right arm"
	desc = "It looks just like a moths, but its covered in black fur."
	icon = 'monkestation/icons/mob/species/tundramoths/bodyparts.dmi'
	icon_state = "tundra_moth_r_arm"
	icon_static = 'monkestation/icons/mob/species/tundramoths/bodyparts.dmi'
	limb_id = SPECIES_TUNDRA
	should_draw_greyscale = FALSE
	unarmed_attack_verb = "slash"
	unarmed_attack_effect = ATTACK_EFFECT_CLAW
	unarmed_attack_sound = 'sound/weapons/slash.ogg'
	unarmed_miss_sound = 'sound/weapons/slashmiss.ogg'

/obj/item/bodypart/leg/left/tundramoth
	name = "Tundra left leg"
	desc = "It looks just like a moths, but its covered in black fur."
	icon = 'monkestation/icons/mob/species/tundramoths/bodyparts.dmi'
	icon_state = "tundra_moth_l_leg"
	icon_static = 'monkestation/icons/mob/species/tundramoths/bodyparts.dmi'
	limb_id = SPECIES_TUNDRA
	should_draw_greyscale = FALSE

/obj/item/bodypart/leg/right/tundramoth
	name = "Tundra right leg"
	desc = "It looks just like a moths, but its covered in black fur."
	icon = 'monkestation/icons/mob/species/tundramoths/bodyparts.dmi'
	icon_state = "tundra_moth_r_leg"
	icon_static = 'monkestation/icons/mob/species/tundramoths/bodyparts.dmi'
	limb_id = SPECIES_TUNDRA
	should_draw_greyscale = FALSE
