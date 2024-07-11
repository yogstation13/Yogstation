/obj/item/organ/tail/vox
	name = "vox tail"
	desc = "A severed vox tail. Somewhere, no doubt, a vox hater is very pleased with themselves."
	icon = 'icons/mob/species/vox/tails.dmi'
	icon_state = "m_tail_lime_BEHIND"
	tail_type = "lime"
	var/icon_state_text = "m_tail_lime"
	var/icon/constructed_tail_icon
	var/tail_markings = "None"
	var/tail_markings_color
	var/original_owner

/obj/item/organ/tail/vox/Initialize(mapload)
	. = ..()
	set_icon_state()

/obj/item/organ/tail/vox/proc/set_icon_state()
	icon_state_text = "m_tail_[tail_type]"
	icon_state = "[icon_state_text]_BEHIND"
	constructed_tail_icon = icon(initial(icon), icon_state)
	var/icon/constructed_tail_icon_north = icon(constructed_tail_icon, dir = SOUTH)
	constructed_tail_icon_north.Turn(180)
	constructed_tail_icon.Insert(constructed_tail_icon_north, dir = NORTH)
	if(tail_markings && tail_markings != "None")
		var/datum/sprite_accessory/vox_tail_markings/vox_markings = GLOB.vox_tail_markings_list[tail_markings]
		var/vox_markings_state_text = "m_vox_tail_markings_[vox_markings.icon_state]"
		var/icon/constructed_markings = icon(vox_markings.icon, "[vox_markings_state_text]_BEHIND")
		var/icon/constructed_markings_north = icon(constructed_markings, dir = SOUTH)
		constructed_markings_north.Turn(180)
		constructed_markings.Insert(constructed_markings_north, dir = NORTH)
		constructed_markings.Blend(tail_markings_color, ICON_ADD)
		constructed_tail_icon.Blend(constructed_markings, ICON_OVERLAY)
	icon = constructed_tail_icon

/obj/item/organ/tail/vox/Insert(mob/living/carbon/human/H, special = 0, drop_if_replaced = TRUE)
	..()
	if(istype(H))
		if(!original_owner)
			original_owner = H
		var/default_part = H.dna.species.mutant_bodyparts["vox_tail"]
		if(!default_part || default_part == "None")
			if(original_owner != H)
				H.dna.species.mutant_bodyparts["vox_tail"] = tail_type
			else
				tail_type = H.dna.species.mutant_bodyparts["vox_tail"] = H.dna.features["vox_skin_tone"]
		
		default_part = H.dna.species.mutant_bodyparts["vox_tail_markings"]
		if(!default_part || default_part == "None")
			if(original_owner != H)
				H.dna.species.mutant_bodyparts["vox_tail_markings"] = tail_markings
			else
				tail_markings = H.dna.species.mutant_bodyparts["vox_tail_markings"] = H.dna.features["vox_tail_markings"]
		H.update_body()

/obj/item/organ/tail/vox/Remove(mob/living/carbon/human/H,  special = 0)
	..()
	if(istype(H))
		H.dna.species.mutant_bodyparts -= "vox_tail"
		H.dna.species.mutant_bodyparts -= "vox_tail_markings"
		update_tail_appearance(H)
		set_icon_state()
		H.update_body()

/obj/item/organ/tail/vox/proc/update_tail_appearance(mob/living/carbon/human/tail_owner)
	if(original_owner && original_owner != tail_owner)
		return
	tail_type = tail_owner.dna.features["vox_skin_tone"]
	tail_markings = tail_owner.dna.features["vox_tail_markings"]
	tail_markings_color = tail_owner.dna.features["mcolor_secondary"]

/obj/item/organ/tail/vox/fake
	name = "fabricated vox tail"
	desc = "A fabricated severed vox tail. This one's made of synthflesh."
