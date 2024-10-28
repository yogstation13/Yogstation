/obj/item/bodypart/head/robot/ipc
	icon = 'monkestation/icons/mob/species/ipc/bodyparts.dmi'
	icon_greyscale = 'monkestation/icons/mob/species/ipc/bodyparts.dmi'
	icon_static = 'monkestation/icons/mob/species/ipc/bodyparts.dmi'
	limb_id = "synth" //Overriden in /species/ipc/replace_body()
	icon_state = "synth_head"
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	biological_state = BIO_ROBOTIC | BIO_BLOODED
	bodytype = BODYTYPE_HUMANOID | BODYTYPE_ROBOTIC
	head_flags = HEAD_HAIR |  HEAD_LIPS | HEAD_EYECOLOR | HEAD_LIPS
	brute_modifier = 1.2 // Monkestation Edit
	burn_modifier = 1.2 // Monkestation Edit

	body_damage_coeff = 1.1	//IPC's Head can dismember	//Monkestation Edit
	max_damage = 40	//Keep in mind that this value is used in the //Monkestation Edit
	dmg_overlay_type = "synth"
/obj/item/bodypart/chest/robot/ipc
	icon = 'monkestation/icons/mob/species/ipc/bodyparts.dmi'
	icon_greyscale = 'monkestation/icons/mob/species/ipc/bodyparts.dmi'
	icon_static = 'monkestation/icons/mob/species/ipc/bodyparts.dmi'
	limb_id = "synth"
	icon_state = "synth_chest"
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	biological_state = BIO_ROBOTIC | BIO_BLOODED
	bodytype = BODYTYPE_HUMANOID | BODYTYPE_ROBOTIC
	bodypart_traits = list(TRAIT_LIMBATTACHMENT)
	body_damage_coeff = 1	//IPC Chest at default	///Monkestation Edit
	max_damage = 250	//Default: 200 ///Monkestation Edit
	brute_modifier = 1.2 // Monkestation Edit
	burn_modifier = 1.2 // Monkestation Edit

	dmg_overlay_type = "synth"

/obj/item/bodypart/arm/left/robot/ipc
	icon = 'monkestation/icons/mob/species/ipc/bodyparts.dmi'
	icon_greyscale = 'monkestation/icons/mob/species/ipc/bodyparts.dmi'
	icon_static = 'monkestation/icons/mob/species/ipc/bodyparts.dmi'
	limb_id = "synth"
	icon_state = "synth_l_arm"
	should_draw_greyscale = FALSE
	biological_state = BIO_ROBOTIC | BIO_JOINTED | BIO_BLOODED
	bodytype = BODYTYPE_HUMANOID | BODYTYPE_ROBOTIC
	brute_modifier = 1.2 // Monkestation Edit
	burn_modifier = 1.2 // Monkestation Edit

	body_damage_coeff = 1.1	//IPC's Limbs Should Dismember Easier	//Monkestation Edit
	max_damage = 30	//Monkestation Edit

	dmg_overlay_type = "synth"

/obj/item/bodypart/arm/right/robot/ipc
	icon = 'monkestation/icons/mob/species/ipc/bodyparts.dmi'
	icon_greyscale = 'monkestation/icons/mob/species/ipc/bodyparts.dmi'
	icon_static = 'monkestation/icons/mob/species/ipc/bodyparts.dmi'
	limb_id = "synth"
	icon_state = "synth_r_arm"
	should_draw_greyscale = FALSE
	biological_state = BIO_ROBOTIC | BIO_JOINTED | BIO_BLOODED
	bodytype = BODYTYPE_HUMANOID | BODYTYPE_ROBOTIC
	brute_modifier = 1.2 // Monkestation Edit
	burn_modifier = 1.2 // Monkestation Edit

	body_damage_coeff = 1.1	//IPC's Limbs Should Dismember Easier	//Monkestation Edit
	max_damage = 30	//Monkestation Edit

	dmg_overlay_type = "synth"

/obj/item/bodypart/leg/left/robot/ipc
	icon = 'monkestation/icons/mob/species/ipc/bodyparts.dmi'
	icon_greyscale = 'monkestation/icons/mob/species/ipc/bodyparts.dmi'
	icon_static = 'monkestation/icons/mob/species/ipc/bodyparts.dmi'
	limb_id = "synth"
	icon_state = "synth_l_leg"
	should_draw_greyscale = FALSE
	biological_state = BIO_ROBOTIC | BIO_JOINTED | BIO_BLOODED
	bodytype = BODYTYPE_HUMANOID | BODYTYPE_ROBOTIC
	brute_modifier = 1.2 // Monkestation Edit
	burn_modifier = 1.2 // Monkestation Edit

	dmg_overlay_type = "synth"
	step_sounds = list('sound/effects/servostep.ogg')

/obj/item/bodypart/leg/right/robot/ipc
	icon = 'monkestation/icons/mob/species/ipc/bodyparts.dmi'
	icon_greyscale = 'monkestation/icons/mob/species/ipc/bodyparts.dmi'
	icon_static = 'monkestation/icons/mob/species/ipc/bodyparts.dmi'
	limb_id = "synth"
	icon_state = "synth_r_leg"
	should_draw_greyscale = FALSE
	biological_state = BIO_ROBOTIC | BIO_JOINTED | BIO_BLOODED
	bodytype = BODYTYPE_HUMANOID | BODYTYPE_ROBOTIC
	brute_modifier = 1.2 // Monkestation Edit
	burn_modifier = 1.2 // Monkestation Edit

	body_damage_coeff = 1.1	//IPC's Limbs Should Dismember Easier	//Monkestation Edit
	max_damage = 30	//Monkestation Edit

	dmg_overlay_type = "synth"
	step_sounds = list('sound/effects/servostep.ogg')
