//Alphabetical order of civilian jobs.
/obj/item/clothing/under/rank/civilian
	worn_icon = 'icons/mob/clothing/uniform/civilian.dmi'

/obj/item/clothing/under/rank/civilian/assistantformal
	name = "assistant's formal uniform"
	desc = "An assistant's formal-wear. Why an assistant needs formal-wear is still unknown."
	icon_state = "assistant_formal"
	item_state = "gy_suit"
	can_adjust = FALSE
	mutantrace_variation = DIGITIGRADE_VARIATION

/obj/item/clothing/under/rank/civilian/bartender
	desc = "It looks like it could use some more flair."
	name = "bartender's uniform"
	icon_state = "barman"
	item_state = "bar_suit"
	alt_covers_chest = TRUE
	mutantrace_variation = DIGITIGRADE_VARIATION

/obj/item/clothing/under/rank/civilian/bartender/purple
	desc = "It looks like it has lots of flair!"
	name = "purple bartender's uniform"
	icon_state = "purplebartender"
	item_state = "purplebartender"
	can_adjust = FALSE

/obj/item/clothing/under/rank/civilian/bartender/skirt
	name = "bartender's skirt"
	desc = "It looks like it could use some more flair."
	icon_state = "barman_skirt"
	item_state = "bar_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP
	mutantrace_variation = NONE

/obj/item/clothing/under/rank/civilian/chaplain
	desc = "It's a black jumpsuit, often worn by religious folk."
	name = "chaplain's jumpsuit"
	icon_state = "chaplain"
	item_state = "bl_suit"
	can_adjust = FALSE
	mutantrace_variation = DIGITIGRADE_VARIATION

/obj/item/clothing/under/rank/civilian/chaplain/skirt
	name = "chaplain's jumpskirt"
	desc = "It's a black jumpskirt, often worn by religious folk."
	icon_state = "chapblack_skirt"
	item_state = "bl_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP
	mutantrace_variation = NONE

/obj/item/clothing/under/rank/civilian/chaplain/burial
	name = "burial garments"
	desc = "Traditional burial garments from the early 22nd century."
	icon_state = "burial"
	item_state = "burial"
	has_sensor = NO_SENSORS
	mutantrace_variation = DIGITIGRADE_VARIATION

/obj/item/clothing/under/rank/civilian/chef
	name = "cook's suit"
	desc = "A suit which is given only to the most <b>hardcore</b> cooks in space."
	icon_state = "chef"
	alt_covers_chest = TRUE
	mutantrace_variation = DIGITIGRADE_VARIATION

/obj/item/clothing/under/rank/civilian/chef/skirt
	name = "cook's skirt"
	desc = "A skirt which is given only to the most <b>hardcore</b> cooks in space."
	icon_state = "chef_skirt"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP
	mutantrace_variation = NONE

/obj/item/clothing/under/rank/civilian/hydroponics
	desc = "It's a jumpsuit designed to protect against minor plant-related hazards."
	name = "botanist's jumpsuit"
	icon_state = "hydroponics"
	item_state = "g_suit"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 5, RAD = 0, FIRE = 0, ACID = 0)
	mutantrace_variation = DIGITIGRADE_VARIATION

/obj/item/clothing/under/rank/civilian/hydroponics/skirt
	name = "botanist's jumpskirt"
	desc = "It's a jumpskirt designed to protect against minor plant-related hazards."
	icon_state = "hydroponics_skirt"
	item_state = "g_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP
	mutantrace_variation = NONE

/obj/item/clothing/under/rank/civilian/hydroponics/durathread
	name = "durathread jumpsuit"
	desc = "A jumpsuit made from durathread, its resilient fibres provide some protection to the wearer."
	icon = 'icons/obj/clothing/under/color.dmi'
	icon_state = "jumpsuit"
	item_state = "jumpsuit"
	worn_icon = 'icons/mob/clothing/uniform/color.dmi'
	greyscale_colors = "#8291a1"
	greyscale_config = /datum/greyscale_config/jumpsuit
	greyscale_config_inhand_left = /datum/greyscale_config/jumpsuit_inhand_left
	greyscale_config_inhand_right = /datum/greyscale_config/jumpsuit_inhand_right
	greyscale_config_worn = /datum/greyscale_config/jumpsuit_worn
	can_adjust = FALSE
	armor = list(MELEE = 10, BULLET = 0, LASER = 10, ENERGY = 0, BOMB = 5, BIO = 0, RAD = 0, FIRE = 40, ACID = 10, WOUND= 5)
	mutantrace_variation = DIGITIGRADE_VARIATION

/obj/item/clothing/under/rank/civilian/janitor
	desc = "It's the official uniform of the station's janitor. It has minor protection from biohazards."
	name = "janitor's jumpsuit"
	icon_state = "janitor"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 10, RAD = 0, FIRE = 0, ACID = 0)
	mutantrace_variation = DIGITIGRADE_VARIATION

