/obj/item/smithed_part/weapon_part/sword_blade
	icon_state = "blade"
	base_name = "sword blade"
	weapon_name = "sword"

	weapon_inhand_icon_state = "sword"
	hilt_icon = 'monkestation/code/modules/smithing/icons/forge_items.dmi'
	hilt_icon_state = "blade-hilt"
	worn_icon = 'monkestation/code/modules/smithing/icons/forge_weapon_worn.dmi'
	worn_icon_state = "sword_back"

/obj/item/smithed_part/weapon_part/sword_blade/finish_weapon()
	sharpness = SHARP_EDGED
	wound_bonus = 15
	bare_wound_bonus = 25
	armour_penetration = 25 * (smithed_quality / 100)

	slot_flags = ITEM_SLOT_SUITSTORE | ITEM_SLOT_BACK

	attack_speed = CLICK_CD_BULKY_WEAPON

	force = round(((material_stats.density + material_stats.hardness) / 9.2) * (smithed_quality * 0.01))
	throwforce = force * 0.75
	w_class = WEIGHT_CLASS_BULKY
	..()
