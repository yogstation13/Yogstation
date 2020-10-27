/datum/species/piscis
	name = "Piscis"
	id = "piscis"
	say_mod = "bobbles"
	default_color = "00FF00"
	species_traits = list(MUTCOLORS,EYECOLOR)
	inherent_biotypes = list(MOB_ORGANIC, MOB_HUMANOID, MOB_AQUATIC)
	mutant_bodyparts = list("tail_piscis")
	default_features = list("tail_piscis" = "Piscis")
	mutantlungs = /obj/item/organ/lungs/piscis
	mutanttongue = /obj/item/organ/tongue/piscis
	mutanttail = /obj/item/organ/tail/piscis
	breathid = "o2"
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	meat = /obj/item/reagent_containers/food/snacks/carpmeat/piscis
	skinned_type = /obj/item/stack/sheet/animalhide/piscis
	disliked_food =  SUGAR | JUNKFOOD | FRIED | GRILLED
	liked_food = MEAT | RAW | VEGETABLES 
	species_language_holder = /datum/language_holder/piscis

/datum/species/piscis/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	. = ..()
	var/obj/item/tank/internals/piscis/tank = new /obj/item/tank/internals/piscis()
	C.put_in_hands(tank)
	C.internal = tank
	var/obj/item/clothing/mask/breath/mask = new()
	var/obj/item/clothing/mask/mask1 = C.get_item_by_slot(SLOT_WEAR_MASK)
	C.doUnEquip(mask1,TRUE,get_turf(C))
	if(!C.equip_to_appropriate_slot(mask))
		qdel(mask)
	C.update_internals_hud_icon(TRUE)
	

