/obj/item/clothing/gloves/tinkerer
	name = "tinker's gloves"
	desc = "Overdesigned engineering gloves that have automated construction subrutines dialed in, allowing for faster construction while worn."
	item_state = "concussive_gauntlets"
	icon_state = "concussive_gauntlets"
	icon = 'modular_dripstation/icons/obj/clothing/gloves.dmi'
	mob_overlay_icon = 'modular_dripstation/icons/mob/clothing/hands.dmi'
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 70, RAD = 0, FIRE = 70, ACID = 50, ELECTRIC = 80)
	clothing_flags = list(TRAIT_QUICK_BUILD)
	custom_materials = list(/datum/material/iron= 2000, /datum/material/silver= 1500, /datum/material/gold = 1000)
	resistance_flags = NONE