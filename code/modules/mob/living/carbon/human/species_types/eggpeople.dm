// This is the dumbest fucking thing I have ever programmed t. Altoids
/datum/species/egg
	// Egghead humanoids composed of eggs and stale memes
  name = "Eggperson"
	id = "egg"
	say_mod = "blurbles"
	default_color = "FFEECC"
	species_traits = list(EYECOLOR,LIPS)
	inherent_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	brutemod = 1.25 // not the toughest egg in the dozen
	heatmod = 1.1 // weak to being boiled
	default_features = list()
	changesource_flags = MIRROR_BADMIN // keeping it to just being an adminbus race for now
	attack_verb = "slash"
	attack_sound = 'sound/weapons/slash.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	meat = /obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/lizard
	skinned_type = /obj/item/stack/sheet/animalhide/lizard
	exotic_bloodtype = "L"
	disliked_food = GROSS | DAIRY | EGG
	liked_food = MEAT

/datum/species/egg/after_equip_job(datum/job/J, mob/living/carbon/human/H)
	H.grant_language(/datum/language/egg)