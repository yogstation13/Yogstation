/datum/species/szlachta 
	name = "Szlachta"
	id = "szlachta"
	limbs_id = "szlachta"
	sexes = FALSE
	nojumpsuit = TRUE
	changesource_flags = MIRROR_BADMIN | WABBAJACK | ERT_SPAWN
	siemens_coeff = 0
	brutemod = 0.8
	heatmod = 0.8
	punchdamagehigh = 17 //hardcore
	punchstunthreshold = 17
	no_equip = list(SLOT_WEAR_MASK, SLOT_WEAR_SUIT, SLOT_GLOVES, SLOT_SHOES, SLOT_W_UNIFORM, SLOT_S_STORE, SLOT_HEAD)
	species_traits = list(NO_UNDERWEAR,NO_DNA_COPY,NOTRANSSTING,NOEYESPRITES,NOFLASH)
	inherent_traits = list(TRAIT_NOGUNS, TRAIT_RESISTCOLD, TRAIT_RESISTHIGHPRESSURE,TRAIT_RESISTLOWPRESSURE,
							TRAIT_NOBREATH, TRAIT_RADIMMUNE, TRAIT_VIRUSIMMUNE, TRAIT_PIERCEIMMUNE, TRAIT_NODISMEMBER,
							TRAIT_MONKEYLIKE, TRAIT_NOCRITDAMAGE, TRAIT_GENELESS, TRAIT_NOSOFTCRIT, TRAIT_NOHARDCRIT, TRAIT_HARDLY_WOUNDED, TRAIT_HUSK)
	mutanteyes = /obj/item/organ/eyes/night_vision/alien

/datum/species/szlachta/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	C.real_name = "towering monstrosity"
	C.name = C.real_name
	if(C.mind)
		C.mind.name = C.real_name
	C.dna.real_name = C.real_name
