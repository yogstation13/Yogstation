/datum/species/shadow/nightmarethrall
	no_equip = list(SLOT_WEAR_MASK, SLOT_WEAR_SUIT, SLOT_GLOVES, SLOT_SHOES, SLOT_W_UNIFORM, SLOT_S_STORE)
	species_traits = list(NOBLOOD,NO_UNDERWEAR,NO_DNA_COPY,NOTRANSSTING,NOEYES)
	inherent_traits = list(TRAIT_RESISTCOLD,TRAIT_NOBREATH,TRAIT_RESISTHIGHPRESSURE,TRAIT_RESISTLOWPRESSURE,TRAIT_NOGUNS,TRAIT_RADIMMUNE,TRAIT_VIRUSIMMUNE,TRAIT_PIERCEIMMUNE,TRAIT_NODISMEMBER,TRAIT_NOHUNGER)

	var/realSpecies


/datum/species/shadow/nightmarethrall/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	.=..()
	realSpecies = old_species
	C.unequip_everything() //they're unable to equip anything, so they shouldn't already be wearing anything

/datum/species/shadow/nightmarethrall/spec_death(gibbed, mob/living/carbon/human/H)
	.=..()
	to_chat(H, "<span class='boldannounce'>You are no longer a servant of the nightmare!</span>")
	if(H.mind && H.mind.special_role)
		to_chat(H, "<span class='notice'>You are now welcome to pursue your antagonist goals again</span>")
	H.set_species(realSpecies)

//Organs
/obj/item/organ/brain/nightmare
	var/obj/effect/proc_holder/spell/targeted/shadowconvert/convert

/obj/item/organ/brain/nightmare/Insert(mob/living/carbon/M, special = 0)
	.=..()
	var/obj/effect/proc_holder/spell/targeted/shadowconvert/C = new
	M.AddSpell(C)

/obj/item/organ/brain/nightmare/Remove(mob/living/carbon/M, special = 0)
	.=..()
	if(convert)
		M.RemoveSpell(convert)
