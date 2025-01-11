/datum/species/polysmorph
	//Human xenopmorph hybrid
	name = "Polysmorph"
	id = SPECIES_POLYSMORPH
	species_traits = list(NOEYESPRITES, DIGITIGRADE, MUTCOLORS, NOCOLORCHANGE, HAS_FLESH, HAS_BONE, HAS_TAIL)
	possible_genders = list(FEMALE)
	inherent_traits = list(TRAIT_ACIDBLOOD, TRAIT_SKINNY)
	inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID
	exotic_blood = /datum/reagent/toxin/acid //Hell yeah sulphuric acid blood
	exotic_bloodtype = "X" //this isn't used for anything other than bloodsplatter colours
	meat = /obj/item/reagent_containers/food/snacks/meat/slab/xeno
	liked_food = GROSS | MEAT | MICE
	disliked_food = GRAIN | DAIRY | VEGETABLES | FRUIT
	say_mod = "hisses"
	bubble_icon = BUBBLE_ALIEN
	species_language_holder = /datum/language_holder/polysmorph
	brutemod = 0.9 //exoskeleton protects against brute
	burnmod = 1.35 //residual plasma inside them, highly flammable
	coldmod = 0.75
	heatmod = 1.5
	pressuremod = 0.75 //Xenos are completely pressure immune, they're bargain bin xenos
	toxmod = 0.8 //their blood is acid, their liver is pretty used to fucked up things
	acidmod = 0.2 //Their blood is literally acid
	action_speed_coefficient = 1.1 //claws aren't dextrous like hands
	speedmod = -0.1 //apex predator humanoid hybrid
	inert_mutation = ACIDSPIT
	punchdamagehigh = 11 //slightly better high end of damage
	damage_overlay_type = "polysmorph"
	species_gibs = "polysmorph"
	deathsound = 'sound/voice/hiss6.ogg'
	screamsound = 'sound/voice/hiss5.ogg'
	mutanteyes = /obj/item/organ/eyes/polysmorph
	mutantliver = /obj/item/organ/liver/alien
	mutanttongue = /obj/item/organ/tongue/polysmorph
	mutanttail = /obj/item/organ/tail/polysmorph
	mutantlungs = /obj/item/organ/lungs/xeno
	attack_verbs = list("slash")
	barefoot_step_sound = FOOTSTEP_MOB_CLAW
	attack_effect = ATTACK_EFFECT_CLAW
	attack_sound = 'sound/weapons/slash.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	fixed_mut_color = "#444466" //don't mess with this if you don't feel like manually adjusting the mutant bodypart sprites
	mutant_bodyparts = list("tail_polysmorph", "dome", "dorsal_tubes", "teeth")
	default_features = list("tail_polysmorph" = "Polys", "dome" = "None", "dorsal_tubes" = "No", "teeth" = "None")
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT

	smells_like = "charred, acidic meat"

/datum/species/polysmorph/random_name(gender,unique,lastname)
	if(unique)
		return random_unique_polysmorph_name()

	var/randname = polysmorph_name()

	return randname

/datum/species/polysmorph/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	.=..()
	var/mob/living/carbon/human/H = C
	if(H.physiology)
		H.physiology.armor.wound += 5	//Pseudo-exoskeleton makes them harder to wound

/datum/species/polysmorph/on_species_loss(mob/living/carbon/human/C, datum/species/new_species, pref_load)
	.=..()
	if(C.physiology)
		C.physiology.armor.wound -= 5

/datum/species/polysmorph/get_butt_sprite()
	return BUTT_SPRITE_XENOMORPH

/datum/species/polysmorph/get_species_description()
	return ""//"TODO: This is polysmorph description"

/datum/species/polysmorph/get_species_lore()
	return list(
		"The final failures in the attempts at creating xenomorphs hybrids to access the alien hivemind, polysmorphs were spawned \
		in now-abandoned planetary and space colonies where they were studied. After it was discovered that the hybrids had their \
		link to the hivemind cut, the project that birthed them was abandoned and Nanotrasen stepped in to employ those that \
		remained onto their space stations, using the opportunity to give them extremely reduced pay and benefits for massive profits.",

		"The impending doom of the polysmorph species interests few people, as most individuals who never have been on a Nanotrasen \
		space station have probably never seen one before and their eccentricities give them trouble integrating into society. \
		The SIC only accepted the release of the polysmorphs outside their colony under the promise that Nanotrasen would take \
		full responsibility for the hybrids' actions.",

		"While deprived of the link to the hivemind, polysmorphs still retain an instinctual tendency toward certain roles \
		depending on their dome. Drones tend to be workers, sentinels lean toward military and law enforcement, praetorians \
		generally take care of logistics and management, and queens are drawn to scientific research.",

		"As of today, the polysmorphs are scattered across the stars, working along other species. Those who couldn't \
		adapt have been relegated to menial jobs in remote locations and their situation is mostly unknown.",
	)

/datum/species/polysmorph/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "running",
			SPECIES_PERK_NAME = "Predator Genes",
			SPECIES_PERK_DESC = "Polysmorphs keep a fraction of the agility found in their xenomorph ancestors. \
								Their movement speed and crawl speed are slightly faster than most races.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "low-vision",
			SPECIES_PERK_NAME = "Darkvision",
			SPECIES_PERK_DESC = "Polysmorphs have an advanced set of eyes hidden inside their domed head. \
								These eyes can provide infrared sight, highlighting any living thing in view even in darkness.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "lungs",
			SPECIES_PERK_NAME = "Devolved Vessels",
			SPECIES_PERK_DESC = "Polysmorphs have a set of plasma vessels, degraded and fused with human lungs through the spawning process. \
								This mutated organ lets polysmorphs breathe both plasma and oxygen safely, but is easily hurt from breathing in hot air.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "bone",
			SPECIES_PERK_NAME = "Exoskeletal",
			SPECIES_PERK_DESC = "Polysmorphs have a rigid exoskeleton lining their bodies, making them harder to wound.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "filter",
			SPECIES_PERK_NAME = "Reckless Filtration",
			SPECIES_PERK_DESC = "Polysmorphs have alien livers capable of filtering out toxins much faster than most races. \
								Despite this, it's not very tough, and takes more damage from processing too many toxins at once.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = "commenting",
			SPECIES_PERK_NAME = "Alien Sssssspeech",
			SPECIES_PERK_DESC = "Polysmorphs have a mouthed tongue similar to xenomorphs, but without the teeth. \
								They have a tendency to hissssss when sssssspeaking.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "wrench",
			SPECIES_PERK_NAME = "Indextrous",
			SPECIES_PERK_DESC = "Polysmorphs have large claw-like fingers built for slicing rather than quick or precise motions. \
								They use tools and items a bit slower than most races.",
		),
	)

	return to_add
