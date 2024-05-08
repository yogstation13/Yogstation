/obj/item/clothing/under/rank/medical
	worn_icon = 'icons/mob/clothing/uniform/medical.dmi'

/obj/item/clothing/under/rank/medical/chemist
	desc = "It's made of a special fiber that gives special protection against biohazards. It has a chemist rank stripe on it."
	name = "chemist's jumpsuit"
	icon_state = "chemistry"
	item_state = "w_suit"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 15, RAD = 0, FIRE = 50, ACID = 65)
	mutantrace_variation = DIGITIGRADE_VARIATION

/obj/item/clothing/under/rank/medical/chemist/skirt
	name = "chemist's jumpskirt"
	desc = "It's made of a special fiber that gives special protection against biohazards. It has a chemist rank stripe on it."
	icon_state = "chemistrywhite_skirt"
	item_state = "w_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP
	mutantrace_variation = NONE

/*
 * Medical
 */
/obj/item/clothing/under/rank/medical/chief_medical_officer
	desc = "It's a jumpsuit worn by those with the experience to be \"Chief Medical Officer\". It provides minor biological protection."
	name = "chief medical officer's jumpsuit"
	icon_state = "cmo"
	item_state = "w_suit"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 15, RAD = 0, FIRE = 0, ACID = 0)
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE
	mutantrace_variation = DIGITIGRADE_VARIATION

/obj/item/clothing/under/rank/medical/chief_medical_officer/turtleneck
	desc = "It's a jumpsuit worn by those with the experience, and the style, to be \"Chief Medical Officer\". It provides minor biological protection."
	name = "chief medical officer's turtleneck jumpsuit"
	icon_state = "cmoturtle"
	item_state = "w_suit"

/obj/item/clothing/under/rank/medical/chief_medical_officer/skirt
	name = "chief medical officer's jumpskirt"
	desc = "It's a jumpskirt worn by those with the experience to be \"Chief Medical Officer\". It provides minor biological protection."
	icon_state = "cmo_skirt"
	item_state = "w_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	dying_key = DYE_REGISTRY_JUMPSKIRT
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP
	mutantrace_variation = NONE

/obj/item/clothing/under/rank/medical/chief_medical_officer/skirt/turtleneck
	name = "chief medical officer's skirtleneck"
	desc = "It's a jumpskirt worn by those with the experience, and the style, to be \"Chief Medical Officer\". It provides minor biological protection."
	icon_state = "cmoturtle_skirt"
	item_state = "w_suit"

/obj/item/clothing/under/rank/medical/virologist
	desc = "It's made of a special fiber that gives special protection against biohazards. It has a virologist rank stripe on it."
	name = "virologist's jumpsuit"
	icon_state = "virology"
	item_state = "w_suit"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 15, RAD = 0, FIRE = 0, ACID = 0)
	mutantrace_variation = DIGITIGRADE_VARIATION

/obj/item/clothing/under/rank/medical/virologist/skirt
	name = "virologist's jumpskirt"
	desc = "It's made of a special fiber that gives special protection against biohazards. It has a virologist rank stripe on it."
	icon_state = "virologywhite_skirt"
	item_state = "w_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP
	mutantrace_variation = NONE

/obj/item/clothing/under/rank/medical/nursesuit
	desc = "It's a jumpsuit commonly worn by nursing staff in the medical department."
	name = "nurse's suit"
	icon_state = "nursesuit"
	item_state = "w_suit"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 15, RAD = 0, FIRE = 0, ACID = 0)
	body_parts_covered = CHEST|GROIN|ARMS
	fitted = NO_FEMALE_UNIFORM
	can_adjust = FALSE

/obj/item/clothing/under/rank/medical/doctor
	desc = "It's made of a special fiber that provides minor protection against biohazards. It has a cross on the chest denoting that the wearer is trained medical personnel."
	name = "medical doctor's jumpsuit"
	icon_state = "medical"
	item_state = "w_suit"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 15, RAD = 0, FIRE = 0, ACID = 0)
	mutantrace_variation = DIGITIGRADE_VARIATION

/obj/item/clothing/under/rank/medical/doctor/blue
	name = "medical scrubs"
	desc = "It's made of a special fiber that provides minor protection against biohazards. This one is in baby blue."
	icon_state = "scrubsblue"
	can_adjust = FALSE

/obj/item/clothing/under/rank/medical/doctor/green
	name = "medical scrubs"
	desc = "It's made of a special fiber that provides minor protection against biohazards. This one is in dark green."
	icon_state = "scrubsgreen"
	can_adjust = FALSE

/obj/item/clothing/under/rank/medical/doctor/purple
	name = "medical scrubs"
	desc = "It's made of a special fiber that provides minor protection against biohazards. This one is in deep purple."
	icon_state = "scrubspurple"
	can_adjust = FALSE

/obj/item/clothing/under/rank/medical/doctor/skirt
	name = "medical doctor's jumpskirt"
	desc = "It's made of a special fiber that provides minor protection against biohazards. It has a cross on the chest denoting that the wearer is trained medical personnel."
	icon_state = "medical_skirt"
	item_state = "w_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP
	mutantrace_variation = NONE

// yogs - removed miscellaneous.dm
/obj/item/clothing/under/rank/medical/pj/red
	name = "red pj's"
	desc = "Sleepwear."
	icon_state = "red_pyjamas"
	item_state = "w_suit"
	can_adjust = FALSE
	mutantrace_variation = DIGITIGRADE_VARIATION

/obj/item/clothing/under/rank/medical/pj/blue
	name = "blue pj's"
	desc = "Sleepwear."
	icon_state = "blue_pyjamas"
	item_state = "w_suit"
	can_adjust = FALSE
	mutantrace_variation = DIGITIGRADE_VARIATION
// yogs end
