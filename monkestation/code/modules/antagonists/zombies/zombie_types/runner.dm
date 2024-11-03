//NEEDS TO BE MADE FAST
/datum/species/zombie/infectious/runner
	name = "Runner Zombie"
	id = SPECIES_ZOMBIE_INFECTIOUS_RUNNER
	maxhealthmod = 0.7
	armor = 0
	hand_path = /obj/item/mutant_hand/zombie/low_infection/weak
	granted_action_types = list()
	bodypart_overlay_icon_states = list(BODY_ZONE_CHEST = "runner-chest", BODY_ZONE_HEAD = "runner-head")
	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/zombie,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/zombie,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/zombie,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/zombie,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/zombie/runner,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/zombie/runner,
	)

/obj/item/bodypart/leg/left/zombie/runner
	speed_modifier = -0.2

/obj/item/bodypart/leg/right/zombie/runner
	speed_modifier = -0.2
