/datum/species/piscis
	name = "Piscis"
	id = "piscis"
	say_mod = "bobbles"
	default_color = "00FF00"
	species_traits = list(MUTCOLORS,EYECOLOR)
	inherent_biotypes = list(MOB_ORGANIC, MOB_HUMANOID, MOB_AQUATIC)
	mutant_bodyparts = list("tail_piscis")
	default_features = list("tail_piscis" = "Piscis")
	mutanttongue = /obj/item/organ/tongue/piscis
	mutanttail = /obj/item/organ/tail/piscis
	mutantlungs = /obj/item/organ/lungs/piscis
	breathid = "o2"
	speedmod = 1
	coldmod = 0.67
	heatmod = 1.5
	stunmod = 1.4
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	meat = /obj/item/reagent_containers/food/snacks/carpmeat/piscis
	skinned_type = /obj/item/stack/sheet/animalhide/piscis
	exotic_bloodtype = "C"
	disliked_food =  SUGAR | JUNKFOOD | FRIED | GRILLED
	liked_food = MEAT | RAW | VEGETABLES 
	species_language_holder = /datum/language_holder/piscis

/datum/species/piscis/spec_life(mob/living/carbon/human/H)
	. = ..()
	var/turf/current_turf = get_turf(H)
	var/datum/gas_mixture/gas = current_turf.return_air()
	if(gas.return_pressure() >= WARNING_HIGH_PRESSURE)
		coldmod = 0.5
		heatmod = 1
		speedmod = 0
		stunmod = 0.9
	else
		coldmod = initial(coldmod)
		heatmod = initial(heatmod)
		speedmod = initial(speedmod)

/datum/species/piscis/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	. = ..()
	var/obj/item/tank/internals/piscis/tank = new /obj/item/tank/internals/piscis()
	C.put_in_hands(tank)
	C.internal = tank
	var/obj/item/clothing/mask/breath/mask = new()
	if(!C.equip_to_appropriate_slot(mask))
		qdel(mask)
	C.update_internals_hud_icon(TRUE)

	

