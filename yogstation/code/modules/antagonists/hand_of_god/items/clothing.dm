//////////////////////////////////////////
//                                      //
//            WARRIOR ROBE              //
//                                      //
//////////////////////////////////////////

/obj/item/clothing/suit/hooded/hog_robe_warrior
	name = "warrior robe"
	desc = "A magical robe of a religious zealot."
	icon_state = "cultrobes"
	item_state = "cultrobes"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	allowed = list(/obj/item/hog_item/upgradeable)
	armor = list(MELEE = 30, BULLET = 20, LASER = 30,ENERGY = 10, BOMB = 15, BIO = 0, RAD = 0, FIRE = 0, ACID = 0)
	flags_inv = HIDEJUMPSUIT
	cold_protection = CHEST|GROIN|LEGS|ARMS
	min_cold_protection_temperature = ARMOR_MIN_TEMP_PROTECT
	heat_protection = CHEST|GROIN|LEGS|ARMS
	max_heat_protection_temperature = ARMOR_MAX_TEMP_PROTECT
    hoodtype = /obj/item/clothing/head/hooded/hog_robe_warrior

/obj/item/clothing/suit/hooded/hog_robe_warrior/Initialize()
	. = ..()
    AddComponent(/datum/component/hog_item, null)

/obj/item/clothing/head/hooded/hog_robe_warrior
	name = "warrior robe"
	desc = "A magical robe of a religious zealot"
	icon_state = "cult_hoodalt"
	armor = list(MELEE = 30, BULLET = 20, LASER = 30,ENERGY = 10, BOMB = 15, BIO = 0, RAD = 0, FIRE = 0, ACID = 0)
	body_parts_covered = HEAD
	flags_inv = HIDEHAIR|HIDEFACE|HIDEEARS

//////////////////////////////////////////
//                                      //
//             MAGE ROBE                //
//                                      //
//////////////////////////////////////////

/obj/item/clothing/suit/hooded/hog_robe_mage
	name = "mage robe"
	desc = "A magical robe, decorated with strange shining crystals."
	icon_state = "cultrobes"
	item_state = "cultrobes"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	allowed = list(/obj/item/hog_item/upgradeable)
	armor = list(MELEE = 30, BULLET = 20, LASER = 30,ENERGY = 10, BOMB = 15, BIO = 0, RAD = 0, FIRE = 0, ACID = 0)
	flags_inv = HIDEJUMPSUIT
	cold_protection = CHEST|GROIN|LEGS|ARMS
	min_cold_protection_temperature = ARMOR_MIN_TEMP_PROTECT
	heat_protection = CHEST|GROIN|LEGS|ARMS
	max_heat_protection_temperature = ARMOR_MAX_TEMP_PROTECT
    hoodtype = /obj/item/clothing/head/hooded/hog_robe_mage

/obj/item/clothing/suit/hooded/hog_robe_mage/Initialize()
	. = ..()
    AddComponent(/datum/component/hog_item, null)

/obj/item/clothing/head/hooded/hog_robe_mage
	name = "mage robe"
	desc = "A magical robe, decorated with strange shining crystals."
	icon_state = "cult_hoodalt"
	armor = list(MELEE = 30, BULLET = 20, LASER = 30,ENERGY = 10, BOMB = 15, BIO = 0, RAD = 0, FIRE = 0, ACID = 0)
	body_parts_covered = HEAD
	flags_inv = HIDEHAIR|HIDEFACE|HIDEEARS