/obj/item/clothing/under/rank/civilian/janitor/skirt
	name = "janitor's jumpskirt"
	desc = "It's the official skirt of the station's janitor. It has minor protection from biohazards."
	icon_state = "janitor_skirt"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP
	mutantrace_variation = NONE

/obj/item/clothing/under/rank/civilian/janitor/maid
	name = "maid uniform"
	desc = "A simple maid uniform for housekeeping."
	icon_state = "janimaid"
	item_state = "janimaid"
	body_parts_covered = CHEST|GROIN|FEET|LEGS
	fitted = FEMALE_UNIFORM_TOP
	can_adjust = FALSE

/obj/item/clothing/under/rank/civilian/lawyer
	desc = "Slick threads."
	name = "Lawyer suit"
	can_adjust = FALSE

/obj/item/clothing/under/rank/civilian/lawyer/black
	icon_state = "lawyer_black"
	item_state = "lawyer_black"
	mutantrace_variation = DIGITIGRADE_VARIATION

/obj/item/clothing/under/rank/civilian/lawyer/black/skirt
	name = "Lawyer black suitskirt"
	icon_state = "lawyer_black_skirt"
	item_state = "lawyer_black"
	fitted = FEMALE_UNIFORM_TOP
	mutantrace_variation = NONE

/obj/item/clothing/under/rank/civilian/lawyer/female
	icon_state = "black_suit_fem"
	item_state = "black_suit_fem"
	mutantrace_variation = DIGITIGRADE_VARIATION

/obj/item/clothing/under/rank/civilian/lawyer/red
	icon_state = "lawyer_red"
	item_state = "lawyer_red"
	mutantrace_variation = DIGITIGRADE_VARIATION

/obj/item/clothing/under/rank/civilian/lawyer/red/skirt
	name = "Lawyer red suitskirt"
	icon_state = "lawyer_red_skirt"
	item_state = "lawyer_red"
	fitted = FEMALE_UNIFORM_TOP
	mutantrace_variation = NONE

/obj/item/clothing/under/rank/civilian/lawyer/blue
	icon_state = "lawyer_blue"
	item_state = "lawyer_blue"
	mutantrace_variation = DIGITIGRADE_VARIATION

/obj/item/clothing/under/rank/civilian/lawyer/blue/skirt
	name = "Lawyer blue suitskirt"
	icon_state = "lawyer_blue_skirt"
	item_state = "lawyer_blue"
	fitted = FEMALE_UNIFORM_TOP
	mutantrace_variation = NONE

/obj/item/clothing/under/rank/civilian/lawyer/bluesuit
	name = "blue suit"
	desc = "A classy suit and tie."
	icon_state = "bluesuit"
	item_state = "bluesuit"
	can_adjust = TRUE
	alt_covers_chest = TRUE
	mutantrace_variation = DIGITIGRADE_VARIATION

/obj/item/clothing/under/rank/civilian/lawyer/bluesuit/skirt
	name = "blue suitskirt"
	desc = "A classy suitskirt and tie."
	icon_state = "bluesuit_skirt"
	item_state = "bluesuit"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP
	mutantrace_variation = NONE

/obj/item/clothing/under/rank/civilian/lawyer/purpsuit
	name = "purple suit"
	icon_state = "lawyer_purp"
	item_state = "lawyer_purp"
	fitted = NO_FEMALE_UNIFORM
	can_adjust = TRUE
	alt_covers_chest = TRUE
	mutantrace_variation = DIGITIGRADE_VARIATION

/obj/item/clothing/under/rank/civilian/lawyer/purpsuit/skirt
	name = "purple suitskirt"
	icon_state = "lawyer_purp_skirt"
	item_state = "lawyer_purp"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP
	mutantrace_variation = NONE

/obj/item/clothing/under/rank/civilian/lawyer/blacksuit
	name = "black suit"
	desc = "A professional black suit. Nanotrasen Investigation Bureau approved!"
	icon_state = "blacksuit"
	item_state = "bar_suit"
	can_adjust = TRUE
	alt_covers_chest = TRUE
	mutantrace_variation = DIGITIGRADE_VARIATION

/obj/item/clothing/under/rank/civilian/lawyer/blacksuit/skirt
	name = "black suitskirt"
	desc = "A professional black suitskirt. Nanotrasen Investigation Bureau approved!"
	icon_state = "reallyblack_suit_skirt"
	item_state = "bar_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	dying_key = DYE_REGISTRY_JUMPSKIRT
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP
	mutantrace_variation = NONE

/obj/item/clothing/under/rank/civilian/artist
	name = "post-modern suit"
	desc = "Only the most modern of folk have the right to wear this suit."
	icon_state = "artist"
	item_state = "artist"
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP
	mutantrace_variation = DIGITIGRADE_VARIATION

/obj/item/clothing/under/rank/civilian/artist/skirt
	name = "post-modern skirt"
	desc = "Only the most modern of folk have the right to wear this suit."
	icon_state = "artist_skirt"
	item_state = "artist"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP
	mutantrace_variation = NONE
