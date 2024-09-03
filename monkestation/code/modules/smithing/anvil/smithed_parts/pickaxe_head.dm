/obj/item/smithed_part/weapon_part/pickaxe_head
	icon_state = "pickaxehead"
	base_name = "pickaxe head"
	worn_icon = 'monkestation/code/modules/smithing/icons/forge_weapon_worn.dmi'
	weapon_name = "pickaxe"
	weapon_inhand_icon_state = "pickaxe"
	lefthand_file = 'icons/mob/inhands/equipment/mining_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/mining_righthand.dmi'
	hilt_icon = 'monkestation/code/modules/smithing/icons/forge_items.dmi'
	hilt_icon_state = "pickaxe-hilt"

/obj/item/smithed_part/weapon_part/pickaxe_head/finish_weapon()
	tool_behaviour = TOOL_MINING

	usesound = list('sound/effects/picaxe1.ogg', 'sound/effects/picaxe2.ogg', 'sound/effects/picaxe3.ogg')
	attack_verb_continuous = list("hits", "pierces", "slices", "attacks")
	attack_verb_simple = list("hit", "pierce", "slice", "attack")

	toolspeed = 1 / max(round(((material_stats.density + material_stats.hardness) / 10) * (smithed_quality * 0.01)),1)
	force = round(((material_stats.density + material_stats.hardness) / 20) * (smithed_quality * 0.01))

	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_BACK
	throwforce = force * 1.5
	w_class = WEIGHT_CLASS_NORMAL
	..()
