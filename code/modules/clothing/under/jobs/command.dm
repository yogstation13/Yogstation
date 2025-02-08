/obj/item/clothing/under/rank/command
	worn_icon = 'icons/mob/clothing/uniform/captain.dmi'

/obj/item/clothing/under/rank/command/captain //Alright, technically not a 'civilian' but its better then giving a .dm file for a single define.
	desc = "It's a blue jumpsuit with some gold markings denoting the rank of \"Captain\"."
	name = "captain's jumpsuit"
	icon_state = "captain"
	item_state = "b_suit"
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 0, ACID = 0, WOUND = 15)
	mutantrace_variation = DIGITIGRADE_VARIATION

/obj/item/clothing/under/rank/command/captain/skirt
	name = "captain's jumpskirt"
	desc = "It's a blue jumpskirt with some gold markings denoting the rank of \"Captain\"."
	icon_state = "captain_skirt"
	item_state = "b_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	dying_key = DYE_REGISTRY_JUMPSKIRT
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP
	mutantrace_variation = NONE

/obj/item/clothing/under/rank/command/captain/suit
	name = "captain's suit"
	desc = "A green suit and yellow necktie. Exemplifies authority."
	icon_state = "green_suit"
	item_state = "dg_suit"
	can_adjust = FALSE
	mutantrace_variation = DIGITIGRADE_VARIATION

/obj/item/clothing/under/rank/command/captain/suit/skirt
	name = "green suitskirt"
	desc = "A green suitskirt and yellow necktie. Exemplifies authority."
	icon_state = "green_suit_skirt"
	item_state = "dg_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP
	mutantrace_variation = NONE

/obj/item/clothing/under/rank/command/captain/parade
	name = "captain's parade uniform"
	desc = "A captain's luxury-wear, for special occasions."
	icon_state = "captain_parade"
	item_state = "by_suit"
	can_adjust = FALSE
	mutantrace_variation = DIGITIGRADE_VARIATION

// yogs - moves head of personnel to command file
/obj/item/clothing/under/rank/command/head_of_personnel
	name = "head of personnel's jumpsuit"
	desc = "It's a jumpsuit worn by someone who works in the position of \"Head of Personnel\"."
	icon_state = "hop"
	item_state = "b_suit"
	can_adjust = FALSE
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE
	mutantrace_variation = DIGITIGRADE_VARIATION

/obj/item/clothing/under/rank/command/head_of_personnel/turtleneck
	name = "head of personnel's turtleneck jumpsuit"
	desc = "It's a comfy turtleneck jumpsuit worn by someone who works in the position of \"Head of Personnel\"."
	icon_state = "hopturtle"
	item_state = "b_suit"
	can_adjust = TRUE

/obj/item/clothing/under/rank/command/head_of_personnel/skirt
	name = "head of personnel's jumpskirt"
	desc = "It's a jumpskirt worn by someone who works in the position of \"Head of Personnel\"."
	icon_state = "hop_skirt"
	item_state = "b_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	dying_key = DYE_REGISTRY_JUMPSKIRT
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP
	mutantrace_variation = NONE

/obj/item/clothing/under/rank/command/head_of_personnel/skirt/turtleneck
	name = "head of personnel's skirtleneck"
	desc = "It's a fashionable skirtleneck worn by someone who works in the position of \"Head of Personnel\"."
	icon_state = "hopturtle_skirt"
	item_state = "b_suit"
	can_adjust = TRUE

/obj/item/clothing/under/rank/command/head_of_personnel/suit
	name = "head of personnel's suit"
	desc = "A teal suit and yellow necktie. An authoritative yet tacky ensemble."
	icon_state = "teal_suit"
	item_state = "g_suit"
	can_adjust = FALSE
	mutantrace_variation = DIGITIGRADE_VARIATION

/obj/item/clothing/under/rank/command/head_of_personnel/suit/skirt
	name = "teal suitskirt"
	desc = "A teal suitskirt and yellow necktie. An authoritative yet tacky ensemble."
	icon_state = "teal_suit_skirt"
	item_state = "g_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP
	mutantrace_variation = NONE
// yogs end
