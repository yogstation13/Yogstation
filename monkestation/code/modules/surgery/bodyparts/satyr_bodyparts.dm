/obj/item/bodypart/head/satyr
	icon_greyscale = 'monkestation/code/modules/ranching/icons/bodyparts.dmi'
	limb_id = SPECIES_SATYR
	is_dimorphic = TRUE
	head_flags = HEAD_HAIR | HEAD_FACIAL_HAIR | HEAD_EYESPRITES | HEAD_EYECOLOR | HEAD_EYEHOLES | HEAD_DEBRAIN

/obj/item/bodypart/chest/satyr
	icon_greyscale = 'monkestation/code/modules/ranching/icons/bodyparts.dmi'
	limb_id = SPECIES_SATYR
	is_dimorphic = TRUE
	acceptable_bodytype = BODYTYPE_ORGANIC | BODYTYPE_DIGITIGRADE

/obj/item/bodypart/arm/left/satyr
	icon_greyscale = 'monkestation/code/modules/ranching/icons/bodyparts.dmi'
	limb_id = SPECIES_SATYR

/obj/item/bodypart/arm/right/satyr
	icon_greyscale = 'monkestation/code/modules/ranching/icons/bodyparts.dmi'
	limb_id = SPECIES_SATYR

/obj/item/bodypart/leg/left/satyr
	icon_greyscale = 'monkestation/code/modules/ranching/icons/bodyparts.dmi'
	limb_id = SPECIES_SATYR
	bodytype = BODYTYPE_DIGITIGRADE | BODYTYPE_ORGANIC
	bodypart_traits = list(TRAIT_HARD_SOLES, TRAIT_NON_IMPORTANT_SHOE_BLOCK)
	step_sounds = list(
		'sound/effects/footstep/hardclaw1.ogg',
		'sound/effects/footstep/hardclaw2.ogg',
		'sound/effects/footstep/hardclaw3.ogg',
		'sound/effects/footstep/hardclaw4.ogg',
		'sound/effects/footstep/hardclaw1.ogg',
	)

/obj/item/bodypart/leg/right/satyr
	icon_greyscale = 'monkestation/code/modules/ranching/icons/bodyparts.dmi'
	limb_id = SPECIES_SATYR
	bodytype = BODYTYPE_DIGITIGRADE | BODYTYPE_ORGANIC
	bodypart_traits = list(TRAIT_HARD_SOLES, TRAIT_NON_IMPORTANT_SHOE_BLOCK)
	step_sounds = list(
		'sound/effects/footstep/hardclaw1.ogg',
		'sound/effects/footstep/hardclaw2.ogg',
		'sound/effects/footstep/hardclaw3.ogg',
		'sound/effects/footstep/hardclaw4.ogg',
		'sound/effects/footstep/hardclaw1.ogg',
	)
