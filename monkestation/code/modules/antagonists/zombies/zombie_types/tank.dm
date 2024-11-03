/datum/species/zombie/infectious/tank
	name = "Tank Zombie"
	id = SPECIES_ZOMBIE_INFECTIOUS_TANK
	armor = 40
	maxhealthmod = 1.5
	heal_rate = 1 // Slightly higher regeneration rate.
	hand_path = /obj/item/mutant_hand/zombie/low_infection
	granted_action_types = list()
	bodypart_overlay_icon_states = list(BODY_ZONE_CHEST = "tank-chest", BODY_ZONE_HEAD = "tank_head", BODY_ZONE_R_ARM = "generic-right-hand", BODY_ZONE_L_ARM = "generic-left-hand")
	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/zombie,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/zombie,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/zombie,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/zombie,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/zombie/tank,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/zombie/tank,
	)

/obj/item/bodypart/leg/left/zombie/tank
	speed_modifier = 1.2

/obj/item/bodypart/leg/right/zombie/tank
	speed_modifier = 1.2
