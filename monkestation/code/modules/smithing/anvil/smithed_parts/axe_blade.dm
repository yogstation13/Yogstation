/obj/item/smithed_part/weapon_part/axe_blade
	icon_state = "axehead"
	base_name = "axe blade"
	weapon_name = "axe"

	weapon_inhand_icon_state = "axe"
	hilt_icon = 'monkestation/code/modules/smithing/icons/forge_items.dmi'
	hilt_icon_state = "axe-hilt"

/obj/item/smithed_part/weapon_part/axe_blade/finish_weapon()
	sharpness = SHARP_EDGED
	embedding = list("pain_mult" = 4, "embed_chance" = 35, "fall_chance" = 10)
	armour_penetration = 30 * (smithed_quality / 100)

	tool_behaviour = TOOL_SAW

	force = round(((material_stats.density + material_stats.hardness) / 8.9) * (smithed_quality * 0.01))
	throwforce = force * 1.75
	w_class = WEIGHT_CLASS_SMALL
	..()
