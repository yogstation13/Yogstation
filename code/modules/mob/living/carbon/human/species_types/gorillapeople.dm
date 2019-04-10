/datum/species/gorilla
	// Damn dirty apes.
	name = "Gorillapeople"
	id = "gorilla"
	say_mod = "grunts"
	default_color = "00FF00"
	species_traits = list(EYECOLOR,LIPS)
	inherent_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	coldmod =0.69
	heatmod = 1.33
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	attack_verb = "maul"
	attack_sound = 'sound/creatures/gorilla.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	meat = /obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/gorilla
	skinned_type = /obj/item/stack/sheet/animalhide/gorilla
	exotic_bloodtype = "G"
	liked_food = GROSS | MEAT
	deathsound = 'sound/voice/gorilla/deathsound.ogg'

/datum/species/gorilla/after_equip_job(datum/job/J, mob/living/carbon/human/H)
	H.grant_language(/datum/language/gorillian)
	H.grant_language(/datum/language/monkey)

/datum/species/gorilla/random_name(gender,unique,lastname)
	if(unique)
		return random_unique_gorilla_name(gender)

	var/randname = gorilla_name(gender)

	if(lastname)
		randname += " [lastname]"

	return randname

// Gorillas don't have tails