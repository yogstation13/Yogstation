//Contains: Engineering department jumpsuits
/obj/item/clothing/under/rank/chief_engineer
	desc = "It's a high visibility jumpsuit given to those engineers insane enough to achieve the rank of \"Chief Engineer\". It has minor radiation shielding."
	name = "chief engineer's jumpsuit"
	icon_state = "chiefengineer"
	item_state = "gy_suit"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 0, RAD = 10, FIRE = 80, ACID = 40)
	resistance_flags = NONE
	mutantrace_variation = MUTANTRACE_VARIATION

/obj/item/clothing/under/rank/chief_engineer/skirt
	name = "chief engineer's jumpskirt"
	desc = "It's a high visibility jumpskirt given to those engineers insane enough to achieve the rank of \"Chief Engineer\". It has minor radiation shielding."
	icon_state = "chief_skirt"
	item_state = "gy_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP
	mutantrace_variation = NO_MUTANTRACE_VARIATION

/obj/item/clothing/under/rank/atmospheric_technician
	desc = "It's a jumpsuit worn by atmospheric technicians."
	name = "atmospheric technician's jumpsuit"
	icon_state = "atmos"
	item_state = "atmos_suit"
	resistance_flags = NONE
	mutantrace_variation = MUTANTRACE_VARIATION

/obj/item/clothing/under/rank/atmospheric_technician/skirt
	name = "atmospheric technician's jumpskirt"
	desc = "It's a jumpskirt worn by atmospheric technicians."
	icon_state = "atmos_skirt"
	item_state = "atmos_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP
	mutantrace_variation = NO_MUTANTRACE_VARIATION

/obj/item/clothing/under/rank/engineer
	desc = "It's an orange high visibility jumpsuit worn by engineers. It has minor radiation shielding."
	name = "engineer's jumpsuit"
	icon_state = "engine"
	item_state = "engi_suit"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 0, RAD = 10, FIRE = 60, ACID = 20)
	resistance_flags = NONE
	mutantrace_variation = MUTANTRACE_VARIATION

/obj/item/clothing/under/rank/engineer/hazard
	name = "engineer's hazard jumpsuit"
	desc = "A high visibility jumpsuit made from heat and radiation resistant materials."
	icon_state = "hazard"
	item_state = "suit-orange"
	alt_covers_chest = TRUE
	mutantrace_variation = NO_MUTANTRACE_VARIATION

/obj/item/clothing/under/rank/engineer/skirt
	name = "engineer's jumpskirt"
	desc = "It's an orange high visibility jumpskirt worn by engineers."
	icon_state = "engine_skirt"
	item_state = "engi_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP
	mutantrace_variation = NO_MUTANTRACE_VARIATION

/obj/item/clothing/under/rank/roboticist
	desc = "It's a slimming black with reinforced seams; great for industrial work."
	name = "roboticist's jumpsuit"
	icon_state = "robotics"
	item_state = "robotics"
	resistance_flags = NONE
	mutantrace_variation = MUTANTRACE_VARIATION

/obj/item/clothing/under/rank/roboticist/skirt
	name = "roboticist's jumpskirt"
	desc = "It's a slimming black with reinforced seams; great for industrial work."
	icon_state = "robotics_skirt"
	item_state = "robotics"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP
	mutantrace_variation = NO_MUTANTRACE_VARIATION
