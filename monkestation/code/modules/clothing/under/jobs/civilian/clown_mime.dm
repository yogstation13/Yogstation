/obj/item/clothing/under/rank/civilian/clown/on_outfit_equip(mob/living/carbon/human/outfit_wearer, visuals_only, item_slot)
	if(QDELETED(outfit_wearer) || visuals_only)
		return
	var/image/invisible = image('icons/effects/effects.dmi', icon_state = null, loc = outfit_wearer)
	invisible.name = "\u200b" // I HATE BYOND I HATE BYOND
	invisible.override = TRUE
	outfit_wearer.add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/clown_disbelief, "clown", invisible, NONE)
