/obj/item/clothing/suit/armor/hazard
	name = "armored hazard vest"
	desc = "A hazard vest with plasteel and metal plates taped on it. It offers minor protection against kinetic damage, but slows you down a significant bit."
	icon = 'modular_skyrat/icons/obj/clothing/suits.dmi'
	mob_overlay_icon = 'modular_skyrat/icons/mob/clothing/suit.dmi'
	anthro_mob_worn_overlay = 'modular_skyrat/icons/mob/clothing/suit_digi.dmi'
	icon_state = "makeshiftarmor"
	item_state = "makeshiftarmor"
	w_class = 3
	blood_overlay_type = "armor"
	armor = list("melee" = 20, "bullet" = 10, "laser" = 5, "energy" = 10, "bomb" = 10, "bio" = 10, "rad" = 35, "fire" = 20, "acid" = 30)
	slowdown = 0.5 //not completely terrible but will not help you either
	mutantrace_variation = STYLE_DIGITIGRADE

//trayshield
/obj/item/shield/riot/trayshield
	name = "tray shield"
	desc = "A makeshift shield that won't last for long."
	icon = 'modular_skyrat/icons/obj/items_and_weapons.dmi'
	lefthand_file = 'modular_skyrat/icons/mob/inhands/lefthand.dmi'
	righthand_file = 'modular_skyrat/icons/mob/inhands/righthand.dmi'
	icon_state = "trayshield"
	force = 5
	throwforce = 5
	throw_speed = 2
	throw_range = 3
	w_class = WEIGHT_CLASS_BULKY
	attack_verb = list("shoved", "bashed")
	block_chance = 30 //same as a buckler, but this shit will break easily lol
	shield_flags = null //no bashing with this piece o' shit
	slot_flags = null //can't wear this shit, not even on your back
	max_integrity = 30 //shit and weak
	repair_material = /obj/item/stack/sheet/metal
