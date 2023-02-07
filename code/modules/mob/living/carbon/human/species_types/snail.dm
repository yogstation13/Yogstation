/datum/species/snail
	name = "Snailperson"
	plural_form = "Snailpeople"
	id = "snail"
	offset_features = list(OFFSET_UNIFORM = list(0,0), OFFSET_ID = list(0,0), OFFSET_GLOVES = list(0,0), OFFSET_GLASSES = list(0,4), OFFSET_EARS = list(0,0), OFFSET_SHOES = list(0,0), OFFSET_S_STORE = list(0,0), OFFSET_FACEMASK = list(0,0), OFFSET_HEAD = list(0,0), OFFSET_FACE = list(0,0), OFFSET_BELT = list(0,0), OFFSET_BACK = list(0,0), OFFSET_SUIT = list(0,0), OFFSET_NECK = list(0,0))
	default_color = "336600" //vomit green
	species_traits = list(EYECOLOR, HAIR, FACEHAIR, LIPS, MUTCOLORS, NO_UNDERWEAR, HAS_FLESH, HAS_BONE)
	inherent_traits = list(TRAIT_ALWAYS_CLEAN)
	inherent_biotypes = list(MOB_ORGANIC, MOB_HUMANOID, MOB_BUG) // splat
	attack_verb = "slap"
	say_mod = "slurs"
	coldmod = 0.5 //snails only come out when its cold and wet
	burnmod = 2
	speedmod = 6
	punchdamagehigh = 0.5 //snails are soft and squishy
	siemens_coeff = 2 //snails are mostly water
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | RACE_SWAP | SLIME_EXTRACT
	sexes = FALSE //snails are hermaphrodites
	species_language_holder = /datum/language_holder/english // No snail language.. yet.
	skinned_type = /obj/item/storage/backpack/snail // drop the funny backpack on gib

	mutanteyes = /obj/item/organ/eyes/snail
	mutanttongue = /obj/item/organ/tongue/snail
	exotic_blood = /datum/reagent/lube

	smells_like = "organic lubricant" // like IPCs

/datum/species/snail/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	. = ..()
	var/obj/item/storage/backpack/bag = C.get_item_by_slot(SLOT_BACK)
	if(!istype(bag, /obj/item/storage/backpack/snail))
		if(C.dropItemToGround(bag)) //returns TRUE even if its null
			C.equip_to_slot_or_del(new /obj/item/storage/backpack/snail(C), SLOT_BACK)
	C.AddComponent(/datum/component/snailcrawl)
	ADD_TRAIT(C, TRAIT_NOSLIPALL, SPECIES_TRAIT)

/datum/species/snail/on_species_loss(mob/living/carbon/C)
	. = ..()
	qdel(C.GetComponent(/datum/component/snailcrawl))
	REMOVE_TRAIT(C, TRAIT_NOSLIPALL, SPECIES_TRAIT)
	var/obj/item/storage/backpack/bag = C.get_item_by_slot(SLOT_BACK)
	if(istype(bag, /obj/item/storage/backpack/snail))
		bag.emptyStorage()
		C.temporarilyRemoveItemFromInventory(bag, TRUE)
		qdel(bag)

// Unused, perhaps for "advanced snails" or something
/obj/item/storage/backpack/snail/armored
	name = "snail shell"
	desc = "Worn by snails as armor and storage compartment."
	armor = list(MELEE = 40, BULLET = 30, LASER = 30, ENERGY = 10, BOMB = 25, BIO = 0, RAD = 0, FIRE = 0, ACID = 50)
	max_integrity = 200
	resistance_flags = FIRE_PROOF | ACID_PROOF

// Instead of losing the backpack, empty it
/obj/item/storage/backpack/snail/doStrip(mob/stripper, mob/owner)
	var/datum/component/storage/ST = GetComponent(/datum/component/storage)
	ST.quick_empty(stripper)
	return src

/datum/species/snail/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	var/ouch = istype(chem, /datum/reagent/consumable/sodiumchloride) || istype(chem, /datum/reagent/medicine/salglu_solution)
	if(ouch)
		H.adjustFireLoss(2*REAGENTS_EFFECT_MULTIPLIER,FALSE,FALSE, BODYPART_ANY)
		playsound(H, 'sound/weapons/sear.ogg', 30, 1)
		chem.holder.remove_reagent(chem.type, chem.metabolization_rate)
		return TRUE
	return ..()
