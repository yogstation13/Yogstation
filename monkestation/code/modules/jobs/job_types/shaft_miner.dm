/datum/outfit/job/miner/equip(mob/living/carbon/human/H, visualsOnly)
	if(is_species(H, /datum/species/lizard))
		backpack_contents += /obj/item/pocket_heater/loaded
	return ..()
