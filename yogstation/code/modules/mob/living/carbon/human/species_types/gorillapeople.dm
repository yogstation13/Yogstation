/datum/species/gorilla
	// Damn dirty apes.
	name = "Gorillapeople"
	id = "gorilla"
	say_mod = "grunts"
	default_color = "FFFFDD"
	species_traits = list(EYECOLOR,LIPS,HAS_FLESH,HAS_BONE)
	inherent_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	coldmod =0.75 // Average 5% weaker to temperature-based damage
	heatmod = 1.35
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	attack_verb = "maul"
	attack_sound = 'sound/creatures/gorilla.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	meat = /obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/gorilla
	skinned_type = /obj/item/stack/sheet/animalhide/gorilla
	exotic_bloodtype = "G"
	liked_food = VEGETABLES | FRUIT | GRAIN // Gorillas are mainly vegetarians
	sound = 'yogstation/sound/voice/gorilla/sound.ogg'

/datum/species/gorilla/after_equip_job(datum/job/J, mob/living/carbon/human/H)
	H.grant_language(/datum/language/monkey)

/datum/species/gorilla/random_name(gender,unique,lastname)
	if(unique)
		return random_unique_gorilla_name(gender)

	var/randname = gorilla_name(gender)

	if(lastname)
		randname += " [lastname]"

	return randname

// Gorillas don't have tails

// But they do have pain receptive toes!
/datum/species/gorilla/has_toes()
	return TRUE
