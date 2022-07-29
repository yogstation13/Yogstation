/obj/item/clothing/suit/space/shadowling
	name = "chitin shell"
	desc = "A dark, semi-transparent shell. Protects against vacuum, but not against the light of the stars." //Still takes damage from spacewalking but is immune to space itself
	mob_overlay_icon = 'yogstation/icons/mob/clothing/suit/suit.dmi'
	icon = 'yogstation/icons/obj/clothing/suits.dmi'
	icon_state = "sl_shell"
	item_state = "sl_shell"
	body_parts_covered = FULL_BODY //Shadowlings are immune to space
	cold_protection = FULL_BODY
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	flags_inv = HIDEGLOVES | HIDESHOES | HIDEJUMPSUIT
	slowdown = 0
	heat_protection = null //You didn't expect a light-sensitive creature to have heat resistance, did you?
	max_heat_protection_temperature = null
	armor = list(MELEE = 30, BULLET = 30, LASER = 0, ENERGY = 0, BOMB = 25, BIO = 100, RAD = 100)
	item_flags = ABSTRACT | DROPDEL
	clothing_flags = THICKMATERIAL | STOPSPRESSUREDAMAGE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/item/clothing/suit/space/shadowling/Initialize()
	.=..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)

/obj/item/clothing/head/shadowling
	name = "chitin helm"
	desc = "A helmet-like enclosure of the head."
	mob_overlay_icon = 'yogstation/icons/mob/clothing/suit/suit.dmi'
	icon = 'yogstation/icons/obj/clothing/hats.dmi'
	icon_state = "sl_head"
	item_state = "sl_head"
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = SPACE_HELM_MAX_TEMP_PROTECT
	armor = list(MELEE = 30, BULLET = 30, LASER = 0, ENERGY = 0, BOMB = 25, BIO = 100, RAD = 100)
	clothing_flags = STOPSPRESSUREDAMAGE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	item_flags = ABSTRACT | DROPDEL

/obj/item/clothing/head/shadowling/Initialize()
	.=..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)
