//*/datum/species/shade
	// Crew member's souls trapped in truespace through wizardry.
	name = "Shade"
	id = "shade"
	say_mod = "moans"
	exclaim_mod = "protests
	yell_mod = "complains"
	whisper_mod = "weeps"
	sexes = 0 //can be guessed from masks i guess
	meat = /obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/skeleton //ectoplasma to be added
	species_traits = list(NOBLOOD)
	inherent_traits = list(TRAIT_NOHUNGER,TRAIT_NOBREATH)
	inherent_biotypes = list(MOB_UNDEAD, MOB_HUMANOID, MOB_SPIRIT)
	mutant_bodyparts = list("cloak", "mask" "legs")
	default_features = list("cloak" = "Short", "mask" = "None", "legs" = "None")
	damage_overlay_type = ""//let's not show bloody wounds or burns over ghosts.
	disliked_food = NONE
	liked_food = GROSS | MEAT | RAW
	changesource_flags = MIRROR_BADMIN //restricted to donor
	no_equip = list(SLOT_SHOES) //ghosts dont wear shoes

	/datum/species/shade/check_species_weakness(obj/item/weapon, mob/living/attacker)
	if(istype(weapon, /obj/item/nullrod))
		return 1 //absorbing magic comes at a price. 2x damage
	return 0//
