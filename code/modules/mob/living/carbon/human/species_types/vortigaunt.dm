/datum/species/vortigaunt
	name = "Vortigaunt"
	id = "vortigaunt"
	limbs_id = "vortigaunt"
	possible_genders = list(PLURAL)
	nojumpsuit = TRUE
	changesource_flags = MIRROR_BADMIN | WABBAJACK | ERT_SPAWN
	siemens_coeff = 0
	brutemod = 0.9
	burnmod = 0.9
	stunmod = 0.8
	speedmod = 0.25
	punchdamagelow = 10
	punchdamagehigh = 12
	punchstunthreshold = 17
	no_equip = list(ITEM_SLOT_MASK, ITEM_SLOT_OCLOTHING, ITEM_SLOT_GLOVES, ITEM_SLOT_FEET, ITEM_SLOT_ICLOTHING, ITEM_SLOT_SUITSTORE, ITEM_SLOT_HEAD)
	species_traits = list(NO_UNDERWEAR,NO_DNA_COPY,NOTRANSSTING,NOEYESPRITES,NOFLASH)
	inherent_traits = list(TRAIT_NOGUNS, TRAIT_RESISTCOLD, TRAIT_RESISTHIGHPRESSURE,TRAIT_RESISTLOWPRESSURE,
							TRAIT_NOBREATH, TRAIT_RADIMMUNE, TRAIT_VIRUSIMMUNE, TRAIT_NODISMEMBER,
							TRAIT_NOCRITDAMAGE, TRAIT_GENELESS, TRAIT_NOSOFTCRIT, TRAIT_HARDLY_WOUNDED)
	mutanteyes = /obj/item/organ/eyes/alien
	var/datum/action/cooldown/spell/conjure_item/infinite_guns/vort_blast/galunga

/datum/species/vortigaunt/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	C.real_name = "vortigaunt"
	C.name = C.real_name
	if(C.mind)
		C.mind.name = C.real_name
	C.dna.real_name = C.real_name

/datum/species/vortigaunt/on_species_loss(mob/living/carbon/C)
	..()
	galunga.Remove(C)

/datum/species/vortigaunt/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	..()
	galunga = new(C)
	galunga.Grant(C)
