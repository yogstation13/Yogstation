//Subtype of human
/datum/species/human/vulpine
	name = "Vulpine Human"
	id = "vulpine"
	limbs_id = "human"
	attack_verbs = list("slash")
	attack_sound = 'sound/weapons/slash.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'

	species_traits = list(EYECOLOR,HAIR,FACEHAIR,LIPS,HAS_FLESH,HAS_BONE,HAS_TAIL)
	mutant_bodyparts = list("ears", "tail_human")
	default_features = list("mcolor" = "FFF", "tail_human" = "Fox", "ears" = "Fox", "wings" = "None")
	rare_say_mod = list("yips"= 10)
	liked_food = SEAFOOD | DAIRY | MICE
	disliked_food = GROSS | RAW
	toxic_food = TOXIC | CHOCOLATE
	mutantears = /obj/item/organ/ears/cat/fox
	mutanttail = /obj/item/organ/tail/cat/fox
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT

	smells_like = "idfk, whatever foxes smell like"

/datum/species/human/vulpine/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	. = ..()
	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		if(!pref_load)			//For some reason tails don't load properly on NPCs, this is used for catgirls so it should work here too
			if(H.dna.features["tail_human"] == "None")
				H.dna.features["tail_human"] = "Fox"
			if(H.dna.features["ears"] == "None")
				H.dna.features["ears"] = "Fox"
		if(H.dna.features["ears"] == "Fox")
			var/obj/item/organ/ears/cat/fox/ears = new
			ears.Insert(H, drop_if_replaced = FALSE)
		else
			mutantears = /obj/item/organ/ears
		if(H.dna.features["tail_human"] == "Fox")
			var/obj/item/organ/tail/cat/fox/tail = new
			tail.Insert(H, drop_if_replaced = FALSE)
		else
			mutanttail = null
		H.dna.update_uf_block(DNA_HUMAN_TAIL_BLOCK)
		H.dna.update_uf_block(DNA_EARS_BLOCK)

/datum/species/human/vulpine/can_wag_tail(mob/living/carbon/human/H)
	return FALSE //i ain't spriting this shit
