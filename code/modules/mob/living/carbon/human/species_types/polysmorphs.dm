/datum/species/polysmorph
	//Human xenopmorph hybrid
	name = "Polysmorph"
	id = "polysmorph"	// if the game needs to manually check your race to do something not included in a proc here, it will use this

	//limbs_id		//this is used if you want to use a different species limb sprites. Mainly used for angels as they look like humans.
	//default_color = "#FFF"	// if alien colors are disabled, this is the color that will be used by that race

	sexes = 0

	//exotic_blood = "..."96BB00	// If your race wants to bleed something other than bog standard blood, change this to reagent id.

	meat = /obj/item/reagent_containers/food/snacks/meat/slab/xeno //What the species drops on gibbing
	liked_food = GROSS | MEAT
	disliked_food = GRAIN | DAIRY | VEGETABLES | FRUIT

	//var/toxic_food = TOXIC

	no_equip = list(SLOT_SHOES)	// slots the race can't equip stuff to
	say_mod = "hisses"	// affects the speech message
	species_language_holder = /datum/language_holder/polysmorph

	coldmod = 0.75		// multiplier for cold damage
	heatmod = 2		// multiplier for heat damage
	acidmod = 0.90     // multiplier for acid damage // yogs - Old Plant People

	//var/damage_overlay_type = "human" //what kind of damage overlays (if any) appear on our species when wounded?

	//var/fixed_mut_color = "" //to use MUTCOLOR with a fixed color that's independent of dna.feature["mcolor"]

	deathsound = 'sound/voice/hiss6.ogg'
	screamsound = 'sound/voice/hiss5.ogg'

	// species-only traits. Can be found in DNA.dm
	//var/list/species_traits = list()
	// generic traits tied to having the species
	//var/list/inherent_traits = list()
	//var/list/inherent_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)

	attack_verb = "slash"
	attack_sound = 'sound/weapons/slash.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'

	mutanteyes = /obj/item/organ/eyes/polysmorph
	mutanttongue = /obj/item/organ/tongue/polysmorph
	mutanttail = /obj/item/organ/tail/polysmorph
